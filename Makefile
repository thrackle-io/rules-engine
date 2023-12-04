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
deployApplicationHandler:; 	forge script script/ApplicationHandlerModule.s.sol --ffi --broadcast --verify -vvvv
deployApplicationManager:;	forge script script/ApplicationAppManager.s.sol --ffi --broadcast --verify -vvvv
deployRuleStorageDiamond:; forge script script/RuleStorageModule.s.sol --ffi --broadcast --verify -vvvv
deployRuleProcessor:; forge script script/RuleProcessorModule.s.sol --ffi --broadcast --verify -vvvv
deployTokenRuleRouter:; forge script script/TokenRuleRouter.s.sol --ffi --broadcast --verify -vvvv
deployTaggedRuleProcessor:; forge script script/TaggedRuleProcessor.s.sol --ffi --broadcast --verify -vvvv
# Deploy contracts(full protocol)
deployAll:;	forge script script/DeployAllModules.s.sol --ffi --broadcast --verify -vvvv
# Deploy Application Contracts(singles)
deployApplicationAppManager:; forge script src/example/script/ApplicationAppManager.s.sol --ffi --broadcast --verify -vvvv
deployApplicationERC20Handler:; forge script src/example/script/ApplicationERC20Handler.s.sol --ffi --broadcast --verify -vvvv
deployApplicationERC20:; forge script src/example/script/ApplicationERC20.s.sol --ffi --broadcast --verify -vvvv
deployApplicationAMMCalcLinear:; forge script src/example/script/ApplicationAMMCalcLinear.s.sol --ffi --broadcast --verify -vvvv
deployApplicationAMMCalcCP:; forge script src/example/script/ApplicationAMMCalcCP.s.sol --ffi --broadcast --verify -vvvv
deployApplicationAMM:; forge script src/example/script/ApplicationAMM.s.sol --ffi --broadcast --verify -vvvv
# Deploy Application Contracts(entire application implementation)
deployAllApp:; forge script src/example/script/ApplicationDeployAll.s.sol --ffi  --broadcast --verify -vvvvv
deployNewApp:; forge script src/example/script/ApplicationUIDeploy.s.sol --ffi  --broadcast --verify -vvvvv
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
checkRulesAddRule:; cast send ${RULE_STORAGE_DIAMOND} "addPercentagePurchaseRule(address,uint16,uint32)(uint256)" ${APPLICATION_APP_MANAGER} 9000 2 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

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
addMinTransferRule:; cast send ${RULE_STORAGE_DIAMOND} "addMinimumTransferRule(address,uint256)(uint256)" ${APPLICATION_APP_MANAGER} 10 ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyMinTransferRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setMinTransferRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkERC20PassMinTransfer:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC20FailMinTransfer:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 5 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> Min Max Balance Rule ERC20 <><><><><>
checkAddAccountBalanceRule:; cast send ${RULE_STORAGE_DIAMOND} "addBalanceLimitRules(address,bytes32[],uint256[],uint256[])(uint256)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [10] [100000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyAccountBalanceRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setMinMaxBalanceRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addGeneralTagMinMax:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkERC20PassMinMaxBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC20FailMinBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkERC20FailMaxBalanceCtrl:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100001 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkBalanceClu:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}
checkBalanceClu2:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}

#			<><><><><> Purchase Limit Rule <><><><><>
addPurchaseLimitRule:; cast send ${RULE_STORAGE_DIAMOND} "addPurchaseRule(address,bytes32[],uint192[],uint32[],uint32[])" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [99] [24] [24] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyPurchaseLimitRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setPurchaseLimitRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkAddGeneralTag:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkPassPurchaseLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 99 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
checkFailPurchaseLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 101 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
#			<><><><><> Sell Limit Rule <><><><><>
addSellLimitRule:; cast send ${RULE_STORAGE_DIAMOND} "addSetOfSellRule(address,bytes32[],uint192[],uint32[])" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [100] [24] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applySellLimitRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setSellLimitRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkAddGeneralTagSellLimit:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${CLU} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
checkPassSellLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 99 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
checkFailSellLimit:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 101 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}

#			<><><><><> ORACLE RULE <><><><><>
loadUserWithTokensOracle:; :; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addOracleRule:; cast send ${RULE_STORAGE_DIAMOND} "addOracleRule(address,uint8,address)(uint256)" ${APPLICATION_APP_MANAGER} 0 ${APPLICATION_ORACLE_ALLOWED_ADDRESS} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyOracleRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setOracleRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
mintFranksOracle:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 10000000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceFranksOracle:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${QUORRA} --from ${KEVIN}
TransferFranksToKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 10000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkFranksBalanceKevin:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${KEVIN} --from ${KEVIN}
AddCluToRestrictionOracle:; cast send ${APPLICATION_ORACLE_RESTRICTED_ADDRESS} "addAddressToSanctionsList(address)" ${CLU} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferFranksFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> TOKEN REGISTRATION <><><><><>
checkTokenRegistered:; cast call ${APPLICATION_APP_MANAGER} "getTokenAddress(string)(address)" "Frankenstein" --from ${KEVIN}

#			<><><><><> BALANCE BY AccessLevel RULE <><><><><>
# mint Franks and dracs 
loadUserWithFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
loadUserWithDracs:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkDracsBalanceSam:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${SAM} --from ${SAM}
addBalanceByAccessLevelRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccessLevelBalanceRule(address,uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [0,10,100,1000,100000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyBalanceByAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountBalanceByAccessLevelRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceByAccessLevelRuleActive:; cast call ${APPLICATION_APPLICATION_HANDLER} "isAccountBalanceByAccessLevelActive()(bool)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
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
addWithdrawalByAccessLevelRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccessLevelWithdrawalRule(address,uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [0,10,100,1000,100000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyWithdrawalByAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setWithdrawalLimitByAccessLevelRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# add kevin access level 1 
transferFranksFromKevintoSamSuccess:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 9000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
transferDracsFromKevinToSameSuccess:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# Kevin is now at the Access Level limit and all transfers will fail unless given higher access level 
transferFranksToSamFromKevinFail:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
transferDracsToSameFromKevinFail:; cast send ${APPLICATION_ERC20_ADDRESS_2} "transfer(address,uint256)(bool)" ${SAM} 1000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}


#			<><><><><> MAX TX SIZE PER PERIOD BY RISK SCORE RULES <><><><><>
addSamAsRiskAdminMaxTX:; cast send ${APPLICATION_APP_MANAGER} "addRiskAdmin(address)" ${SAM} --private-key ${QUORRA_PRIVATE_KEY} 
addMaxTxSizePerPeriodByRiskRule:; cast send ${RULE_STORAGE_DIAMOND} "addMaxTxSizePerPeriodByRiskRule(address,uint48[],uint8[],uint8,uint8)(uint32)" ${APPLICATION_APP_MANAGER} [10000000000,10000000,10000,1] [25,50,75] 12 12 --private-key ${QUORRA_PRIVATE_KEY} 
assignCluRiskScoreOf55:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${CLU} 55 --private-key ${SAM_PRIVATE_KEY} 
applyMaxTxSizePerPeriodByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setMaxTxSizePerPeriodByRiskRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY}
checkMaxTxSizePerPeriodByRiskIsActive:; cast call ${APPLICATION_APPLICATION_HANDLER} "isMaxTxSizePerPeriodByRiskActive()(bool)"
loadCluWithFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
loadKevinWithFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 100000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
turnOffMaxTxSizePerPeriodByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateMaxTxSizePerPeriodByRiskRule(bool)" 0 --private-key ${QUORRA_PRIVATE_KEY} 
turnOnMaxTxSizePerPeriodByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateMaxTxSizePerPeriodByRiskRule(bool)" 1 --private-key ${QUORRA_PRIVATE_KEY} 
moveForwardInTime6Hours:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[21600]}' http://localhost:8545
cluTransfers2FrankToKevin:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${KEVIN} 2000000000000000000 --private-key ${CLU_PRIVATE_KEY}
cluTransfers9998FrankToKevin:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${KEVIN} 9998000000000000000000 --private-key ${CLU_PRIVATE_KEY}
kevinTransfers2FrankToClu:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 2000000000000000000 --private-key ${KEVIN_PRIVATE_KEY}
kevinTransfers9998FrankToClu:;  cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 9998000000000000000000 --private-key ${KEVIN_PRIVATE_KEY}


#			<><><><><> ACCOUNT BALANCE BY RISK RULE <><><><><>
# mint Franks and give user Franks 
addAccountBalanceByRiskRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccountBalanceByRiskScore(address,uint8[],uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [10,20,30,40,50,60,70,80,90] [1000000000,1000000000,100000000,10000000,1000000,100000,10000,1000,100,10] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyAccountBalanceByRiskRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountBalanceByRiskRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addSamAsRiskAdmin:; cast send ${APPLICATION_APP_MANAGER} "addRiskAdmin(address)" ${SAM}  --private-key ${QUORRA_PRIVATE_KEY}
addRiskScoreKevin:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${KEVIN}  10 --private-key ${SAM_PRIVATE_KEY}
addRiskScoreClu:; cast send ${APPLICATION_APP_MANAGER} "addRiskScore(address,uint8)" ${CLU}  90 --private-key ${SAM_PRIVATE_KEY}
#test transfer passes 
transferFranksSamtoKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 10000000000000000000 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
#test transfer fails 
transferFranksFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 1000000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> TRANSACTION LIMIT BY RISK RULE <><><><><>
# mint Franks and give user Franks 
addTransactionLimitByRiskScore:; cast send ${RULE_STORAGE_DIAMOND} "addTransactionLimitByRiskScore(address,uint8[],uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [10,20,30,40,50,60,70,80,90] [1000000000,1000000000,100000000,10000000,1000000,100000,10000,1000,100,10] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
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
turnOnAccessLevel0RuleForNFT:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccessLevel0Rule(bool)" true --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
turnOnAccessLevel0RuleForCoin:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccessLevel0Rule(bool)" true --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addQuorraAsAccessTier:; cast send ${APPLICATION_APP_MANAGER} "addAccessTier(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY}
addAccessLevel1toSam:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${SAM} 1 --private-key ${QUORRA_PRIVATE_KEY}
# transferFrankNFTFromKevinToSam 
addAccessLevel0toSam:; cast send ${APPLICATION_APP_MANAGER} "addAccessLevel(address,uint8)" ${SAM} 0 --private-key ${QUORRA_PRIVATE_KEY}
# these should fail
# transferFrankNFTFromKevinToSam
# transferFranksFromKevinToSam

#			<><><><><> ADMIN WITHDRAWAL RULE <><><><><>
mintAMillFranksToQuorra:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 1000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
registerAdminWithdrawalRuleA:; cast send ${RULE_STORAGE_DIAMOND} "addAdminWithdrawalRule(address,uint256,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 1000000000000000000000000 1704110400 --private-key ${QUORRA_PRIVATE_KEY}
registerAdminWithdrawalRuleB:; cast send ${RULE_STORAGE_DIAMOND} "addAdminWithdrawalRule(address,uint256,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 100000000000000000000000 1709294400 --private-key ${QUORRA_PRIVATE_KEY}
applyAdminWithdrawalRuleA:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAdminWithdrawalRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY}
applyAdminWithdrawalRuleB:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAdminWithdrawalRuleId(uint32)" 1 --private-key ${QUORRA_PRIVATE_KEY}
turnOffAdminWithdrawalRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "activateAdminWithdrawalRule(bool)" 0 --private-key ${QUORRA_PRIVATE_KEY}
turnOnAdminWithdrawalRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "activateAdminWithdrawalRule(bool)" 1 --private-key ${QUORRA_PRIVATE_KEY}
transferFromQuorraToCluToBreakRuleA:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 800000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY}
transferFromQuorraToCluToBreakRuleB:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)" ${CLU} 100000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY}
#			<><><><><> MINIMUM BALANCE BY DATE RULE <><><><><>
# mint Franks
giveKevin1000Franks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${KEVIN} 1000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addMinBalByDateRule:; cast send ${RULE_STORAGE_DIAMOND} "addMinBalByDateRule(address,bytes32[],uint256[],uint256[],uint256[])(uint32)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [10] [720] [0] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyMinBalByDateRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setMinBalByDateRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addSimpleGeneralTagKevin:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${KEVIN} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
# this should fail
Transfer999FranksFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 999 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# moveForwardInTime6Months
# Now it should pass
Transfer999FranksFromKevinToCluPass:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${SAM} 999 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> ERC20 TRANSFER VOLUME RULE <><><><><>
# mintFranks
# giveKevin1000Franks
addTokenTransferVolumeRule:; cast send ${RULE_STORAGE_DIAMOND} "addTransferVolumeRule(address, uint16, uint8, uint64,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 200 2 0 1000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyTokenTransferVolumeRuleToToken:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setTokenTransferVolumeRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# these should pass but will contribute to the threshold being reached
Transfer19FranksFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 19 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# this one should fail
Transfer1FrankFromKevinToClu:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
moveForwardInTime2Days:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[172800]}' http://localhost:8545
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


#			<><><><><> ERC20 TOTAL SUPPLY VOLATILITY RULE  <><><><><>
#	mint franks 1,000,000 total supply
mintFranksForTotalSupplyRule:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 1000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
#   create rule with 10% volatility threshold, 24 hrs period starting at noon with 0 as totalSupply to call totalSupply() from token 
addTotalSupplyVolatilityRule:; cast send ${RULE_STORAGE_DIAMOND} "addSupplyVolatilityRule(address,uint16,uint8,uint8,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 1000 24 12 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
#	activate rule 
applyTotalSupplyVolatilityRule:; cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setTotalSupplyVolatilityRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
#	warp into rule period 
# 	Mint tokens below rule threshold (50,000)
mintFranksToKevinForVolRule:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${KEVIN} 50000000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
#	failed mint
mintFranksToCluFailsVolRule:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${CLU} 100000000000000000000000 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
#	move to new period 
#	failed mint passes 
#	test Burn fails in current period (at limit)
burnFranksKevinForVolRule:; cast send ${APPLICATION_ERC20_ADDRESS} "burn(uint256)" 50000000000000000000000 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
#	move forward to new period 
#	burn successful 


# <><><><><><><><><><> ERC721 TESTS  <><><><><><><><><><>
#			<><><><><> NFT Trade Counter RULE <><><><><>
# Application Administrators Mints an Frankenstein NFT
mintFrankNFT:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${QUORRA} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Create an NFT Trade Counter Rule for any NFT tagged as a "BoredGrape" to only allow 1 trade per day
addNFTTransferCounterRule:; cast send ${RULE_STORAGE_DIAMOND} "addNFTTransferCounterRule(address,bytes32[],uint8[])(uint256)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [1] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Apply the NFT Trade Counter Rule to Frankenstein NFT
applyNFTTransferCounterRule:; cast send ${APPLICATION_ERC721_HANDLER} "setTradeCounterRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
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
moveForwardInTime1Day:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[86400]}' http://localhost:8545
# Transfer Frankenstein NFT from Sam to Clu(This will now complete successfully)
transferFrankNFTFromSamToCluAgain:;cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${SAM} ${CLU} 0 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
#checkNFTBalanceClu
# !!!! NOTE !!!! They could turn this into a soulbound NFT by setting the trades at 0

#			<><><><><> AccessLevel LEVEL RULES NFT <><><><><>
addAccessLevelBalanceRule:; cast send ${RULE_STORAGE_DIAMOND} "addAccessLevelBalanceRule(address,uint48[])" ${APPLICATION_APP_MANAGER} [15,30,60,120,210] --private-key ${QUORRA_PRIVATE_KEY} 
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
applyAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "setAccountBalanceByAccessLevelRuleId(uint32)" 0  --private-key ${QUORRA_PRIVATE_KEY} 
tryToTransferNFT2ToGem:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${GEM} 2 --private-key ${CLU_PRIVATE_KEY} 
transferNFT1ToGem:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${GEM} 1 --private-key ${CLU_PRIVATE_KEY} 
tryToTransferNFT4ToSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${SAM} 4 --private-key ${CLU_PRIVATE_KEY} 
transferNFT0ToSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeTransferFrom(address,address,uint256)" ${CLU} ${SAM} 0 --private-key ${CLU_PRIVATE_KEY} 
mintCoinsForQuorra:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 100000000000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
turnOffAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountBalanceByAccessLevelRule(bool)" 0 --private-key ${QUORRA_PRIVATE_KEY} 
turnOnAccessLevelRule:; cast send ${APPLICATION_APPLICATION_HANDLER} "activateAccountBalanceByAccessLevelRule(bool)" 1 --private-key ${QUORRA_PRIVATE_KEY} 


#			<><><><><> NFT Application Administrators Withdrawal Rule <><><><><>  
# Mint NFTs to app admin account 
mintFrankNFTforAdmin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${QUORRA} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Add Rule
addNFTAdminWithdrawalRule:; cast send ${RULE_STORAGE_DIAMOND} "addAdminWithdrawalRule(address,uint256,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 5 1704110400 --private-key ${QUORRA_PRIVATE_KEY}
# Apply Withdrawal rule 
applyNFTAdminWithdrawalRule:; cast send ${APPLICATION_ERC721_HANDLER} "setAdminWithdrawalRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY}
# Attempt to transfer before rule expires (fails)
transferFrankNFTFromQuorraToSamFails:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${SAM} 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# Move time to after rule 
moveForwardInTime1Year:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[31536000]}' http://localhost:8545
# Transfer NFTs 
transferNFTFromQuorraToSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${SAM} 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

#			<><><><><> NFT TransactionLimitByRisk RULE <><><><><>
# <<Quorra mints 0-4 token IDs>>
addTransactionLimitByRiskScoreNFTrule:; cast send ${RULE_STORAGE_DIAMOND} "addTransactionLimitByRiskScore(address,uint8[],uint48[])(uint32)" ${APPLICATION_APP_MANAGER} [10,20,30,40,50,60,70,80,90] [70000,60000,50000,40000,30000,20000,10000,1000,100,10] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
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
applyAccountBalanceRuleNFT:; cast send ${APPLICATION_ERC721_HANDLER} "setMinMaxBalanceRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
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

#			<><><><><> MINIMUM BALANCE BY DATE ERC721 RULE <><><><><>
#<<Mint Frank NFTs to Users>> Repeat mint function 2x for Sam
mintFranksNFTMinBalByDateSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${SAM}  --private-key ${QUORRA_PRIVATE_KEY}
#<<Add Rule>>
addMinBalByDateERC721Rule:; cast send ${RULE_STORAGE_DIAMOND} "addMinBalByDateRule(address,bytes32[],uint256[],uint256[],uint256[])(uint32)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [1] [48] [0] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyMinBalByERC721Rule:; cast send ${APPLICATION_ERC721_HANDLER} "setMinBalByDateRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
#<<Tag Users>>
addMinBalByDateTagSam:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${SAM} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
addMinBalByDateTagKevin:; cast send ${APPLICATION_APP_MANAGER} "addGeneralTag(address,bytes32)" ${KEVIN} 0x5461796c65720000000000000000000000000000000000000000000000000000  --private-key ${QUORRA_PRIVATE_KEY}
#<<Passing Transfer From Sam to Kevin>>
transferFranksNFTSamToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${SAM} ${KEVIN} 0 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
#<<Failing Transfer From Kevin to Sam>>
transferFranksNFTKevinToSamFails:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${SAM} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
#<<Move Time Forward to Expire Rule>>
moveForwardinTime3days:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[259200]}' http://localhost:8545
#<<Repeat Failed Transfer (passes)>>
transferFranksNFTKevinToSamPasses:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${SAM} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> ERC721 TRANSFER VOLUME RULE <><><><><>
TransferVolumeMintFrankNFT1forKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${KEVIN} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferVolumeMintFrankNFT2forKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${KEVIN} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferVolumeAddTokenTransferVolumeRule:; cast send ${RULE_STORAGE_DIAMOND} "addTransferVolumeRule(address, uint16, uint8, uint64,uint256)(uint32)" ${APPLICATION_APP_MANAGER} 2000 48 0 10 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
TransferVolumeApplyTokenTransferVolumeRuleToToken:; cast send ${APPLICATION_ERC721_HANDLER} "setTokenTransferVolumeRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# this should pass
TransferVolumeTransferNFT0ToFromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${CLU} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# this one should fail
TransferVolumeTransferNFT1ToFromKevinToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${CLU} 1 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
TransferVolumeMoveForwardInTime2Days:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[172800]}' http://localhost:8545
# Now it should pass
# TransferVolumeTransferNFT1ToFromKevinToClu

#			<><><><><> ERC721 MINT FEE  <><><><><>
# This test requires that the safeMint and associated functions are uncommented in the applicationERC721 contract.
setMintPrice:; cast send ${APPLICATION_ERC721_ADDRESS_1} "setMintPrice(uint256)" 1 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
setTreasuryAddress:; cast send ${APPLICATION_ERC721_ADDRESS_1} "setTreasuryAddress(address)" ${QUORRA}  --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
mintPaidFrankNFT:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${CLU} --private-key ${CLU_PRIVATE_KEY} --from ${CLU} --value 1ether
mintPaidFrankNFTNoEther:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${CLU} --private-key ${CLU_PRIVATE_KEY} --from ${CLU} 

#			<><><><><> ERC721 MINIMUM HOLD TIME RULE <><><><><>
# add the rule
MinimumHoldTimeSetHours:; cast send ${APPLICATION_ERC721_HANDLER} "setMinimumHoldTimeHours(uint32)" 24 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
MinimumHoldTimeGetHours:; cast call ${APPLICATION_ERC721_HANDLER} "getMinimumHoldTimeHours()(uint32)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# mint
MinimumHoldTimeMintFrankNFT1forKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${KEVIN} --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# this should fail
MinimumHoldTimeTransferNFT1ToFromKevinToClu1:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${CLU} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# move forward in time one day
moveForwardInTime24Hours:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[86400]}' http://localhost:8545
# now it will pass
MinimumHoldTimeTransferNFT1ToFromKevinToClu2:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${KEVIN} ${CLU} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}

#			<><><><><> ERC721 TOTAL SUPPLY VOLATILITY RULE  <><><><><>
#	mint frank NFTs to Quorra
#   create rule with same params as erc20 (10% volatility threshold)
#   addTotalSupplyVolatilityRule
#	activate rule 
applyTotalSupplyVolatilityRuleERC721:; cast send ${APPLICATION_ERC721_HANDLER} "setTotalSupplyVolatilityRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
#	warp into rule period 
# 	Mint tokens below rule threshold 
mintFranksNFTToSamVolRule:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${SAM}  --private-key ${SAM_PRIVATE_KEY}
#	failed mint 
#mintFranksNFTToSamVolRule
#	move to new period 
#	failed mint passes 
#	fail burn in same period 
burnFranksNFTSamVolRule:; cast send ${APPLICATION_ERC721_ADDRESS_1} "burn(uint256)" 22  --private-key ${SAM_PRIVATE_KEY}
burnFranksNFTSamVolRule2:; cast send ${APPLICATION_ERC721_ADDRESS_1} "burn(uint256)" 21  --private-key ${SAM_PRIVATE_KEY}
#	move to new period and burn successful 


# <><><><><><><><><><> AMM MODULE TESTS  <><><><><><><><><><>
#			<><><><><> AMM <><><><><>
mintFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${QUORRA} 10000000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceFranksAMM:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${QUORRA} --from ${KEVIN}
mintDracs:; cast send ${APPLICATION_ERC20_ADDRESS_2} "mint(address,uint256)" ${QUORRA} 10000000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceDracs:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${QUORRA} --from ${KEVIN}
approveFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${APPLICATION_AMM_ADDRESS} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
approveDracs:; cast send ${APPLICATION_ERC20_ADDRESS_2} "approve(address,uint256)" ${APPLICATION_AMM_ADDRESS} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addLiquidity:; cast send ${APPLICATION_AMM_ADDRESS} "addLiquidity(uint256,uint256)" 1000000 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
getAMMReserve0:; cast call ${APPLICATION_AMM_ADDRESS} "getReserve0()(uint256)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
giveCluFranks:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
approveCluFranksForAMM:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${APPLICATION_AMM_ADDRESS} 500000 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
swap0for1:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS} 50000 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
checkBalanceCluCoin2:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}

#			<><><><><> MinMaxBalance Rule AMM <><><><><>
addMinMaxBalanceRule:; cast send ${RULE_STORAGE_DIAMOND} "addBalanceLimitRules(address,bytes32[],uint256[],uint256[])(uint256)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [10] [100000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addMinMaxBalanceRule2:; cast send ${RULE_STORAGE_DIAMOND} "addBalanceLimitRules(address,bytes32[],uint256[],uint256[])(uint256)" ${APPLICATION_APP_MANAGER} [0x5461796c65720000000000000000000000000000000000000000000000000000] [15] [10000] --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyMinMaxBalanceRuleToken0:; cast send ${APPLICATION_AMM_HANDLER} "setMinMaxBalanceRuleIdToken0(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyMinMaxBalanceRuleToken1:; cast send ${APPLICATION_AMM_HANDLER} "setMinMaxBalanceRuleIdToken1(uint32)" 1 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkAMMHandler:; cast call ${APPLICATION_AMM_HANDLER} "getMinMaxBalanceRuleIdToken0()" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
swap0for1PassMinMax:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS} 500 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}

#			<><><><><> AMM Fees <><><><><>
# mintFranks to Quorra 
checkBalanceFranks:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${QUORRA} --from ${KEVIN}
mintDracsAmm:; cast send ${APPLICATION_ERC20_ADDRESS_2} "mint(address,uint256)" ${QUORRA} 1000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkBalanceDracsAMM:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${QUORRA} --from ${KEVIN}
approveFranksAMM:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${APPLICATION_AMM_ADDRESS} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
approveDracsAMM:; cast send ${APPLICATION_ERC20_ADDRESS_2} "approve(address,uint256)" ${APPLICATION_AMM_ADDRESS} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
addLiquidityAMM:; cast send ${APPLICATION_AMM_ADDRESS} "addLiquidity(uint256,uint256)" 1000000 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
AMMReserve0:; cast call ${APPLICATION_AMM_ADDRESS} "getReserve0()(uint256)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
giveCluFranksAMM:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
approveCluFranksForAMMFees:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${APPLICATION_AMM_ADDRESS} 50000 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}

addAMMFeeRule:; cast send ${RULE_STORAGE_DIAMOND} "addAMMFeeRule(address,uint256)(uint256)" ${APPLICATION_APP_MANAGER} 500 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyAMMFeeRule:; cast send ${APPLICATION_AMM_HANDLER} "setAMMFeeRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
checkAMMFeeActive:; cast call ${APPLICATION_AMM_HANDLER} "isAMMFeeRuleActive()(bool)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
swap0for1WithFee:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS} 100 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
checkCluCoin2Balance:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${CLU} --from ${KEVIN}
checkBalanceTreasuryCoin2:; cast call ${APPLICATION_ERC20_ADDRESS_2} "balanceOf(address)(uint256)" ${AMM_TREASURY} --from ${KEVIN}
checkBalanceTreasuryCoin:; cast call ${APPLICATION_ERC20_ADDRESS} "balanceOf(address)(uint256)" ${AMM_TREASURY} --from ${KEVIN}

#			<><><><><> AMM Purchase Percentage Rule <><><><><>
# << mint Franks and Dracs to Quorra >>
giveCluDracsAMM:; cast send ${APPLICATION_ERC20_ADDRESS_2} "mint(address,uint256)" ${CLU} 1000000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# << add liquidity to AMM >>
addPercentagePurchaseRule:; cast send ${RULE_STORAGE_DIAMOND} "addPercentagePurchaseRule(address,uint16,uint32,uint256,uint32)(uint32)" ${APPLICATION_APP_MANAGER} 1000 24 1000000 6 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applyPercentagePurchaseRule:; cast send ${APPLICATION_AMM_HANDLER} "setPurchasePercentageRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# << give AMM Approval for tokens >> 
approveCluDracsForAMM:; cast send ${APPLICATION_ERC20_ADDRESS_2} "approve(address,uint256)" ${APPLICATION_AMM_ADDRESS} 500000 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
# << move forward in time to activate rule >> 
moveForwardInTime36Hours:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[129600]}' http://localhost:8545
swap1for0Clu:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS_2} 100 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
swap1for0ClueFails:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS_2} 99900 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
swap0for1CluePasses:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS} 100 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}


#			<><><><><> AMM Sell Percentage Rule <><><><><>
# << mint Franks to Quorra >>
giveCluFranksForSwap:; cast send ${APPLICATION_ERC20_ADDRESS} "transfer(address,uint256)(bool)" ${CLU} 100000 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# << add liquidity to AMM >>
addSellPercentageRule:; cast send ${RULE_STORAGE_DIAMOND} "addPercentageSellRule(address,uint16,uint32,uint256,uint32)(uint32)" ${APPLICATION_APP_MANAGER} 1000 24 10000000 6 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applySellPercentageRule:; cast send ${APPLICATION_AMM_HANDLER} "setSellPercentageRuleId(uint32)" 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# << give AMM Approval for tokens >> 
# << move forward in time to activate rule >> 
swap0for1Clue:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS} 100 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
swap0for1ClueFails:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS} 99905 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
swap1for0CluePasses:; cast send ${APPLICATION_AMM_ADDRESS} "swap(address,uint256)(uint256)" ${APPLICATION_ERC20_ADDRESS_2} 100 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}


# <><><><><><><><><><> STAKING MODULE TESTS  <><><><><><><><><><>
#			<><><><><> FUNGIBLE TOKEN STAKING <><><><><>
mintFranksForClu:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${CLU} 10000000000000000000000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
mintRewardTokensForStakingContract:; cast send ${APPLICATION_ERC20_ADDRESS_2} "mint(address,uint256)" ${ERC20STAKING_CONTRACT} 10000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
eddieApprovesStakingContract:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${ERC20STAKING_CONTRACT} 100000000000 --private-key ${CLU_PRIVATE_KEY} 
eddieTrysToStakesAFewFranksFor3Months:; cast send ${ERC20STAKING_CONTRACT} "stake(uint256,uint8,uint8)" 10 5 3 --private-key ${CLU_PRIVATE_KEY} 
eddieStakesSomeFranksForTenMonths:; cast send ${ERC20STAKING_CONTRACT} "stake(uint256,uint8,uint8)" 1000000 5 10 --private-key ${CLU_PRIVATE_KEY} 
moveForwardInTime6Months:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[15552001]}' http://localhost:8545
moveForwardInTime4Months:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[10368000]}' http://localhost:8545
moveForwardInTime10Months:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[25921000]}' http://localhost:8545
eddieClaimsRewards:; cast send ${ERC20STAKING_CONTRACT} "claimRewards()" --private-key ${CLU_PRIVATE_KEY} 

#			<><><><><> NON FUNGIBLE TOKEN STAKING  <><><><><>
# <<mint reward tokens for staking contract>>
mintRewardERC20ForERC721Staking:; cast send ${APPLICATION_ERC20_ADDRESS_2} "mint(address,uint256)" ${ERC721STAKING_CONTRACT} 10000000000000000000000 --private-key ${QUORRA_PRIVATE_KEY} 
# <<mint NFTs to users to stake>>
# <<Mint tokens 0,1,2 to Quorra) 
transferFrankToken0ToKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${KEVIN} 0 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
transferFrankToken1ToSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${SAM} 1 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
transferFrankToken2ToClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "transferFrom(address,address,uint256)" ${QUORRA} ${CLU} 2 --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
# <<approve staking contract for NFTs for each user>>
approveStakingContractKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "approve(address,uint256)" ${ERC721STAKING_CONTRACT} 0 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
approveStakingContractSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "approve(address,uint256)" ${ERC721STAKING_CONTRACT} 1 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
approveStakingContractClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "approve(address,uint256)" ${ERC721STAKING_CONTRACT} 2 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
# <<stake users NFTs>>
stakeToken0Kevin:; cast send ${ERC721STAKING_CONTRACT} "stake(address,uint256,uint8,uint8)" ${APPLICATION_ERC721_ADDRESS_1} 0 5 3 --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
stakeToken1Sam:; cast send ${ERC721STAKING_CONTRACT} "stake(address,uint256,uint8,uint8)" ${APPLICATION_ERC721_ADDRESS_1} 1 5 4 --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
stakeToken2Clu:; cast send ${ERC721STAKING_CONTRACT} "stake(address,uint256,uint8,uint8)" ${APPLICATION_ERC721_ADDRESS_1} 2 5 10 --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
# <<move forward in time>>
checkBlockTime:; cast call ${ERC721STAKING_CONTRACT} "getBlocktime()(uint256)" --private-key ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
#moveForwardInTime4Months
# <<calculate rewards>>
calcRewardsForKevin:; cast call ${ERC721STAKING_CONTRACT} "calculateRewards(address)(uint256)" ${KEVIN} --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
# <<move to middle of period>> 
# moveForwardInTime6Months
# <<calculate rewards again>>
calcRewardsForSam:; cast call ${ERC721STAKING_CONTRACT} "calculateRewards(address)(uint256)" ${SAM} --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
# <<move to end of period>>
# moveForwardInTime10Months
calcRewardsForClu:; cast call ${ERC721STAKING_CONTRACT} "calculateRewards(address)(uint256)" ${CLU} --private-key ${CLU_PRIVATE_KEY} --from ${CLU}
# <<claim user rewards>>
claimKevin:; cast send ${ERC721STAKING_CONTRACT} "claimRewards()" --private-key ${KEVIN_PRIVATE_KEY} --from ${KEVIN}
claimSam:; cast send ${ERC721STAKING_CONTRACT} "claimRewards()" --private-key ${SAM_PRIVATE_KEY} --from ${SAM}
claimClu:; cast send ${ERC721STAKING_CONTRACT} "claimRewards()" --private-key ${CLU_PRIVATE_KEY} --from ${CLU}


#		         	<><><><><> ERC20 Auto Mint Reward Token Staking Contract  <><><><><>		         	#
# NOTE This contract does not need to have reward tokens minted or transfered to contract. Rewards are minted to user at claim. 
# <<Mint Franks (staking token) to Sam, Clu and Kevin>> 
mintFranksForStakingSam:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${SAM} 100000 --private-key ${QUORRA_PRIVATE_KEY} 
mintFranksForStakingClu:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${CLU} 100000 --private-key ${QUORRA_PRIVATE_KEY} 
mintFranksForStakingKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "mint(address,uint256)" ${KEVIN} 100000 --private-key ${QUORRA_PRIVATE_KEY} 
# <<Sam, Clu and Kevin Approve Staking Contract>> 
approveAutoMintStakingSam:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${ERC20AUTOMINT_STAKING_CONTRACT} 100000000000 --private-key ${SAM_PRIVATE_KEY} 
approveAutoMintStakingClu:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${ERC20AUTOMINT_STAKING_CONTRACT} 100000000000 --private-key ${CLU_PRIVATE_KEY} 
approveAutoMintStakingKevin:; cast send ${APPLICATION_ERC20_ADDRESS} "approve(address,uint256)" ${ERC20AUTOMINT_STAKING_CONTRACT} 100000000000 --private-key ${KEVIN_PRIVATE_KEY} 
# <<Sam Stakes for 1 days >> 
stakeSam1Days:; cast send ${ERC20AUTOMINT_STAKING_CONTRACT} "stake(uint256,uint8,uint8)" 10000 3 1 --private-key ${SAM_PRIVATE_KEY} 
# <<Clu Stakes for 2 days >> 
stakeClu2Days:; cast send ${ERC20AUTOMINT_STAKING_CONTRACT} "stake(uint256,uint8,uint8)" 10000 3 2 --private-key ${CLU_PRIVATE_KEY} 
# <<Kevin Stakes for 3 days >> 
stakeKevin3Days:; cast send ${ERC20AUTOMINT_STAKING_CONTRACT} "stake(uint256,uint8,uint8)" 10000 3 3 --private-key ${KEVIN_PRIVATE_KEY} 
# <<Move time forward 4 days >>
moveForwardInTime4Days:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[345600]}' http://localhost:8545
# <<Sam Claims >> 
claimRewardsSam:; cast send ${ERC20AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${SAM_PRIVATE_KEY} 
# <<Clu Claims >> 
claimRewardsClu:; cast send ${ERC20AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${CLU_PRIVATE_KEY} 
# <<Kevin Claims >> 
claimRewardsKevin:; cast send ${ERC20AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${KEVIN_PRIVATE_KEY} 
###FAILCASE: Sam tries to claim again with zero rewards earned. 
# <<Sam Claims >> 
claimRewardsSamAgain:; cast send ${ERC20AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${SAM_PRIVATE_KEY} 
calculateRewardsAutoMint:; cast call ${ERC20AUTOMINT_STAKING_CONTRACT} "calculateRewards(address)(uint256)" ${SAM} --private-key ${QUORRA_PRIVATE_KEY} 

#			<><><><><> ERC721 Auto Mint Reward Token Staking Contract  <><><><><>		         	
# NOTE This contract does not need to have reward tokens minted or transfered to contract. Rewards are minted to user at claim. 
# <<Mint Franks (ERC721 staking token) to Sam, Clu and Kevin>> 
mintFrankNFTsForStakingSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${SAM}  --private-key ${QUORRA_PRIVATE_KEY} 
mintFrankNFTsForStakingClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${CLU} --private-key ${QUORRA_PRIVATE_KEY} 
mintFrankNFTsForStakingKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "safeMint(address)" ${KEVIN} --private-key ${QUORRA_PRIVATE_KEY} 
# <<Sam, Clu and Kevin Approve Staking Contract>> 
approveNFTAutoMintStakingSam:; cast send ${APPLICATION_ERC721_ADDRESS_1} "approve(address,uint256)" ${ERC721AUTOMINT_STAKING_CONTRACT} 0 --private-key ${SAM_PRIVATE_KEY} 
approveNFTAutoMintStakingClu:; cast send ${APPLICATION_ERC721_ADDRESS_1} "approve(address,uint256)" ${ERC721AUTOMINT_STAKING_CONTRACT} 1 --private-key ${CLU_PRIVATE_KEY} 
approveNFTAutoMintStakingKevin:; cast send ${APPLICATION_ERC721_ADDRESS_1} "approve(address,uint256)" ${ERC721AUTOMINT_STAKING_CONTRACT} 2 --private-key ${KEVIN_PRIVATE_KEY} 
# <<Sam Stakes for 1 days >> 
stakeNFT0Sam1Days:; cast send ${ERC721AUTOMINT_STAKING_CONTRACT} "stake(address,uint256,uint8,uint8)" ${APPLICATION_ERC721_ADDRESS_1} 0 3 1 --private-key ${SAM_PRIVATE_KEY} 
# <<Clu Stakes for 2 days >> 
stakeNFT1Clu2Days:; cast send ${ERC721AUTOMINT_STAKING_CONTRACT} "stake(address,uint256,uint8,uint8)" ${APPLICATION_ERC721_ADDRESS_1} 1 3 2 --private-key ${CLU_PRIVATE_KEY} 
# <<KEVIN Stakes for 3 days >> 
stakeNFT2Kevin3Days:; cast send ${ERC721AUTOMINT_STAKING_CONTRACT} "stake(address,uint256,uint8,uint8)" ${APPLICATION_ERC721_ADDRESS_1} 2 3 3 --private-key ${KEVIN_PRIVATE_KEY} 
# <<Move time forward 4 days >>
moveForwardInTime4DaysNFT:; curl -H "Content-Type: application/json" -X POST --data '{"id":${CHAIN_ID},"jsonrpc":"2.0","method":"evm_increaseTime","params":[345600]}' http://localhost:8545
# <<Sam Claims >> 
claimRewardsSamNFTStaking:; cast send ${ERC721AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${SAM_PRIVATE_KEY} 
# <<Clu Claims >> 
claimRewardsCluNFTStaking:; cast send ${ERC721AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${CLU_PRIVATE_KEY} 
# <<Kevin Claims >> 
claimRewardsKevinNFTStaking:; cast send ${ERC721AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${KEVIN_PRIVATE_KEY} 
###FAILCASE: Sam tries to claim again with zero rewards earned. 
# <<Sam Claims >> 
claimRewardsSamAgainNFTStaking:; cast send ${ERC721AUTOMINT_STAKING_CONTRACT} "claimRewards()" --private-key ${SAM_PRIVATE_KEY} 
calculateRewardsAutoMintNFT:; cast call ${ERC721AUTOMINT_STAKING_CONTRACT} "calculateRewards(address)(uint256)" ${SAM} --private-key ${QUORRA_PRIVATE_KEY} 

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
applicationRulesAddMinTransfer:; cast send ${RULE_STORAGE_DIAMOND} "addMinimumTransferRule(address,uint256)(uint256)" ${APPLICATION_APP_MANAGER} 10 ${QUORRA_PRIVATE_KEY} --from ${QUORRA}
applicationCheckRulesMinTransfer:; cast call ${RULE_STORAGE_DIAMOND} "getMinimumTransferRule(uint32)(uint256)" 1 ${QUORRA_PRIVATE_KEY} --from ${QUORRA}

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