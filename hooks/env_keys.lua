-- hooks/env_keys.lua
-- Zephyr/CMake locate the SDK via ZEPHYR_SDK_INSTALL_DIR. Export only SDK
-- directories in PATH so mise does not create shims for inherited binaries.

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

function PLUGIN:EnvKeys(ctx)
	local mainPath = context.install_path(ctx)

	return {
		{ key = "ZEPHYR_TOOLCHAIN_VARIANT", value = "zephyr" },
		{ key = "ZEPHYR_SDK_INSTALL_DIR", value = mainPath },
		{ key = "PATH", value = table.concat(sdk_bin_paths(mainPath), ":") },
	}
end
