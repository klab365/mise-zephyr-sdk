# AGENTS.md

## Repo Shape
- This is a mise/vfox plugin for the Zephyr RTOS SDK, not a Zephyr app; plugin hooks are in `hooks/`, shared Lua helpers are in `lib/`, and plugin metadata is `metadata.lua`.
- `examples/hello-world` is the integration fixture used by CI; it is a normal `west` workspace and app, not the plugin implementation.
- The plugin installs the Zephyr SDK only. Zephyr itself, `west`, CMake, Ninja, and Python dependencies are supplied by the consuming project or the example's `mise.toml`/`run.sh`.

## Plugin Behavior To Preserve
- `ZEPHYR_SDK_TOOLCHAINS` or `MISE_TOOL_OPTS__TOOLCHAINS` is required before install; `all` is intentionally rejected to avoid downloading every SDK toolchain.
- `hooks/pre_install.lua` resolves the host-specific `*_minimal.tar.xz` asset from GitHub releases; `hooks/post_install.lua` downloads selected toolchain assets after extraction.
- `hooks/env_keys.lua` exports only `ZEPHYR_TOOLCHAIN_VARIANT=zephyr` and `ZEPHYR_SDK_INSTALL_DIR`; do not add PATH setup unless Zephyr's lookup behavior changes.
- Native Windows is unsupported by design; point users to WSL instead of adding Windows asset guesses.
- GitHub API helpers honor `GITHUB_TOKEN`; use it locally if release metadata calls hit rate limits.

## Development Commands
- Install this checkout as a local plugin: `mise plugin install zephyr-sdk ./mise-zephyr-sdk` from this repo's parent, or `mise plugin install zephyr-sdk "file://$PWD"` from the repo root.
- List release-backed versions: `mise ls-remote zephyr-sdk`.
- Focused install check after hook changes: `ZEPHYR_SDK_TOOLCHAINS=x86_64-zephyr-elf mise install zephyr-sdk@0.17.4 --force`.
- There is no separate build step for hook edits; re-run `mise install ... --force` to exercise changed Lua hooks.

## Integration Verification
- CI's install job sequence is: install local plugin, in `examples/hello-world` run `mise trust`, `mise use --yes zephyr-sdk@<version>`, then `mise install`, then verify `ZEPHYR_SDK_INSTALL_DIR`, `ZEPHYR_TOOLCHAIN_VARIANT=zephyr`, and `sdk_version`.
- Full example run from `examples/hello-world`: `./run.sh`.
- `./run.sh` uses `native_sim/native/64` on Linux and `qemu_x86` elsewhere; macOS needs `qemu-system-i386` available or the run target fails.
- To test the Zephyr 4.4 / SDK 1.0 path used in CI: from `examples/hello-world`, run `mise use zephyr-sdk@1.0.0` then `ZEPHYR_REVISION=v4.4.0 ./run.sh`.
- The example creates ignored directories under `examples/hello-world` (`.venv`, `.west`, `build`, `modules`, `tools`, `zephyr`); do not commit generated workspace contents.
