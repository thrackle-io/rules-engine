# Token Systen Level Invariants

The word **token** in this context refers to both ERC20 fungible tokens and ERC721 NFTs.

- A rule-Id-setting transaction for a token reverts if the rule id doesn't exist in the protocol.

- When the AccountMaxValueByAccessLevel rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer of tokens reverts if the sum of balances valued in USD of all application assets (fungible and non-fungible) of the receiving address exceeds the maximum of the AccountMaxValueByAccessLevel rule applied for the application and for the access level of the receiving address.

- When the AccountMaxValueOutByAccessLevel rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer of tokens reverts if the address's cumulative total of funds withdrawn from the protocol in USD terms exceeds the maximum for that account's access level defined in the AccountMaxValueOutByAccessLevel rule applied for the application counting from the activation date of the rule. This is a lifetime cumulative total.

- When the AccountDenyForNoAccessLevel rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer of tokens reverts if an address with access level 0 is at either the sending or the receiving side of the transfer.

- When a Pause rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, a transfer of tokens reverts if the transfer happens inside a pause rule window.

- When the AccountMaxValueByRiskScore rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, a transfer of tokens reverts if the sum of balances valued in USD of all application assets (fungible and non-fungible) of an address exceeds the maximum of the AccountMaxValueByRiskScore applied for the application and for the risk-score braket that the address falls on.

- When the AccountMaxTxValueByRiskScore is applied, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer reverts if the cumulative USD value transacted in a period exceeds the maximum defined in the AccountMaxTxValueByRiskScore applied for the application and for the risk-score braket that the address falls on. If the rule doesn't have a period, the rule is evaluated in a per transaction basis.

- When the OracleAllowDeny rule is applied, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer of tokens reverts if the tokens are going towards an address that has been found in the denied list or not found in an allowed list specified in the OracleAllowDeny rule applied to the token.

- When the TokenMaxTradingVolume rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer of tokens reverts if the cumulative amount of tokens transacted in a defined period of time by an address relative to the total supply of the token exceeds the maximum defined in the TokenMaxTradingVolume applied to the token. The total supply can be given live or stored as a hard coded value in the rule itself. If it is given live, this would be captured at the beginning of the period and will remain the same for the entire period for the sake of the integrity of the rule.

- When the TokenMaxSupplyVolatility rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer of tokens reverts if the cumulative net amount of tokens minted or burned in a defined period of time relative to the total supply at the beginning of the period exceeds the maximum defined in the TokenMaxSupplyVolatility applied to the token. The total supply can be given live or stored as a hard coded value in the rule itself. If it is given live, this would be captured at the beginning of the period and will remain the same for the entire period for the sake of the integrity of the rule.

- When the TokenMaxBuyVolume rule is active,  and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer reverts if it has been identified as a purchase and the cumulative amount of tokens purchased in a defined period of time relative to the total supply at the beginning of the period exceeds the maximum of the TokenMaxBuyVolume applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself. If it is given live, this would be captured at the beginning of the period and will remain the same for the entire period for the sake of the integrity of the rule.

- When the TokenMaxSellVolume rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer reverts if it has been identified as a sale and the cumulative amount of tokens sold in a defined period of time relative to the total supply at the beginning of the period exceeds the maximum of the TokenMaxSellVolume applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself. If it is given live, this would be captured at the beginning of the period and will remain the same for the entire period for the sake of the integrity of the rule.

- When the AccountMinMaxTokenBalance rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer reverts if the balance of a specific token of an address is less than the minimum or greater than the maximum determined by the most restrictive tags for the address found in the AccountMinMaxTokenBalance rule applied to the token.

- When the AdminMaxValueOut rule is active, the token balance of a rule bypasser address cannot be less than the minimum defined in the AdminMaxValueOut during the applicable period. While the rule is in the applicable period, the rule can never be deactivated, and the rule bypasser account must not be allowed to renounce its role.

- When the MaxBuySize rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer reverts if it has been identified as a purchase and the cumulative amount of tokens purchased in a defined period of time exceeds the maximum of the most restrictive tags of the account found in the MaxBuySize applied for the asset. If no period is set for the rule, then the rule is checked at a per transaction basis instead of a period.

- When the MaxSell Size rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, a transfer reverts if it has been identified as a sale and the cumulative amount of tokens sold in a defined period of time exceeds the maximum of the most restrictive tags of the account found in the MaxSellSize applied for the asset. If no period is set for the rule, then the rule is checked at a per transaction basis instead of a period.

## ERC20 Specific

- When TokenMinTransactionSize rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, an ERC20-token transfer reverts if the total amount of fungible tokens transferred is less than the amount specified in the TokenMinTransactionSize rule applied to the ERC20.

## ERC721 Specific

- When the TokenMinHoldTime rule is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, an ERC721-token transfer reverts if that particular NFT is being transferred before the hold-time period has passed counting from its last trade date.

- When the TokenMaxDailyTrades is active, and neither the receiver nor the sender address have the ruleBypassAccount role, and the receiver address is not a registered Treasury, an ERC721-token transfer reverts if the amount of times that that particular NFT has been transferred during a fixed 24-hour period exceeds the maximum defined by the most restrictive tag of the NFT contract found in the TokenMaxDailyTrades applied to the token.
