# Handler Utils Invariants

## HandlerUtils Invariants

- Version will never be blank
- Version will never change.
- When mint, determineTransferAction always returns ActionTypes.MINT 
- When burn, deterineTransferAction always returns ActionTypes.BURN 
- When sell, deterineTransferAction always returns ActionTypes.SELL 
- When buy, deterineTransferAction always returns ActionTypes.BUY 
- When p2ptransfer, deterineTransferAction always returns ActionTypes.P2P_TRANSFER 