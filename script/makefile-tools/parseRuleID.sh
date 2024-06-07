#!/bin/bash

OUTPUT_JSON=$(sed -n 's/logs //p' makefile_output.txt)

PARSED_RULE_ID=$(echo $OUTPUT_JSON | jq '.[0].topics[2]' | tr -d '"')
RULE_ID="${PARSED_RULE_ID: -1}"

rm makefile_output.txt

echo Your rule id is $RULE_ID
