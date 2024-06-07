  #!/bin/bash

  INPUT="Test"
  
  for var in "$@"
  do
    if [[ "$var" = "-s" ]]
    then
      settingInput=true
    elif $settingInput;
    then
      INPUT="$var"
      settingInput=false
    elif [[ "$var" = "--help" ]]
    then
      echo "--------------------------------------------------"
      echo "Possible Arguments:"
      echo "-s: The string to convert"
      echo "--------------------------------------------------"
      exit
    fi
  done

CONVERTED=$(echo $INPUT | xxd -p)
TRUNCATED=$(echo ${CONVERTED:0:8})
DIGITS=$(echo "${#TRUNCATED}")
DIFF="$((64-$DIGITS))"
OUTPUT=$(echo "$TRUNCATED * 10^$DIFF" | bc)
echo 0x$OUTPUT