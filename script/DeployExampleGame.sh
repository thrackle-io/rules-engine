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

echo "Is this a local deployment (y or n)?"
read LOCAL

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
    anvil --gas-limit 80000000 &> ./anvil_output.txt &
    sleep 8

    # Parsing anvil output to grab an adress and its private key
    ARRAY=$(cat anvil_output.txt | grep \(0\) | tr '\n' ' ')
    IFS=' ' read -r -a array <<< "$ARRAY"
    APP_ADMIN_1_KEY="${array[5]}"
    APP_ADMIN_1="${array[1]//\"}"

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

    forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

    # Parsing the output from the protocol deployment to find the needed addresses

    # Retreive the Version Facet Address
    if [ "$LOCAL" = "y" ]; then
        VERSION_FACET_UNCUT=$(jq '.transactions[] | select(.contractName=="VersionFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        VERSION_FACET_UNCUT=$(jq '.transactions[] | select(.contractName=="VersionFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    VERSION_FACET="${VERSION_FACET_UNCUT//\"}"

    # Retreive the Protocol Native Facet Address
    if [ "$LOCAL" = "y" ]; then
        PROTOCOL_NATIVE_FACET_UNCUT=$(jq '.transactions[] | select(.contractName=="ProtocolNativeFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        PROTOCOL_NATIVE_FACET_UNCUT=$(jq '.transactions[] | select(.contractName=="ProtocolNativeFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    PROTOCOL_NATIVE_FACET="${PROTOCOL_NATIVE_FACET_UNCUT//\"}"

    # Retrieve the Protocol Raw Facet
    if [ "$LOCAL" = "y" ]; then
        PROTOCOL_RAW_FACET_UNCUT=$(jq '.transactions[] | select(.contractName=="ProtocolRawFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        PROTOCOL_RAW_FACET_UNCUT=$(jq '.transactions[] | select(.contractName=="ProtocolRawFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    PROTOCOL_RAW_FACET="${PROTOCOL_RAW_FACET_UNCUT//\"}"

    # Retrieve the ERC20 Rule Processor Facet
    if [ "$LOCAL" = "y" ]; then
        ERC20_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC20RuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        ERC20_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC20RuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    ERC20_RULE_PROCESSOR="${ERC20_RULE_PROCESSOR_UNCUT//\"}"

    # Retrieve the ERC721 Rule Processor Facet
    if [ "$LOCAL" = "y" ]; then
        ERC721_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC721RuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        ERC721_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC721RuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    ERC721_RULE_PROCESSOR="${ERC721_RULE_PROCESSOR_UNCUT//\"}"

    # Retrieve the Fee Rule Processor Facet
    if [ "$LOCAL" = "y" ]; then
        FEE_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="FeeRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        FEE_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="FeeRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    FEE_RULE_PROCESSOR="${FEE_RULE_PROCESSOR_UNCUT//\"}"

    # Retrieve the Application Risk Processor Facet
    if [ "$LOCAL" = "y" ]; then
        APPLICATION_RISK_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ApplicationRiskProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        APPLICATION_RISK_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ApplicationRiskProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    APPLICATION_RISK_PROCESSOR="${APPLICATION_RISK_PROCESSOR_UNCUT//\"}"

   # Retrieve the Application Access Level Processor Facet
    if [ "$LOCAL" = "y" ]; then
        APPLICATION_ACCESS_LEVEL_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ApplicationAccessLevelProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        APPLICATION_ACCESS_LEVEL_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ApplicationAccessLevelProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    APPLICATION_ACCESS_LEVEL_PROCESSOR="${APPLICATION_ACCESS_LEVEL_PROCESSOR_UNCUT//\"}"

   # Retrieve the Application Pause Processor Facet
    if [ "$LOCAL" = "y" ]; then
        APPLICATION_PAUSE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ApplicationPauseProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json)
    else
        APPLICATION_PAUSE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ApplicationPauseProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/80001/run-latest.json)
    fi
    APPLICATION_PAUSE_PROCESSOR="${APPLICATION_PAUSE_PROCESSOR_UNCUT//\"}"

    forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

   # Retrieve the ERC20 Tagged Rule Processor Facet
    if [ "$LOCAL" = "y" ]; then
        ERC20_TAGGED_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC20TaggedRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        ERC20_TAGGED_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC20TaggedRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    ERC20_TAGGED_RULE_PROCESSOR="${ERC20_TAGGED_RULE_PROCESSOR_UNCUT//\"}"

   # Retrieve the ERC721 Tagged Rule Processor Facet
    if [ "$LOCAL" = "y" ]; then
        ERC721_TAGGED_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC721TaggedRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        ERC721_TAGGED_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="ERC721TaggedRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    ERC721_TAGGED_RULE_PROCESSOR="${ERC721_TAGGED_RULE_PROCESSOR_UNCUT//\"}"

   # Retrieve the Risk Tagged Rule Processor Facet
    if [ "$LOCAL" = "y" ]; then
        RISK_TAGGED_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="RiskTaggedRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        RISK_TAGGED_RULE_PROCESSOR_UNCUT=$(jq '.transactions[] | select(.contractName=="RiskTaggedRuleProcessorFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    RISK_TAGGED_RULE_PROCESSOR="${RISK_TAGGED_RULE_PROCESSOR_UNCUT//\"}"

   # Retrieve the Rule Application Validation Facet
    if [ "$LOCAL" = "y" ]; then
        RULE_APPLICATION_VALIDATION_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleApplicationValidationFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        RULE_APPLICATION_VALIDATION_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleApplicationValidationFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    RULE_APPLICATION_VALIDATION="${RULE_APPLICATION_VALIDATION_UNCUT//\"}"

   # Retrieve the Rule Data Facet
    if [ "$LOCAL" = "y" ]; then
        RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    RULE_DATA="${RULE_DATA_UNCUT//\"}"

   # Retrieve the Tagged Rule Data Facet
    if [ "$LOCAL" = "y" ]; then
        TAGGED_RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="TaggedRuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        TAGGED_RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="TaggedRuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    TAGGED_RULE_DATA="${TAGGED_RULE_DATA_UNCUT//\"}"

   # Retrieve the App Rule Data Facet
    if [ "$LOCAL" = "y" ]; then
        APP_RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="AppRuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        APP_RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="AppRuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    APP_RULE_DATA="${APP_RULE_DATA_UNCUT//\"}"

   # Retrieve the Fee Rule Data Facet
    if [ "$LOCAL" = "y" ]; then
        FEE_RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="FeeRuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json)
    else
        FEE_RULE_DATA_UNCUT=$(jq '.transactions[] | select(.contractName=="FeeRuleDataFacet") | .contractAddress' broadcast/DeployAllModulesPt2.s.sol/80001/run-latest.json)
    fi
    FEE_RULE_DATA="${FEE_RULE_DATA_UNCUT//\"}"

    echo VERSION_FACET=$VERSION_FACET
    sed -i '' 's/VERSION_FACET=.*/VERSION_FACET='$VERSION_FACET'/g' $ENV_FILE

    echo PROTOCOL_NATIVE_FACET=$PROTOCOL_NATIVE_FACET 
    sed -i '' 's/PROTOCOL_NATIVE_FACET=.*/PROTOCOL_NATIVE_FACET='$PROTOCOL_NATIVE_FACET'/g' $ENV_FILE

    echo PROTOCOL_RAW_FACET=$PROTOCOL_RAW_FACET 
    sed -i '' 's/PROTOCOL_RAW_FACET=.*/PROTOCOL_RAW_FACET='$PROTOCOL_RAW_FACET'/g' $ENV_FILE

    echo ERC20_RULE_PROCESSOR=$ERC20_RULE_PROCESSOR
    sed -i '' 's/ERC20_RULE_PROCESSOR=.*/ERC20_RULE_PROCESSOR='$ERC20_RULE_PROCESSOR'/g' $ENV_FILE

    echo ERC721_RULE_PROCESSOR=$ERC721_RULE_PROCESSOR
    sed -i '' 's/ERC721_RULE_PROCESSOR=.*/ERC721_RULE_PROCESSOR='$ERC721_RULE_PROCESSOR'/g' $ENV_FILE

    echo FEE_RULE_PROCESSOR=$FEE_RULE_PROCESSOR
    sed -i '' 's/FEE_RULE_PROCESSOR=.*/FEE_RULE_PROCESSOR='$FEE_RULE_PROCESSOR'/g' $ENV_FILE

    echo APPLICATION_RISK_PROCESSOR=$APPLICATION_RISK_PROCESSOR
    sed -i '' 's/APPLICATION_RISK_PROCESSOR=.*/APPLICATION_RISK_PROCESSOR='$APPLICATION_RISK_PROCESSOR'/g' $ENV_FILE

    echo APPLICATION_ACCESS_LEVEL_PROCESSOR=$APPLICATION_ACCESS_LEVEL_PROCESSOR
    sed -i '' 's/APPLICATION_ACCESS_LEVEL_PROCESSOR=.*/APPLICATION_ACCESS_LEVEL_PROCESSOR='$APPLICATION_ACCESS_LEVEL_PROCESSOR'/g' $ENV_FILE

    echo APPLICATION_PAUSE_PROCESSOR=$APPLICATION_PAUSE_PROCESSOR
    sed -i '' 's/APPLICATION_PAUSE_PROCESSOR=.*/APPLICATION_PAUSE_PROCESSOR='$APPLICATION_PAUSE_PROCESSOR'/g' $ENV_FILE

    echo ERC20_TAGGED_RULE_PROCESSOR=$ERC20_TAGGED_RULE_PROCESSOR 
    sed -i '' 's/ERC20_TAGGED_RULE_PROCESSOR=.*/ERC20_TAGGED_RULE_PROCESSOR='$ERC20_TAGGED_RULE_PROCESSOR'/g' $ENV_FILE

    echo ERC721_TAGGED_RULE_PROCESSOR=$ERC721_TAGGED_RULE_PROCESSOR 
    sed -i '' 's/ERC721_TAGGED_RULE_PROCESSOR=.*/ERC721_TAGGED_RULE_PROCESSOR='$ERC721_TAGGED_RULE_PROCESSOR'/g' $ENV_FILE

    echo RISK_TAGGED_RULE_PROCESSOR=$RISK_TAGGED_RULE_PROCESSOR 
    sed -i '' 's/RISK_TAGGED_RULE_PROCESSOR=.*/RISK_TAGGED_RULE_PROCESSOR='$RISK_TAGGED_RULE_PROCESSOR'/g' $ENV_FILE

    echo RULE_APPLICATION_VALIDATION=$RULE_APPLICATION_VALIDATION
    sed -i '' 's/RULE_APPLICATION_VALIDATION=.*/RULE_APPLICATION_VALIDATION='$RULE_APPLICATION_VALIDATION'/g' $ENV_FILE

    echo RULE_DATA=$RULE_DATA
    sed -i '' 's/RULE_DATA=.*/RULE_DATA='$RULE_DATA'/g' $ENV_FILE

    echo TAGGED_RULE_DATA=$TAGGED_RULE_DATA
    sed -i '' 's/TAGGED_RULE_DATA=.*/TAGGED_RULE_DATA='$TAGGED_RULE_DATA'/g' $ENV_FILE

    echo APP_RULE_DATA=$APP_RULE_DATA | tee -a $ENV_FILE
    sed -i '' 's/APP_RULE_DATA=.*/APP_RULE_DATA='$APP_RULE_DATA'/g' $ENV_FILE

    echo FEE_RULE_DATA=$FEE_RULE_DATA | tee -a $ENV_FILE
    sed -i '' 's/FEE_RULE_DATA=.*/FEE_RULE_DATA='$FEE_RULE_DATA'/g' $ENV_FILE
    echo "################################################################"
    echo

    forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

    # Retreive the Rule Processor Diamond Address
    if [ "$LOCAL" = "y" ]; then
        RULE_PROCESSOR_DIAMOND_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleProcessorDiamond") | .contractAddress' broadcast/DeployAllModulesPt3.s.sol/31337/run-latest.json)
    else
        RULE_PROCESSOR_DIAMOND_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleProcessorDiamond") | .contractAddress' broadcast/DeployAllModulesPt3.s.sol/80001/run-latest.json)
    fi
    RULE_PROCESSOR_DIAMOND="${RULE_PROCESSOR_DIAMOND_UNCUT//\"}"
    # sed -i '2s/.*/RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/' .env

    echo "################################################################"
    echo export APP_ADMIN_1=$APP_ADMIN_1 | tee $OUTPUTFILE
    echo export APP_ADMIN_1_KEY=$APP_ADMIN_1_KEY | tee -a $OUTPUTFILE
    echo export RULE_PROCESSOR_DIAMOND=$RULE_PROCESSOR_DIAMOND | tee -a $OUTPUTFILE

fi

# Asking the user for the name of the application
echo Enter the name of your application
read APP_NAME

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
ERC721_FILE_NAME=$APP_NAME"ERC721.sol"
ERC721_HANDLER_FILE_NAME=$APP_NAME"ERC721Handler.sol"

echo $FILE_NAME
cp ./src/example/application/ApplicationAppManager.sol ./src/example/$APP_NAME/$FILE_NAME

sed -i '' 's/ApplicationAppManager/'$APP_NAME'AppManager/g' ./src/example/$APP_NAME/$FILE_NAME

cp ./src/example/application/ApplicationHandler.sol ./src/example/$APP_NAME/$HANDLER_FILE_NAME

sed -i '' 's/ ApplicationHandler/ '$APP_NAME'Handler/g' ./src/example/$APP_NAME/$HANDLER_FILE_NAME

cp ./src/example/pricing/ApplicationERC721Pricing.sol ./src/example/$APP_NAME/$PRICING_FILE_NAME

sed -i '' 's/ApplicationERC721Pricing/'$APP_NAME'ERC721Pricing/g' ./src/example/$APP_NAME/$PRICING_FILE_NAME

cp ./src/example/ERC721/ApplicationERC721FreeMint.sol ./src/example/$APP_NAME/$ERC721_FILE_NAME

sed -i '' 's/ApplicationERC721/'$APP_NAME'ERC721/g' ./src/example/$APP_NAME/$ERC721_FILE_NAME

cp ./src/example/ERC721/ApplicationERC721Handler.sol ./src/example/$APP_NAME/$ERC721_HANDLER_FILE_NAME

sed -i '' 's/ApplicationERC721Handler/'$APP_NAME'ERC721Handler/g' ./src/example/$APP_NAME/$ERC721_HANDLER_FILE_NAME

forge build --use solc:0.8.17

# Deploying the App specific contracts
echo "################################################################"
echo  Deploying "$APP_NAME"AppManager
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$FILE_NAME:"$APP_NAME"AppManager --constructor-args $APP_ADMIN_1 $APP_NAME false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT) 
OUTPUTARRAY=$(echo $OUTPUT | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"

APPLICATION_APP_MANAGER="${outputarray[9]}"
echo export APPLICATION_APP_MANAGER=$APPLICATION_APP_MANAGER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"Handler
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$HANDLER_FILE_NAME:"$APP_NAME"Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

OUTPUTARRAY=$(echo $OUTPUT | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"

APPLICATION_HANDLER="${outputarray[9]}"
echo export APPLICATION_HANDLER=$APPLICATION_HANDLER | tee -a $OUTPUTFILE
echo

# Deploying the AppManager, AppHandler and ERC721Pricing module
echo "################################################################"
echo  Deploying "$APP_NAME"ERC721Pricing
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$PRICING_FILE_NAME:"$APP_NAME"ERC721Pricing --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1 $GAS_ARGUMENT)

OUTPUTARRAY=$(echo $OUTPUT | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_PRICER="${outputarray[9]}"

echo export APPLICATION_PRICER=$APPLICATION_PRICER | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC721
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ERC721_FILE_NAME:"$APP_NAME"ERC721 --constructor-args "Frankenstein" "FRANKPIC" $APPLICATION_APP_MANAGER "baseURI" --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

OUTPUTARRAY=$(echo $OUTPUT | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC721_1="${outputarray[9]}"

echo export APPLICATION_ERC721_1=$APPLICATION_ERC721_1 | tee -a $OUTPUTFILE
echo

echo "################################################################"
echo  Deploying "$APP_NAME"ERC721Handler
echo "################################################################"
echo

OUTPUT=$(forge create ./src/example/$APP_NAME/$ERC721_HANDLER_FILE_NAME:"$APP_NAME"ERC721Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER $APPLICATION_ERC721_1 false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL $GAS_ARGUMENT)

OUTPUTARRAY=$(echo $OUTPUT | tr '\n' ' ')
IFS=': ' read -r -a outputarray <<< "$OUTPUTARRAY"
APPLICATION_ERC721_1_HANDLER="${outputarray[9]}"

echo export APPLICATION_ERC721_1_HANDLER=$APPLICATION_ERC721_1_HANDLER | tee -a $OUTPUTFILE
echo

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
echo  Set Price of ERC721 collection
echo "################################################################"
echo

cast send $APPLICATION_PRICER "setNFTCollectionPrice(address,uint256)" $APPLICATION_ERC721_1 1000000000000000000 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL 

echo "################################################################"
echo  Make Rule Admin
echo "################################################################"
echo

cast send $APPLICATION_APP_MANAGER "addRuleAdministrator(address)" $APP_ADMIN_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

echo "################################################################"
echo  Create NFT Transfer Counter Rule
echo "################################################################"
echo

cast send $RULE_PROCESSOR_DIAMOND "addNFTTransferCounterRule(address,bytes32[],uint8[],uint64)(uint32)" $APPLICATION_APP_MANAGER \[0x5461796c65720000000000000000000000000000000000000000000000000000\] \[1\] 1675723152 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1 --rpc-url $ETH_RPC_URL &> ./transaction_output.txt 

cat transaction_output.txt

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

cast send $APPLICATION_ERC721_1_HANDLER "setTradeCounterRuleId(uint32)" $RULE_ID --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1


if [ "$LOCAL" = "y" ]; then
    rm ./anvil_output.txt
fi

rm ./transaction_output.txt