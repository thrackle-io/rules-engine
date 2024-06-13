#!/bin/bash
set -eo pipefail
cd "$(dirname "$0")"

# function to get input from the user
promptForInput() {
  echo -n "Enter $1: "
  read var1
}

# Get the environment variables
source .env
# Set the colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

./foundry-version-check.sh

if [ -n $FOUNDRY_PROFILE ]; then
  RPC_URL="local"
fi
##### VALIDATE and RETRIEVE Entry variables
echo $RPC_URL
# prompt for rpc-url if it's blank
if test -z "$RPC_URL"; then
while true; do
  promptForInput "RPC_URL"

  if test -z "$var1"
  then    
    printf "RPC_URL cannot be blank\n"
  else
    RPC_URL="$var1"
    printf "RPC_URL= %s\n" "$RPC_URL"
    break
  fi
done
fi

# prompt for processor address if it's blank
echo $RULE_PROCESSOR_DIAMOND
if test -z "$RULE_PROCESSOR_DIAMOND"; then
while true; do
  promptForInput "RULE_PROCESSOR_DIAMOND"

  if test -z "$var1"
  then    
    printf "RULE_PROCESSOR_DIAMOND cannot be blank\n"
  else
    PROCESSOR_ADDRESS="$var1"
    break
  fi
done
fi

# prompt for APPLICATION_APP_MANAGER address if it's blank
echo $APPLICATION_APP_MANAGER
if test -z "$APPLICATION_APP_MANAGER"; then
while true; do
  promptForInput "APPLICATION_APP_MANAGER"

  if test -z "$var1"
  then    
    printf "APPLICATION_APP_MANAGER cannot be blank\n"
  else
    APPLICATION_APP_MANAGER="$var1"
    break
  fi
done
fi

###########################################################
echo "...Checking to make sure AppManager is deployed"
if [ $RPC_URL == "local" ]; then
  cast call $APPLICATION_APP_MANAGER "version()(string)" 1> /dev/null
else
  cast call $APPLICATION_APP_MANAGER "version()(string)" --rpc-url $RPC_URL 1> /dev/null
fi
ret_code=$?
if [ $ret_code == 1 ]; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - AppManager not deployed to "
    TEXT+=$RPC_URL
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

echo "...Checking to make sure the AppManager has a handler"
if [ $RPC_URL == "local" ]; then
  HANDLER=$(cast call $APPLICATION_APP_MANAGER 'applicationHandler()(address)')  
else
  HANDLER=$(cast call $APPLICATION_APP_MANAGER 'applicationHandler()(address)' --rpc-url $RPC_URL) 
fi
if test -z "$HANDLER"; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - No ApplicationHandler set in AppManager: "
    TEXT+=$APPLICATION_APP_MANAGER
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

echo "...Checking to make sure the handler is connected back to the AppManager"
if [ $RPC_URL == "local" ]; then
  HANDLER_APPLICATION_APP_MANAGER=$(cast call $HANDLER 'appManagerAddress()(address)')  
else
  HANDLER_APPLICATION_APP_MANAGER=$(cast call $HANDLER 'appManagerAddress()(address)' --rpc-url $RPC_URL) 
fi
COMP_HANDLER_APPLICATION_APP_MANAGER=$(echo "$HANDLER_APPLICATION_APP_MANAGER" | tr '[:lower:]' '[:upper:]')
COMP_APPLICATION_APP_MANAGER=$(echo "$APPLICATION_APP_MANAGER" | tr '[:lower:]' '[:upper:]')
if [ "$COMP_HANDLER_APPLICATION_APP_MANAGER" != "$COMP_APPLICATION_APP_MANAGER" ]; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - The Handler is not connected to the correct AppManager. Create a new ApplicationHandler and connect it to AppManager: " 
    TEXT+=$COMP_APPLICATION_APP_MANAGER
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

# This line will only be reached if all the commands above succeed
echo -e "$GREEN SUCCESS$NC - AppManager is successfully deployed and configured"

exit 0
