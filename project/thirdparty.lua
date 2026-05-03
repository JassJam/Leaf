includes("thirdparty/dipp.lua")

--

local common_boost_libs = {
    "asio",
    "iostreams",
    "lzma",
    "zlib",
    "bzip2",
    "filesystem",
    "system",
    "program_options",
    "serialization",
    "test",
    "thread",
    "leaf",
    "cobalt",
}

local boost_libs_ver = "1.88.0"
local boost_libs_str = "boost[cmake," .. table.concat(common_boost_libs, ",") .. "] " .. boost_libs_ver
add_requires(boost_libs_str, {alias = "boost-common"})

--

add_requires("crow")

--

add_requires("fmt")

--

add_requires("coffee.dipp")

--

add_requires("libpq", {configs = {shared = true}})
add_requires("libpqxx", {configs = {shared = true}})

--

add_requires("nlohmann_json")

--

if is_config("with-logging", true) then
    add_requires("spdlog", {configs = {std_format = true, wchar = false, noexcept = true}})
end
