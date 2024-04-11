# ApplicationProtocolHandler Invariants

### Note: Not implemented yet

- Upon creation of the contract the App Manager address passed in to the constructor will be the contracts owner.
- If checkApplicationRules is called by an account that is not the registered AppManager the transaction will be reverted.

- If setNFTPricingAddress is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted.
- If setNFTPricingAddress is called with an address of 0 the transaction will be reverted. 
- If setNFTPricingAddress is not reverted the ERC721PricingAddressSet event will be emitted. 
- If setERC20PricingAddress is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted. 
- If setERC20PricingAddress is called with an address of 0 the transaction will be reverted.
- If setERC20PricingAddress is not reverted the ERC20PricingAddressSet event will be emitted.

- If getAccTotalValuation is called with an address of 0 a value of 0 will be returned. 
- If _getERC20Price is called with an address of 0 the transaction will be reverted. 
- If _getNFTValuePerCollection is called with an address of 0 the transaction will be reverted. 
- If _getNFTCollectionValue is called with an address of 0 the transaction will be reverted. 

- If setAccountMaxValueByRiskScoreId is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted.
- If setAccountMaxValueByRiskScoreId is not reverted the ApplicationRuleApplied event will be emitted.
- If activateAccountMaxValueByRiskScore is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted. 
- If activateAccountMaxValueByRiskScore is not reverted when true is passed in the ApplicationHandlerActivated event will be emitted.
- If activateAccountMaxValueByRiskScore is not reverted when false is passed in the ApplicationHandlerDeactivated event will be emitted.

- If setAccountMaxValueByAccessLevelsId is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted.
- If setAccountMaxValueByAccessLevelsId is not reverted the ApplicationRuleApplied event will be emitted.
- If activateAccountMaxValueByAccessLevel is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted. 
- If activateAccountMaxValueByAccessLevel it not reverted when true is passed in the ApplicationHandlerActivated event will be emitted.
- If activateAccountMaxValueByAccessLevel is not reverted when false is passed in the ApplicationHandlerDeactivated event will be emitted.

- If activateAccountDenyForNoAccessLevelRule is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted. 
- If activateAccountDenyForNoAccessLevelRule is not reverted when true is passed in the ApplicationHandlerActivated event will be emitted.
- If activateAccountDenyForNoAccessLevelRule is not reverted when false is passed in the ApplicationHandlerDeactivated event will be emitted. 

- If setAccountMaxValueOutByAccessLevelId is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted.
- If setAccountMaxValueOutByAccessLevelId is not reverted the ApplicationRuleApplied event will be emitted. 
- If activateAccountMaxValueOutByAccessLevel is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted.
- If activateAccountMaxValueOutByAccessLevel is not reverted when true is passed in the ApplicationHandlerActivated event will be emitted.
- If activateAccountMaxValueOutByAccessLevel is not reverted when false is passed in the ApplicationHanlderDeactivated event will be emitted.

- If setAccountMaxTxValueByRiskScoreId is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted. 
- If setAccountMaxTxValueByRiskScoreId is not reverted the ApplicationRuleApplied event will be emitted.
- If activateAccountMaxTxValueByRiskScore is called by an account that is not a Rule Admin for the registered App Manager the transaction will be reverted. 
- If activateAccountMaxTxValueByRiskScore is not reverted when true is passed in the ApplicationHandlerActivate event will be emitted.
- If activateAccountMaxTxValueByRiskScore is not reverted when false is passed in the ApplicationHandlerDeactivated event will be emitted.

- If activatePauseRule is called by an account that is not the registered App Manager the transaction will be reverted.
- If activatePauseRule is not reverted when true is passed in the ApplicationHandlerActivate event will be emitted.
- If activatePauseRule is not reverted when false is passed in the ApplicationHandlerActivate event will be emitted. 

- When PauseRule is active, checkApplicationRules transactions will be reverted.
- When AccountDenyForNoAccessLevel is active, violation of the rule is reverted.
- When AccountMaxValueByAccessLevel is active, violation of the rule is reverted.
- When AccountMaxValueOutByAccessLevel is active, violation of the rule is reverted.
- When AccountMaxValueByRiskScore is active, violation of the rule is reverted.
- When AccountMaxTxValueByRiskScore is active, violation of the rule is reverted.