#pragma once

#include <leaf/common/DI.hpp>
#include <leaf/endpoints/ListJournalEntriesEndpoint.hpp>

namespace leaf
{
    using ListJournalEntriesEndpointService =    //
        di::Injected<ListJournalEntriesEndpoint, //
                     di::ServiceLifetime::scoped>;
}
