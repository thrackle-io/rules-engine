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
    anvil --gas-limit 80000000 &> ./anvil_output.txt &
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
    echo "Protocol already deployed skipping Protocol Deployment Scripts"
else

    # Deploying the protocol
    echo "################################################################"
    echo Running Deploy Protocol scripts
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

forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

if [ "$LOCAL" = "y" ]; then
    APPLICATION_APP_MANAGER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationAppManager")) | .contractAddress' broadcast/Application_Deploy_01_AppManager.s.sol/31337/run-latest.json)
else
    APPLICATION_APP_MANAGER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationAppManager")) | .contractAddress' broadcast/Application_Deploy_01_AppManager.s.sol/80001/run-latest.json)
fi
APPLICATION_APP_MANAGER="${APPLICATION_APP_MANAGER_UNCUT//\"}"

echo $APPLICATION_APP_MANAGER
echo 

if [ "$LOCAL" = "y" ]; then
    APPLICATION_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationHandler")) | .contractAddress' broadcast/Application_Deploy_01_AppManager.s.sol/31337/run-latest.json)
else
    APPLICATION_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationHandler")) | .contractAddress' broadcast/Application_Deploy_01_AppManager.s.sol/80001/run-latest.json)
fi
APPLICATION_HANDLER="${APPLICATION_APP_MANAGER_UNCUT//\"}"

echo $APPLICATION_HANDLER
echo 

bash script/ParseApplicationDeploy.sh 1

forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

if [ "$LOCAL" = "y" ]; then 
    APPLICATION_ERC20_1_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC20")) | .contractAddress' broadcast/Application_Deploy_02_ApplicationFT1.s.sol/31337/run-latest.json)
else
    APPLICATION_ERC20_1_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC20")) | .contractAddress' broadcast/Application_Deploy_02_ApplicationFT1.s.sol/80001/run-latest.json)
fi
APPLICATION_ERC20_1="${APPLICATION_ERC20_1_UNCUT//\"}"

echo $APPLICATION_ERC20_1
echo 

if [ "$LOCAL" = "y" ]; then
    APPLICATION_ERC20_1_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="HandlerDiamond")) | .contractAddress' broadcast/Application_Deploy_02_ApplicationFT1.s.sol/31337/run-latest.json)
else
    APPLICATION_ERC20_1_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="HandlerDiamond")) | .contractAddress' broadcast/Application_Deploy_02_ApplicationFT1.s.sol/80001/run-latest.json)
fi
APPLICATION_ERC20_1_HANDLER="${APPLICATION_ERC20_1_HANDLER_UNCUT//\"}"

echo $APPLICATION_ERC20_1_HANDLER
echo 

bash script/ParseApplicationDeploy.sh 2

forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

if [ "$LOCAL" = "y" ]; then
    APPLICATION_ERC721_1_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC721AdminOrOwnerMint")) | .contractAddress' broadcast/Application_Deploy_04_ApplicationNFT.s.sol/31337/run-latest.json)
else
    APPLICATION_ERC721_1_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC721AdminOrOwnerMint")) | .contractAddress' broadcast/Application_Deploy_04_ApplicationNFT.s.sol/80001/run-latest.json)
fi
APPLICATION_ERC721_1="${APPLICATION_ERC721_1_UNCUT//\"}"

echo $APPLICATION_ERC721_1
echo 

if [ "$LOCAL" = "y" ]; then
    APPLICATION_ERC721_1_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="HandlerDiamond")) | .contractAddress' broadcast/Application_Deploy_02_ApplicationFT1.s.sol/31337/run-latest.json)
else
    APPLICATION_ERC721_1_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="HandlerDiamond")) | .contractAddress' broadcast/Application_Deploy_02_ApplicationFT1.s.sol/80001/run-latest.json)
fi
APPLICATION_ERC721_1_HANDLER="${APPLICATION_ERC721_1_HANDLER_UNCUT//\"}"

echo $APPLICATION_ERC721_1_HANDLER
echo 

bash script/ParseApplicationDeploy.sh 3

forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

if [ "$LOCAL" = "y" ]; then
    ORACLE_1_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="OracleApproved")) | .contractAddress' broadcast/Application_Deploy_05_Oracle.s.sol/31337/run-latest.json)
else
    ORACLE_1_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="OracleApproved")) | .contractAddress' broadcast/Application_Deploy_05_Oracle.s.sol/80001/run-latest.json)
fi
ORACLE_1_HANDLER="${ORACLE_1_HANDLER_UNCUT//\"}"

echo $ORACLE_1_HANDLER
echo 

if [ "$LOCAL" = "y" ]; then
    ORACLE_2_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="OracleDenied")) | .contractAddress' broadcast/Application_Deploy_05_Oracle.s.sol/31337/run-latest.json)
else
    ORACLE_2_HANDLER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="OracleDenied")) | .contractAddress' broadcast/Application_Deploy_05_Oracle.s.sol/80001/run-latest.json)
fi
ORACLE_2_HANDLER="${ORACLE_2_HANDLER_UNCUT//\"}"

echo $ORACLE_2_HANDLER
echo 

bash script/ParseApplicationDeploy.sh 4

forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL $GAS_ARGUMENT_SCRIPT

if [ "$LOCAL" = "y" ]; then
    APPLICATION_ERC20_PRICER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC20Pricing")) | .contractAddress' broadcast/Application_Deploy_06_Pricing.s.sol/31337/run-latest.json)
else
    APPLICATION_ERC20_PRICER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC20Pricing")) | .contractAddress' broadcast/Application_Deploy_06_Pricing.s.sol/80001/run-latest.json)
fi
APPLICATION_ERC20_PRICER="${APPLICATION_ERC20_PRICER_UNCUT//\"}"

echo $APPLICATION_ERC20_PRICER
echo 

if [ "$LOCAL" = "y" ]; then
    APPLICATION_ERC721_PRICER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC721Pricing")) | .contractAddress' broadcast/Application_Deploy_06_Pricing.s.sol/31337/run-latest.json)
else
    APPLICATION_ERC721_PRICER_UNCUT=$(jq '.transactions[] | select((.transactionType=="CREATE") and (.contractName=="ApplicationERC721Pricing")) | .contractAddress' broadcast/Application_Deploy_06_Pricing.s.sol/80001/run-latest.json)
fi
APPLICATION_ERC721_PRICER="${APPLICATION_ERC721_PRICER_UNCUT//\"}"

echo $APPLICATION_ERC721_PRICER
echo 

bash script/ParseApplicationDeploy.sh 5

echo $APPLICATION_ERC20_1
echo 

forge build 

echo "################################################################"
echo  Mint a billion coins
echo "################################################################"
echo

echo $APP_ADMIN_1
echo $APP_ADMIN_1_KEY
echo $APPLICATION_ERC20_1

cast send $APPLICATION_ERC20_1 "mint(address,uint256)" $APP_ADMIN_1 10000000000000000000000000000000 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1 --rpc-url $ETH_RPC_URL

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

cast send $ORACLE_1_HANDLER "addAddressToApprovedList(address)" $APP_ADMIN_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

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