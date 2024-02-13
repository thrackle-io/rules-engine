# AccessLevels Invariants

- Upon creation ownership of the contract will be transfered to the App Manager address passed in to the constructor.
- When addLevel is called by an address that is not the registered App Manager the transaction will be reverted.
- When addLevel is called with a level value greater than 4 the transaction will be reverted.
- When addLevel is called with an address of 0 the transaction will be reverted.
- If addLevel is not reverted the AccessLevelAdded event will be emitted.

- When addAccessLevelToMultipleAccounts is called by an address that is not the registered App Manager the transaction will be reverted.
- When addAccessLevelToMultipleAccounts is called with a level value greater than 4 the transaction will be reverted.
- If addAccessLevelToMultipleAccounts is not reverted the AccessLevelAdded event will be emitted for each address in the array.

- When removeAccessLevel is called by an address that is not the registered App Manager the transaction will be reverted.
- If removeAccessLevel is not reverted the AccessLevelRemoved event will be emitted for each address in the array.