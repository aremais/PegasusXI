/*
===========================================================================

  Copyright (c) 2024 LandSandBoat Dev Teams

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

#include "database.h"

#include "application.h"
#include "logging.h"
#include "macros.h"
#include "settings.h"
#include "timer.h"
#include "utils.h"

#include <chrono>
#include <mutex>
using namespace std::chrono_literals;

namespace
{

// TODO: Manual checkout and pooling of state
// Each thread gets its own connection, so we don't need to worry about thread safety.
thread_local Synchronized<db::detail::State> state;

std::once_flag logDbTargetOnce;

// Lowercase: matched against to_lower(exception.what()) so variants like
// "MySQL server has gone away" are recognized (case-sensitive find missed these).
const std::vector<std::string> connectionIssues = {
    "lost connection",
    "server has gone away",
    "connection refused",
    "can't connect to server",
    "communications link failure",
    "broken pipe",
    "connection reset",
    "connection was killed",
    "errno=2006", // CR_SERVER_GONE_ERROR (MySQL)
    "errno=2013", // CR_SERVER_LOST
};

bool timersEnabled = false;

} // namespace

auto db::getConnection() -> std::unique_ptr<sql::Connection>
{
    try
    {
        const auto login  = settings::get<std::string>("network.SQL_LOGIN");
        const auto passwd = settings::get<std::string>("network.SQL_PASSWORD");
        const auto host   = settings::get<std::string>("network.SQL_HOST");
        const auto port   = settings::get<uint16>("network.SQL_PORT");
        const auto schema = settings::get<std::string>("network.SQL_DATABASE");
        const auto url    = fmt::format("tcp://{}:{}/{}", host, port, schema);

        auto connection = std::unique_ptr<sql::Connection>(sql::mariadb::get_driver_instance()->connect(url.c_str(), login.c_str(), passwd.c_str()));

        std::call_once(logDbTargetOnce,
                       [&]()
                       {
                           const auto maxAttempts = 1U + settings::get<uint32>("network.SQL_QUERY_RETRY_COUNT");
                           ShowInfo(fmt::format(
                               "SQL connected successfully; using {}@{}:{}/{} (preparedStmt retries on transient connection loss: {}; XI_NETWORK_SQL_* env overrides apply). "
                               "This line is normal startup info, not a database error.",
                               login, host, port, schema, maxAttempts));
                       });

        return connection;
    }
    catch (const std::exception& e)
    {
        // If we can't establish a connection to the database we can't do anything.
        // Time to die!
        ShowCritical("!!! Failed to connect to database, terminating server !!!");
        ShowCritical(e.what());
        std::this_thread::sleep_for(1s);
        std::terminate();
    }
}

auto db::detail::isConnectionIssue(const std::exception& e) -> bool
{
    const auto str = to_lower(fmt::format("{}", e.what()));
    for (const auto& issue : connectionIssues)
    {
        if (str.find(issue) != std::string::npos)
        {
            return true;
        }
    }

    return false;
}

auto db::detail::validateQueryLeadingKeyword(const std::string& query) -> ResultSetType
{
    auto parts = split(to_upper(query), " ");

    std::vector<std::string> cleanedParts;
    for (const auto& part : parts)
    {
        if (!part.empty() && part != "\n")
        {
            cleanedParts.push_back(trim(trim(part), "\n"));
        }
    }
    parts = std::move(cleanedParts);

    if (parts.empty())
    {
        return ResultSetType::Invalid;
    }

    const auto keyword = parts[0];
    if (keyword == "SELECT")
    {
        return ResultSetType::Select;
    }
    else if (keyword == "INSERT")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "UPDATE")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "DELETE")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "REPLACE")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "CREATE")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "ALTER")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "DROP")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "TRUNCATE")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "SET")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "SHOW")
    {
        return ResultSetType::Select;
    }
    else if (keyword == "START")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "COMMIT")
    {
        return ResultSetType::Update;
    }
    else if (keyword == "ROLLBACK")
    {
        return ResultSetType::Update;
    }

    // Else
    return ResultSetType::Invalid;
}

auto db::detail::validateQueryContent(const std::string& query) -> bool
{
    // NOTE: We shouldn't be checking for the presence of '%', as this
    //     : is the SQL wildcard character.

    if (query.find("{}") != std::string::npos)
    {
        return false;
    }

    if (query.find(';') != std::string::npos)
    {
        return false;
    }

    return true;
}

Synchronized<db::detail::State>& db::detail::getState()
{
    TracyZoneScoped;

    // NOTE: mariadb-connector-cpp doesn't seem to make any guarantees about whether or not isValid()
    //     : is const. So we're going to have to wrap calls to it as though they aren't.

    const auto needFreshConnection = state.read(
        [&](auto& s) -> bool
        {
            if (s.connection == nullptr)
            {
                return true;
            }
            try
            {
                if (s.connection->isClosed())
                {
                    return true;
                }
                // Idle connections are often closed server-side (wait_timeout). Without this, the first
                // real query fails with "Lost connection to server during query" and hits the retry path.
                return !s.connection->isValid();
            }
            catch (const std::exception&)
            {
                return true;
            }
        });

    if (!needFreshConnection)
    {
        return state;
    }

    state.write(
        [&](auto& s)
        {
            s.reset();
        });

    return state;
}

auto db::detail::timer(const std::string& query) -> xi::final_action<std::function<void()>>
{
    const auto start = timer::now();
    return xi::finally<std::function<void()>>(
        [query, start]() -> void
        {
            const auto end      = timer::now();
            const auto duration = timer::count_milliseconds(end - start);
            if (timersEnabled && settings::get<bool>("logging.SQL_SLOW_QUERY_LOG_ENABLE"))
            {
                if (duration > settings::get<uint32>("logging.SQL_SLOW_QUERY_ERROR_TIME"))
                {
                    ShowError(fmt::format("SQL query took {}ms: {}", duration, query));
                }
                else if (duration > settings::get<uint32>("logging.SQL_SLOW_QUERY_WARNING_TIME"))
                {
                    ShowWarning(fmt::format("SQL query took {}ms: {}", duration, query));
                }
            }
        });
}

auto db::escapeString(std::string_view str) -> std::string
{
    static const std::unordered_map<char, std::string> replacements = {
        // Replacement map similar to str_replace in PHP
        { '\\', "\\\\" },
        { '\0', "\\0" },
        { '\n', "\\n" },
        { '\r', "\\r" },
        { '\'', "\\'" },
        { '\"', "\\\"" },
        { '\x1a', "\\Z" },

        // Extras
        { '\b', "\\b" },
        { '%', "\\%" },
        { '|', "\\|" },
        { ';', "\\;" },
    };

    std::string escapedStr;

    for (size_t i = 0; i < str.size(); ++i)
    {
        const char c = str[i];

        // Emulate original strlen-based SqlConnection::EscapeString
        if (c == '\0')
        {
            break;
        }

        const auto it = replacements.find(c);
        if (it != replacements.end())
        {
            escapedStr += it->second;
        }
        else
        {
            escapedStr += c;
        }
    }

    return escapedStr;
}

auto db::escapeString(const std::string& str) -> std::string
{
    if (str.empty())
    {
        return {};
    }

    return db::escapeString(std::string_view(str));
}

auto db::escapeString(const char* str) -> std::string
{
    if (str == nullptr)
    {
        return {};
    }

    return db::escapeString(std::string_view(str));
}

auto db::getDatabaseSchema() -> std::string
{
    TracyZoneScoped;

    return detail::getState().write(
        [&](detail::State& state) -> std::string
        {
            return state.connection->getSchema().c_str();
        });
}

auto db::getDatabaseVersion() -> std::string
{
    TracyZoneScoped;

    return detail::getState().write(
        [&](detail::State& state) -> std::string
        {
            const std::unique_ptr<sql::DatabaseMetaData> metadata(state.connection->getMetaData());
            return fmt::format("{} {}", metadata->getDatabaseProductName().c_str(), metadata->getDatabaseProductVersion().c_str());
        });
}

auto db::getDriverVersion() -> std::string
{
    TracyZoneScoped;

    return detail::getState().write(
        [&](detail::State& state) -> std::string
        {
            const std::unique_ptr<sql::DatabaseMetaData> metadata(state.connection->getMetaData());
            return fmt::format("{} {}", metadata->getDriverName().c_str(), metadata->getDriverVersion().c_str());
        });
}

void db::checkCharset()
{
    TracyZoneScoped;

    // Check that the SQL charset is what we require
    const auto rset = preparedStmt("SELECT @@character_set_database, @@collation_database");
    if (rset && rset->rowsCount())
    {
        bool foundError = false;
        while (rset->next())
        {
            const auto charsetSetting   = rset->get<std::string>(0);
            const auto collationSetting = rset->get<std::string>(1);
            if (!starts_with(charsetSetting, "utf8") || !starts_with(collationSetting, "utf8"))
            {
                foundError = true;

                ShowWarning(
                    fmt::format("Unexpected character_set or collation setting in database: {}: {}. Expected utf8*.",
                                charsetSetting,
                                collationSetting)
                        .c_str());
            }
        }

        if (foundError)
        {
            ShowWarning("Non utf8 charset can result in data reads and writes being corrupted!");
            ShowWarning("Non utf8 collation can be indicative that the database was not set up per required specifications.");
        }
    }
}

void db::checkTriggers()
{
    const auto triggerQuery = "SHOW TRIGGERS WHERE `Trigger` LIKE ?";

    const auto triggers = {
        "account_delete",
        "session_delete",
        "auction_house_list",
        "auction_house_buy",
        "char_insert",
        "char_delete",
        "delivery_box_insert",
        "ensure_synth_ingredients_are_ordered",
        "ensure_synergy_ingredients_are_ordered",
    };

    bool foundError = false;
    for (const auto& trigger : triggers)
    {
        const auto rset = preparedStmt(triggerQuery, trigger);
        if (!rset || rset->rowsCount() == 0)
        {
            ShowWarning(fmt::format("Missing trigger: {}", trigger));
            foundError = true;
        }
    }

    if (foundError)
    {
        ShowCriticalFmt("Missing triggers can result in data corruption or loss of data!!!");
        ShowCriticalFmt("Please ensure all triggers are present in the database (re-run dbtool.py).");
        std::this_thread::sleep_for(1s);
        std::terminate();
    }
}

bool db::setAutoCommit(bool value)
{
    TracyZoneScoped;

    if (!db::preparedStmt("SET @@autocommit = ?", value ? 1 : 0))
    {
        ShowError("Failed to set autocommit value");
        return false;
    }

    return true;
}

bool db::getAutoCommit()
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT @@autocommit");
    FOR_DB_SINGLE_RESULT(rset)
    {
        return rset->get<uint32>(0) == 1;
    }

    ShowError("Failed to get autocommit status");

    return false;
}

bool db::transactionStart()
{
    TracyZoneScoped;

    if (!db::preparedStmt("START TRANSACTION"))
    {
        ShowError("Failed to start transaction");
        return false;
    }

    return true;
}

bool db::transactionCommit()
{
    TracyZoneScoped;

    if (!db::preparedStmt("COMMIT"))
    {
        ShowError("Failed to commit transaction");
        return false;
    }

    return true;
}

bool db::transactionRollback()
{
    TracyZoneScoped;

    if (!db::preparedStmt("ROLLBACK"))
    {
        ShowError("Failed to rollback transaction");
        return false;
    }

    return true;
}

void db::enableTimers()
{
    timersEnabled = true;
}

bool db::transaction(const std::function<void()>& transactionFn)
{
    TracyZoneScoped;

    const bool wasAutoCommitOn = db::getAutoCommit();

    if (db::setAutoCommit(false) && db::transactionStart())
    {
        try
        {
            transactionFn();
            db::transactionCommit();
        }
        catch (const std::exception& e)
        {
            ShowCritical("Transaction failed: Rolling back!");
            ShowCritical("Transaction failed: %s", e.what());

            db::transactionRollback();
            db::setAutoCommit(wasAutoCommitOn);
            return false;
        }
    }
    else
    {
        db::setAutoCommit(wasAutoCommitOn);
        return false;
    }

    db::setAutoCommit(wasAutoCommitOn);
    return true;
}

auto db::getTableColumnNames(const std::string& tableName) -> std::vector<std::string>
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_NAME = ? AND TABLE_SCHEMA = ?", tableName, db::getDatabaseSchema());
    if (rset && rset->rowsCount())
    {
        std::vector<std::string> columnNames;
        while (rset->next())
        {
            columnNames.emplace_back(rset->get<std::string>(0));
        }

        return columnNames;
    }

    return {};
}
