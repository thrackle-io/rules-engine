#!/bin/bash
set -e

# Using cargo directly to compile foundry from github
# --rev pins foundry to a known-good commit hash. Awk ignores comments in `foundry.lock`
cargo install \
	--git https://github.com/foundry-rs/foundry \
	--rev $(awk '$1~/^[^#]/' foundry.lock) \
	--profile local \
	--locked forge cast chisel anvil