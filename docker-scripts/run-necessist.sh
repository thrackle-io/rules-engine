#!/bin/bash
set -e

source .venv/bin/activate
necessist --verbose --framework foundry -- --ffi

date=$(date +"%Y-%m-%d")
aws s3 cp necessist.db s3://necessist-database/necessist-${date}.db