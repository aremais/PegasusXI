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

#pragma once

#include <iostream>
#include <memory>

namespace console_pause
{

auto shouldPause(int argc, char** argv) -> bool;
auto shouldPauseFromCommandLine() -> bool;
void pauseIfNeeded(int argc, char** argv);
void pauseIfNeededFromCommandLine();

} // namespace console_pause

template<typename AppType>
auto runApplication(int argc, char** argv) -> int
{
    try
    {
        const auto app = std::make_unique<AppType>(argc, argv);
        app->run();
        return 0;
    }
    catch (const std::exception& e)
    {
        std::cerr << "Fatal error: " << e.what() << '\n';
        console_pause::pauseIfNeeded(argc, argv);
        return 1;
    }
    catch (...)
    {
        std::cerr << "Unknown fatal error\n";
        console_pause::pauseIfNeeded(argc, argv);
        return 1;
    }
}
