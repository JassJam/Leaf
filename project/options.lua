-- enable logging for the project
option("with-logging", {
    showmenu = true,
    default = true,
    description = "Enable logging"
})

-- enable samples for the project
option("with-samples", {
    showmenu = true,
    default = true,
    description = "Build samples"
})

-- enable tests for the project
option("with-tests", {
    showmenu = true,
    default = true,
    description = "Build tests"
})

-- set the type of graphics backend to use
option("gfx-backend-vulkan", {
    showmenu = true,
    default = true,
    description = "Enable Vulkan graphics backend"
})
option("gfx-backend-d3d12", {
    showmenu = true,
    default = true,
    description = "Enable Direct3D 12 graphics backend"
})
option("gfx-backend-d3d11", {
    showmenu = true,
    default = true,
    description = "Enable Direct3D 11 graphics backend"
})
option("gfx-backend-opengl", {
    showmenu = true,
    default = false,
    description = "Enable OpenGL graphics backend"
})

-- deterministic seed used to obfuscate runtime C API export symbols
option("capi-export-seed", {
    showmenu = true,
    default = "",
    description = "Seed for deterministic C API export obfuscation (empty disables)"
})
