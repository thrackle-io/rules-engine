
# function to check for installations
installed()
{
  command -v "$1" >/dev/null 2>&1
}
# function to get input from the user
promptForInput() {
  echo -n "Enter $1: "
  read var1
}

# Get the environment variables
source .env.deployTest
# Set the colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# make sure that foundry is installed. If it is, update it. If not, install it.
if installed forge; then
  echo "...Updating Foundry..."
  COMMAND="$(foundryup --commit $(awk '$1~/^[^#]/' foundry.lock))"
else
  echo "...Installing Foundry..."
  $(curl -L https://foundry.paradigm.xyz)
fi

##### VALIDATE and RETRIEVE Entry variables

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
if test -z "$PROCESSOR_ADDRESS"; then
while true; do
  promptForInput "PROCESSOR_ADDRESS"

  if test -z "$var1"
  then    
    printf "PROCESSOR_ADDRESS cannot be blank\n"
  else
    PROCESSOR_ADDRESS="$var1"
    break
  fi
done
fi

###########################################################
echo "...Check to make sure the rule processor diamond is deployed and functional..."
if [ $RPC_URL == "local" ]; then
  cast call $PROCESSOR_ADDRESS "version()(string)" 1> /dev/null
else
  cast call $PROCESSOR_ADDRESS "version()(string)"  --rpc-url $RPC_URL 1> /dev/null
fi
ret_code=$?
if [ $ret_code == 1 ]; then
    echo -e "$RED                 FAIL $NC"
    TEXT="$RED ERROR!!!$NC - RuleProcessorDiamond not deployed to "
    TEXT+="$RPC_URL"
    echo -e $TEXT
    exit 1
else
  echo -e "$YELLOW                PASS $NC"
fi

# This line will only be reached if all the commands above succeed
echo -e "$GREEN SUCCESS$NC - Protocol is successfully deployed and configured"

exit 0
