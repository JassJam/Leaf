local packages = {
    {name = "boost-common", opts = {public = true}},
    {name = "crow", opts = {public = true}},
    {name = "coffee.dipp", opts = {public = true}},
}

if is_config("with-logging", true) then
    table.insert(packages, {name = "spdlog", opts = {public = true}})
end

project_utils:declare_project({
    name = "Leaf",
    kind = "binary",

    include_dirs = {
        {path = "include", opts = {public = true}},
        {path = "src"},
    },
    headerfiles = {
        {path = "include/**.hpp", opts = {public = true}},
        {path = "src/**.hpp"},
    },
    files = {
        {path = "src/**.cpp"}
    },
    
    filegroups = {
        {name = "include", opts = {rootdir = "include/coffee"}},
    },

    packages = packages,
})
