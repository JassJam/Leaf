#pragma once

#include <pqxx/pqxx>

namespace leaf
{
    class PostgreSql
    {
    public:
        PostgreSql();

    public:
        [[nodiscard]]
        pqxx::work NewTransaction();

    private:
        pqxx::connection m_Connection;
    };
}
