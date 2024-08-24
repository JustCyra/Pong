--- @class BuildFile
--- Basic Settings
--- @field name string Name of the executable
--- @field developer string Developer name for file metadata
--- @field output? string Output location<br>Defaults to `$SAVE_DIRECTORY`
--- @field version string Version of the executable. Used to name the folder in output
--- @field love string Version of LÖVE to use. Must match github releases!
--- @field ignore string[] Folders/Files to ignore in your project
--- @field icon string 256x256px PNG icon path for executable, will be converted for you
--- Optional Settings
--- @field use32bit? boolean Set `true` to build Windows 32-bit alongside 64-bit
--- @field identifier? string MacOS team identifier. Defaults to `game.developer.name`
--- @field libs? { BuildPlatforms: string[], all: string[] } Files to place in output directly rather then fuse
--- @field hooks? { before_build: string, after_build: string } Hooks to run commands via `os.execute` before or after building
--- @field platforms? BuildPlatforms[] Specify platforms for which to build for

--- @enum BuildPlatforms
local BuildPlatforms = {
    windows = 'windows',
    linux = 'linux',
    macos = 'macos'
}

return {
    name = 'Pong',
    developer = 'Cyra',
    icon = 'resources/images/icon.png',
    version = '0.1',
    love = '11.5',
    output = '../.builds',
    ignore = {
        'build.lua',
        'engine/type',
    },
    use32bit = true,
    platforms = {
        BuildPlatforms.windows,
        BuildPlatforms.linux
    },
    hooks = {
        before_build = '../.scripts/prepare_build.sh',
        after_build = '../.scripts/finish_build.sh'
    }
} --[[@as BuildFile]]