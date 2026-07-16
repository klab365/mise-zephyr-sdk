-- metadata.lua
PLUGIN = {
	name = "zephyr-sdk",
	version = "0.1.0",
	description = "Zephyr RTOS Software Development Kit: cross toolchains, host tools and QEMU binaries needed to build Zephyr applications",
	author = "burak/klab365",
	homepage = "https://github.com/klab365/mise-zephyr-sdk",
	license = "Apache-2.0",

	-- No system dependencies to declare: this plugin only downloads a
	-- prebuilt archive and runs the SDK's own setup.sh, which mise/vfox
	-- runs directly (no compiler toolchain needed to install the plugin).
}
