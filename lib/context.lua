-- lib/context.lua
-- Compatibility helpers for hook context fields exposed by mise/vfox.

local M = {}

function M.install_path(ctx)
	local path = ctx.path or ctx.rootPath or ctx.install_path or ctx.installPath or ctx.install_dir or ctx.installDir

	if path == nil or path == "" then
		error("zephyr-sdk: hook context does not include an install path")
	end

	return path
end

return M
