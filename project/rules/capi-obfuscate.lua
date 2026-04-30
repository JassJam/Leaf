-- rule to obfuscate C API exports using generated wrappers
-- usage:
--   xmake f --capi-export-seed=<seed>
rule("capi-obfuscate")
    on_load(function(target)
        local generated_root = path.join(os.projectdir(), "build", "generated", "capi", target:name())
        local map_header_rel = path.join("coffee", "base", "CapiExportMap.h")
        local map_header = path.join(generated_root, map_header_rel)
        local wrapper_cpp = path.join(generated_root, "CapiExportWrappers.cpp")
        os.mkdir(generated_root)
        os.mkdir(path.join(generated_root, "coffee"))
        os.mkdir(path.join(generated_root, "coffee", "base"))
        if not os.isfile(map_header) then
            io.writefile(map_header,
                         "#pragma once\n\n// Bootstrap fallback generated CAPI export map.\n")
        end
        if not os.isfile(wrapper_cpp) then
            io.writefile(wrapper_cpp,
                         "// Bootstrap fallback generated CAPI export wrappers.\n")
        end

        local seed = get_config("capi-export-seed")
        if not seed or seed == "" then
            return
        end

        local include_root = path.join(target:scriptdir(), "include", "coffee")
        if not os.isdir(include_root) then
            return
        end

        local header_files = os.files(path.join(include_root, "**", "capi", "*.h"))
        if #header_files == 0 then
            return
        end

        local function _trim(text)
            return (text:gsub("^%s+", ""):gsub("%s+$", ""))
        end

        local function _hash_string(text)
            local hash = 0
            for i = 1, #text do
                local byte = string.byte(text, i)
                hash = (hash * 131 + byte + i) % 4294967291
            end
            return hash
        end

        local function _to_base36(value)
            local alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"
            local base = #alphabet
            if value == 0 then
                return "0"
            end

            local chars = {}
            local current = value
            while current > 0 do
                local index = (current % base) + 1
                table.insert(chars, 1, alphabet:sub(index, index))
                current = math.floor(current / base)
            end
            return table.concat(chars)
        end

        local function _split_top_level_by_comma(text)
            local result = {}
            local start_index = 1
            local paren_depth = 0

            for i = 1, #text do
                local ch = text:sub(i, i)
                if ch == "(" then
                    paren_depth = paren_depth + 1
                elseif ch == ")" then
                    paren_depth = paren_depth - 1
                elseif ch == "," and paren_depth == 0 then
                    table.insert(result, _trim(text:sub(start_index, i - 1)))
                    start_index = i + 1
                end
            end

            table.insert(result, _trim(text:sub(start_index)))
            return result
        end

        local function _parse_capi_declarations(content)
            local decls = {}
            local pos = 1

            while true do
                local macro_start = content:find("COFFEE_ENGINE_CAPI%s*%(", pos)
                if not macro_start then
                    break
                end

                local first_paren = content:find("%(", macro_start)
                local depth = 0
                local i = first_paren
                while i <= #content do
                    local ch = content:sub(i, i)
                    if ch == "(" then
                        depth = depth + 1
                    elseif ch == ")" then
                        depth = depth - 1
                        if depth == 0 then
                            break
                        end
                    end
                    i = i + 1
                end

                local body = content:sub(first_paren + 1, i - 1)
                local parts = _split_top_level_by_comma(body)
                if #parts >= 3 then
                    local return_type = _trim(parts[1])
                    local name = _trim(parts[2])
                    local args = _trim(table.concat(parts, ", ", 3))
                    table.insert(decls, {
                        return_type = return_type,
                        name = name,
                        args = args,
                    })
                end

                pos = i + 1
            end

            return decls
        end

        local function _extract_arg_names(args)
            local arg_list = _trim(args)
            if arg_list:sub(1, 1) == "(" and arg_list:sub(-1, -1) == ")" then
                arg_list = _trim(arg_list:sub(2, -2))
            end

            if arg_list == "" or arg_list == "void" then
                return {}
            end

            local names = {}
            local params = _split_top_level_by_comma(arg_list)
            for _, param in ipairs(params) do
                local name = _trim(param):match("([%a_][%w_]*)%s*$")
                if not name then
                    raise("unable to parse parameter name for CAPI wrapper: " .. param)
                end
                table.insert(names, name)
            end
            return names
        end

        local function _hash_function(used_aliases, text)
            local hash = _hash_string(seed .. ":" .. text)
            local alias = "x" .. _to_base36(hash)
            while used_aliases[alias] do
                hash = (hash + 97) % 4294967291
                alias = "x" .. _to_base36(hash)
            end
            return alias
        end

        table.sort(header_files)

        local declarations = {}
        local declaration_set = {}
        local include_headers = {}
        for _, file in ipairs(header_files) do
            local content = io.readfile(file) or ""
            local parsed = _parse_capi_declarations(content)
            for _, decl in ipairs(parsed) do
                if not declaration_set[decl.name] then
                    declaration_set[decl.name] = true
                    table.insert(declarations, decl)
                end
            end

            local relative_to_include = path.relative(file, path.join(target:scriptdir(), "include"))
            table.insert(include_headers, relative_to_include)
        end

        if #declarations == 0 then
            return
        end

        table.sort(declarations, function(a, b)
            return a.name < b.name
        end)
        table.sort(include_headers)

        local aliases = {}
        local used_aliases = {}
        for _, decl in ipairs(declarations) do
            local alias = _hash_function(used_aliases, decl.name)
            used_aliases[alias] = true
            aliases[decl.name] = alias
        end

        local map_lines = {
            "#pragma once",
            "",
            "// Auto-generated by xmake rule: capi-obfuscate",
            "",
        }

        for _, decl in ipairs(declarations) do
            table.insert(map_lines, "#define _" .. decl.name .. " " .. aliases[decl.name])
        end

        local map_content = table.concat(map_lines, "\n")
        if io.readfile(map_header) ~= map_content then
            io.writefile(map_header, map_content)
        end

        local wrapper_lines = {
            "// Auto-generated by xmake rule: capi-obfuscate",
            "#include <coffee/base/api.h>",
            "",
        }

        for _, include_header in ipairs(include_headers) do
            table.insert(wrapper_lines, "#include <" .. include_header:gsub("\\", "/") .. ">")
        end

        table.insert(wrapper_lines, "")
        table.insert(wrapper_lines, "extern \"C\"")
        table.insert(wrapper_lines, "{")

        for _, decl in ipairs(declarations) do
            local arg_names = _extract_arg_names(decl.args)
            local call_args = table.concat(arg_names, ", ")
            local wrapper_name = "_" .. decl.name

            table.insert(wrapper_lines, "COFFEE_ENGINE_API " .. decl.return_type .. " " .. wrapper_name .. " " .. decl.args)
            table.insert(wrapper_lines, "{")
            if decl.return_type == "void" then
                if call_args == "" then
                    table.insert(wrapper_lines, "    " .. decl.name .. "();")
                else
                    table.insert(wrapper_lines, "    " .. decl.name .. "(" .. call_args .. ");")
                end
            else
                if call_args == "" then
                    table.insert(wrapper_lines, "    return " .. decl.name .. "();")
                else
                    table.insert(wrapper_lines, "    return " .. decl.name .. "(" .. call_args .. ");")
                end
            end
            table.insert(wrapper_lines, "}")
            table.insert(wrapper_lines, "")
        end

        table.insert(wrapper_lines, "}")
        table.insert(wrapper_lines, "")

        local wrapper_content = table.concat(wrapper_lines, "\n")
        if io.readfile(wrapper_cpp) ~= wrapper_content then
            io.writefile(wrapper_cpp, wrapper_content)
        end

        target:add("includedirs", generated_root, {public = true, before = true})
        target:add("files", wrapper_cpp)
    end)
rule_end()