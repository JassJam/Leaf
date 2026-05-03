#pragma once

#include <leaf/common/DI.hpp>
#include <leaf/interfaces/JournalRepositoryService.hpp>

#include "PsqlJournalRepository.hpp"
#include "PostgreSqlService.hpp"

namespace leaf
{
    namespace details
    {
        using PsqlJournalRepositoryService = di::Injected<PsqlJournalRepository,
                                                          di::ServiceLifetime::scoped,
                                                          di::Dependency<PostgreSqlService>>;
    }

    struct PsqlJournalRepositoryService : details::PsqlJournalRepositoryService
    {
        using details::PsqlJournalRepositoryService::PsqlJournalRepositoryService;

        static void Register(di::ServiceCollection& services)
        {
            services.add_impl<JournalRepositoryService, PsqlJournalRepositoryService>();
        }
    };
}
