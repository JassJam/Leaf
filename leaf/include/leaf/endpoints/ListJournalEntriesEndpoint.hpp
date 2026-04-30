#pragma once

#include <crow.h>

namespace leaf
{
    class ListJournalEntriesEndpoint
    {
    public:
        static constexpr crow::HTTPMethod Method  = crow::HTTPMethod::Get;
        static constexpr const char       Route[] = "/journal-entries";

        std::string HandleRequest(const crow::request&)
        {
            return "Hello world2";
        }
    };
}
