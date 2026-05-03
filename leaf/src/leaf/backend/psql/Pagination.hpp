#pragma once

#include <fmt/format.h>
#include <pqxx/pqxx>
#include <leaf/common/Page.hpp>

namespace leaf
{
    template<typename T>
    class Paginator
    {
    public:
        explicit Paginator(pqxx::work& txn) : m_Transaction(txn)
        {
        }

    public:
        template<typename MapperTy, typename... Args>
        [[nodiscard]]
        Page<T> FetchPage(const std::string& query, // FROM users WHERE active = true
                          MapperTy           mapper,
                          const PageQuery&   pageQuery,
                          Args&&... args)
        {
            // Append LIMIT + OFFSET params after user's args
            // We need to know how many args were passed to number $N correctly
            constexpr int argCount = sizeof...(Args);

            const auto countQuery  = fmt::format("SELECT COUNT(*) {}", query);
            const auto selectQuery = fmt::format("SELECT * {} ORDER BY id LIMIT ${} OFFSET ${}",
                                                 query,
                                                 argCount + 1,
                                                 argCount + 2);

            pqxx::params countParams{ std::forward<Args>(args)... };

            pqxx::params selectParams{ std::forward<Args>(args)...,
                                       pageQuery.PageSize,
                                       pageQuery.PageIndex * pageQuery.PageSize };

            // Count with same filters
            auto     countRes  = m_Transaction.exec(countQuery, countParams);
            uint32_t totalRows = countRes[0][0].as<uint32_t>();

            auto res = m_Transaction.exec(selectQuery, selectParams);

            return BuildPage(res, mapper, pageQuery, totalRows);
        }

    private:
        template<typename MapperTy>
        [[nodiscard]]
        static Page<T> BuildPage(const pqxx::result& res,
                                 MapperTy&           mapper,
                                 const PageQuery&    pageQuery,
                                 uint32_t            totalRows)
        {
            std::vector<T> items;
            items.reserve(res.size());

            for (const auto& row : res)
            {
                items.push_back(mapper(row));
            }

            return Page<T>{ .Items       = std::move(items),
                            .CurrentPage = pageQuery.PageIndex,
                            .PageSize    = pageQuery.PageSize,
                            .TotalRows   = totalRows,
                            .TotalPages =
                                (totalRows + pageQuery.PageSize - 1) / pageQuery.PageSize };
        }

    private:
        pqxx::work& m_Transaction;
    };
}
