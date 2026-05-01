#pragma once

#include <string>

#include <leaf/common/UUID.hpp>
#include <leaf/common/Time.hpp>

#include "Language.hpp"

namespace leaf
{
    struct Experience
    {
        UUID                  Id;
        Date                  StartDate;
        std::optional<Date>   EndDate;
        std::string           Title;
        std::string           Description;
        std::vector<Language> TechStack;
    };
}
