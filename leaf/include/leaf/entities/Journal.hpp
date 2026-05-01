#pragma once

#include <string>

#include <leaf/common/UUID.hpp>
#include <leaf/common/Time.hpp>

namespace leaf
{
    struct JournalEntry
    {
        UUID        Id;
        std::string Title;
        UUID        Body;
        Date        CreateDate;
    };
}
