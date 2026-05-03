#include <leaf/LeafApp.hpp>

#include <leaf/endpoints/GetJournalEntryEndpointService.hpp>
#include <leaf/endpoints/ListJournalEntriesEndpointService.hpp>

#include "leaf/backend/psql/PostgreSqlService.hpp"
#include "leaf/backend/psql/PsqlJournalRepositoryService.hpp"

namespace leaf::di
{
    static ServiceCollection GetServices()
    {
        ServiceCollection services;

        GetJournalEntryEndpointService::Register(services);
        ListJournalEntriesEndpointService::Register(services);

        PostgreSqlService::Register(services);
        PsqlJournalRepositoryService::Register(services);

        return services;
    }

    static leaf::LeafApp CreateApp()
    {
        return leaf::LeafApp(ServiceProvider(GetServices()));
    }
}

int main()
{
    auto app = leaf::di::CreateApp();

    using x = leaf::GetJournalEntryEndpointService::value_type;
    app.Register<leaf::GetJournalEntryEndpointService>();
    app.Register<leaf::ListJournalEntriesEndpointService>();

    app.Run();
    return 0;
}
