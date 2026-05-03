#pragma once

#include <leaf/common/DI.hpp>
#include "PostgreSql.hpp"

namespace leaf
{
    namespace details
    {
        using PostgreSqlService =    //
            di::Injected<PostgreSql, //
                         di::ServiceLifetime::scoped>;
    }

    struct PostgreSqlService : public details::PostgreSqlService
    {
        using details::PostgreSqlService::PostgreSqlService;

        static void Register(di::ServiceCollection& services)
        {
            services.emplace<PostgreSqlService>();
        }
    };
}
