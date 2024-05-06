# ProtocolERC20Handler Invariants

##### Note: not implemented, todo
This document covers all the facets for the ERC20 handler, its rules, and the inherited contracts it uses.

## ERC20HandlerMainFacet Invariants

- Only the connected ERC20 can access checkAllRules
- Can only be initialized once
- All transfers are allowed to a registered treasury account
- When a rule is set, its status is active.
- 10 AccountAllowDenyOracle may be applied per action.
- All rules - id's may only be set by a ruleAdmin
- All rules - id's may only be set to an existing rule id in the RuleProcessorDiamond
- All rules - When setting a rule, only valid actions(0-4) are allowed
- All rules - When activating a rule, only valid actions(0-4) are allowed
- All rules - When deactivating a rule, only valid actions(0-4) are allowed
- All rules - When a rule id is set, then the rule is deactivated, retrieving the id still returns the rule id
- All rules - When a rule is NOT active, call to activate the rule always emits ApplicationHandlerActionActivated event
- All rules - When a rule is active, subsequent calls to activate the rule do not emit ApplicationHandlerActionActivated event
- Application rules - When any application rule is active, it is checked for all accounts except the RuleBypassAccount
- When upgrading the facet, all data remains pristine 

## HandlerBase Invariants

- Only an App Admin or the owning token can propose a new owner
- Proposed address can not be set to zero address
- When an address is proposed, AppManagerAddressProposed is always emitted
- Any type of address may confirm the proposed AppManager as long as it is the proposed AppManager.
- Only the proposed AppManager may confirm the AppManagerAddress
- When AppManagerAddress is confirmed, AppManagerAddressSet event is always emitted

## ERC20TaggedRuleFacet Invariants(covers TradingRuleFacet as well)

- When AccountMinMaxTokenBalance is active, violation of the rule is reverted.
- When AccountMaxBuySize is active, violation of the rule is reverted. 
- When TokenMaxBuyVolume is active, violation of the rule is reverted. 
- When AccountMaxSellSize is active, violation of the rule is reverted. 
- When TokenMaxSellVolume is active, violation of the rule is reverted. 
- When upgrading the facet, all data remains pristine 

## ERC20NonTaggedRuleFacet Invariants

- When accountAllowDenyOracle is active, violation of the rule is reverted.
- When tokenMinTxSize is active, violation of the rule is reverted. 
- When tokenMaxTradingVolume is active, violation of the rule is reverted. 
- When tokenMaxSupplyVolatility is active, violation of the rule is reverted. 
- When tokenMinTxSize is active, violation of the rule is reverted. 
- When tokenMinTxSize is active, violation of the rule is reverted.
- When upgrading the facet, all data remains pristine 

## NFTValuationLimit

- Only AppAdmin or owning token may set the NFT Valuation Limit
- When NFTValuationLimit is set, it always emits NFTValuationLimitUpdated event
