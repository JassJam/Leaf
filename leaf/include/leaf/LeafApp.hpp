#pragma once

#include <utility>
#include <crow.h>

#include <leaf/common/DI.hpp>

namespace leaf
{
    class LeafApp
    {
        using App = crow::App<>;

    public:
        explicit LeafApp(di::ServiceProvider&& serviceProvider)
            : m_ServiceProvider(std::move(serviceProvider))
        {
        }

    public:
        void Run();

        template<typename EndpointService>
        void Register()
        {
            using endpoint_type = typename EndpointService::value_type;

            auto& route = CROW_ROUTE(m_App, endpoint_type::Route);

            constexpr bool hasMethod = requires { endpoint_type::Method; };
            if constexpr (hasMethod)
            {
                route.methods(endpoint_type::Method);
            }

            endpoint_type& endpoint =
                static_cast<endpoint_type&>(*m_ServiceProvider.get<EndpointService>());

            [&]<typename TReturn, typename... TArgs>(TReturn (endpoint_type::*method)(TArgs...))
            {
                route([&endpoint, method](TArgs... args)
                      { return std::invoke(method, endpoint, args...); });
            }(&endpoint_type::HandleRequest);
        }

    private:
        di::ServiceProvider m_ServiceProvider;
        App                 m_App;
    };
}
