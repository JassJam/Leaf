#pragma once

#include <utility>
#include <optional>
#include <boost/leaf.hpp>

namespace leaf::outcome
{
    using namespace boost::leaf;

    template<typename Ty, typename... Args>
    inline result<Ty> success(Args&&... args) noexcept(std::is_nothrow_constructible_v<Ty, Args...>)
        requires(!std::is_same_v<Ty, void>)
    {
        return result<Ty>{ std::forward<Args>(args)... };
    }

    inline result<void> success() noexcept
    {
        return result<void>{};
    }

    //

    /// <summary>
    /// transform - Apply a function to the success value
    /// </summary>
    template<typename T, typename F>
    auto transform(result<T>&& res, F&& func)
    {
        using ReturnType = std::invoke_result_t<F, T>;

        if (res)
        {
            if constexpr (std::is_void_v<ReturnType>)
            {
                std::forward<F>(func)(std::move(res).value());
                return result<void>{};
            }
            else
            {
                return result<ReturnType>{
                    std::forward<F>(func)(std::move(res).value()) //
                };
            }
        }
        return std::move(res).error();
    }

    /// <summary>
    /// transform - Apply a function to the success value
    /// </summary>
    template<typename T, typename F>
    auto transform(const result<T>& res, F&& func)
    {
        using ReturnType = std::invoke_result_t<F, const T&>;

        if (res)
        {
            if constexpr (std::is_void_v<ReturnType>)
            {
                std::forward<F>(func)(res.value());
                return result<void>{};
            }
            else
            {
                return result<ReturnType>{
                    std::forward<F>(func)(res.value()) //
                };
            }
        }
        return res.error();
    }

    /// <summary>
    /// chain another operation that returns a result
    /// </summary>
    template<typename T, typename F>
    auto and_then(result<T>&& res, F&& func)
    {
        if (res)
        {
            return std::forward<F>(func)(std::move(res).value());
        }
        return std::move(res).error();
    }

    /// <summary>
    /// chain another operation that returns a result
    /// </summary>
    template<typename T, typename F>
    auto and_then(const result<T>& res, F&& func)
    {
        if (res)
        {
            return std::forward<F>(func)(res.value());
        }
        return res.error();
    }

    /// <summary>
    /// execute function if result has error, returns new result
    /// </summary>
    template<typename T, typename F>
        requires std::is_invocable_v<F>
    auto value_or(result<T>&& res, F&& func)
    {
        if (res)
        {
            return std::forward<result<T>>(res).value();
        }

        if constexpr (std::is_invocable_v<F>)
        {
            return std::forward<F>(func)();
        }
        else
        {
            return std::forward<F>(func)(std::move(res).error());
        }
    }

    /// <summary>
    /// execute function if result has error, returns new result
    /// </summary>
    template<typename T>
    auto value_or(result<T>&& res, T&& value)
    {
        if (res)
        {
            return std::forward<result<T>>(res).value();
        }

        return std::forward<T>(value);
    }

    /// <summary>
    /// execute function if result has error, returns new result
    /// </summary>
    template<typename T>
    auto value_or(result<T>&& res, std::optional<T>&& value) -> std::optional<T>
    {
        if (res)
        {
            return std::forward<result<T>>(res).value();
        }

        return std::forward<T>(value);
    }

    /// <summary>
    /// execute function if result has error, returns new result
    /// </summary>
    template<typename T>
    auto value_or(result<T>&& res, std::nullopt_t) -> std::optional<T>
    {
        if (res)
        {
            return std::forward<result<T>>(res).value();
        }

        return std::nullopt;
    }

    /// <summary>
    /// execute function if result has value (void return)
    /// </summary>
    template<typename T, typename F>
    void if_present(const result<T>& res, F&& func)
    {
        if (res)
        {
            std::forward<F>(func)(res.value());
        }
    }

    /// <summary>
    /// execute function if result has value (void return)
    /// </summary>
    template<typename T, typename F>
    void if_present(result<T>&& res, F&& func)
    {
        if (res)
        {
            std::forward<F>(func)(std::move(res).value());
        }
    }

    /// <summary>
    /// execute function if result has error (void return)
    /// </summary>
    template<typename T, typename F>
    void if_error(const result<T>& res, F&& func)
    {
        if (!res)
        {
            if constexpr (std::is_invocable_v<F>)
            {
                std::forward<F>(func)();
            }
            else
            {
                std::forward<F>(func)(res.error());
            }
        }
    }

    /// <summary>
    /// execute function if result has error (void return)
    /// </summary>
    template<typename T, typename F>
    void if_error(result<T>&& res, F&& func)
    {
        if (!res)
        {
            if constexpr (std::is_invocable_v<F>)
            {
                std::forward<F>(func)();
            }
            else
            {
                std::forward<F>(func)(std::move(res).error());
            }
        }
    }

    /// <summary>
    /// handle some of the possible errors
    /// </summary>
    template<typename T, typename... Handlers>
    auto handle_some(result<T>&& res, Handlers&&... handlers)
    {
        return boost::leaf::try_handle_some([movedRes = std::move(res)] { return movedRes; },
                                            std::forward<Handlers>(handlers)...);
    }

    /// <summary>
    /// handle all of the possible errors
    /// </summary>
    template<typename T, typename... Handlers>
    auto handle_all(result<T>&& res, Handlers&&... handlers)
    {
        return boost::leaf::try_handle_all([movedRes = std::move(res)] { return movedRes; },
                                           std::forward<Handlers>(handlers)...);
    }

    /// <summary>
    /// inspect some of the possible errors
    /// </summary>
    template<typename T, typename... Handlers>
    void inspect_some(result<T>&& res, Handlers&&... handlers)
    {
        if (!res)
        {
            boost::leaf::try_handle_some([&] { return std::move(res); },
                                         std::forward<Handlers>(handlers)...);
        }
    }

    /// <summary>
    /// inspect all of the possible errors
    /// </summary>
    template<typename T, typename... Handlers>
    void inspect_all(result<T>&& res, Handlers&&... handlers)
    {
        if (!res)
        {
            boost::leaf::try_handle_all([&] { return std::move(res); },
                                        std::forward<Handlers>(handlers)...);
        }
    }

    /// <summary>
    /// flatten nested results
    /// </summary>
    template<typename T>
    auto flatten(result<result<T>>&& res) -> result<T>
    {
        if (res)
        {
            return std::move(res).value();
        }
        return std::move(res).error();
    }

    /// <summary>
    /// pattern match on the result
    /// </summary>
    template<typename T, typename OnSuccess, typename OnError>
    auto match_result(result<T>&& res, OnSuccess&& onSuccess, OnError&& onError)
    {
        if (res)
        {
            return std::forward<OnSuccess>(onSuccess)(std::move(res).value());
        }
        else
        {
            if constexpr (std::is_invocable_v<OnError>)
            {
                return std::forward<OnError>(onError)();
            }
            else
            {
                return std::forward<OnError>(onError)(std::move(res).error());
            }
        }
    }
}

#define LEAF_OUTCOME_GET(var, expr)                                                                                \
    auto&& BOOST_LEAF_TMP = expr;                                                                                  \
    static_assert(                                                                                                 \
        ::boost::leaf::is_result_type<typename std::decay<decltype(BOOST_LEAF_TMP)>::type>::value,                 \
        "BOOST_LEAF_ASSIGN/BOOST_LEAF_AUTO requires a result object as the second argument (see is_result_type)"); \
    if (!BOOST_LEAF_TMP)                                                                                           \
        return BOOST_LEAF_TMP.error();                                                                             \
    auto& var = BOOST_LEAF_TMP.value()

#define LEAF_OUTCOME_ASSIGN(var, expr)                                                                             \
    auto&& BOOST_LEAF_TMP = expr;                                                                                  \
    static_assert(                                                                                                 \
        ::boost::leaf::is_result_type<typename std::decay<decltype(BOOST_LEAF_TMP)>::type>::value,                 \
        "BOOST_LEAF_ASSIGN/BOOST_LEAF_AUTO requires a result object as the second argument (see is_result_type)"); \
    if (!BOOST_LEAF_TMP)                                                                                           \
        return BOOST_LEAF_TMP.error();                                                                             \
    var = BOOST_LEAF_TMP.value()

#define LEAF_OUTCOME_CHECK(expr) BOOST_LEAF_CHECK(expr)

#define LEAF_OUTCOME_ON_ERROR(...)                                                                 \
    [[maybe_unused]]                                                                               \
    auto&& BOOST_LEAF_TMP = outcome::on_error(__VA_ARGS__)

#define LEAF_OUTCOME_THROW(...) BOOST_LEAF_THROW_EXCEPTION(__VA_ARGS__)

#define LEAF_OUTCOME_THROW_OR_RETURN(expr)                                                         \
    auto&& BOOST_LEAF_TMP = expr;                                                                  \
    if (!BOOST_LEAF_TMP)                                                                           \
    {                                                                                              \
        LEAF_OUTCOME_THROW(BOOST_LEAF_TMP.error());                                                \
    }                                                                                              \
    return BOOST_LEAF_TMP.value();
