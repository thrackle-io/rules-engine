#!/bin/bash

echo "################################################################"
echo Anvil output will be located in anvil_output.txt
echo Transaction output will be located in transaction_output.txt
echo a env file will be created with all of the relevant address exports at .test_env
echo "################################################################"
echo

OUTPUTFILE="test_env"

ENV_FILE=".env"

# Updating foundry
echo "################################################################"
echo Running foundryUp
echo "################################################################"
echo
foundryup --version nightly-09fe3e041369a816365a020f715ad6f94dbce9f2 &> /dev/null

# echo "Is this a local deployment (y or n)?"
# read LOCAL

LOCAL="y"

while [ "y" != "$LOCAL" ] && [ "n" != "$LOCAL" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Is this a local deployment (y or n)?"
  read LOCAL
  LOCAL=$(echo "$LOCAL" | tr '[:upper:]' '[:lower:]')  
done

if [ "$LOCAL" = "y" ]; then
    export FOUNDRY_PROFILE=local

    GAS_ARGUMENT=""
    ALREADY_DEPLOYED="n"

    # Local Deployment
    # Starting Anvil 
    echo "################################################################"
    echo Starting anvil
    echo "################################################################"
    echo 
    anvil --gas-limit 80000000 --code-size-limit 30000 &> ./anvil_output.txt &
    sleep 8

    # Parsing anvil output to grab an adress and its private key
    ARRAY=$(cat anvil_output.txt | grep \(0\) | tr '\n' ' ')
    IFS=' ' read -r -a array <<< "$ARRAY"
    echo $ARRAY
    echo
    APP_ADMIN_1_KEY="${array[5]}"
    APP_ADMIN_1="${array[1]//\"}"
    
    ARRAY=$(cat anvil_output.txt | grep \(1\) | tr '\n' ' ')
    IFS=' ' read -r -a array <<< "$ARRAY"
    echo $ARRAY
    echo
    USER_1="${array[1]//\"}"

    ARRAY=$(cat anvil_output.txt | grep \(2\) | tr '\n' ' ')
    echo $ARRAY
    echo
    IFS=' ' read -r -a array <<< "$ARRAY"
    USER_2="${array[1]//\"}"


    export ETH_RPC_URL=http://127.0.0.1:8545
else
    GAS_ARGUMENT=" --gas-price 10gwei"
    GAS_ARGUMENT_SCRIPT=" --gas-price 10"
    # Network Deployment (Mainnet or Testnet)

    # Request App Admin Address and Key
    echo Please enter App Admin Address
    read APP_ADMIN_1
    echo Please enter App Admin Private Key
    read APP_ADMIN_1_KEY
    # Request and export ETH_RPC_URL
    echo please enter RPC URL
    read ETH_RPC_URL

    echo "Is the Protocol already deployed (y or n)?"
    read ALREADY_DEPLOYED

    ALREADY_DEPLOYED=$(echo "$ALREADY_DEPLOYED" | tr '[:upper:]' '[:lower:]')

    while [ "y" != "$ALREADY_DEPLOYED" ] && [ "n" != "$ALREADY_DEPLOYED" ] ; do
    echo
    echo "Not a valid answer (y or n)"
    echo "Is the Protocol already deployed (y or n)?"
    read ALREADY_DEPLOYED
    ALREADY_DEPLOYED=$(echo "$ALREADY_DEPLOYED" | tr '[:upper:]' '[:lower:]')  
    done

    if [ "$ALREADY_DEPLOYED" = "y" ]; then
        echo "Pleast enter the RULE_PROCESSOR_DIAMOND address"
        read RULE_PROCESSOR_DIAMOND
    fi

fi

sed -i '' 's/LOCAL_DEPLOYMENT_OWNER=.*/LOCAL_DEPLOYMENT_OWNER='$APP_ADMIN_1'/g' $ENV_FILE
sed -i '' 's/LOCAL_DEPLOYMENT_OWNER_KEY=.*/LOCAL_DEPLOYMENT_OWNER_KEY='$APP_ADMIN_1_KEY'/g' $ENV_FILE

if [ "$ALREADY_DEPLOYED" = "y" ]; then
    echo "Protocol already deployed skipping DeployAllModules.s.sol"
else

    # Deploying the protocol
    echo "################################################################"
    echo Running DeployAllModules.s.sol
    echo $ETH_RPC_URL
    echo "################################################################"
    echo

    # forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT
    forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

    # Retreive the Rule Processor Diamond Address
    if [ "$LOCAL" = "y" ]; then
        RULE_PROCESSOR_DIAMOND_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleProcessorDiamond") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        RULE_PROCESSOR_DIAMOND_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleProcessorDiamond") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    RULE_PROCESSOR_DIAMOND="${RULE_PROCESSOR_DIAMOND_UNCUT//\"}"

    echo $RULE_PROCESSOR_DIAMOND
    echo 

    sed -i '' 's/RULE_PROCESSOR_DIAMOND=.*/RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE

    forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT
    forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

    echo "################################################################"
    echo export APP_ADMIN_1=$APP_ADMIN_1 | tee $OUTPUTFILE
    echo export APP_ADMIN_1_KEY=$APP_ADMIN_1_KEY | tee -a $OUTPUTFILE
    echo export RULE_PROCESSOR_DIAMOND=$RULE_PROCESSOR_DIAMOND | tee -a $OUTPUTFILE

fi

# Asking the user for the name of the application
echo Name of your application is Frankenstein
APP_NAME="Frankenstein"

echo "################################################################"
echo Creating/Compiling 
echo "1. ApplicationAppManager.sol" 
echo "2. ApplicationHandler.sol"
echo "3. ApplicationERC721Pricing"
echo for $APP_NAME
echo "################################################################"
echo

# Creating a directory with the application name, copying the relevant solidity files into that directory,
# renaming the files (and updating their contents) based on the applicaiton name, and compiling the solidity
mkdir ./src/example/$APP_NAME
FILE_NAME=$APP_NAME"AppManager.sol"
HANDLER_FILE_NAME=$APP_NAME"Handler.sol"
PRICING_FILE_NAME=$APP_NAME"ERC721Pricing.sol"
ERC20_PRICING_FILE_NAME=$APP_NAME"ERC20Pricing.sol"
ERC721_FILE_NAME=$APP_NAME"ERC721.sol"
ERC721_HANDLER_FILE_NAME=$APP_NAME"ERC721Handler.sol"
ERC20_FILE_NAME=$APP_NAME"ERC20.sol"
ERC20_HANDLER_FILE_NAME=$APP_NAME"ERC20Handler.sol"
ORACLE_FILE_NAME=$APP_NAME"Allowed.sol"

echo $FILE_NAME
cp ./src/example/application/ApplicationAppManager.sol ./src/example/$APP_NAME/$FILE_NAME

sed -i '' 's/ApplicationAppManager/'$APP_NAME'AppManager/g' ./src/example/$APP_NAME/$FILE_NAME

cp ./src/example/application/ApplicationHandler.sol ./src/example/$APP_NAME/$HANDLER_FILE_NAME

sed -i '' 's/ ApplicationHandler/ '$APP_NAME'Handler/g' ./src/example/$APP_NAME/$HANDLER_FILE_NAME

cp ./src/example/pricing/ApplicationERC721Pricing.sol ./src/example/$APP_NAME/$PRICING_FILE_NAME

sed -i '' 's/ApplicationERC721Pricing/'$APP_NAME'ERC721Pricing/g' ./src/example/$APP_NAME/$PRICING_FILE_NAME

cp ./src/example/pricing/ApplicationERC20Pricing.sol ./src/example/$APP_NAME/$ERC20_PRICING_FILE_NAME

sed -i '' 's/ApplicationERC20Pricing/'$APP_NAME'ERC20Pricing/g' ./src/example/$APP_NAME/$ERC20_PRICING_FILE_NAME

cp ./src/example/ERC721/ApplicationERC721FreeMint.sol ./src/example/$APP_NAME/$ERC721_FILE_NAME

sed -i '' 's/ApplicationERC721/'$APP_NAME'ERC721/g' ./src/example/$APP_NAME/$ERC721_FILE_NAME

cp ./src/example/ERC721/ApplicationERC721Handler.sol ./src/example/$APP_NAME/$ERC721_HANDLER_FILE_NAME

sed -i '' 's/ApplicationERC721Handler/'$APP_NAME'ERC721Handler/g' ./src/example/$APP_NAME/$ERC721_HANDLER_FILE_NAME

cp ./src/example/ERC20/ApplicationERC20.sol ./src/example/$APP_NAME/$ERC20_FILE_NAME

sed -i '' 's/ApplicationERC20/'$APP_NAME'ERC20/g' ./src/example/$APP_NAME/$ERC20_FILE_NAME

cp ./src/example/ERC20/ApplicationERC20Handler.sol ./src/example/$APP_NAME/$ERC20_HANDLER_FILE_NAME

sed -i '' 's/ApplicationERC20Handler/'$APP_NAME'ERC20Handler/g' ./src/example/$APP_NAME/$ERC20_HANDLER_FILE_NAME

# Oracle

cp ./src/example/OracleApproved.sol ./src/example/$APP_NAME/$ORACLE_FILE_NAME

sed -i '' 's/OracleApproved/'$APP_NAME'Allowed/g' ./src/example/$APP_NAME/$ORACLE_FILE_NAME

forge build 

# Deploying the App specific contracts
echo "################################################################"
echo  Deploying "$APP_NAME"AppManager
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$FILE_NAME:"$APP_NAME"AppManager --constructor-args $APP_ADMIN_1 $APP_NAME false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT) 
INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"

APPLICATION_APP_MANAGER="${outputarray[4]}"
echo export APPLICATION_APP_MANAGER=$APPLICATION_APP_MANAGER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"Handler
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$HANDLER_FILE_NAME:"$APP_NAME"Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"

APPLICATION_HANDLER="${outputarray[4]}"
echo export APPLICATION_HANDLER=$APPLICATION_HANDLER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC721Pricing
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$PRICING_FILE_NAME:"$APP_NAME"ERC721Pricing --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1 $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC721_PRICER="${outputarray[4]}"

echo export APPLICATION_ERC721_PRICER=$APPLICATION_ERC721_PRICER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC20 Pricing
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ERC20_PRICING_FILE_NAME:"$APP_NAME"ERC20Pricing --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1 $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC20_PRICER="${outputarray[4]}"

echo export APPLICATION_ERC20_PRICER=$APPLICATION_ERC20_PRICER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC721
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ERC721_FILE_NAME:"$APP_NAME"ERC721 --constructor-args "Frankenstein" "FRANKPIC" $APPLICATION_APP_MANAGER "baseURI" --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC721_1="${outputarray[4]}"

echo export APPLICATION_ERC721_1=$APPLICATION_ERC721_1 | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC20
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ERC20_FILE_NAME:"$APP_NAME"ERC20 --constructor-args "FTA" "ufta" $APPLICATION_APP_MANAGER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC20_1="${outputarray[4]}"

echo export APPLICATION_ERC20_1=$APPLICATION_ERC20_1 | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC20Handler
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ERC20_HANDLER_FILE_NAME:"$APP_NAME"ERC20Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER $APPLICATION_ERC20_1 false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC20_1_HANDLER="${outputarray[4]}"

echo export APPLICATION_ERC20_1_HANDLER=$APPLICATION_ERC20_1_HANDLER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC721Handler
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ERC721_HANDLER_FILE_NAME:"$APP_NAME"ERC721Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER $APPLICATION_ERC721_1 false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC721_1_HANDLER="${outputarray[4]}"

echo export APPLICATION_ERC721_1_HANDLER=$APPLICATION_ERC721_1_HANDLER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying first "$APP_NAME"Allowed contract
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ORACLE_FILE_NAME:"$APP_NAME"Allowed --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
ORACLE_1_HANDLER="${outputarray[4]}"

echo export ORACLE_1_HANDLER=$ORACLE_1_HANDLER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying second "$APP_NAME"Allowed contract
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ORACLE_FILE_NAME:"$APP_NAME"Allowed --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

INBETWEEN=$(echo $OUTPUT | sed 's/^.*Deployer/Deployer/')

OUTPUTARRAY=$(echo $INBETWEEN | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
ORACLE_2_HANDLER="${outputarray[4]}"

echo export ORACLE_2_HANDLER=$ORACLE_2_HANDLER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Connect ApplicationHandler to ApplicationManager
echo "################################################################"
echo

cast send $APPLICATION_APP_MANAGER "setNewApplicationHandlerAddress(address)" $APPLICATION_HANDLER --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1 --rpc-url $ETH_RPC_URL

echo "################################################################"
echo  Connect handler to ERC721
echo "################################################################"
echo

cast send $APPLICATION_ERC721_1 "connectHandlerToToken(address)" $APPLICATION_ERC721_1_HANDLER --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1 --rpc-url $ETH_RPC_URL 

echo "################################################################"
echo  Register ERC721 with App Manager
echo "################################################################"
echo

cast send $APPLICATION_APP_MANAGER "registerToken(string,address)" "FRANKPIC" $APPLICATION_ERC721_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL 

echo "################################################################"
echo  Connect handler to ERC20
echo "################################################################"
echo

cast send $APPLICATION_ERC20_1 "connectHandlerToToken(address)" $APPLICATION_ERC20_1_HANDLER --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1 --rpc-url $ETH_RPC_URL 

echo "################################################################"
echo  Register ERC20 with App Manager
echo "################################################################"
echo

cast send $APPLICATION_APP_MANAGER "registerToken(string,address)" "ufta" $APPLICATION_ERC20_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL 

echo "################################################################"
echo  Mint a billion coins
echo "################################################################"
echo

cast send $APPLICATION_ERC20_1 "mint(address,uint256)" $APP_ADMIN_1 10000000000000000000000000000000 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1

echo "################################################################"
echo  Set Price of ERC721 collection
echo "################################################################"
echo

cast send $APPLICATION_ERC721_PRICER "setNFTCollectionPrice(address,uint256)" $APPLICATION_ERC721_1 1000000000000000000 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL 

echo "################################################################"
echo  Make Rule Admin
echo "################################################################"
echo

cast send $APPLICATION_APP_MANAGER "addRuleAdministrator(address)" $APP_ADMIN_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

echo "################################################################"
echo  Add to allowed list
echo "################################################################"
echo

# Comment the following line out to see the oracle rule fail
cast send $ORACLE_1_HANDLER "addAddressToApprovedList(address)" $USER_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

cast send $ORACLE_2_HANDLER "addAddressToApprovedList(address)" $USER_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

echo "################################################################"
echo  Create Account Min/Max Token Balance Rule
echo "################################################################"
echo

cast send $RULE_PROCESSOR_DIAMOND "addAccountMinMaxTokenBalance(address,bytes32[],uint256[],uint256[],uint16[],uint64)(uint32)" $APPLICATION_APP_MANAGER [0x0000000000000000000000000000000000000000000000000000000000000000\] [1] [100] [] 1675723152 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1 --rpc-url $ETH_RPC_URL &> ./transaction_output.txt 

OUTPUT_JSON=$(sed -n 's/logs //p' transaction_output.txt)

PARSED_RULE_ID=$(echo $OUTPUT_JSON | jq '.[0].topics[2]' | tr -d '"')
RULE_ID="${PARSED_RULE_ID: -1}"

echo "################################################################"
echo PARSED_RULE_ID=$PARSED_RULE_ID
echo  export Rule_ID=$RULE_ID | tee -a $OUTPUTFILE
echo "################################################################"
echo

echo "################################################################"
echo  Set the Rule on the Handler
echo "################################################################"
echo

cast send $APPLICATION_ERC20_1_HANDLER "setAccountMinMaxTokenBalanceId(uint8[], uint32)" [0] 0 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1

# echo "################################################################"
# echo  Tag USER_1
# echo "################################################################"
# echo

# cast send $APPLICATION_APP_MANAGER "addTag(address,bytes32)" $USER_1 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key $APP_ADMIN_1_KEY

if [ "$LOCAL" = "y" ]; then
    rm ./anvil_output.txt
fi
ECHO "export ETH_RPC_URL=http://127.0.0.1:8545"
ECHO "export RULE_PROCESSOR_DIAMOND=$RULE_PROCESSOR_DIAMOND"
ECHO "export APPLICATION_APP_MANAGER=$APPLICATION_APP_MANAGER"
ECHO "export APP_ADMIN_1_KEY=$APP_ADMIN_1_KEY"
ECHO "export APP_ADMIN_1=$APP_ADMIN_1"
ECHO "export USER_1=$USER_1"
ECHO "export USER_2=$USER_2"
ECHO "export APPLICATION_ERC20_1=$APPLICATION_ERC20_1"
ECHO "export APPLICATION_ERC20_1_HANDLER=$APPLICATION_ERC20_1_HANDLER"
rm ./transaction_output.txt