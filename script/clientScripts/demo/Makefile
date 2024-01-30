# Deploy contracts(singles)

mintFranks:;	cast send $$APPLICATION_ERC721_1 "safeMint(address, uint256)" $USER_1 0 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1

createRule:; 	cast send $$RULE_PROCESSOR_DIAMOND "addAccountMinMaxTokenBalance(address,bytes32[],uint256[],uint256[],uint16[],uint64)(uint32)" $$APPLICATION_APP_MANAGER \[\] \[0\] \[1\] \[\] 1769924800 --private-key $$APP_ADMIN_1_KEY --from $$APP_ADMIN_1 --rpc-url $$ETH_RPC_URL &> ./transaction_output.txt 

applyRuleToTransfers:; 	cast send $$APPLICATION_ERC721_1_HANDLER "setAccountMinMaxTokenBalanceId(uint8[], uint32)" [0] 0 --private-key $$APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $$APP_ADMIN_1

transfer:;	cast send $$APPLICATION_ERC721_1 "transferFrom(address,address,uint256)" $$USER_1 $$USER_2 0 --private-key $$USER_1_KEY

checkFrankBalanceUser1:; cast call $$APPLICATION_ERC721_1 "balanceOf(address)(uint256)" $$USER_1 --private-key $$APP_ADMIN_1_KEY --from $$APP_ADMIN_1 

transferOverMax:;	cast send $$APPLICATION_ERC721_1 "transferFrom(address,address,uint256)" $$USER_1 $$USER_2 1 --private-key $$USER_1_KEY

mintFranksToUser:;

applyRuleToMints:;

mintFranksToUser1OverMax:;


