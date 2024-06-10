  #!/bin/bash

INPUT=${1:-'Test'}
CONVERTED=$(echo $INPUT | xxd -p)
TRUNCATED=$(echo ${CONVERTED:0:8})
DIGITS=$(echo "${#TRUNCATED}")
DIFF="$((64-$DIGITS))"
OUTPUT=$(echo "$TRUNCATED * 10^$DIFF" | bc)
echo 0x$OUTPUT