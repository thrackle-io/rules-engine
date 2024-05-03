# Protocol Invariants

All invariants have links to their invariant test files unless specified otherwise.

## Notes

\* Tested thoroughly through fuzz testing and unit testing.


## General Invariants

### [All Rules - Storage](../../../../../test/protocol/economic/invariant/rules/)

- The total amount of rules will never decrease.
- There can be only a total of 2**32 of each rule type.
- The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
- The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
- Rules can never be erased from the blockchain.
- Rules can never be modified.

### [All Rules - Processing and Application](../../../../../test/client/token/invariant/)

- Deactivating a rule in one token, AMM or Application does not affect its application in others.
- Rules can be shared by multiple applications and/or assets. # note not implemented
- Rules at the application level apply to all registered tokens. # note not implemented
  
## [Rule Invariants - With State Variables](../../../../../test/client/token/invariant/)

### [Account Max Value Out By Access Level](../../../../../test/client/token/invariant/accountMaxValueOutByAccessLevel/RuleProcessingAccountMaxValueOutByAccessLevelMulti.t.i.sol)

- When this rule is applied, An account's cumulative total of funds withdrawn from the protocol in USD terms must not exceed the maximum for that account's access level defined in the Account-Max-Value-Out-By-Access-Level rule applied for the application counting from the activation of the rule. 

### [Account Max Transaction Value By Risk](../../../../../test/client/token/invariant/accountMaxTxValueByRiskScore/RuleProcessingAccountMaxTxValueByRiskScoreMulti.t.i.sol)

- When this rule is applied, the cumulative USD value transacted in all application assets within a defined period of time can never exceed the maximum of the AccountMaxTxValueByRiskScore applied for the application and the risk score of the account.

### [Token Max Trading Volume](../../../../../test/client/token/invariant/tokenMaxTradingVolume/RuleProcessingTokenMaxTradingVolumeMulti.t.i.sol)

- When this rule is applied, the cumulative amount of tokens transacted in a defined period of time relative to the total supply of the token can never exceed the maximum of the TokenMaxTradingVolume applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.

### [Token Max Supply Votality](../../../../../test/client/token/invariant/tokenMaxSupplyVolatility/RuleProcessingTokenMaxSupplyVolatilityMulti.t.i.sol)

- When this rule is applied, the cumulative net amount of tokens minted or burned in a defined period of time relative to the total supply at the beginning of the period can never exceed the maximum of the TokenMaxSupplyVolatility applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.

### [Token Max Buy Volume](../../../../../test/client/token/invariant/tokenMaxBuyVolume/RuleProcessingTokenMaxBuyVolumeMulti.t.i.sol)

- When this rule is applied, the cumulative amount of tokens purchased in a defined period of time relative to the total supply at the beginning of the period can never exceed the maximum of the TokenMaxBuyVolume applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.

### [Token Max Sell Volume](../../../../../test/client/token/invariant/tokenMaxSellVolume/RuleProcessingTokenMaxSellVolumeMulti.t.i.sol)

- When this rule is applied, the cumulative amount of tokens sold in a defined period of time relative to the total supply at the beginning of the period can never exceed the maximum of the TokenMaxSellVolume applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.

### [Account Max Buy Size](../../../../../test/client/token/invariant/accountMaxBuySize/RuleProcessingAccountMaxBuySizeMulti.t.i.sol)

- When this rule is applied, the cumulative amount of tokens purchased in a defined period of time can never exceed the maximum of the most restrictive tags of the account found in the MaxBuySize applied for the asset.  

### [Account Max Sell Size](../../../../../test/client/token/invariant/accountMaxSellSize/RuleProcessingAccountMaxSellSizeMulti.t.i.sol)

- When this rule is applied, the cumulative amount of tokens sold in a defined period of time can never exceed the maximum of the most restrictive tags of the account found in the AccountMaxSellSize applied for the asset.  

### [Token Max Daily Trades](../../../../../test/client/token/invariant/tokenMaxDailyTrades/RuleProcessingTokenMaxDailyTradesMulti.t.i.sol)

- When this rule is applied, the amount of times that a particular NFT is transferred during a fixed 24-hour period can never exceed the maximum defined by the most restrictive tag of the NFT found in the TokenMaxDailyTrades applied to the token.

### Token Min Hold Time *

- When this rule is applied, an NFT can never be transferred before the hold-time period has passed counting from the last trade date.

## Rule Invariants - Without State Variables

### Balance By Access Level *

- The total USD balance in application assets (fungible and non-fungible) of an account must not exceed the maximum of the AccessLevelBalance rule applied for the application and the access level of the account.

### AccountDenyForNoAccessLevel *

- When this rule is applied, an account with access level 0 must not be allowed to transfer tokens of an application.

### Pause Rule *

- When this rule is applied, the transfer of any tokens (including mints and burns) of an application is not possible while inside a pause rule window applied to an application.

### Account Max Value By Risk *

- When this rule is applied, the total USD balance in application assets (fungible and non-fungible) of an account must not exceed the maximum of the AccountMaxValueByRiskScore applied for the application and the risk score of the account.

### Token Min Transaction Size *

- When this rule is applied, the total amount of tokens transferred in a single transaction must never be less than the amount specified in the TokenMinTransactionSize applied to the token.

### Account Approve Deny Oracle *

- When this rule is applied, a transaction must revert if a transfer of tokens is going towards an address that has been found in the denied list or not found in an allowed list specified in the oracle rule.

### Account Min Max Token Balance *

- When this rule is applied, the balance of a specific token of an account cannot be less than the minimum or greater than the maximum determined by the most restrictive tags of the account found in the AccountMinMaxTokenBalance applied to the token while the rule is in the active and applicable period (If a period has been applied).

### Admin Min Token Balance *

- When this rule is applied, the token balance of a rule bypasser account cannot be less than the minimum defined in the AdminwithdrawalRule while the rule is in the active and applicable period. While the rule is in the applicable period, the rule can never be deactivated, and the rule bypasser account must not be allowed to renounce its role.

### RuleApplicationValidationFacet *

- A rule cannot be applied in a handler if the rule doesn't exist in the protocol, or the action is not enabled.


