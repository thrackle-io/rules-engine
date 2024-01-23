# Tagged Rules
[![Project Version][version-image]][version-url]

---

| Tagged Rules | Purpose |
|:-|:-| 
| [Minimum Account Balance By Date Rule](../rules/MINIMUM-ACCOUNT-BALANCE-BY-DATE.md) | The purpose of the minimum-balance-by-date rule is to prevent token holders from rapidly flooding the market with newly acquired tokens since a dramatic increase in supply over a short time frame can cause a token price crash. This rule attempts to mitigate this scenario by making holders wait some period of time before they can transfer their tokens. The length of time depends on the account's tags. Different accounts may need to wait different periods of time depending on their tags, or even no time at all. |
| [Min/Max Account Balance Rule](../rules/MIN-MAX-ACCOUNT-BALANCE.md)] | The minimum-maximum-account-balance rule enforces token balance thresholds for user accounts with specific tags. This allows developers to set lower and upper limits on the amount of each token the user account can hold. This rule attempts to mitigate the risk of token holders selling more than the minimum allowed amount and accumulating more than the maximum allowed amount of tokens for each specific tag. |
| [ACCOUNT-PURCHASE](../rules/ACCOUNT-PURCHASE-RULE.md) | The Account Purchase Rule is an account based measure which restricts an account’s ability to purchase more of a token. This may be put in place to restrict large transactions from occurring against suspected malicious accounts or other accounts of interest. The amount of purchases allowed depends on the account's tags. Different accounts may get different purchase restrictions depending on their tags. |
| [ACCOUNT-SELL](../rules/ACCOUNT-SELL-RULE.md) | The Account Sell Rule is an account based measure which restricts an account’s ability to sell a token. This may be put in place to restrict large transactions from occurring against suspected malicious accounts or other accounts of interest. The amount of sales allowed depends on the account's tags. Different accounts may get different sale restrictions depending on their tags. |
| [Transfer Counter Rule](./TRANSFER-COUNTER.md) | The transfer-counter rule enforces a daily limit on the number of trades for each token within a collection. In the context of this rule, a "trade" is a transfer of a token from one address to another. Example uses of this rule: to mitigate price manipulation of tokens in the collection via the limitation of wash trading or the prevention of malfeasance for holders who transfer a token between addresses repeatedly. When this rule is active and the tradesAllowedPerDay is 0 this rule will act as a pseudo "soulBound" token, preventing all transfers of tokens in the collection.   |
| [Admin Withdrawal Rule](./ADMIN-WITHDRAWAL-RULE.md) | The purpose of the admin-withdrawal rule is to allow developers to prove to their community that they will hold a certain amount of tokens for a certain period of time. Adding this rule prevents developers from flooding the market with their supply and effectively "rug pulling" their community. |






<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron