#!/bin/bash
set -e

source ~/.bashrc

# Pin foundry to a known-good commit hash. Awk ignores comments in `foundry.lock`
#foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)
foundryup --version nightly-7469d79cca59e0bb5f23563ac5a6bd5f2ec8c5e4