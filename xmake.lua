includes("project/options.lua")

add_rules("mode.debug", "mode.release")
set_languages("c++23")
add_defines("NOMINMAX")

set_policy("install.strip_packagelibs", false)
set_warnings("allextra", "error")

--

add_options("with-logging")

add_extrafiles("LICENSE.txt")
add_extrafiles(".clang-format")
add_extrafiles(".clang-tidy")

includes("project/thirdparty.lua")
includes("project/projects.lua")
