package("coffee.dipp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/JassJam/dipp")
    set_description("C++ Dependency injection inspired inspired by .NET's Microsoft.Extensions.DependencyInjection")
    set_license("MIT")

    add_urls("https://github.com/JassJam/dipp/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/JassJam/dipp.git")

    add_versions("v1.0.9", "7e93cffec133e6cf4257b43e29e9d07a152058d1cf3f7e8bdf97394527290009")

    add_configs("test", {description = "Build test code", default = false, type = "boolean"})
    add_configs("benchmark", {description = "Build benchmark code", default = false, type = "boolean"})
    add_configs("error-type", {description = "Error type to use", default = "result", type = "string", values = {"result", "exceptions"}})
    add_configs("cpp-version", {description = "C++ version to use", default = "c++20", type = "string", values = {"c++20", "c++23"}})

    on_load(function (package)
        if package:config("error-type") == "result" then
            package:add("deps", "boost[cmake,regex,leaf]")
            package:add("defines", "DIPP_USE_RESULT")
        end
    end)

    on_install(function (package)
        local configs = {
            test = false,
            benchmark = false,
            ["error-type"] = package:config("error-type"),
            ["cpp-version"] = package:config("cpp-version"),
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dipp/dipp.hpp>
            void test() {
                dipp::service_provider services({});
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
package_end()