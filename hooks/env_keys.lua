-- hooks/env_keys.lua
-- Zephyr/CMake locate the SDK via ZEPHYR_SDK_INSTALL_DIR, and PATH exposes
-- the installed SDK compiler and host tool binaries for direct shell use.

local context = require("context")

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function sdk_bin_paths(mainPath)
	local paths = {}
	local command = "for dir in "
		.. shell_quote(mainPath .. "/bin")
		.. " "
		.. shell_quote(mainPath .. "/usr/bin")
		.. " "
		.. shell_quote(mainPath .. "/opt") .. "/*/bin"
		.. " "
		.. shell_quote(mainPath .. "/hosttools/sysroots") .. "/*/usr/bin"
		.. " "
		.. shell_quote(mainPath .. "/hosttools/sysroots") .. "/*/usr/*/bin"
		.. " "
		.. shell_quote(mainPath) .. "/*/bin"
		.. " "
		.. shell_quote(mainPath .. "/gnu") .. "/*/bin"
		.. "; do [ -d \"$dir\" ] && printf '%s\n' \"$dir\"; done"
	local handle = io.popen(command, "r")

	if handle == nil then
		return paths
	end

	for path in handle:lines() do
		table.insert(paths, path)
	end
	handle:close()

	return paths
end

local function prepend_path(paths, current)
	local seen = {}
	local values = {}

	local function add(path)
		if path ~= nil and path ~= "" and not seen[path] then
			seen[path] = true
			table.insert(values, path)
		end
	end

	for _, path in ipairs(paths) do
		add(path)
	end

	for path in tostring(current or ""):gmatch("[^:]+") do
		add(path)
	end

	return table.concat(values, ":")
end

function PLUGIN:EnvKeys(ctx)
	local mainPath = context.install_path(ctx)
	local path = prepend_path(sdk_bin_paths(mainPath), os.getenv("PATH"))

	return {
		{ key = "ZEPHYR_TOOLCHAIN_VARIANT", value = "zephyr" },
		{ key = "ZEPHYR_SDK_INSTALL_DIR", value = mainPath },
		{ key = "PATH", value = path },
	}
end
