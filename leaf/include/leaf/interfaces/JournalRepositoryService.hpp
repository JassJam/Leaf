#pragma once

#include <leaf/common/DI.hpp>
#include <leaf/interfaces/JournalRepository.hpp>

namespace leaf
{
    using JournalRepositoryService =           //
        di::InjectedUnique<IJournalRepository, //
                           di::ServiceLifetime::scoped>;
}
