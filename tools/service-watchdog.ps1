param(
    [string]$ServerPath = "D:\server",
    [string]$TaskName = "PegasusXI-Service-Watchdog",
    [switch]$InstallTask,
    [switch]$RunOnce
)

$ErrorActionPreference = "Stop"

$services = @(
    @{ Name = "xi_connect"; Exe = "xi_connect.exe" },
    @{ Name = "xi_world";   Exe = "xi_world.exe"   },
    @{ Name = "xi_search";  Exe = "xi_search.exe"  },
    @{ Name = "xi_map";     Exe = "xi_map.exe"     }
)

$logDir = Join-Path $ServerPath "log"
$logFile = Join-Path $logDir "service-watchdog.log"

function Write-Log {
    param([string]$Message)
    try {
        if (-not (Test-Path -LiteralPath $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
        Add-Content -Path $logFile -Value $line
    } catch {
        # no-op: logging must never block watchdog checks
    }
}

function Start-ServerProcess {
    param(
        [string]$Name,
        [string]$Exe,
        [string]$LogFile
    )

    $exePath = Join-Path $ServerPath $Exe
    if (-not (Test-Path -LiteralPath $exePath)) {
        Write-Log "ERROR: Missing executable $exePath"
        return $false
    }

    $args = @()
    if ($LogFile) {
        $args = @("--log", $LogFile)
    }

    try {
        Start-Process -FilePath $exePath -WorkingDirectory $ServerPath -ArgumentList $args | Out-Null
        Write-Log "RESTARTED: $Exe was not running; started successfully."
        return $true
    } catch {
        Write-Log "ERROR: Failed to start $Exe. $($_.Exception.Message)"
        return $false
    }
}

function Restart-IpcStack {
    Write-Log "RESTARTING: xi_map died; restarting connect/world/search/map for ZMQ IPC recovery."

    foreach ($svc in $services) {
        Get-Process -Name $svc.Name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }

    Start-Sleep -Seconds 3

    Start-ServerProcess -Name "xi_connect" -Exe "xi_connect.exe" -LogFile "log/connect-server.log" | Out-Null
    Start-Sleep -Seconds 2
    Start-ServerProcess -Name "xi_search" -Exe "xi_search.exe" -LogFile "log/search-server.log" | Out-Null
    Start-Sleep -Seconds 2
    Start-ServerProcess -Name "xi_world" -Exe "xi_world.exe" -LogFile "log/world-server.log" | Out-Null
    Start-Sleep -Seconds 3
    Start-ServerProcess -Name "xi_map" -Exe "xi_map.exe" -LogFile "log/map-server.log" | Out-Null
}

function Ensure-ServiceRunning {
    param(
        [string]$Name,
        [string]$Exe,
        [string]$LogFile
    )

    $proc = Get-Process -Name $Name -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Log "OK: $Exe already running."
        return
    }

    if ($Name -eq "xi_map") {
        Restart-IpcStack
        return
    }

    Start-ServerProcess -Name $Name -Exe $Exe -LogFile $LogFile | Out-Null
}

function Run-HealthCheck {
    $mapRunning = Get-Process -Name "xi_map" -ErrorAction SilentlyContinue
    if (-not $mapRunning) {
        Restart-IpcStack
        return
    }

    foreach ($svc in $services) {
        Ensure-ServiceRunning -Name $svc.Name -Exe $svc.Exe -LogFile ("log/{0}" -f ($svc.Exe -replace '\.exe$', '-server.log'))
    }
}

function Install-WatchdogTask {
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) {
        $scriptPath = $MyInvocation.MyCommand.Path
    }
    if (-not $scriptPath) {
        throw "Unable to determine script path."
    }

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -ServerPath `"$ServerPath`" -RunOnce"
    # Task Scheduler rejects very large durations; use a long finite duration instead.
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Days 3650)
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Highest

    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null
    Write-Host "Installed scheduled task '$TaskName' (every 15 minutes)."
}

if ($InstallTask) {
    Install-WatchdogTask
    exit 0
}

if ($RunOnce) {
    Run-HealthCheck
    exit 0
}

# Default behavior if run directly without switches
Run-HealthCheck
