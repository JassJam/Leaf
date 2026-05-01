#pragma once

#include <chrono>

namespace leaf
{
    using DateTime = std::chrono::sys_seconds;
    using Date     = std::chrono::year_month_day;
}
