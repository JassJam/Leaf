#pragma once

#include <string>
#include <vector>
#include <optional>

#include <leaf/common/UUID.hpp>
#include <leaf/common/Time.hpp>

#include "CommentLike.hpp"

namespace leaf
{
    struct Comment
    {
        UUID                     Id;
        UUID                     JournalEntryId;
        std::optional<UUID>      ParentId;
        std::string              GuestName;
        std::string              Body;
        DateTime                 CreatedAt;
        std::vector<Comment>     Replies;
        std::vector<CommentLike> Likes;
    };
}
