#pragma once

#include <leaf/common/DI.hpp>
#include <leaf/endpoints/ListJournalEntriesEndpoint.hpp>

namespace leaf
{
    namespace details
    {
        using ListJournalEntriesEndpointService =    //
            di::Injected<ListJournalEntriesEndpoint, //
                         di::ServiceLifetime::scoped,
                         di::Dependency<JournalRepositoryService>>;
    }

    struct ListJournalEntriesEndpointService : public details::ListJournalEntriesEndpointService
    {
        using details::ListJournalEntriesEndpointService::ListJournalEntriesEndpointService;

        static void Register(di::ServiceCollection& services)
        {
            services.emplace<ListJournalEntriesEndpointService>();
        }
    };
}
