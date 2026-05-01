#pragma once

#include <string>

#include <leaf/common/UUID.hpp>

namespace leaf
{
    struct Url
    {
        UUID        Id;
        std::string Value;
        std::string Type;
    };
}
