/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "console_pause.h"

#include <cstdlib>
#include <cstring>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

namespace console_pause
{

#ifdef _WIN32
namespace
{

auto hasCiFlag(const char* commandLine) -> bool
{
    return commandLine && std::strstr(commandLine, "--ci") != nullptr;
}

auto hasCiFlag(int argc, char** argv) -> bool
{
    for (int i = 1; i < argc; ++i)
    {
        if (std::strcmp(argv[i], "--ci") == 0)
        {
            return true;
        }
    }

    return false;
}

auto isNoPauseRequested() -> bool
{
    const char* noPause = std::getenv("XI_NO_PAUSE");
    return noPause && noPause[0] == '1';
}

auto isInteractiveConsole() -> bool
{
    return GetConsoleWindow() != nullptr;
}

} // namespace
#endif

auto shouldPause(int argc, char** argv) -> bool
{
#ifdef _WIN32
    if (!isInteractiveConsole())
    {
        return false;
    }

    if (hasCiFlag(argc, argv))
    {
        return false;
    }

    if (isNoPauseRequested())
    {
        return false;
    }

    return true;
#else
    (void)argc;
    (void)argv;
    return false;
#endif
}

auto shouldPauseFromCommandLine() -> bool
{
#ifdef _WIN32
    if (!isInteractiveConsole())
    {
        return false;
    }

    if (hasCiFlag(GetCommandLineA()))
    {
        return false;
    }

    if (isNoPauseRequested())
    {
        return false;
    }

    return true;
#else
    return false;
#endif
}

void pauseIfNeeded(int argc, char** argv)
{
    if (!shouldPause(argc, argv))
    {
        return;
    }

#ifdef _WIN32
    std::system("pause");
#endif
}

void pauseIfNeededFromCommandLine()
{
    if (!shouldPauseFromCommandLine())
    {
        return;
    }

#ifdef _WIN32
    std::system("pause");
#endif
}

} // namespace console_pause
