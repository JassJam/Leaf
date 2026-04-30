-- TODO: will be removed in favor of https://github.com/xmake-io/xmake/pull/7342
rule("target-csharp")
    set_extensions(".cs", ".csproj")

    local function find_csproj(target)
        local sourcefiles = target:sourcefiles()
        print("Finding .csproj file for target " .. target:name())
        for _, file in ipairs(sourcefiles) do
            if path.extension(file) == ".csproj" then
                print("Found .csproj file: " .. file)
                return file
            end
        end
        return nil
    end

    local function print_missing_csproj_warning(target)
        print("Warning: No .csproj file found for target " .. target:name() .. ", C# build will be skipped")
    end

    on_build(function (target)
        local target_path =  target:targetdir()
        local csproj = find_csproj(target)
        if csproj then
            local mode = "Debug"
            if is_mode("release") then
                mode = "Release"
            end

            os.execv("dotnet", {
                "build", csproj,
                "--configuration", mode,
                "--output", target_path,
                "--nologo",
                "--verbosity", "minimal",
            })
        else
            print_missing_csproj_warning(target)
        end
    end)
    on_clean(function (target)
        local csproj = find_csproj(target)
        if csproj then
            os.execv("dotnet", {
            "clean", csproj,
            "--nologo",
            "--verbosity", "minimal",
        })
        else
            print_missing_csproj_warning(target)
        end
    end)
    on_run(function (target)
        local csproj = find_csproj(target)
        if csproj then
            local mode = "Debug"
            if is_mode("release") then
                mode = "Release"
            end

            os.execv("dotnet", {
                "run", csproj,
                "--configuration", mode,
                "--nologo",
                "--verbosity", "minimal",
            })
        else
            print_missing_csproj_warning(target)
        end
    end)
    on_install(function (target)
        local install_path =  target:installdir()
        local csproj = find_csproj(target)
        if csproj then
            local mode = "Debug"
            if is_mode("release") then
                mode = "Release"
            end
            os.execv("dotnet", {
                "publish", csproj,
                "--configuration", mode,
                "--output", install_path,
                "--nologo",
                "--verbosity", "minimal",
            })
        else
            print_missing_csproj_warning(target)
        end
    end)
rule_end()
