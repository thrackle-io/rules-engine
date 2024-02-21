# Handler Utils Invariants

## HandlerUtils Invariants

- Version will never be blank
- Version will never change.
- When mint, determineTransferAction always returns ActionTypes.MINT 
- When burn, determineTransferAction always returns ActionTypes.BURN 
- When sell, determineTransferAction always returns ActionTypes.SELL 
- When buy, determineTransferAction always returns ActionTypes.BUY 
- When p2ptransfer, determineTransferAction always returns ActionTypes.P2P_TRANSFER 