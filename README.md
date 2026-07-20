# mise-zephyr-sdk

A [mise](https://mise.jdx.dev) tool plugin for the [Zephyr RTOS SDK](https://github.com/zephyrproject-rtos/sdk-ng).

Handles, in one `mise use`:
- downloading the right "minimal" SDK tarball for your OS/arch
- running the SDK's `setup.sh` to pull toolchains and register the CMake package
- setting `ZEPHYR_TOOLCHAIN_VARIANT` and `ZEPHYR_SDK_INSTALL_DIR` so Zephyr's build system finds it automatically

Supports Linux (x86_64/arm64) and macOS (x86_64/arm64). Windows is not supported natively — use WSL.

## Install

```bash
mise plugin install zephyr-sdk https://github.com/klab365/mise-zephyr-sdk.git
ZEPHYR_SDK_TOOLCHAINS=x86_64-zephyr-elf mise use zephyr-sdk@0.17.4
```

For projects, commit the plugin source and tool version in `mise.toml` so users
and CI do not need a separate `mise plugin install` step:

```toml
[plugins]
zephyr-sdk = "https://github.com/klab365/mise-zephyr-sdk.git"

[tools]
zephyr-sdk = "0.17.4"
cmake = "3"
ninja = "latest"

[env]
ZEPHYR_SDK_TOOLCHAINS = "x86_64-zephyr-elf"
```

## Choosing which toolchains to install

You must configure the Zephyr SDK toolchains your project needs. The plugin does
not support `all`, because that downloads every cross toolchain and makes installs
very large.

Recommended project config:

```toml
[plugins]
zephyr-sdk = "https://github.com/klab365/mise-zephyr-sdk.git"

[env]
ZEPHYR_SDK_TOOLCHAINS = "x86_64-zephyr-elf"

[tools]
zephyr-sdk = "0.17.4"
```

Space-separate multiple toolchains: `"x86_64-zephyr-elf arm-zephyr-eabi"`.

## What this plugin does *not* do

It only manages the SDK itself. Your project's `mise.toml` still needs the rest of the toolchain as ordinary tools, e.g.:

```toml
[env]
ZEPHYR_SDK_TOOLCHAINS = "x86_64-zephyr-elf"

[tools]
zephyr-sdk = "0.17.4"
cmake = "3"
ninja = "latest"
uv = "0.11.6"
```

See `examples/hello-world` for a minimal Zephyr application using this plugin.

## Development

```bash
git clone https://github.com/klab365/mise-zephyr-sdk.git
mise plugin install zephyr-sdk ./mise-zephyr-sdk
mise ls-remote zephyr-sdk
ZEPHYR_SDK_TOOLCHAINS=x86_64-zephyr-elf mise install zephyr-sdk@0.17.4
```

After editing hooks, just re-run `ZEPHYR_SDK_TOOLCHAINS=x86_64-zephyr-elf mise install zephyr-sdk@<version> --force` — no build step.

## License

Apache-2.0
