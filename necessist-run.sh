#!/bin/bash
set -e

source ~/.bashrc
source ~/.cargo/env
source .venv/bin/activate
cargo install necessist
necessist --verbose --framework foundry -- --ffi

date=$(date +"%Y-%m-%d")
aws s3 cp necessist.db s3://necessist-database/necessist-${date}.db