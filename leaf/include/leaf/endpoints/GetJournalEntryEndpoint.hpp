#pragma once

#include <crow.h>
#include <leaf/interfaces/JournalRepository.hpp>

namespace leaf
{
    class GetJournalEntryEndpoint
    {
    public:
        static constexpr crow::HTTPMethod Method  = crow::HTTPMethod::Get;
        static constexpr const char       Route[] = "/memos/<string>";

    public:
        explicit GetJournalEntryEndpoint(IJournalRepository& journalRepository)
            : m_JournalRepository(journalRepository)
        {
        }

        crow::json::wvalue HandleRequest(const std::string& id);

    private:
        IJournalRepository& m_JournalRepository;
    };
}
