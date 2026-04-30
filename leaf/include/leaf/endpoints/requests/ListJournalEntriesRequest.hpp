#pragma once

#include <crow.h>

namespace leaf
{
    struct ListJournalEntriesRequest
    {
        uint32_t Page;
        uint32_t Size;
    };
}
