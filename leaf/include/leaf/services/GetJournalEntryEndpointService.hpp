#pragma once

#include <leaf/common/DI.hpp>
#include <leaf/endpoints/GetJournalEntryEndpoint.hpp>

namespace leaf
{
    using GetJournalEntryEndpointService =    //
        di::Injected<GetJournalEntryEndpoint, //
                     di::ServiceLifetime::scoped>;
}
