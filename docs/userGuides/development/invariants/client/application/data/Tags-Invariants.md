# Tags Invariants

###### Note: Invariants not implemented yet but properly fuzz tested

- Upon creation ownership of the contract will be transfered to the App Manager address passed in to the constructor.
- If addTag is called with an empty string for the tag the transaction will be reverted.
- If addTag is called with an address of 0 the transaction will be reverted.
- If addTag is not reverted the Tag event will be emitted. 

- If addTagToMultipleAccounts is called with an empty string for the tag the transaction will be reverted.
- If addTagToMultipleAccounts is not reverted the Tag event will be emitted for each address in the array.

- If removeTag is not reverted the Tag event will be emitted.