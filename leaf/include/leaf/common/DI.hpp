#pragma once

#include <dipp/dipp.hpp>

namespace leaf::di
{
    using ServiceCollection = dipp::service_collection;
    using ServiceProvider   = dipp::service_provider;
    using ServiceScope      = dipp::service_scope;
    template<dipp::details::base_injected_type Ty>
    using ServiceGetter = dipp::service_getter<Ty>;

    using ServiceLifetime = dipp::service_lifetime;
    template<dipp::details::base_injected_type... ArgsTy>
    using Dependency = dipp::dependency<ArgsTy...>;

    template<typename Ty,
             ServiceLifetime                          Lifetime,
             dipp::details::dependency_container_type DepsTy  = Dependency<>,
             size_t                                   Key     = size_t{},
             dipp::details::service_scope_type        ScopeTy = dipp::service_scope>
    using InjectedFunctor = dipp::injected_functor<Ty, Lifetime, DepsTy, Key, ScopeTy>;

    template<typename Ty,
             ServiceLifetime                          Lifetime,
             dipp::details::dependency_container_type DepsTy  = Dependency<>,
             size_t                                   Key     = size_t{},
             dipp::details::service_scope_type        ScopeTy = dipp::service_scope>
    using InjectedUnique = dipp::injected_unique<Ty, Lifetime, DepsTy, Key, ScopeTy>;

    template<typename Ty,
             ServiceLifetime                          Lifetime,
             dipp::details::dependency_container_type DepsTy  = Dependency<>,
             size_t                                   Key     = size_t{},
             dipp::details::service_scope_type        ScopeTy = dipp::service_scope>
    using InjectedShared = dipp::injected_shared<Ty, Lifetime, DepsTy, Key, ScopeTy>;

    template<typename Ty,
             ServiceLifetime                          Lifetime,
             dipp::details::dependency_container_type DepsTy  = Dependency<>,
             size_t                                   Key     = size_t{},
             dipp::details::service_scope_type        ScopeTy = dipp::service_scope>
    using InjectedRef = dipp::injected_ref<Ty, Lifetime, DepsTy, Key, ScopeTy>;

    template<typename Ty,
             ServiceLifetime                          Lifetime,
             dipp::details::dependency_container_type DepsTy  = Dependency<>,
             size_t                                   Key     = size_t{},
             dipp::details::service_scope_type        ScopeTy = dipp::service_scope>
    using Injected = dipp::injected<Ty, Lifetime, DepsTy, Key, ScopeTy>;

    using dipp::make_any;
    using dipp::make_error;
    using dipp::make_result;

    using dipp::details::move_only_any;
}
