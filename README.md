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
mise use zephyr-sdk@0.17.4
```

## Choosing which toolchains to install

By default `setup.sh` is run with `-t all`, which downloads every cross toolchain (large). To install only what you need, set `ZEPHYR_SDK_TOOLCHAINS` **before** installing, e.g. in your project's `mise.toml`:

```toml
[env]
ZEPHYR_SDK_TOOLCHAINS = "x86_64-zephyr-elf"

[tools]
zephyr-sdk = "0.17.4"
```

Space-separate multiple toolchains: `"x86_64-zephyr-elf arm-zephyr-eabi"`.

## What this plugin does *not* do

It only manages the SDK itself. Your project's `mise.toml` still needs the rest of the toolchain as ordinary tools, e.g.:

```toml
[tools]
zephyr-sdk = "0.17.4"
cmake = "3"
ninja = "latest"
uv = "0.11.6"
"pipx:west" = "1.5.0"
```

See `examples/hello-world` for a minimal Zephyr application using this plugin.

## Development

```bash
git clone https://github.com/klab365/mise-zephyr-sdk.git
mise plugin install zephyr-sdk ./mise-zephyr-sdk
mise ls-remote zephyr-sdk
mise install zephyr-sdk@0.17.4
```

After editing hooks, just re-run `mise install zephyr-sdk@<version> --force` — no build step.

## License

Apache-2.0
