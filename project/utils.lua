project_utils = {}


local function _make_moduleonly_library()
    set_kind("moduleonly")
end

local function _make_headeronly_library()
    set_kind("headeronly")
end

local function _make_static_library()
    set_kind("static")
end

local function _make_shared_library()
    set_kind("shared")
end

local function _make_binary_library()
    set_kind("binary")
end

local function _make_phony_library()
    set_kind("phony")
end

local function _declare_target(opts)
    target(opts.name)
        add_rules("target-env")

        if not opts.path then
            opts.path = "."
        end

        set_group(opts.group)

        if opts.rules then
            for _, rule in ipairs(opts.rules) do
                add_rules(rule)
            end
        end

        local switch = {
            moduleonly = _make_moduleonly_library,
            headeronly = _make_headeronly_library,
            static = _make_static_library,
            shared = _make_shared_library,
            binary = _make_binary_library,
            phony = _make_phony_library,
        }
        if opts.kind then
            switch[opts.kind]()
        end

        for _, dir in ipairs(opts.include_dirs or {}) do
            if type(dir) == "string" then
                add_includedirs(opts.path .. "/" .. dir)
            else
                add_includedirs(opts.path .. "/" .. dir.path, dir.opts)
            end
        end

        if opts.files then
            for _, file in ipairs(opts.files) do
                if type(file) == "string" then
                    add_files(file)
                else
                    add_files(file.path, file.opts)
                end
            end
        end

        if opts.extrafiles then
            for _, file in ipairs(opts.extrafiles) do
                if type(file) == "string" then
                    add_extrafiles(file)
                else
                    add_extrafiles(file.path, file.opts)
                end
            end
        end

        if opts.headerfiles then
            for _, file in ipairs(opts.headerfiles) do
                if type(file) == "string" then
                    add_headerfiles(file)
                else
                    add_headerfiles(file.path, file.opts)
                end
            end
        end

        if opts.forceincludes then
            for _, file in ipairs(opts.forceincludes) do
                if type(file) == "string" then
                    add_forceincludes(file)
                else
                    add_forceincludes(file.path, file.opts)
                end
            end
        end

        if opts.defines then
            for _, define in ipairs(opts.defines) do
                if type(define) == "string" then
                    add_defines(define)
                else
                    add_defines(define.name, define.opts)
                end
            end
        end

        if opts.deps then
            for _, dep in ipairs(opts.deps) do
                if type(dep) == "string" then
                    add_deps(dep)
                else
                    add_deps(dep.name, dep.opts)
                end
            end
        end

        if opts.packages then
            for _, package in ipairs(opts.packages) do
                if type(package) == "string" then
                    add_packages(package)
                else
                    add_packages(package.name, package.opts)
                end
            end
        end

        if opts.filegroups then
            for _, filegroup in ipairs(opts.filegroups) do
                add_filegroups(filegroup.name, filegroup.opts)
            end
        end

        if opts.callback then
            opts.callback()
        end

    target_end()
end

local function _add_tests(opts)
    local test_opts = opts.test
    if not test_opts then
        return
    end

    local test_group = opts.group
    if test_group then
        test_group = "tests/" .. test_group
    else
        test_group = "tests"
    end

    local initial_name = test_opts.name
    if not initial_name then
        initial_name = "test." .. opts.name
    end

    local test_deps = test_opts.deps or {}
    table.insert(test_deps, opts.name)

    local test_packages = test_opts.packages or {}
    table.insert(test_packages, {name = "boost-common", {public = true, inherit = true}})

    local test_config = {
        name = initial_name,
        kind = "binary",
        group = test_group,
        path = test_opts.path or opts.path or ".",
        deps = test_deps,
        packages = test_packages,
        files = test_opts.files,
        extrafiles = test_opts.extrafiles,
        include_dirs = test_opts.include_dirs,
        headerfiles = test_opts.headerfiles,
        filegroups = test_opts.filegroups,
        defines = test_opts.defines,
        forceincludes = test_opts.forceincludes,
        rules = test_opts.rules,
    }

    test_config.callback = function()
        add_tests("default")
        if test_opts.callback then
            test_opts.callback()
        end
    end
    _declare_target(test_config)
end

---
-- Declare a project with the given options
-- opts:
-- - name: the name of the project
-- - path: the path to the project
-- - group: the group of the project
-- - kind: the kind of the project
-- - callback?: a callback function to be called after the project is declared
-- - files[]?: a list of files to be added to the project
-- - - path: the path to the files
-- - - opts?: options for the files
-- - - OR
-- - - a string with the path to the files
-- - extrafiles[]?: a list of extra files to be added to the project
-- - - path: the path to the files
-- - - opts?: options for the files
-- - - OR
-- - - a string with the path to the files
-- - headerfiles[]?: a list of header files to be added to the project
-- - - path: the path to the files
-- - - opts?: options for the files
-- - - OR
-- - - a string with the path to the files
-- - deps[]?: a list of dependencies
-- - - name: the name of the dependency
-- - - opts?: options for the dependency
-- - - OR
-- - - a string with the name of the dependency
-- - packages[]?: a list of packages
-- - - name: the name of the package
-- - - opts?: options for the package
-- - - OR
-- - - a string with the name of the package
-- - forceincludes[]?: a list of forceincludes
-- - - path: the path to the forceincludes
-- - - opts?: options for the forceincludes
-- - - OR
-- - - a string with the path to the forceincludes
-- - defines[]?: a list of defines
-- - - name: the name of the define
-- - - opts?: options for the define
-- - - OR
-- - - a string with the name of the define
-- - include_dirs[]?: a list of include directories
-- - - path: the path to the include directories
-- - - opts?: options for the include directories
-- - - OR
-- - - a string with the path to the include directories
-- - filegroups[]?: a list of file groups
-- - - name: the name of the file group
-- - - opts: options for the file group
-- - test?: test configuration (inherits from parent opts and can override/extend)
-- - - files[]: a list of test files to be added to the project (REQUIRED if test is defined)
-- - - - path: the path to the test files
-- - - - opts?: options for the test files
-- - - - OR
-- - - - a string with the path to the test files
-- - - include_dirs[]?: a list of include directories for test targets
-- - - - path: the path to the include directories
-- - - - opts?: options for the include directories
-- - - - OR
-- - - - a string with the path to the include directories
-- - - headerfiles[]?: a list of header files for test targets
-- - - filegroups[]?: a list of file groups for test targets
-- - - defines[]?: a list of defines for test targets
-- - - forceincludes[]?: a list of force includes for test targets
-- - - packages[]?: additional packages for test targets (boost-common is always included)
-- - - deps[]?: additional dependencies for test targets (parent target is always included)
-- - - callback?: a callback function for test targets
-- - - rules[]?: a list of additional rules for test targets
function project_utils:declare_project(opts)
    _declare_target(opts)

    if is_config("with-tests", true) then
        _add_tests(opts)
    end
end
