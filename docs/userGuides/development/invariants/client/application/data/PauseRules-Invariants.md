# Pause Rules Invariants

###### Note: Invariants not implemented yet but properly fuzz tested
- Upon creation ownership of the contract will be transfered to the App Manager address passed in to the constructor.
- If addPauseRule is called with a pauseStop that is less than pauseStart the transaction will be reverted. 
- If addPauseRule is called with a pauseStart is less than the current block timestamp the transaction will be reverted.
- If addPauseRule is not reverted the PauseRuleEvent event will be emitted. 
- If getPauseRules is called by an address that is not the registered App Manager the transaction will be reverted. 
- If isPauseRulesEmpty is called by an address that is not the registered App Manager the transaction will be reverted.  