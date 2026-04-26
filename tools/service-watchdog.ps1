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

function Ensure-ServiceRunning {
    param(
        [string]$Name,
        [string]$Exe
    )

    $proc = Get-Process -Name $Name -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Log "OK: $Exe already running."
        return
    }

    $exePath = Join-Path $ServerPath $Exe
    if (-not (Test-Path -LiteralPath $exePath)) {
        Write-Log "ERROR: Missing executable $exePath"
        return
    }

    try {
        # Start in the interactive desktop session so the service window/icon is visible.
        Start-Process -FilePath $exePath -WorkingDirectory $ServerPath | Out-Null
        Write-Log "RESTARTED: $Exe was not running; started successfully."
    } catch {
        Write-Log "ERROR: Failed to start $Exe. $($_.Exception.Message)"
    }
}

function Run-HealthCheck {
    foreach ($svc in $services) {
        Ensure-ServiceRunning -Name $svc.Name -Exe $svc.Exe
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
