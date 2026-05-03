#pragma once

#include <crow.h>
#include <leaf/interfaces/JournalRepository.hpp>

namespace leaf
{
    class ListJournalEntriesEndpoint
    {
    public:
        static constexpr crow::HTTPMethod Method  = crow::HTTPMethod::Get;
        static constexpr const char       Route[] = "/memos";

    public:
        explicit ListJournalEntriesEndpoint(IJournalRepository& journalRepository)
            : m_JournalRepository(journalRepository)
        {
        }

        crow::response HandleRequest(const crow::request& req);

    private:
        IJournalRepository& m_JournalRepository;
    };
}
