#pragma once

#include <leaf/interfaces/JournalRepository.hpp>
#include "PostgreSql.hpp"

namespace leaf
{
    class PsqlJournalRepository : public IJournalRepository
    {
    public:
        explicit PsqlJournalRepository(PostgreSql& db) : m_Db(db)
        {
        }

    public:
        Page<JournalEntry> GetJournalEntries(const PageQuery& query) override;
        JournalEntry       GetJournalEntryBy(const std::string& id) override;

    private:
        PostgreSql& m_Db;
    };
}
