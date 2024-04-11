# Accounts Invariants

#### Note: Not implemented, todo later

- Upon creation ownership of the contract will be transfered to the App Manager address passed in to the constructor.
- When addAccount is called by an address that is not the registered App Manager the transaction will be reverted.
- If addAccount is called with an address of 0 the transaction will be reverted.
- If addAccount is not reverted the AccountAdded event is emitted. 

- If removeAccount is called by an address that is not the registered App Manager the transaction will be reverted.
- If removeAccount is not reverted the AccountRemoved event is emitted.