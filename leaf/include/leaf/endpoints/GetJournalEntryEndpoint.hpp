#pragma once

#include <crow.h>

namespace leaf
{
    class GetJournalEntryEndpoint
    {
    public:
        static constexpr crow::HTTPMethod Method  = crow::HTTPMethod::Get;
        static constexpr const char       Route[] = "/journal-entry";

        std::string HandleRequest(const crow::request&)
        {
            return "Hello world";
        }
    };
}
