#pragma once

#include <chrono>
#include <format>

namespace leaf
{
    using Date     = std::chrono::year_month_day;
    using DateTime = std::chrono::sys_seconds;
}
