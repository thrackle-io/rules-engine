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

script/foundryScripts/foundry-version-check.sh

if [ -n $FOUNDRY_PROFILE ]; then
  RPC_URL="local"
fi

##### VALIDATE and RETRIEVE Entry variables
echo $RPC_URL
# prompt for rpc-url if it's blank
if [[ -z $RPC_URL ]]; then
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

# prompt for APPLICATION_ERC721_ADDRESS_1 address if it's blank
echo $APPLICATION_ERC721_ADDRESS_1
if [[ -z "$APPLICATION_ERC721_ADDRESS_1" ]]; then
  while true; do
    promptForInput "APPLICATION_ERC721_ADDRESS_1"

    if test -z "$var1"
    then    
      printf "APPLICATION_ERC721_ADDRESS_1 cannot be blank\n"
    else
      APPLICATION_ERC721_ADDRESS_1="$var1"
      break
    fi
  done
fi

###########################################################
echo "...Checking to make sure ERC721 is deployed..."
if [ $RPC_URL == "local" ]; then
  cast call $APPLICATION_ERC721_ADDRESS_1 "getHandlerAddress()(address)" 1> /dev/null
else
  cast call $APPLICATION_ERC721_ADDRESS_1 "getHandlerAddress()(address)" --rpc-url $RPC_URL 1> /dev/null
fi
ret_code=$?
if [ $ret_code == 1 ]; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - ERC721:""$APPLICATION_ERC721_ADDRESS_1"" not deployed to ""$RPC_URL"
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

echo "...Checking to make sure ERC721 has a handler..."
if [ $RPC_URL == "local" ]; then
  HANDLER=$(cast call $APPLICATION_ERC721_ADDRESS_1 'getHandlerAddress()(address)')  
else
  HANDLER=$(cast call $APPLICATION_ERC721_ADDRESS_1 'getHandlerAddress()(address)' --rpc-url $RPC_URL) 
fi
if test -z "$HANDLER"; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - No handler set in ERC721: ""$APPLICATION_ERC721_ADDRESS_1"
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi



echo "...Checking to make sure the handler is connected to the ERC721..."
if [ $RPC_URL == "local" ]; then
  HANDLER_ERC721=$(cast call $HANDLER 'owner()(address)')  
else
  HANDLER_ERC721=$(cast call $HANDLER 'owner()(address)' --rpc-url $RPC_URL) 
fi

COMP_HANDLER_ERC721=$(echo "$HANDLER_ERC721" | tr '[:lower:]' '[:upper:]')
COMP_APPLICATION_ERC721_ADDRESS_1=$(echo "$APPLICATION_ERC721_ADDRESS_1" | tr '[:lower:]' '[:upper:]')

if [ "$COMP_HANDLER_ERC721" != "$COMP_APPLICATION_ERC721_ADDRESS_1" ]; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - The Handler is not connected to the correct ERC721. Create a new handler and connect it to ERC721: ""$APPLICATION_ERC721_ADDRESS_1"
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

echo "...Checking to make sure the pricing modules are set within the ERC721's Handler..."
if [ $RPC_URL == "local" ]; then
  APP_MANAGER=$(cast call $HANDLER 'getAppManagerAddress()(address)')  
  APP_HANDLER=$(cast call $APP_MANAGER 'getHandlerAddress()(address)')
  HANDLER_PRICER=$(cast call $APP_HANDLER 'nftPricingAddress()(address)')  
else
  APP_MANAGER=$(cast call $HANDLER 'getAppManagerAddress()(address)'  --rpc-url $RPC_URL)  
  APP_HANDLER=$(cast call $APP_MANAGER 'getHandlerAddress()(address)' --rpc-url $RPC_URL)
  HANDLER_PRICER=$(cast call $APP_HANDLER 'nftPricingAddress()(address)' --rpc-url $RPC_URL) 
fi
echo $HANDLER_PRICER
if test -z "$HANDLER_PRICER"; then
    TEXT="$RED ERROR!!!$NC - The Handler does not have a ProtocolERC721Pricing module set. Set it in ERC721: ""$APPLICATION_ERC721_ADDRESS_1"" with function, setNFTPricingAddress(address)"
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

echo "...Checking to make sure the ERC721 is registered with the AppManager..."
if [ $RPC_URL == "local" ]; then
  APP_MANAGER=$(cast call $HANDLER 'getAppManagerAddress()(address)')  
  REGISTERED=$(cast call $APP_MANAGER 'getTokenID(address)(string)' $APPLICATION_ERC721_ADDRESS_1)  
else
  APP_MANAGER=$(cast call $HANDLER 'getAppManagerAddress()(address)'  --rpc-url $RPC_URL)  
  REGISTERED=$(cast call $APP_MANAGER 'isRegisteredHandler(address)(bool)' $HANDLER --rpc-url $RPC_URL) 
fi
if test -z "$REGISTERED"; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - The ERC721 is not registered in the AppManager. Call the registerToken(string _token, address _tokenAddress) in AppManager: ""$APP_MANAGER"" to register it."
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

echo "...Checking to make sure the ERC721's Handler is registered with the AppManager..."
if [ $RPC_URL == "local" ]; then
  REGISTERED=$(cast call $APP_MANAGER 'isRegisteredHandler(address)(bool)' $HANDLER)  
else
  APP_MANAGER=$(cast call $HANDLER 'getAppManagerAddress()(address)'  --rpc-url $RPC_URL)  
fi
if [ "$REGISTERED" != "true" ]; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - The ERC721's Handler is not registered in the AppManager. You must deregister the ERC721, ensure it has a valid handler attached, then reregister so the AppManager will detect it. Call the deregisterToken(string _tokenId) in AppManager: ""$APP_MANAGER"" to deregister it. Then call the registerToken(string _token, address _tokenAddress) in AppManager: ""$APP_MANAGER"" to register it correctly."
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

# This line will only be reached if all the commands above succeed
echo -e "$GREEN SUCCESS$NC - Protocol Supported ERC721 is successfully deployed and configured"
exit 0
