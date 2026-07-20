-- lib/toolchains.lua
-- Reads and validates the Zephyr SDK toolchain selection before any downloads.

local M = {}

function M.configured()
	local toolchains = os.getenv("MISE_TOOL_OPTS__TOOLCHAINS") or os.getenv("ZEPHYR_SDK_TOOLCHAINS")

	if toolchains == nil or toolchains:gsub("%s", "") == "" then
		error("zephyr-sdk: ZEPHYR_SDK_TOOLCHAINS must be configured; refusing to install every toolchain")
	end

	if toolchains:lower():gsub(",", " "):match("%f[%w]all%f[%W]") then
		error("zephyr-sdk: `all` is not allowed; configure only the Zephyr SDK toolchains your project needs")
	end

	return toolchains
end

return M
