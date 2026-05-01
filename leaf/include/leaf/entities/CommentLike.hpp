#pragma once

#include <string>

#include <leaf/common/UUID.hpp>
#include <leaf/common/Time.hpp>

namespace leaf
{
    struct CommentLike
    {
        UUID        Id;
        UUID        CommentId;
        std::string GuestName;
        std::string Reaction;
        DateTime    CreatedAt;
    };
}
