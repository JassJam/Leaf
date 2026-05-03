#pragma once

#include <string>

#include <leaf/common/UUID.hpp>
#include <leaf/common/Time.hpp>

namespace leaf
{
    struct JournalEntry
    {
        std::string Id;
        std::string Title;
        std::string Summary;
        std::string CreateDate;
        std::string MarkdownFileId;
    };
}
