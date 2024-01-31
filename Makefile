# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean remove install update solc build deploy

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_17

# Clean the repo
clean  :;	forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the Modules
install :; 
	sudo apt-get update
	sudo apt-get install -y python3-pip
	pip3 install eth_abi
	forge install dapphub/ds-test 
	forge install OpenZeppelin/openzeppelin-contracts
# Update Dependencies
update:; forge update
# Builds
build  :; forge clean && forge build --optimize
# Test 
testAll:; forge test -vv --ffi 

# Deploy contracts(singles)
deployApplicationHandler:; 	forge script script/ApplicationHandlerModule.s.sol --ffi --broadcast -vvv
deployApplicationManager:;	forge script script/ApplicationAppManager.s.sol --ffi --broadcast -vvv
deployRuleStorageDiamond:; forge script script/RuleStorageModule.s.sol --ffi --broadcast -vvv
deployRuleProcessor:; forge script script/RuleProcessorModule.s.sol --ffi --broadcast -vvv
deployTokenRuleRouter:; forge script script/TokenRuleRouter.s.sol --ffi --broadcast -vvv
deployTaggedRuleProcessor:; forge script script/TaggedRuleProcessor.s.sol --ffi --broadcast -vvv
# Deploy contracts(full protocol)
deployAll:;	forge script script/DeployAllModules.s.sol --ffi --broadcast -vvv
# Deploy Application Contracts(singles)
deployApplicationAppManager:; forge script src/example/script/ApplicationAppManager.s.sol --ffi --broadcast -vvv
deployApplicationERC20Handler:; forge script src/example/script/ApplicationERC20Handler.s.sol --ffi --broadcast -vvv
deployApplicationERC20:; forge script src/example/script/ApplicationERC20.s.sol --ffi --broadcast -vvv
# Deploy Application Contracts(entire application implementation)
deployAllApp:; forge script script/clientScripts/ApplicationDeployAll.s.sol --ffi  --broadcast -vvv
deployNewApp:; forge script script/clientScripts/ApplicationUIDeploy.s.sol --ffi  --broadcast -vvv
# Using a different env ref for pipeline deploy command.
# Note from RK -- Outside the scope of what I'm doing right now, but
# This could also be accomplished by creating a "pipeline" profile in foundry.toml which
# defines its own value for eth-rpc-url, similarly to how the docker profile is set up now,
# and then having the deploy pipeline set FOUNDRY_PROFILE=pipeline in the build environment
deployAllPipeline:; forge script script/DeployAllModules.s.sol --ffi --rpc-url ${PIPELINE_ETH_RPC_URL} --broadcast --verify -vvvv
deployAllPipelineResume:; forge script script/DeployAllModules.s.sol --ffi --rpc-url ${PIPELINE_ETH_RPC_URL} --broadcast --verify -vvvv --resume

			
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>    TERMINAL TESTS    <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# Testing is in modules: Access, Rule, AMM and Staking   
# Command names should be unique for each test and not reused in this file. command_test.txt can reuse command names for running the full test at once. 
# If a command is reused in command_test.txt comment what action was taken not reused command 
# Addresses are stored in env and referenced here. 

# <><><><><><><><><><> ACCESS MODULE TESTS <><><><><><><><><><>
addAppAdministrator:; cast send ${APPLICATION_APP_MANAGER} "addAppAdministrator(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
checkAppAdministrator:; cast call ${APPLICATION_APP_MANAGER} "isAppAdministrator(address)(bool)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
addAccessTier:; cast send ${APPLICATION_APP_MANAGER} "addAccessTier(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
checkAccessTier:; cast call ${APPLICATION_APP_MANAGER} "isAccessTier(address)(bool)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
addRiskAdmin:; cast send ${APPLICATION_APP_MANAGER} "addRiskAdmin(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
checkRiskAdmin:; cast call ${APPLICATION_APP_MANAGER} "isRiskAdmin(address)(bool)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}

checkApplicationHandlerInquire:; cast call ${APPLICATION_HANDLER} "checkAction(uint8,address, address)(bool)" ${ACTION_INQUIRE} ${APPLICATION_APP_MANAGER} ${ADDRESS_USER} --private-key ${PRIVATE_KEY_01} 
checkApplicationHandlerInquire2:; cast call ${APPLICATION_APP_MANAGER} "checkAction(uint8,address)(bool)" ${ACTION_INQUIRE} ${ADDRESS_USER} --private-key ${PRIVATE_KEY_01} 
checkApplicationHandlerSell:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,int8)" ${ADDRESS_USER} 4  --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkApplicationHandlerSell2:; cast call ${APPLICATION_HANDLER} "checkAction(uint8,address, address)(bool)" ${ACTION_SELL} ${APPLICATION_APP_MANAGER} ${ADDRESS_USER} --private-key ${PRIVATE_KEY_01} 
checkRulesAddRule:; cast send ${RULE_STORAGE_DIAMOND} "addTokenMaxBuyVolume(address,uint16,uint32)(uint256)" ${APPLICATION_APP_MANAGER} 9000 2 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

# <><><><><><><><><><> APP MANAGER TESTS <><><><><><><><><><>
addMultipleAppAdmins:; cast send ${APPLICATION_APP_MANAGER} "addMultipleAppAdministrator(address[])" [${QUORRA},${CLU},${SAM}]  --private-key ${QUORRA_PRIVATE_KEY}
checkMultipleAppAdmins:; cast call ${APPLICATION_APP_MANAGER} "isAppAdministrator(address)(bool)" ${CLU}  --private-key ${QUORRA_PRIVATE_KEY}
addMultipleAccessTierAdmins:; cast send ${APPLICATION_APP_MANAGER} "addMultipleAccessTier(address[])" [${QUORRA},${CLU},${SAM}]  --private-key ${QUORRA_PRIVATE_KEY}
checkMultipleAccessTierAdmins:; cast call ${APPLICATION_APP_MANAGER} "isAccessTier(address)(bool)" ${SAM}  --private-key ${QUORRA_PRIVATE_KEY}
addMultipleRiskAdmins:; cast send ${APPLICATION_APP_MANAGER} "addMultipleRiskAdmin(address[])" [${QUORRA},${CLU},${SAM}]  --private-key ${QUORRA_PRIVATE_KEY}
checkMultipleRiskAdmins:; cast call ${APPLICATION_APP_MANAGER} "isRiskAdmin(address)(bool)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
addTagToMultipleUsers:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTagToMultipleAccounts(address[],bytes32)" [${QUORRA},${CLU},${SAM}] 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkTagToMultipleUsers:; cast call ${APPLICATION_APP_MANAGER} "hasTag(address, bytes32)(bool)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
removeGeneralTag:; cast send ${APPLICATION_APP_MANAGER} "removeGeneralTag(address, bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
addMultipleTagsToMultipleUsers:; cast send ${APPLICATION_APP_MANAGER} "addMultipleGeneralTagToMultipleAccounts(address[], bytes32[])" [${QUORRA},${CLU},${SAM}] [0x5441472100000000000000000000000000000000000000000000000000000000,0x5441472100000000000000000000000000000000000000000000000000000000,0x5441472100000000000000000000000000000000000000000000000000000000] --private-key ${QUORRA_PRIVATE_KEY}

addMultipleRiskScores:; cast send ${APPLICATION_APP_MANAGER} "addMultipleRiskScores(address[], uint8[])" [${QUORRA},${CLU},${SAM}] [10,20,99] --private-key ${QUORRA_PRIVATE_KEY}
checkMultipleRiskScores:; cast call ${APPLICATION_APP_MANAGER} "getRiskScore(address)" ${SAM} --private-key ${QUORRA_PRIVATE_KEY}
addRiskScoreToMultipleAccounts:; cast send ${APPLICATION_APP_MANAGER} "addRiskScoreToMultipleAccounts(address[], uint8)" [${QUORRA},${CLU},${SAM}] 25 --private-key ${QUORRA_PRIVATE_KEY}

addMultipleAccessTiers:; cast send ${APPLICATION_APP_MANAGER} "addMultipleAccessLevels(address[], uint8[])" [${QUORRA},${CLU},${SAM}] [1,2,4] --private-key ${QUORRA_PRIVATE_KEY}
checkMultipleAccessTiers:; cast call ${APPLICATION_APP_MANAGER} "getAccessLevel(address)" ${SAM} --private-key ${QUORRA_PRIVATE_KEY}
addAccessTierToMultipleAccounts:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevelToMultipleAccounts(address[], uint8)" [${QUORRA},${CLU},${SAM}] 4 --private-key ${QUORRA_PRIVATE_KEY}

# <><><><><><><><><><> PROCESSOR MODULE TESTS  <><><><><><><><><><>
# Rule Module contains sectioned tests for ERC20 and ERC721 
# <><><><><><><><><><> ERC20 TESTS  <><><><><><><><><><>

#			<><><><><> Minimum Transfer Rule <><><><><>
loadUserWithTokens:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceKevin1:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${KEVIN} --from ${KEVIN}
addMinTransferRule:; cast send ${RULE_STORAGE_DIAMOND} "addTokenMinTxSize(address,uint256)(uint256)" ${APPLICATION_APP_MANAGER} 10 ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyMinTransferRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setTokenMinTxSizeId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkERC20PassMinTransfer:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC20FailMinTransfer:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 5 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> Min Max Balance Rule ERC20 <><><><><>
checkAddAccountBalanceRule:; cast send ${RULE_STORAGE_DIAMOND} "addBalanceLimitRules(address,bytes32[],uint256[],uint256[])(uint256)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [10] [100000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyAccountBalanceRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountMinMaxTokenBalanceId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addGeneralTagMinMax:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkERC20PassMinMaxBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC20FailMinBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC20FailMaxBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100001 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkBalanceClu:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}
checkBalanceClu2:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}

#			<><><><><> Purchase Limit Rule <><><><><>
addPurchaseLimitRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxBuySize(address,bytes32[],uint192[],uint32[],uint32[])" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [99] [24] [24] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyPurchaseLimitRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountMaxBuySizeId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkAddGeneralTag:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkPassPurchaseLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 99 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkFailPurchaseLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 101 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
#			<><><><><> Sell Limit Rule <><><><><>
addSellLimitRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxSellSize(address,bytes32[],uint192[],uint32[])" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [100] [24] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applySellLimitRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountMaxSellSizeId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkAddGeneralTagSellLimit:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkPassSellLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 99 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
checkFailSellLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 101 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}

#			<><><><><> ORACLE RULE <><><><><>
loadUserWithTokensOracle:; :; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addAccountApproveDenyOracle:; cast send ${RULE_STORAGE_DIAMOND} "addAccountApproveDenyOracle(address,uint8,address)(uint256)" ${APPLICATION_APP_MANAGER} 0 ${APPLICATION_ORACLE_0_ADDRESS} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyAccountApproveDenyOracle:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountApproveDenyOracleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
mintFranksOracle:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 10000000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceFranksOracle:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${QUORRA} --from ${KEVIN}
TransferFranksToKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 10000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkFranksBalanceKevin:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${KEVIN} --from ${KEVIN}
AddCluToRestrictionOracle:; cast send ${APPLICATION_ORACLE_1_ADDRESS} "addAddressToSanctionsList(address)" ${CLU} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferFranksFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> TOKEN REGISTRATION <><><><><>
checkTokenRegistered:; cast call ${APPLICATION_APP_MANAGER} "getTokenAddress(string)(address)" "Frankenstein" --from ${KEVIN}

#			<><><><><> BALANCE BY AccessLevel RULE <><><><><>
# mint Franks and dracs 
loadUserWithFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
loadUserWithDracs:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkDracsBalanceSam:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${SAM} --from ${SAM}
addBalanceByAccessLevelRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxValueByAccessLevel(address,uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [0,10,100,1000,100000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyBalanceByAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountMaxValueByAccessLevelId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceByAccessLevelRuleActive:; cast call ${APPLICATION_APPLICATION_HANDLER} "isAccountMaxValueByAccessLevelActive()(bool)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applicationAddCluAsAccessTier:; cast send ${APPLICATION_APP_MANAGER} "addAccessTier(address)" ${CLU}  --private-key ${QUORRA_PRIVATE_KEY}
applicationAddAccessLevel1toKevin:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${KEVIN} 1 --private-key ${CLU_PRIVATE_KEY}
applicationGetKevinAccessLevel:; cast call ${APPLICATION_APP_MANAGER} "getAccessLevel(address)(uint8)" ${KEVIN}  --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
getFrankPrice:; cast call ${ERC20_PRICING_CONTRACT} "getTokenPrice(address)(uint256)" ${APPLICATION_ERC20_ADDRESS} --private-key ${QUORRA_PRIVATE_KEY}
getDracPrice:; cast call ${ERC20_PRICING_CONTRACT} "getTokenPrice(address)(uint256)" ${APPLICATION_ERC20_ADDRESS_2} --private-key ${QUORRA_PRIVATE_KEY}
Transfer1DracToKevin:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${KEVIN} 1000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkDracsBalanceKevin:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${KEVIN} --from ${KEVIN}
Transfer9FranksToKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 9000000000000000000 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
Transfer1FranksToKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 1000000000000000000 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}

#			<><><><><> WITHDRAWAL BY ACCESS LEVEL RULE <><><><><>
# mint Franks and dracs 
sendFranksFromQuorraToKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 10000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
sendDracsFromSQuorraToKevin:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${KEVIN} 10000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addWithdrawalByAccessLevelRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxValueOutByAccessLevel(address,uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [0,10,100,1000,100000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyWithdrawalByAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountMaxValueOutByAccessLevelId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# add kevin access level 1 
transferFranksFromKevintoSamSuccess:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 9000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
transferDracsFromKevinToSameSuccess:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# Kevin is now at the Access Level limit and all transfers will fail unless given higher access level 
transferFranksToSamFromKevinFail:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
transferDracsToSameFromKevinFail:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}


#			<><><><><> MAX TX SIZE PER PERIOD BY RISK SCORE RULES <><><><><>
addSamAsRiskAdminMaxTX:; cast send ${APPLICATION_APP_MANAGER} "addRiskAdmin(address)" ${SAM} --private-key ${QUORRA_PRIVATE_KEY} 
addAccountMaxTxValueByRiskScore:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxTxValueByRiskScore(address,uint48[],uint8[],uint8,uint8)(uint32)" ${APPLICATION_APP_MANAGER} [10000000000,10000000,10000,1] [25,50,75] 12 12 --private-key ${QUORRA_PRIVATE_KEY} 
assignCluRiskScoreOf55:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${CLU} 55 --private-key ${SAM_PRIVATE_KEY} 
applyMaxTxSizePerPeriodByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountMaxTxValueByRiskScoreId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY}
checkAccountMaxTxValueByRiskScoreIsActive:; cast call ${APPLICATION_APPLICATION_HANDLER} "isAccountMaxTxValueByRiskScoreActive()(bool)"
loadCluWithFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
loadKevinWithFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 100000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
turnOffMaxTxSizePerPeriodByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountMaxTxValueByRiskScore(bool)" 0 --private-key ${QUORRA_PRIVATE_KEY} 
turnOnMaxTxSizePerPeriodByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountMaxTxValueByRiskScore(bool)" 1 --private-key ${QUORRA_PRIVATE_KEY} 
moveForwardInTime6Hours:; curl -H "Content-Type: application/json" -X POST --data '{"id":31337,"jsonrpc":"2.0","method":"evm_increaseTime","params":[21600]}' http://localhost:8545
cluTransfers2FrankToKevin:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${KEVIN} 2000000000000000000 --private-key ${CLU_PRIVATE_KEY}
cluTransfers9998FrankToKevin:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${KEVIN} 9998000000000000000000 --private-key ${CLU_PRIVATE_KEY}
kevinTransfers2FrankToClu:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 2000000000000000000 --private-key ${KEVIN_PRIVATE_KEY}
kevinTransfers9998FrankToClu:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 9998000000000000000000 --private-key ${KEVIN_PRIVATE_KEY}


#			<><><><><> ACCOUNT BALANCE BY RISK RULE <><><><><>
# mint Franks and give user Franks 
addAccountBalanceByRiskRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxValueByRiskScore(address,uint8[],uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [10,20,30,40,50,60,70,80,90] [1000000000,1000000000,100000000,10000000,1000000,100000,10000,1000,100,10] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyAccountBalanceByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountMaxValueByRiskScoreId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addSamAsRiskAdmin:; cast send ${APPLICATION_APP_MANAGER} "addRiskAdmin(address)" ${SAM}  --private-key ${QUORRA_PRIVATE_KEY}
addRiskScoreKevin:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${KEVIN}  10 --private-key ${SAM_PRIVATE_KEY}
addRiskScoreClu:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${CLU}  90 --private-key ${SAM_PRIVATE_KEY}
#test transfer passes 
transferFranksSamtoKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 10000000000000000000 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
#test transfer fails 
transferFranksFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 1000000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> TRANSACTION LIMIT BY RISK RULE <><><><><>
# mint Franks and give user Franks 
addAccountMaxTxValueByRiskScore:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxTxValueByRiskScore(address,uint8[],uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [10,20,30,40,50,60,70,80,90] [1000000000,1000000000,100000000,10000000,1000000,100000,10000,1000,100,10] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyTransactionLimitByRiskScore:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setTransactionLimitByRiskRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# add Risk Scores to Kevin and Clu 
# transfer Franks From Sam to Kevin 
# transfer Franks From Kevin To Clu <<should fail>> 



#			<><><><><> AccessLevel = 0 RULES <><><><><>
# mint FrankNFT to Quorra 
# transfer Frank NFT To Kevin
# mint Franks ERC20 to Quorra 
# transfer Frank NFT From Kevin To Sam
transferFranksFromKevinToSam:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
transferFrankNFTFromSamToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${SAM} ${KEVIN} 0 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
turnOnAccountDenyForNoAccessLevelRuleForNFT:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountDenyForNoAccessLevelRule(bool)" true --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
turnOnAccountDenyForNoAccessLevelRuleForCoin:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountDenyForNoAccessLevelRule(bool)" true --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addQuorraAsAccessTier:; cast send ${APPLICATION_APP_MANAGER} "addAccessTier(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
addAccessLevel1toSam:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${SAM} 1 --private-key ${QUORRA_PRIVATE_KEY}
# transferFrankNFTFromKevinToSam 
addAccountDenyForNoAccessLeveltoSam:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${SAM} 0 --private-key ${QUORRA_PRIVATE_KEY}
# these should fail
# transferFrankNFTFromKevinToSam
# transferFranksFromKevinToSam

#			<><><><><> ADMIN WITHDRAWAL RULE <><><><><>
mintAMillFranksToQuorra:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 1000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
registerAdminMinTokenBalanceA:; cast send ${RULE_STORAGE_DIAMOND} "addAdminMinTokenBalance(address,uint256,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 1000000000000000000000000 1704110400 --private-key ${QUORRA_PRIVATE_KEY}
registerAdminMinTokenBalanceB:; cast send ${RULE_STORAGE_DIAMOND} "addAdminMinTokenBalance(address,uint256,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 100000000000000000000000 1709294400 --private-key ${QUORRA_PRIVATE_KEY}
applyAdminMinTokenBalanceA:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAdminMinTokenBalanceId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY}
applyAdminMinTokenBalanceB:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAdminMinTokenBalanceId(uint32)" 1 --private-key ${QUORRA_PRIVATE_KEY}
turnOffAdminMinTokenBalance:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "activateAdminMinTokenBalance(bool)" 0 --private-key ${QUORRA_PRIVATE_KEY}
turnOnAdminMinTokenBalance:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "activateAdminMinTokenBalance(bool)" 1 --private-key ${QUORRA_PRIVATE_KEY}
transferFromQuorraToCluToBreakRuleA:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 800000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY}
transferFromQuorraToCluToBreakRuleB:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 100000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY}

#			<><><><><> ERC20 TRANSFER VOLUME RULE <><><><><>
# mintFranks
# giveKevin1000Franks
addTokenMaxTradingVolume:; cast send ${RULE_STORAGE_DIAMOND} "addTokenMaxTradingVolume(address, uint16, uint8, uint64,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 200 2 0 1000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyTokenMaxTradingVolumeToToken:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setTokenMaxTradingVolumeId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# these should pass but will contribute to the threshold being reached
Transfer19FranksFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 19 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# this one should fail
Transfer1FrankFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
moveForwardInTime2Days:; curl -H "Content-Type: application/json" -X POST --data '{"id":31337,"jsonrpc":"2.0","method":"evm_increaseTime","params":[172800]}' http://localhost:8545
# Now it should pass
# Transfer1FrankFromKevinToClu

#			<><><><><> Token Fees <><><><><>
			# Mint a bunch of Frankenstein coins to the main admin
# mintFranks
			# create the token fee rule 
tokenFee_createTokenFeeRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "addFee(bytes32,uint256, uint256,int24, address)" 0x5461796c65720000000000000000000000000000000000000000000000000000 0 1000000000000000000 300 ${FEE_TREASURY} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
			# transfer tokens to a non admin
tokenFee_transferTokensToUser1:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
 			# tag the initiating account with fee tag
tokenFee_AddGeneralTag:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
			# transfer some tokens that will cause a fee
tokenFee_transferTokensFromUser1ToUser2:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 1000 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
_tokenFee_checkFranksBalanceUser2:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${KEVIN} --from ${KEVIN}
_tokenFee_checkFranksBalanceUser1:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}

# <><><><><><><><><><> ERC721 TESTS  <><><><><><><><><><>
#			<><><><><> NFT Trade Counter RULE <><><><><>
# Application Administrators Mints an Frankenstein NFT
mintFrankNFT:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${QUORRA} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Create an NFT Trade Counter Rule for any NFT tagged as a "BoredGrape" to only allow 1 trade per day
addTokenMaxDailyTrades:; cast send ${RULE_STORAGE_DIAMOND} "addTokenMaxDailyTrades(address,bytes32[],uint8[])(uint256)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [1] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Apply the NFT Trade Counter Rule to Frankenstein NFT
applytokenMaxDailyTradesRules:; cast send ${APPLICATION_ERC721_HANDLER} "setTokenMaxDailyTradesId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Tag the Frankenstein NFT with "BoredGrape" metadata tag
tagFrankNFT:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${APPLICATION_ERC721_ADDRESS_1} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
# Verify Frankenstein NFT is a "BoredGrape"
hasTagFrankNFT:; cast call ${APPLICATION_APP_MANAGER} "hasTag(address, bytes32)(bool)" ${APPLICATION_ERC721_ADDRESS_1} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY} 
# Transfer Frankenstein NFT to Kevin(This transfer won't count toward rule because one party is a AppAdministrator)
transferFrankNFTToKevin:;cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${KEVIN} 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Transfer Frankenstein NFT from Kevin to Sam(This one will count toward the rule transfers)
transferFrankNFTFromKevinToSam:;cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${SAM} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# Transfer Frankenstein NFT from Sam to Clu(This one should fail)
transferFrankNFTFromSamToClu:;cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${SAM} ${CLU} 0 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
# Check the Frankenstein NFT balances to make sure transfer did not occur
checkFrankNFTBalanceClu:; cast call ${APPLICATION_ERC721_ADDRESS_1} "balanceOf(address)(uint256)" ${CLU} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkNFTBalanceSam:; cast call ${APPLICATION_ERC721_ADDRESS_1} "balanceOf(address)(uint256)" ${SAM} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Make sure the DeLorean hits 88 mph and time travel one day into the future
moveForwardInTime1Day:; curl -H "Content-Type: application/json" -X POST --data '{"id":31337,"jsonrpc":"2.0","method":"evm_increaseTime","params":[86400]}' http://localhost:8545
# Transfer Frankenstein NFT from Sam to Clu(This will now complete successfully)
transferFrankNFTFromSamToCluAgain:;cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${SAM} ${CLU} 0 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
#checkNFTBalanceClu
# !!!! NOTE !!!! They could turn this into a soulbound NFT by setting the trades at 0

#			<><><><><> AccessLevel LEVEL RULES NFT <><><><><>
addAccountMaxValueByAccessLevel:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxValueByAccessLevel(address,uint48[])" ${APPLICATION_APP_MANAGER} [15,30,60,120,210] --private-key ${QUORRA_PRIVATE_KEY} 
makeKevinAccessTier:; cast send ${APPLICATION_APP_MANAGER} "addAccessTier(address)" ${KEVIN}  --private-key ${QUORRA_PRIVATE_KEY}
giveGemAccessLevel2:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${GEM} 2 --private-key ${KEVIN_PRIVATE_KEY}
giveSamAccessLevel3:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${SAM} 3 --private-key ${KEVIN_PRIVATE_KEY}
getAccessLevelForGem:; cast call ${APPLICATION_APP_MANAGER} "getAccessLevel(address)(address,uint256,int8,bool)" ${GEM}  
mintAnNFTForClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${CLU} --private-key ${QUORRA_PRIVATE_KEY} 
setNFT0A50USDPrice:; cast send ${ERC721_PRICING_CONTRACT} "setSingleNFTPrice(address,uint256,uint256)" ${APPLICATION_ERC721_ADDRESS_1} 0 49990000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
setNFT2A150USDPrice:; cast send ${ERC721_PRICING_CONTRACT} "setSingleNFTPrice(address,uint256,uint256)" ${APPLICATION_ERC721_ADDRESS_1} 2 150000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
setNFT4A200USDPrice:; cast send ${ERC721_PRICING_CONTRACT} "setSingleNFTPrice(address,uint256,uint256)" ${APPLICATION_ERC721_ADDRESS_1} 4 200000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
send10USDWorthOfCoinsToGem:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${GEM} 10000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
send10USDWorthOfCoinsToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 10000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
send10USDWorthOfCoinsToSam:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${SAM} 10000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
applyAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountMaxValueByAccessLevelId(uint32)" 0  --private-key ${QUORRA_PRIVATE_KEY} 
tryToTransferNFT2ToGem:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${GEM} 2 --private-key ${CLU_PRIVATE_KEY} 
transferNFT1ToGem:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${GEM} 1 --private-key ${CLU_PRIVATE_KEY} 
tryToTransferNFT4ToSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${SAM} 4 --private-key ${CLU_PRIVATE_KEY} 
transferNFT0ToSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${SAM} 0 --private-key ${CLU_PRIVATE_KEY} 
mintCoinsForQuorra:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 100000000000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
turnOffAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountMaxValueByAccessLevel(bool)" 0 --private-key ${QUORRA_PRIVATE_KEY} 
turnOnAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountMaxValueByAccessLevel(bool)" 1 --private-key ${QUORRA_PRIVATE_KEY} 


#			<><><><><> NFT Application Administrators Withdrawal Rule <><><><><>  
# Mint NFTs to app admin account 
mintFrankNFTforAdmin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${QUORRA} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Add Rule
addNFTAdminMinTokenBalance:; cast send ${RULE_STORAGE_DIAMOND} "addAdminMinTokenBalance(address,uint256,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 5 1704110400 --private-key ${QUORRA_PRIVATE_KEY}
# Apply Withdrawal rule 
applyNFTAdminMinTokenBalance:; cast send ${APPLICATION_ERC721_HANDLER} "setAdminMinTokenBalanceId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY}
# Attempt to transfer before rule expires (fails)
transferFrankNFTFromQuorraToSamFails:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${SAM} 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Move time to after rule 
moveForwardInTime1Year:; curl -H "Content-Type: application/json" -X POST --data '{"id":31337,"jsonrpc":"2.0","method":"evm_increaseTime","params":[31536000]}' http://localhost:8545
# Transfer NFTs 
transferNFTFromQuorraToSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${SAM} 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

#			<><><><><> NFT TransactionLimitByRisk RULE <><><><><>
# <<Quorra mints 0-4 token IDs>>
addAccountMaxTxValueByRiskScoreNFTrule:; cast send ${RULE_STORAGE_DIAMOND} "addAccountMaxTxValueByRiskScore(address,uint8[],uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [10,20,30,40,50,60,70,80,90] [70000,60000,50000,40000,30000,20000,10000,1000,100,10] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyTransactionLimitByRiskScoreNFT:; cast send ${APPLICATION_ERC721_HANDLER} "setTransactionLimitByRiskRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# add Sam As Risk Admin
addRiskScoreGem:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${GEM}  10 --private-key ${SAM_PRIVATE_KEY}
addRiskScoreCluNFT:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${CLU} 90 --private-key ${SAM_PRIVATE_KEY}
# NFT 0 to 50USD Price
# NFT 2 to 150USD Price
setNFT4A20000USDPrice:; cast send ${ERC721_PRICING_CONTRACT} "setSingleNFTPrice(address,uint256,uint256)" ${APPLICATION_ERC721_ADDRESS_1} 4 20000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY}  
getRiskScoreGem:; cast call ${APPLICATION_APP_MANAGER} "getRiskScore(address)(uint8)" ${GEM} ${NFT1} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
getRiskScoreClu:; cast call ${APPLICATION_APP_MANAGER} "getRiskScore(address)(uint8)" ${CLU} ${NFT1} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
transferNFT2ToGem:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${GEM} 2 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
NFT1TransferToGem:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${GEM} 1 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
transferNFT4ToGem:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${GEM} 4 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
tryToTransferNFT4ToCluFail:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${GEM} ${CLU} 4 --private-key ${GEM_PRIVATE_KEY} --from ${GEM}

#			<><><><><> Min Max Balance Rule ERC721 <><><><><>
addAccountBalanceRuleNFT:; cast send ${RULE_STORAGE_DIAMOND} "addBalanceLimitRules(address,bytes32[],uint256[],uint256[])(uint256)" ${APPLICATION_APP_MANAGER} [0x4f73636172000000000000000000000000000000000000000000000000000000] [1] [4] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyAccountBalanceRuleNFT:; cast send ${APPLICATION_ERC721_HANDLER} "setAccountMinMaxTokenBalanceId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkAddGeneralTagNFT:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x4f73636172000000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkERC721PassMinMaxBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC721FailMinBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC721FailMaxBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100001 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkNFTBalanceClu:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}
transferNFT1FromCluToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${KEVIN} 1 --private-key ${CLU_PRIVATE_KEY} 
transferNFT2FromCluToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${KEVIN} 2 --private-key ${CLU_PRIVATE_KEY} 
transferNFT3FromCluToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${KEVIN} 3 --private-key ${CLU_PRIVATE_KEY} 
transferNFT0FromCluToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${KEVIN} 0 --private-key ${CLU_PRIVATE_KEY} 
transferNFT4FromCluToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${KEVIN} 4 --private-key ${CLU_PRIVATE_KEY} 
transferNFT5FromCluToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${KEVIN} 5 --private-key ${CLU_PRIVATE_KEY} 
transferNFT6FromCluToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${KEVIN} 6 --private-key ${CLU_PRIVATE_KEY} 
transferNFT1FromToKevinClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${KEVIN} ${CLU} 1 --private-key ${KEVIN_PRIVATE_KEY} 
transferNFT2FromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${KEVIN} ${CLU} 2 --private-key ${KEVIN_PRIVATE_KEY} 
transferNFT3FromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${KEVIN} ${CLU} 3 --private-key ${KEVIN_PRIVATE_KEY} 
transferNFT0FromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${KEVIN} ${CLU} 0 --private-key ${KEVIN_PRIVATE_KEY} 
transferNFT4FromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${KEVIN} ${CLU} 4 --private-key ${KEVIN_PRIVATE_KEY} 
transferNFT5FromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${KEVIN} ${CLU} 5 --private-key ${KEVIN_PRIVATE_KEY} 
transferNFT6FromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${KEVIN} ${CLU} 6 --private-key ${KEVIN_PRIVATE_KEY} 

#			<><><><><> ERC721 TRANSFER VOLUME RULE <><><><><>
TransferVolumeMintFrankNFT1forKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${KEVIN} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferVolumeMintFrankNFT2forKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${KEVIN} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferVolumeAddTokenMaxTradingVolume:; cast send ${RULE_STORAGE_DIAMOND} "addTokenMaxTradingVolume(address, uint16, uint8, uint64,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 2000 48 0 10 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferVolumeApplyTokenMaxTradingVolumeToToken:; cast send ${APPLICATION_ERC721_HANDLER} "setTokenMaxTradingVolumeId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# this should pass
TransferVolumeTransferNFT0ToFromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${CLU} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# this one should fail
TransferVolumeTransferNFT1ToFromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${CLU} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
TransferVolumeMoveForwardInTime2Days:; curl -H "Content-Type: application/json" -X POST --data '{"id":31337,"jsonrpc":"2.0","method":"evm_increaseTime","params":[172800]}' http://localhost:8545
# Now it should pass
# TransferVolumeTransferNFT1ToFromKevinToClu

#			<><><><><> ERC721 MINT FEE  <><><><><>
# This test requires that the safeMint and associated functions are uncommented in the applicationERC721 contract.
setMintPrice:; cast send ${APPLICATION_ERC721_ADDRESS_1} "setMintPrice(uint256)" 1 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
setTreasuryAddress:; cast send ${APPLICATION_ERC721_ADDRESS_1} "setTreasuryAddress(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
mintPaidFrankNFT:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${CLU} --private-key ${CLU_PRIVATE_KEY} --from ${CLU} --value 1ether
mintPaidFrankNFTNoEther:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${CLU} --private-key ${CLU_PRIVATE_KEY} --from ${CLU} 


#			<><><><><><><><><><><><><><><> UPGRADEABILITY  <><><><><><><><><><><><><><><>
# <<AppManager Upgrade>> 
addAccessTierUpgrade:; cast send ${APPLICATION_APP_MANAGER} "addAccessTier(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
checkAccessTierUpgrade:; cast call ${APPLICATION_APP_MANAGER} "isAccessTier(address)(bool)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
setGemAccessLevel3Upgrade:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${GEM} 3 --private-key ${QUORRA_PRIVATE_KEY}
getAccessLevelForGemUpgrade:; cast call ${APPLICATION_APP_MANAGER} "getAccessLevel(address)(uint8)" ${GEM}  --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
migrateDataContractsToNewAppManager:;  cast send ${APPLICATION_APP_MANAGER} "migrateDataContracts(address)" ${APPLICATION_APP_MANAGER_2}  --private-key ${QUORRA_PRIVATE_KEY}
connectDataContractsToNewAppManager:;  cast send ${APPLICATION_APP_MANAGER_2} "connectDataContracts(address)" ${APPLICATION_APP_MANAGER}  --private-key ${QUORRA_PRIVATE_KEY}
applicationGetAccessLevelUpgrade2:; cast call ${APPLICATION_APP_MANAGER_2} "getAccessLevel(address)(uint8)" ${GEM}  --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

# <<ApplicationERC20Handler Upgrade>> 
tokenFee_createTokenFeeRuleUpgrade:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "addFee(bytes32,uint256, uint256,int24, address)" 0x5461796c65720000000000000000000000000000000000000000000000000000 0 1000000000000000000 300 ${FEE_TREASURY} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
tokenFee_checkTokenFeeRuleUpgrade:; cast call ${APPLICATION_ERC20_HANDLER_ADDRESS} "getFeeTotal()(uint256)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
migrateDataContractsToNewCoinHandler:;  cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "migrateDataContracts(address)" ${APPLICATION_ERC20_HANDLER_ADDRESS_2}  --private-key ${QUORRA_PRIVATE_KEY}
connectDataContractsToNewCoinHandler:;  cast send ${APPLICATION_ERC20_HANDLER_ADDRESS_2} "connectDataContracts(address)" ${APPLICATION_ERC20_HANDLER_ADDRESS}  --private-key ${QUORRA_PRIVATE_KEY}
tokenFee_checkTokenFeeRuleUpgrade2:; cast call ${APPLICATION_ERC20_HANDLER_ADDRESS_2} "getFeeTotal()(uint256)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

#			<><><><><><><><><><><><><><><> Narrative <><><><><><><><><><><><><><><>
# Deploy the Application App Manager
applicationDeployAppManager:;	forge script src/example/script/ApplicationAppManager.s.sol --ffi --fork-url http://localhost:8545  --broadcast --verify -vvvv			
applicationAddAppAdministrator:; cast send ${APPLICATION_APP_MANAGER} "addAppAdministrator(address)" ${CLU}  --private-key ${QUORRA_PRIVATE_KEY}
applicationCheckAppAdministrator:; cast call ${APPLICATION_APP_MANAGER} "isAppAdministrator(address)(bool)" ${CLU}  --private-key ${QUORRA_PRIVATE_KEY}

# Attempts to set Gem's AccessLevel
applicationAddAccessLevel1:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,int8)" ${GEM} 4 --private-key ${CLU_PRIVATE_KEY}

applicationAddAccessTier:; cast send ${APPLICATION_APP_MANAGER} "addAccessTier(address)" ${CLU}  --private-key ${QUORRA_PRIVATE_KEY}
applicationAddAccessLevel2:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,int8)" ${GEM} 4 --private-key ${CLU_PRIVATE_KEY}

applicationGetAccessLevel:; cast call ${APPLICATION_APP_MANAGER} "getAccessLevel(address)(address,uint256,int8,bool)" ${GEM}  --private-key ${CLU_PRIVATE_KEY} --from ${CLU}

# Set up general tags
applicationAddGeneralTagGem:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${GEM} 0x4b4e49475448  --private-key ${CLU_PRIVATE_KEY}
applicationCheckGeneralTag:; cast call ${APPLICATION_APP_MANAGER} "hasTag(address,bytes32)(bool)" ${GEM} 0x4b4e49475448  --private-key ${CLU_PRIVATE_KEY}

# Deploy the Application Token
applicationDeployToken:;	forge script src/example/script/ApplicationERC20.s.sol --ffi --fork-url http://localhost:8545  --broadcast --verify -vvvv			
applicationTokenCheckBalance:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${QUORRA} --from ${QUORRA}
applicationTokenTransferKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 2000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applicationTokenCheckKevinBalance:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${KEVIN} --from ${QUORRA}

# Kevin is mad and transfers 1 token to Sam
applicationTokenTransferSam1:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
applicationTokenCheckSamBalance:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${SAM} --from ${QUORRA}


# Kevin starts spamming ecosystem

# Create Minimum Transfer Rule 
applicationRulesAddMinTransfer:; cast send ${RULE_STORAGE_DIAMOND} "addTokenMinTxSize(address,uint256)(uint256)" ${APPLICATION_APP_MANAGER} 10 ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applicationCheckRulesMinTransfer:; cast call ${RULE_STORAGE_DIAMOND} "getTokenMinTxSize(uint32)(uint256)" 1 ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

# Apply Minimum Transfer Rule to Application Token
applicationTokenApplyMinTransferRule:; cast send ${APPLICATION_ERC20_ADDRESS} "setRuleByIndex(uint8,uint32)" 9 1 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applicationTokenTransferSam2:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

# Learns from their mistake, add a rule to prevent Kevin/Sam from misbehaving
applicationAddAccountBalanceRule:; cast send ${RULE_STORAGE_DIAMOND} "addBalanceLimitRules(address,bytes32[],uint256[],uint256[])(uint256)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [10] [10000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

# Apply Account Rule to Application Token
applicationTokenApplyAccountBalanceRule:; cast send ${APPLICATION_ERC20_ADDRESS} "setRuleByIndex(uint8,uint32)" 10 1 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applicationAddGeneralTagSam:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${SAM} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}

# Kevin transfers 500000 tokens to Sam
applicationTokenTransferSam3:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 500000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

applicationTokenApplyMinTzzzzzransferRule:; cast send ${APPLICATION_ERC20_ADDRESS} "setRuleByIndex(uint8,uint32)" 9 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

setup-yarn:
	yarn 

##local-node: setup-yarn 
##	yarn hardhat node 
