#!/bin/bash
set -e

source ~/.bashrc
source ~/.cargo/env
source .venv/bin/activate
cargo install necessist
git checkout external
necessist --verbose --framework foundry -- --ffi