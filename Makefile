# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

###############################################
# Cast Sends - Setters
###############################################

# Create a Account Min Max Token Balance rule. To use a specific string for the tag use the following syntax:
# make setRule INPUT=tag
# otherwise if INOUT is not specified, "Test" will be used for the tag.
# Output is parsed and the created rule id is given as output to the make call
createRule: createRuleCastSend
	@echo $(shell sh ./script/makefile-tools/parseRuleID.sh)

# Simply calls the cast send for creating the rule, does not parse the output
createRuleCastSend: 
	@if [ -z "$(INPUT)" ]; then \
		cast send ${RULE_PROCESSOR_DIAMOND} "addAccountMinMaxTokenBalance(address,bytes32[],uint256[],uint256[],uint16[],uint64)(uint32)" ${APPLICATION_APP_MANAGER} [0x5465737400000000000000000000000000000000000000000000000000000000] [10] [1000] [2] 0 --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545 > makefile_output.txt; \
	else \
		cast send ${RULE_PROCESSOR_DIAMOND} "addAccountMinMaxTokenBalance(address,bytes32[],uint256[],uint256[],uint16[],uint64)(uint32)" ${APPLICATION_APP_MANAGER} [$(shell sh ./script/makefile-tools/convertStringToByte32.sh ${INPUT})] [10] [1000] [2] 0 --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545 > makefile_output.txt; \
	fi

# To set the rule with a specific id and action types use the following syntax:
# make setRule RULEID=id ACTIONTYPES=action
# Note: ACTIONTYPES can be a comma delimited list
# otherwise if RULEID and ACTIONTYPES are not specified, 0 will be used for the rule id and action type.
setRule:
	@if [[ -z "$(RULEID)"  ||  -z "$(ACTIONTYPES)" ]]; then \
		cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountMinMaxTokenBalanceId(uint8[], uint32)" [0] 0 --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	else \
		cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountMinMaxTokenBalanceId(uint8[], uint32)" [${ACTIONTYPES}] ${RULEID} --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	fi

# To clear exisiting rules and set the rule with specific ids and action types use the following syntax:
# make setRuleFull RULEID=id ACTIONTYPES=action
# otherwise if RULEID and ACTIONTYPES are not specified, 0 will be used for the rule id and action type.
setRuleFull:
	@if [[ -z "$(RULEIDS)"  ||  -z "$(ACTIONTYPES)" ]]; then \
		cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountMinMaxTokenBalanceIdFull(uint8[], uint32[])" [0] [0] --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	else \
		cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "setAccountMinMaxTokenBalanceIdFull(uint8[], uint32[])" [${ACTIONTYPES}] [${RULEIDS}] --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	fi

# To activate the rule for a specific action type, use the following syntax:
# make activateRule ACTIONTYPE=action
# otherwise if ACTIONTYPE is not specified, 0 will be used for the action type.
activateRule:
	@if [ -z "$(ACTIONTYPE)" ]; then \
		cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "activateAccountMinMaxTokenBalance(uint8[], bool)()" [0] true --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	else \
		cast send ${APPLICATION_ERC20_HANDLER_ADDRESS} "activateAccountMinMaxTokenBalance(uint8[], bool)()" [$(ACTIONTYPE)] true --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	fi

###############################################
# Cast Calls - Getters
###############################################

# To check if the rule is active for a specific action type, use the following syntax:
# make checkIfActive ACTIONTYPE=actiontype
# otherwise if ACTIONTYPE is not specified, 0 will be used for the action type.
checkIfActive:
	@if [ -z "$(ACTIONTYPE)" ]; then \
		cast call ${APPLICATION_ERC20_HANDLER_ADDRESS} "isAccountMinMaxTokenBalanceActive(uint8)(bool)" 0 --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	else \
		cast call ${APPLICATION_ERC20_HANDLER_ADDRESS} "isAccountMinMaxTokenBalanceActive(uint8)(bool)" $(ACTIONTYPE) --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	fi

# To retrieve the rule Id for a specific action type, use the following syntax:
# make retrieveRuleId ACTIONTYPE=actiontype
# otherwise if ACTIONTYPE is not specified, 0 will be used for the action type.
retrieveRuleId:
	@if [ -z "$(ACTIONTYPE)" ]; then \
		cast call ${APPLICATION_ERC20_HANDLER_ADDRESS} "getAccountMinMaxTokenBalanceId(uint8)(uint32)" 0 --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	else \
		cast call ${APPLICATION_ERC20_HANDLER_ADDRESS} "getAccountMinMaxTokenBalanceId(uint8)(uint32)" $(ACTIONTYPE) --private-key ${APP_ADMIN_PRIVATE_KEY} --from ${APP_ADMIN} --rpc-url http://127.0.0.1:8545; \
	fi