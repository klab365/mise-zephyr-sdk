# Hello World Example

Minimal Zephyr application showing how to use `mise-zephyr-sdk` with a normal `west` workspace.

This plugin installs the Zephyr SDK only. It does not install Zephyr itself.
The plugin source and required Zephyr SDK toolchain are declared in `mise.toml`.

## Usage

From this directory:

Use `native_sim/native/64` on Linux. On macOS, use `qemu_x86`.

```bash
./run.sh
```

The checked-in default uses Zephyr `v4.2.0` with Zephyr SDK `0.17.4`. To try
Zephyr `v4.4.0`, use an SDK from the `1.0` line:

```bash
mise use zephyr-sdk@1.0.0
ZEPHYR_REVISION=v4.4.0 ./run.sh
```

For macOS:

```bash
west build -b qemu_x86 app
west build -t run
```

For hardware boards, replace the board name and set `ZEPHYR_SDK_TOOLCHAINS` in `mise.toml` to the toolchain your board needs.
