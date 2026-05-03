#pragma once

#include <vector>

namespace leaf
{
    struct PageQuery
    {
        uint32_t PageIndex = 0;
        uint32_t PageSize  = 10;
    };

    template<typename Ty>
    struct Page
    {
        std::vector<Ty> Items;
        uint32_t        CurrentPage;
        uint32_t        PageSize;
        uint32_t        TotalRows;
        uint32_t        TotalPages;

        [[nodiscard]]
        bool HasNext() const
        {
            return CurrentPage + 1 < TotalPages;
        }

        [[nodiscard]]
        bool HasPrev() const
        {
            return CurrentPage > 0;
        }
    };
}
