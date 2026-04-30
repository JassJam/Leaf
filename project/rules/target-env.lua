-- rule to process .env files and generate C++ defines
-- supports typed environment variables: KEY:TYPE=VALUE
-- types: string (quoted), int, bool, double/float, raw (default, unquoted)
-- priority: system env vars > .env.local (debug only) > .env
-- Examples:
--   DEFAULT_PASSWORD:string=R"(test"test)"  -> #define DEFAULT_PASSWORD R"(test"test)"
--   API_KEY:string=secret123                -> #define API_KEY "secret123"
--   MAX_RETRIES:int=5                       -> #define MAX_RETRIES 5
--   DEBUG_MODE:bool=true                    -> #define DEBUG_MODE true
--   TIMEOUT:double=30.5                     -> #define TIMEOUT 30.5
--   CONFIG_PATH="C:\Program Files\App"      -> #define CONFIG_PATH C:\Program Files\App (raw)
rule("target-env")
    set_extensions(".env")

    on_load(function(target)
        local function _parse_env_file(file)
            local env_vars = {}
            local content = io.readfile(file)
            if not content then
                return env_vars
            end
            for line in content:gmatch("[^\r\n]+") do
                if not line:match("^%s*$") and not line:match("^%s*#") then
                    local key, type_hint, value = line:match("^([A-Z_][A-Z0-9_]*):([a-z]+)%s*=%s*(.*)$")
                    if not key then
                        key, value = line:match("^([A-Z_][A-Z0-9_]*)%s*=%s*(.*)$")
                        type_hint = ""
                    end
                    if key and value then
                        value = value:match("^(.-)%s*$")
                        env_vars[key] = {value = value, type = type_hint}
                    end
                end
            end
            return env_vars
        end

        local function _merge_env_vars(dest, source)
            for k, v in pairs(source) do
                dest[k] = v
            end
        end

        local sourcefiles = target:sourcefiles()
        local env_files = {}
        
        for _, sourcefile in ipairs(sourcefiles) do
            local file_name = path.filename(sourcefile)
            if file_name:match("^%.env") and not file_name:match("%.local$") then
                local local_file = sourcefile .. ".local"
                local local_exists = os.isfile(local_file)
                table.insert(env_files, {
                    base = sourcefile,
                    local_file = local_exists and local_file or nil
                })
            end
        end
        
        local env_vars = {}
        
        for _, env_pair in ipairs(env_files) do
            _merge_env_vars(env_vars, _parse_env_file(env_pair.base))
            
            if env_pair.local_file and is_mode("debug") then
                _merge_env_vars(env_vars, _parse_env_file(env_pair.local_file))
            end
        end
        
        if #env_files > 0 then
            local build_dir = path.join(os.projectdir(), "build")
            os.mkdir(build_dir)
            
            local header_path = path.join(build_dir, target:name() .. "_env_config.h")
            local need_regenerate = not os.isfile(header_path)
            if need_regenerate then
                io.writefile(header_path, "// Auto-generated from .env file\n#pragma once\n\n")
            end
            
            if not need_regenerate then
                local header_mtime = os.mtime(header_path)
                for _, env_pair in ipairs(env_files) do
                    if os.mtime(env_pair.base) > header_mtime then
                        need_regenerate = true
                        break
                    end
                    if env_pair.local_file and is_mode("debug") and os.mtime(env_pair.local_file) > header_mtime then
                        need_regenerate = true
                        break
                    end
                end
            end
            
            if need_regenerate then
                local header_content = "// Auto-generated from .env file\n#pragma once\n\n"
                
                local count = 0
                for key, var_info in pairs(env_vars) do
                    count = count + 1
                    local value = var_info.value
                    local var_type = var_info.type
                    
                    local system_value = os.getenv(key)
                    if system_value then
                        value = system_value
                    end
                    
                    if var_type == "int" then
                        header_content = header_content .. string.format('#define %s %s\n', key, value)
                    elseif var_type == "bool" then
                        local bool_val = (value == "true" or value == "1") and "true" or "false"
                        header_content = header_content .. string.format('#define %s %s\n', key, bool_val)
                    elseif var_type == "double" or var_type == "float" then
                        header_content = header_content .. string.format('#define %s %s\n', key, value)
                    elseif var_type == "string" then
                        local raw_content = value:match('^R"%((.*)%)"$')
                        if raw_content then
                            header_content = header_content .. string.format('#define %s R"(%s)"\n', key, raw_content)
                        elseif value:match('^".*"$') then
                            value = value:gsub("\\\\", "\\")
                            header_content = header_content .. string.format('#define %s %s\n', key, value)
                        else
                            value = value:gsub("\\", "\\\\")
                            value = value:gsub('"', '\\"')
                            header_content = header_content .. string.format('#define %s "%s"\n', key, value)
                        end
                    else
                        header_content = header_content .. string.format('#define %s %s\n', key, value)
                    end
                end
                
                local existing_content = io.readfile(header_path)
                if existing_content ~= header_content then
                    io.writefile(header_path, header_content)
                end
            end
            
            target:add("forceincludes", header_path)
        end
    end)
rule_end()
