#pragma once

#include <leaf/common/DI.hpp>
#include <leaf/endpoints/GetJournalEntryEndpoint.hpp>

#include <leaf/interfaces/JournalRepositoryService.hpp>

namespace leaf
{
    namespace details
    {
        using GetJournalEntryEndpointService =    //
            di::Injected<GetJournalEntryEndpoint, //
                         di::ServiceLifetime::scoped,
                         di::Dependency<JournalRepositoryService>>;
    }

    struct GetJournalEntryEndpointService : public details::GetJournalEntryEndpointService
    {
        using details::GetJournalEntryEndpointService::GetJournalEntryEndpointService;

        static void Register(di::ServiceCollection& services)
        {
            services.emplace<GetJournalEntryEndpointService>();
        }
    };
}
