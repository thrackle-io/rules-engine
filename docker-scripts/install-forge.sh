#!/bin/bash
set -e

source ~/.bashrc

# Pin foundry to a known-good commit hash. Awk ignores comments in `foundry.lock`
#foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)
foundryup --version nightly-2e3c197afc341c0f4adbb9dbe09fc04ebb9b7a5d