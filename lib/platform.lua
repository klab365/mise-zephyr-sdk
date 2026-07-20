-- lib/platform.lua
-- Maps mise/vfox's RUNTIME.osType / RUNTIME.archType onto the platform
-- tokens used in Zephyr SDK release asset filenames, e.g.:
--   zephyr-sdk-0.17.4_linux-x86_64_minimal.tar.xz
--   zephyr-sdk-0.17.4_linux-aarch64_minimal.tar.xz
--   zephyr-sdk-0.17.4_macos-x86_64_minimal.tar.xz
--   zephyr-sdk-0.17.4_macos-aarch64_minimal.tar.xz

local M = {}

-- Returns the "<os>-<arch>" token used in sdk-ng release asset names,
-- or nil (plus an error message) if the platform isn't supported.
function M.asset_token()
	local os_type = RUNTIME.osType   -- "linux", "darwin", "windows"
	local arch = RUNTIME.archType    -- "amd64", "arm64", ...

	local os_token
	if os_type == "linux" then
		os_token = "linux"
	elseif os_type == "darwin" then
		os_token = "macos"
	else
		return nil, "the Zephyr SDK does not publish native Windows minimal tarballs; use WSL"
	end

	local arch_token
	if arch == "amd64" or arch == "x86_64" then
		arch_token = "x86_64"
	elseif arch == "arm64" or arch == "aarch64" then
		arch_token = "aarch64"
	else
		return nil, "unsupported architecture: " .. tostring(arch)
	end

	return os_token .. "-" .. arch_token
end

return M
