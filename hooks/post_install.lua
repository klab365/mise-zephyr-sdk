-- hooks/post_install.lua
-- The "minimal" tarball only contains host tools + setup.sh; the actual
-- cross toolchains are pulled down by running setup.sh, which also
-- registers the SDK as a CMake package (what Zephyr's build system uses
-- to find it via ZEPHYR_SDK_INSTALL_DIR).
--
-- Which toolchains to install is controlled by the ZEPHYR_SDK_TOOLCHAINS
-- env var (space or comma separated, e.g. "x86_64-zephyr-elf arm-zephyr-eabi").
-- Falls back to "all" if unset -- override it in your project's mise.toml:
--
--   [env]
--   ZEPHYR_SDK_TOOLCHAINS = "x86_64-zephyr-elf"

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function setup_toolchain_args(value)
	local args = {}

	for toolchain in value:gsub(",", " "):gmatch("%S+") do
		if not toolchain:match("^[%w_-]+$") then
			error("zephyr-sdk: invalid toolchain name in ZEPHYR_SDK_TOOLCHAINS: " .. toolchain)
		end

		table.insert(args, shell_quote(toolchain))
	end

	if #args == 0 then
		error("zephyr-sdk: ZEPHYR_SDK_TOOLCHAINS must not be empty")
	end

	return table.concat(args, " ")
end

function PLUGIN:PostInstall(ctx)
	local path = ctx.path

	if RUNTIME.osType == "windows" then
		error("zephyr-sdk: native Windows install is not supported by this plugin; use WSL")
	end

	local toolchains = os.getenv("ZEPHYR_SDK_TOOLCHAINS") or "all"
	local toolchain_args = setup_toolchain_args(toolchains)

	local cmd = "chmod +x " .. shell_quote(path .. "/setup.sh") .. " && cd " .. shell_quote(path) .. " && ./setup.sh -c -h -t " .. toolchain_args

	local ok = os.execute(cmd)
	if ok ~= true and ok ~= 0 then
		error("zephyr-sdk: setup.sh failed (toolchains=" .. toolchains .. ")")
	end
end
