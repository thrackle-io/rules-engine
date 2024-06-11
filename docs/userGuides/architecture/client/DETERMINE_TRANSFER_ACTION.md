# Determine Transfer Action Function 

## Purpose

The protocol implements a function to determine the [action type](../../rules/ACTION-TYPES.md) of the current transfer. That action type is then passed to the asset handler diamond to continue the rule check process. 

## Function Overview

The determine transfer action function will asses the `_from`, `_to`, and `_sender` addresses within the transaction and determine the action with the following logic: 

```c
function determineTransferAction(address _from, address _to, address _sender) internal returns (ActionTypes action)

├── if _from address is address(0)
│ ├── it will determine the action is a Mint
│ └── it will emit Action event with mint action type
├── if msg.sender is a contract
│ └── if tx.origin is equal to the _from address
|    ├── it will determine the action is a Sell
│    └── it will emit Action event with sell action type
│       └── else
|          ├── it will determine the action is a Buy
│          └── it will emit Action event with buy action type
├── else 
│ ├── it will determine the action is a P2P Transfer 
│ └── it will emit Action event with P2P Transfer action type
└── when the action has been determined 
    └── the function will return the action type 
```

## Situational Determinations 

The determine transfer action function will assess if the `_from` address is a contract or an externally owned account. When it is determined that _from is a contract the action type is a Buy action. This can determine certain transfers from individuals that could be realistically assessed as a P2P Transfer action as a Buy action. Transfers from Smart Contract Accounts or Smart Contract Wallets will be determined as a buy. 

Additionally, if tokens are transfered during the construction of a contract, this transfer will be determined as a P2P Transfer and not a Buy action. This is because the contract at construction has no code and would be considered an externally owned account until the contract is deployed. 