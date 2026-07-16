-- hooks/env_keys.lua
-- These are the two variables Zephyr's CMake build system actually looks
-- for -- no PATH manipulation needed, since west/CMake locate the
-- compilers themselves via ZEPHYR_SDK_INSTALL_DIR.

function PLUGIN:EnvKeys(ctx)
	local mainPath = ctx.path

	return {
		{ key = "ZEPHYR_TOOLCHAIN_VARIANT", value = "zephyr" },
		{ key = "ZEPHYR_SDK_INSTALL_DIR", value = mainPath },
	}
end
