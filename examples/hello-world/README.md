# Hello World Example

Minimal Zephyr application showing how to use `mise-zephyr-sdk` with a normal `west` workspace.

This plugin installs the Zephyr SDK only. It does not install Zephyr itself.

## Usage

From this directory:

```bash
mise trust
mise install
west init -m https://github.com/zephyrproject-rtos/zephyr --mr v4.2.0 zephyr-workspace
cd zephyr-workspace
west update
uv pip install --system -r zephyr/scripts/requirements.txt
west zephyr-export
west build -b native_sim/native/64 ../app
west build -t run
```

For hardware boards, replace `native_sim/native/64` with your board name and set `ZEPHYR_SDK_TOOLCHAINS` in `mise.toml` to the toolchain your board needs.
