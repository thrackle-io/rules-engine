#!/bin/bash

function parseContractAddress() {
    ADDRESS_UNCUT=$(jq 'nth('$3'; .transactions[] | select((.transactionType=="CREATE") and (.contractName=="'$1'"))) | .contractAddress' broadcast/$4/$2/run-latest.json)
    ADDRESS="${ADDRESS_UNCUT//\"}"
    echo $ADDRESS
}

ENV_FILE=".env"

if [[ -n $CHAIN_ID ]]; then
  CHAIN_ID=${CHAIN_ID}
elif [[ -n $DB_CHAIN ]]; then
  CHAIN_ID=${DB_CHAIN}
else
  CHAIN_ID=31337
fi

settingChainID=false
NUMBER=1
  for var in "$@"
  do
    if [[ "$var" = "--chainid" ]]
    then
      settingChainID=true
    elif $settingChainID;
    then
      CHAIN_ID="$var"
      settingVal=false
    elif [[ "$var" = "--help" ]]
    then
      echo "--------------------------------------------------"
      echo "Possible Arguments:"
      echo "--chainid - set the chain id for the deployment"
      echo "--------------------------------------------------"
      exit
    else
      NUMBER="$var"
    fi
  done

echo

if [[ $NUMBER == 1 ]]; then
  # Retreive the App Manager
  APPLICATION_APP_MANAGER=$(parseContractAddress "ApplicationAppManager" $CHAIN_ID 0 "Application_Deploy_01_AppManager.s.sol")
  echo APPLICATION_APP_MANAGER=$APPLICATION_APP_MANAGER
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_APP_MANAGER=.*/APPLICATION_APP_MANAGER='$APPLICATION_APP_MANAGER'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_APP_MANAGER=.*/APPLICATION_APP_MANAGER='$APPLICATION_APP_MANAGER'/g' $ENV_FILE 
  fi

  # Retrieve the App Handler
  APPLICATION_APPLICATION_HANDLER=$(parseContractAddress "ApplicationHandler" $CHAIN_ID 0 "Application_Deploy_01_AppManager.s.sol")
  echo APPLICATION_APPLICATION_HANDLER=$APPLICATION_APPLICATION_HANDLER
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_APPLICATION_HANDLER=.*/APPLICATION_APPLICATION_HANDLER='$APPLICATION_APPLICATION_HANDLER'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_APPLICATION_HANDLER=.*/APPLICATION_APPLICATION_HANDLER='$APPLICATION_APPLICATION_HANDLER'/g' $ENV_FILE
  fi
fi

if [[ $NUMBER == 2 ]]; then
  # Retrieve the ERC 20
  APPLICATION_ERC20_ADDRESS=$(parseContractAddress "ApplicationERC20" $CHAIN_ID 0 "Application_Deploy_02_ApplicationFT1.s.sol")
  echo APPLICATION_ERC20_ADDRESS=$APPLICATION_ERC20_ADDRESS
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC20_ADDRESS=.*/APPLICATION_ERC20_ADDRESS='$APPLICATION_ERC20_ADDRESS'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC20_ADDRESS=.*/APPLICATION_ERC20_ADDRESS='$APPLICATION_ERC20_ADDRESS'/g' $ENV_FILE
  fi

  # Retrieve the ERC 20 Handler
  APPLICATION_ERC20_HANDLER_ADDRESS=$(parseContractAddress "HandlerDiamond" $CHAIN_ID 0 "Application_Deploy_02_ApplicationFT1.s.sol")
  echo APPLICATION_ERC20_HANDLER_ADDRESS=$APPLICATION_ERC20_HANDLER_ADDRESS
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC20_HANDLER_ADDRESS=.*/APPLICATION_ERC20_HANDLER_ADDRESS='$APPLICATION_ERC20_HANDLER_ADDRESS'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC20_HANDLER_ADDRESS=.*/APPLICATION_ERC20_HANDLER_ADDRESS='$APPLICATION_ERC20_HANDLER_ADDRESS'/g' $ENV_FILE 
  fi
fi
# # Retrieve the ERC 20
# APPLICATION_ERC20_ADDRESS_2=$(parseContractAddress "ApplicationERC20" $CHAIN_ID 1)
# echo APPLICATION_ERC20_ADDRESS=$APPLICATION_ERC20_ADDRESS_2
# echo

# os=$(uname -a)
# if [[ $os == *"Darwin"* ]]; then
#   sed -i '' 's/APPLICATION_ERC20_ADDRESS_2=.*/APPLICATION_ERC20_ADDRESS_2='$APPLICATION_ERC20_ADDRESS_2'/g' $ENV_FILE
# else
#   sed -i 's/APPLICATION_ERC20_ADDRESS_2=.*/APPLICATION_ERC20_ADDRESS_2='$APPLICATION_ERC20_ADDRESS_2'/g' $ENV_FILE 
# fi

if [[ $NUMBER == 3 ]]; then
  # Retrieve the ERC 721 
  APPLICATION_ERC721_ADDRESS_1=$(parseContractAddress "ApplicationERC721AdminOrOwnerMint" $CHAIN_ID 0 "Application_Deploy_04_ApplicationNFT.s.sol")
  echo APPLICATION_ERC721_ADDRESS_1=$APPLICATION_ERC721_ADDRESS_1
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC721_ADDRESS_1=.*/APPLICATION_ERC721_ADDRESS_1='$APPLICATION_ERC721_ADDRESS_1'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC721_ADDRESS_1=.*/APPLICATION_ERC721_ADDRESS_1='$APPLICATION_ERC721_ADDRESS_1'/g' $ENV_FILE
  fi

  # Retrieve the ERC 721 Handler
  APPLICATION_ERC721_HANDLER=$(parseContractAddress "HandlerDiamond" $CHAIN_ID 0 "Application_Deploy_04_ApplicationNFT.s.sol")
  echo APPLICATION_ERC721_HANDLER=$APPLICATION_ERC721_HANDLER
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC721_HANDLER=.*/APPLICATION_ERC721_HANDLER='$APPLICATION_ERC721_HANDLER'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC721_HANDLER=.*/APPLICATION_ERC721_HANDLER='$APPLICATION_ERC721_HANDLER'/g' $ENV_FILE 
  fi

  # Retrive the Upgradeable ERC 721
  APPLICATION_ERC721U_ADDRESS=$(parseContractAddress "ApplicationERC721UProxy" $CHAIN_ID 0 "Application_Deploy_04_ApplicationNFTUpgradeable.s.sol")
  echo APPLICATION_ERC721U_ADDRESS=$APPLICATION_ERC721U_ADDRESS
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC721U_ADDRESS=.*/APPLICATION_ERC721U_ADDRESS='$APPLICATION_ERC721U_ADDRESS'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC721U_ADDRESS=.*/APPLICATION_ERC721U_ADDRESS='$APPLICATION_ERC721U_ADDRESS'/g' $ENV_FILE
  fi

    # Retrieve the ERC 721U Handler
  APPLICATION_ERC721U_HANDLER=$(parseContractAddress "HandlerDiamond" $CHAIN_ID 0 "Application_Deploy_04_ApplicationNFTUpgradeable.s.sol")
  echo APPLICATION_ERC721U_HANDLER=$APPLICATION_ERC721U_HANDLER
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC721U_HANDLER=.*/APPLICATION_ERC721U_HANDLER='$APPLICATION_ERC721U_HANDLER'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC721U_HANDLER=.*/APPLICATION_ERC721U_HANDLER='$APPLICATION_ERC721U_HANDLER'/g' $ENV_FILE 
  fi
fi

if [[ $NUMBER == 4 ]]; then
  # Retrieve the Oracle Allowed Contract Address 
  APPLICATION_ORACLE_ALLOWED_ADDRESS=$(parseContractAddress "OracleApproved" $CHAIN_ID 0 "Application_Deploy_05_Oracle.s.sol")
  echo APPLICATION_ORACLE_ALLOWED_ADDRESS=$APPLICATION_ORACLE_ALLOWED_ADDRESS
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ORACLE_ALLOWED_ADDRESS=.*/APPLICATION_ORACLE_ALLOWED_ADDRESS='$APPLICATION_ORACLE_ALLOWED_ADDRESS'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ORACLE_ALLOWED_ADDRESS=.*/APPLICATION_ORACLE_ALLOWED_ADDRESS='$APPLICATION_ORACLE_ALLOWED_ADDRESS'/g' $ENV_FILE
  fi

  # Retrieve the Oracle Denied Contract Address 
  APPLICATION_ORACLE_DENIED_ADDRESS=$(parseContractAddress "OracleDenied" $CHAIN_ID 0 "Application_Deploy_05_Oracle.s.sol")
  echo APPLICATION_ORACLE_DENIED_ADDRESS=$APPLICATION_ORACLE_DENIED_ADDRESS
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ORACLE_DENIED_ADDRESS=.*/APPLICATION_ORACLE_DENIED_ADDRESS='$APPLICATION_ORACLE_DENIED_ADDRESS'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ORACLE_DENIED_ADDRESS=.*/APPLICATION_ORACLE_DENIED_ADDRESS='$APPLICATION_ORACLE_DENIED_ADDRESS'/g' $ENV_FILE 
  fi
fi

if [[ $NUMBER == 5 ]]; then
  # Retrieve the ERC 721 Pricing
  ERC721_PRICING_CONTRACT=$(parseContractAddress "ApplicationERC721Pricing" $CHAIN_ID 0 "Application_Deploy_06_Pricing.s.sol")
  echo ERC721_PRICING_CONTRACT=$ERC721_PRICING_CONTRACT
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/ERC721_PRICING_CONTRACT=.*/ERC721_PRICING_CONTRACT='$ERC721_PRICING_CONTRACT'/g' $ENV_FILE
  else
    sed -i 's/ERC721_PRICING_CONTRACT=.*/ERC721_PRICING_CONTRACT='$ERC721_PRICING_CONTRACT'/g' $ENV_FILE
  fi

  # Retrieve the ERC 20 Pricing
  ERC20_PRICING_CONTRACT=$(parseContractAddress "ApplicationERC20Pricing" $CHAIN_ID 0 "Application_Deploy_06_Pricing.s.sol")
  echo ERC20_PRICING_CONTRACT=$ERC20_PRICING_CONTRACT
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/ERC20_PRICING_CONTRACT=.*/ERC20_PRICING_CONTRACT='$ERC20_PRICING_CONTRACT'/g' $ENV_FILE
  else
    sed -i 's/ERC20_PRICING_CONTRACT=.*/ERC20_PRICING_CONTRACT='$ERC20_PRICING_CONTRACT'/g' $ENV_FILE 
  fi
fi

if [[ $NUMBER == 6 ]]; then
  # Retrieve the ERC 20
  APPLICATION_ERC20_ADDRESS_2=$(parseContractAddress "ApplicationERC20" $CHAIN_ID 0 "Application_Deploy_03_ApplicationFT2.s.sol")
  echo APPLICATION_ERC20_ADDRESS_2=$APPLICATION_ERC20_ADDRESS_2
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC20_ADDRESS_2=.*/APPLICATION_ERC20_ADDRESS_2='$APPLICATION_ERC20_ADDRESS_2'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC20_ADDRESS_2=.*/APPLICATION_ERC20_ADDRESS_2='$APPLICATION_ERC20_ADDRESS_2'/g' $ENV_FILE
  fi

  # Retrieve the ERC 20 Handler
  APPLICATION_ERC20_HANDLER_ADDRESS_2=$(parseContractAddress "HandlerDiamond" $CHAIN_ID 0 "Application_Deploy_03_ApplicationFT2.s.sol")
  echo APPLICATION_ERC20_HANDLER_ADDRESS_2=$APPLICATION_ERC20_HANDLER_ADDRESS_2
  echo

  os=$(uname -a)
  if [[ $os == *"Darwin"* ]]; then
    sed -i '' 's/APPLICATION_ERC20_HANDLER_ADDRESS_2=.*/APPLICATION_ERC20_HANDLER_ADDRESS_2='$APPLICATION_ERC20_HANDLER_ADDRESS_2'/g' $ENV_FILE
  else
    sed -i 's/APPLICATION_ERC20_HANDLER_ADDRESS_2=.*/APPLICATION_ERC20_HANDLER_ADDRESS_2='$APPLICATION_ERC20_HANDLER_ADDRESS_2'/g' $ENV_FILE 
  fi
fi

