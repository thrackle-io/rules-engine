# Protocol Invariants

## General Invariants

- The total amount of rules will never decrease.
- There can be only a total of 2**32 of each rule type.
- The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
- The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
- Rules can never be erased from the blockchain.
- Rules can never be modified.
- There is a total of 5 possible access levels that can be applied to an account which are positive integers from 0 to 4.
- There is a total of 100 possible risk scores that can be applied to an account which are positive integers from 0 to 99. *We have to check this. The logic actually allows only until 98*
- An account can have a maximum of 10 tags registered in the application.
- Rules that depend on a period of time, depend on a non-rolling period. This means that each period starts and ends at a fixed time, and it has no memory of past periods.
- Rules can be applied independently which means that a token, AMM or application can have none, some or all possible rules activated.
- The usage of rules is totally open which means that they can be used by any token, applicationManager and/or AMM respectively (or other external type of contract).
- Only accounts with the role of RuleAdministrator in a protocol-compliant AppManager contract can create rules in the protocol.
- Rules can be shared by multiple applications and/or assets.
- Deactivating a rule in one token, AMM or Application does not affect its application in others.
- Rules at the application level apply to all registered tokens.


## AppAdministratorOnly and AppAdministratorOnlyU Modifiers

- When applied to a function, it means that the function is only callable by an account with the role of AppAdministrator.

## AppAdministratorOrOwnerOnly Modifier

- When applied to a function, it means that the function is only callable by the owner of the contract or an account with the role of AppAdministrator.

## RuleAdministratorOnly Modifier

- When applied to a function, it means that the function is only callable by an account with the role of RuleAdministrator.

## ApplicationAccessLevelProcessorFacet

### Balance By Access Level

- The total USD balance in application assets (fungible and non-fungible) of an account must not exceed the maximum of the AccessLevelBalance rule applied for the application and the access level of the account.

### Withdraw By Access Level

- An account's cumulative total of funds withdrawn from the protocol in USD terms must not exceed the maximum for that account's access level defined in the Withdraw-By-Access-Level rule applied for the application counting from the activation of the rule. This is a lifetime cumulative total which can't be ever reset.

### checkAccessLevel0Passes

- When this rule is applied, an account with access level 0 must not be allowed to transfer tokens of an application.

## ApplicationPauseProcessorFacet

### Pause Rule

- When this rule is applied, the transfer of any tokens (including mints and burns) of an application is not possible while inside a pause rule window applied to an application.

## ApplicationRiskProcessorFacet

### Balance By Risk

- When this rule is applied, the total USD balance in application assets (fungible and non-fungible) of an account must not exceed the maximum of the AccountBalanceToRiskRule applied for the application and the risk score of the account.

### Maximum Transaction Size Per Period By Risk

- When this rule is applied, the cumulative USD value transacted in all application assets within a defined period of time can never exceed the maximum of the TxSizePerPeriodToRiskRule applied for the application and the risk score of the account.


### Minimum Transfer

- When this rule is applied, the total amount of tokens transferred in a single transaction must never be less than the amount specified in the TokenMinimumTransferRule applied to the token.

### Oracle Rules

- When this rule is applied, a transaction must revert if a transfer of tokens is going towards an address that has been found in the denied list or not found in an allowed list specified in the oracle rule.

## Token Transfer Volume

- When this rule is applied, the cumulative amount of tokens transacted in a defined period of time relative to the total supply of the token can never exceed the maximum of the TokenTransferVolumeRule applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.

### Supply Votality

- When this rule is applied, the cumulative net amount of tokens minted or burned in a defined period of time relative to the total supply at the beginning of the period can never exceed the maximum of the SupplyVolatilityRule applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.


### Purchase Percentage

- When this rule is applied, the cumulative amount of tokens purchased in a defined period of time relative to the total supply at the beginning of the period can never exceed the maximum of the TokenPercentagePurchaseRule applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.

### Sell Percentage

- When this rule is applied, the cumulative amount of tokens sold in a defined period of time relative to the total supply at the beginning of the period can never exceed the maximum of the TokenPercentageSellRule applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.

## ERC20TaggedRuleProcessorFacet

### Min Max Account Balance

- When this rule is applied, the balance of a specific token of an account cannot be less than the minimum or greater than the maximum determined by the most restrictive tags of the account found in the MinMaxBalanceRule applied to the token.

### Admin Withdrawal

- When this rule is applied, the token balance of a rule bypasser account cannot be less than the minimum defined in the AdminwithdrawalRule while the rule is in the active and applicable period. While the rule is in the applicable period, the rule can never be deactivated, and the rule bypasser account must not be allowed to renounce its role.

### Min Balance By Date

- When this rule is applied, the token balance of an account cannot be less than the minimum defined by the most restrictive tags of the account found in the MinBalByDateRule while the rule is in the active and applicable period.

### Purchase Limit

- When this rule is applied, the cumulative amount of tokens purchased in a defined period of time can never exceed the maximum of the most restrictive tags of the account found in the PurchaseRule applied for the asset.  

### Sell Limit

- When this rule is applied, the cumulative amount of tokens sold in a defined period of time can never exceed the maximum of the most restrictive tags of the account found in the SellRule applied for the asset.  

## ERC721RuleProcessorFacet

### Hold Time

- When this rule is applied, an NFT can never be transferred before the hold-time period has passed counting from the last trade date.

### NFT Transfer count

- When this rule is applied, the amount of times that a particular NFT is transferred during a fixed 24-hour period can never exceed the maximum defined by the most restrictive tag of the NFT found in the NFTTradeCounterRule applied to the token.

## RiskTaggedRuleProcessorFacet

### checkTransactionLimitByRiskScore

- When this rule is applied, the USD value transacted in a single transaction can never exceed the maximum of the TransactionSizeToRiskRule applied for the application and the risk score of the account.

## RuleApplicationValidationFacet

- A rule cannot be applied in a handler if the rule doesn't exist in the protocol.


