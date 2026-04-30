#pragma once

#include <crow.h>

namespace leaf
{
    struct ListJournalEntriesResponse
    {
        uint32_t Page;
        uint32_t Size;
        bool     HasMore;
        uint32_t TotalPages;
    };
}
