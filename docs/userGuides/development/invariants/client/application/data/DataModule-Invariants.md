# Data Module Invariants

##### Note: Todo, not implemented

- The Data Module contract can not be instantiated.
- If proposeOwner is called by an address that is not either the current owner or an App Admin the transaction will be reverted.
- If proposeOwner is called with an address of 0 the transaction will be reverted. 
- If confirmOwner is called with an address of 0 the transaction will be reverted. 
- If confirmDataProvider is called by an address that is not either the current owner or an App Admin the transaction will be reverted.
