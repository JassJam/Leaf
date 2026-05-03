#include <fmt/format.h>
#include <fmt/compile.h>

#include "PostgreSql.hpp"

namespace leaf
{
    PostgreSql::PostgreSql()
        : m_Connection(fmt::format(FMT_COMPILE("host={} port={} dbname={} user={} password={}"),
                                   DB_HOST,
                                   POSTGRES_PORT,
                                   POSTGRES_DB,
                                   POSTGRES_USER,
                                   POSTGRES_PASSWORD))
    {
    }

    pqxx::work PostgreSql::NewTransaction()
    {
        return pqxx::work(m_Connection);
    }
}
