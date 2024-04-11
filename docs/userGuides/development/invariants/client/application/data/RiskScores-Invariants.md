# Risk Scores Invariants

##### Note: Not implemented todo

- Upon creation ownership of the contract will be transfered to the App Manager address passed in to the constructor.
- If addScore is called by an address that is not the registered App Manager the transaction will be reverted. 
- If addScore is called with a value greater than 100 the transaction will be reverted.
- If addScore is called with an address of 0 the transaction will be reverted. 
- If addScore is not reverted the RiskScoreAdded event will be emitted. 

- If addRiskScoreToMultipleAccounts is called with a value greater than 100 the transaction will be reverted. 
- If addRiskScoreToMultipleAccounts is not reverted the RiskScoreAdded event will be emitted for each address in the array.

- If removeScore is called by an address that is not the registered App Manager the transaction will be reverted. 
- If removeScore is not reverted the RiskScoreRemoved event will be emitted. 