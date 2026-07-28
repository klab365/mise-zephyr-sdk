-- hooks/post_install.lua
-- The "minimal" tarball only contains setup metadata; the actual cross
-- toolchains, and host tools in newer SDK releases, are release assets
-- downloaded after extraction. The plugin exports ZEPHYR_SDK_INSTALL_DIR, so
-- the SDK does not need CMake user-package registration during install.
--
-- Which toolchains to install is controlled by the ZEPHYR_SDK_TOOLCHAINS env var
-- (space or comma separated, e.g. "x86_64-zephyr-elf arm-zephyr-eabi"). This is
-- required to avoid accidentally downloading every Zephyr SDK toolchain.
--
--   [env]
--   ZEPHYR_SDK_TOOLCHAINS = "x86_64-zephyr-elf"

local context = require("context")
local platform = require("platform")
local toolchains = require("toolchains")

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function command_succeeds(cmd)
	local ok = os.execute(cmd)
	return ok == true or ok == 0
end

local function asset_exists(url)
	return command_succeeds("curl -fsIL --retry 3 --retry-delay 2 " .. shell_quote(url) .. " >/dev/null 2>&1")
end

local function install_version(ctx, path)
	local version = ctx.version or ctx.toolVersion or ctx.tool_version or ctx.versionName
	if version ~= nil and version ~= "" then
		return version
	end

	version = path:match("([^/]+)/*$")
	if version ~= nil and version ~= "" then
		return version
	end

	error("zephyr-sdk: hook context does not include a version")
end

local function parse_toolchains(value)
	local names = {}

	for toolchain in value:gsub(",", " "):gmatch("%S+") do
		if not toolchain:match("^[%w_-]+$") then
			error("zephyr-sdk: invalid toolchain name: " .. toolchain)
		end

		table.insert(names, toolchain)
	end

	if #names == 0 then
		error("zephyr-sdk: toolchains must not be empty")
	end

	return names
end

local function supported_toolchains(path)
	local file, err = io.open(path .. "/sdk_toolchains", "r")
	if not file then
		file, err = io.open(path .. "/sdk_gnu_toolchains", "r")
	end

	if not file then
		error("zephyr-sdk: failed to read SDK toolchain list: " .. tostring(err))
	end

	local supported = {}
	for toolchain in file:read("*a"):gmatch("%S+") do
		supported[toolchain] = true
	end
	file:close()

	return supported
end

local function validate_toolchains(path, names)
	local supported = supported_toolchains(path)
	for _, toolchain in ipairs(names) do
		if not supported[toolchain] then
			error("zephyr-sdk: unknown toolchain " .. toolchain)
		end
	end
end

local function toolchain_asset_names(host, toolchain)
	return {
		{ filename = "toolchain_" .. host .. "_" .. toolchain .. ".tar.xz", install_dir = "" },
		{ filename = "toolchain_gnu_" .. host .. "_" .. toolchain .. ".tar.xz", install_dir = "gnu" },
	}
end

local function install_toolchain(path, version, host, toolchain)
	if command_succeeds("test -d " .. shell_quote(path .. "/" .. toolchain))
		or command_succeeds("test -d " .. shell_quote(path .. "/gnu/" .. toolchain)) then
		return
	end

	if not command_succeeds("command -v curl >/dev/null 2>&1") then
		error("zephyr-sdk: curl is required to download SDK toolchains")
	end

	for _, asset in ipairs(toolchain_asset_names(host, toolchain)) do
		local install_dir = path
		if asset.install_dir ~= "" then
			install_dir = path .. "/" .. asset.install_dir
			if not command_succeeds("mkdir -p " .. shell_quote(install_dir)) then
				error("zephyr-sdk: failed to create toolchain directory " .. asset.install_dir)
			end
		end

		local filename = asset.filename
		local url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v" .. version .. "/" .. filename
		local archive = install_dir .. "/" .. filename
		local cmd = "cd " .. shell_quote(install_dir)
			.. " && curl -fsL --progress-bar -o " .. shell_quote(archive) .. " " .. shell_quote(url)
			.. " && tar xf " .. shell_quote(archive)
			.. " && rm -f " .. shell_quote(archive)

		if command_succeeds(cmd) then
			return
		end

		command_succeeds("rm -f " .. shell_quote(archive))
	end

	error("zephyr-sdk: failed to install toolchain " .. toolchain)
end

local function install_hosttools(path, version, host)
	if command_succeeds("test -x " .. shell_quote(path .. "/usr/bin/openocd"))
		and command_succeeds("test -x " .. shell_quote(path .. "/usr/bin/qemu-system-arm")) then
		return
	end

	if not command_succeeds("command -v curl >/dev/null 2>&1") then
		error("zephyr-sdk: curl is required to download SDK hosttools")
	end

	local filename = "hosttools_" .. host .. ".tar.xz"
	local url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v" .. version .. "/" .. filename
	if not asset_exists(url) then
		return
	end

	local archive = path .. "/" .. filename
	local cmd = "cd " .. shell_quote(path)
		.. " && curl -fsL --retry 3 --retry-delay 2 --progress-bar -o " .. shell_quote(archive) .. " " .. shell_quote(url)
		.. " && tar xf " .. shell_quote(archive)
		.. " && rm -f " .. shell_quote(archive)

	if not command_succeeds(cmd) then
		command_succeeds("rm -f " .. shell_quote(archive))
		error("zephyr-sdk: failed to install hosttools")
	end
end

function PLUGIN:PostInstall(ctx)
	local path = context.install_path(ctx)
	local version = install_version(ctx, path)

	if RUNTIME.osType == "windows" then
		error("zephyr-sdk: native Windows install is not supported by this plugin; use WSL")
	end

	local host, perr = platform.asset_token()
	if not host then
		error(perr)
	end

	local configured = toolchains.configured()
	local names = parse_toolchains(configured)
	validate_toolchains(path, names)

	for _, toolchain in ipairs(names) do
		install_toolchain(path, version, host, toolchain)
	end

	install_hosttools(path, version, host)
end
