# mise-zephyr-sdk

A [mise](https://mise.jdx.dev) tool plugin for the [Zephyr RTOS SDK](https://github.com/zephyrproject-rtos/sdk-ng).

Handles, in one `mise use`:
- downloading the right "minimal" SDK tarball for your OS/arch
- downloading the configured SDK toolchains directly
- setting `ZEPHYR_TOOLCHAIN_VARIANT` and `ZEPHYR_SDK_INSTALL_DIR` so Zephyr's build system finds it automatically
- adding installed SDK compiler and host tool `bin` directories to `PATH` for direct shell use

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
python = "3.13"
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
python = "3.13"
zephyr-sdk = "0.17.4"
```

Space-separate multiple toolchains: `"x86_64-zephyr-elf arm-zephyr-eabi"`.

## Hosttools prerequisites

SDK releases publish hosttools as separate assets. For `0.17.4`, hosttools are
Linux-only. Starting with `1.0.0`, Zephyr also publishes macOS and Windows
hosttools; this plugin supports Linux and macOS, but not native Windows.

On Linux, the hosttools asset contains a Zephyr/Yocto `.sh` installer that
relocates QEMU, OpenOCD, and related host tools into the mise install directory.

That installer requires these commands at SDK install time:

- `python3` or `python2`
- `xz`
- `file`
- `xargs`

If your project only needs to compile firmware and does not need SDK-provided
QEMU/OpenOCD/BOSSA host tools, skip hosttools:

```toml
[env]
ZEPHYR_SDK_TOOLCHAINS = "x86_64-zephyr-elf"
ZEPHYR_SDK_SKIP_HOSTTOOLS = "1"
```

With hosttools skipped, the plugin still installs SDK metadata and the selected
compiler toolchains, but it does not require Python or the Linux relocation
utilities listed above. To add hosttools later, remove `ZEPHYR_SDK_SKIP_HOSTTOOLS`
and reinstall the SDK:

```bash
mise install --force zephyr-sdk
```

`python` may be managed by mise, but it must be installed before `zephyr-sdk`.
In project `mise.toml`, declare `python` as the first entry in `[tools]`, before
`zephyr-sdk`, then install normally. If needed, bootstrap Python explicitly:

```bash
mise install python
mise install zephyr-sdk
```

Minimal Ubuntu/devcontainer images often omit `file`. Install the Linux OS
utilities in the container image:

```Dockerfile
RUN apt-get update && apt-get install -y \
    file \
    xz-utils \
    findutils \
    && rm -rf /var/lib/apt/lists/*
```

The plugin does not install OS packages itself. If the upstream hosttools
installer fails, the plugin leaves `hosttools-install.log` in the SDK install
directory and reports its path.

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
