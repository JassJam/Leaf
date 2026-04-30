#include <leaf/LeafApp.hpp>

#include <leaf/services/GetJournalEntryEndpointService.hpp>
#include <leaf/services/ListJournalEntriesEndpointService.hpp>

namespace leaf::di
{
    static ServiceCollection GetServices()
    {
        ServiceCollection services;

        services.emplace<GetJournalEntryEndpointService>();
        services.emplace<ListJournalEntriesEndpointService>();

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

    app.Register<leaf::GetJournalEntryEndpointService>();
    app.Register<leaf::ListJournalEntriesEndpointService>();

    app.Run();
    return 0;
}
