#pragma once

#include <string>

#include <leaf/common/UUID.hpp>
#include <leaf/common/Time.hpp>

#include "Url.hpp"
#include "Language.hpp"

namespace leaf
{
    struct Project
    {
        UUID                  Id;
        std::string           Title;
        std::string           Summary;
        UUID                  Body;
        Date                  CreateDate;
        std::vector<Language> TechStack;
        std::vector<Url>      Urls;
    };
}
