#!/usr/bin/env bash
set -euo pipefail

if [ "${RUNNER_OS:-$(uname -s)}" = "Linux" ]; then
  board="native_sim/native/64"
else
  board="qemu_x86"
fi

if [ "$board" = "qemu_x86" ] && ! command -v qemu-system-i386 >/dev/null 2>&1; then
  if [ "${CI:-}" = "true" ] && command -v brew >/dev/null 2>&1; then
    brew install qemu
  else
    echo "qemu-system-i386 is required to run $board" >&2
    exit 1
  fi
fi

echo "### Install mise and dependencies"
mise trust
mise install
eval "$(mise env -s bash)"


echo "### Install python dependencies"
uv venv .venv
uv pip install --python .venv/bin/python west==1.5.0
export PATH="$(pwd)/.venv/bin:$PATH"

west init -l .
west update

export ZEPHYR_BASE="$(west list zephyr -f '{abspath}')"
test -d "$ZEPHYR_BASE"

uv pip install --python .venv/bin/python -r requirements.txt

export ZEPHYR_PYTHON="$(pwd)/.venv/bin/python"

west zephyr-export
west build -b "$board" app

if [ "$board" = "qemu_x86" ]; then
  set +e
  west build -t run
  status=$?
  set -e

  if [ "$status" -ne 1 ]; then
    exit "$status"
  fi
else
  west build -t run
fi
