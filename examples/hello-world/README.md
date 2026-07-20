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

For macOS:

```bash
west build -b qemu_x86 app
west build -t run
```

For hardware boards, replace the board name and set `ZEPHYR_SDK_TOOLCHAINS` in `mise.toml` to the toolchain your board needs.
