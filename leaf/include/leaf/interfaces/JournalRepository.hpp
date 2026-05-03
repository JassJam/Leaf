#pragma once

#include <leaf/common/Page.hpp>
#include <leaf/entities/Journal.hpp>

namespace leaf
{
    class IJournalRepository
    {
    public:
        virtual ~IJournalRepository() = default;

    public:
        virtual Page<JournalEntry> GetJournalEntries(const PageQuery& query) = 0;
        virtual JournalEntry       GetJournalEntryBy(const std::string& id)  = 0;
    };
}
