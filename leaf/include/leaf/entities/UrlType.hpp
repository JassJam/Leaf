#pragma once

#include <string>

#include <leaf/common/UUID.hpp>

namespace leaf
{
    struct UrlType
    {
        UUID        Id;
        std::string Name;
        std::string Icon;
    };
}
