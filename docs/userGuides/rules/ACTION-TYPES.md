# Action Types

## Purpose
The ActionTypes enum, located in [ActionEnum.sol](../../../src/common/ActionEnum.sol), 
identifies the possible action types for the protocol. Rules can be enabled for any subset of these actions.

## Enum

|uint8 value|Name|
|----|----|
|0|`P2P_TRANSFER`|
|1|`BUY`|
|2|`SELL`|
|3|`MINT`|
|4|`BURN`|

## P2P_TRANSFER

The protocol defines a peer to peer transfer as any transfer that does not meet the requirements below for BUY, SELL, MINT, or BURN.

## BUY

The protocol defines a buy as as any transfer where the from address is a contract, the originating sender equals the from address, to address is not the zero address, and from address is not the zero address. Please note that within this action, there are two different common techniques: custodial style and non-custodial style. Non-custodial style, like OpenSea, uses a contract to perform the trade, but the token is transferferred directly from the buyer and seller. Custodial style, like NFT AMM's, uses a contract to perform the trade, but the marketplace(or pool) owns the token to purchase so it is transferred directly from the marketplace(or pool) contract. 

## SELL

The protocol defines a sell as any transfer where the originating sender is not the from address, to address is not the zero address, and from address is not the zero address. Please note that within this action, there are two different common techniques: custodial style and non-custodial style. Non-custodial style, like OpenSea, uses a contract to perform the trade, but the token is transferferred directly from the buyer and seller. Custodial style, like NFT AMM's, use a contract to perform the trade, but the marketplace(or pool) owns the token to sell so it is transferred directly to the marketplace(or pool) contract. 

## MINT

The protocol defines a mint as a transfer from zero address to any address or contract originating from any sender.

## BURN

The protocol defines a burn as a transfer to the zero address from any address(except the zero address) or any contract originating from any sender.

## What Actions apply to what Rules? 

Please see [Rule Applicatibility](./RULE-APPLICABILITY.md)
