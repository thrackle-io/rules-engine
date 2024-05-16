# Tagged Rules
[![Project Version][version-image]][version-url]

---

| Tagged Rules | Purpose |
|:-|:-|
| [Account Min/Max Token Balance Rule](../rules/ACCOUNT-MIN-MAX-TOKEN-BALANCE.md) | The account-min-max-token-balance rule enforces token balance thresholds for user accounts with specific tags. This allows developers to set lower and upper limits on the amount of each token the user account can hold. This rule attempts to mitigate the risk of token holders selling more than the minimum allowed amount and accumulating more than the maximum allowed amount of tokens for each specific tag. It can also be used to prevent token holders from rapidly flooding the market with newly acquired tokens since a dramatic increase in supply over a short time frame can cause a token price crash. This is done by associating an opional period with the rule. |
| [Account Max Trade Size](../rules/ACCOUNT-MAX-TRADE-SIZE.md) | The Account Max Trade Size Rule is an account based measure which restricts an account’s ability to buy or sell more of a token. This may be put in place to restrict large transactions from occurring against suspected malicious accounts or other accounts of interest. The amount of buys or sells allowed depends on the account's tags. Different accounts may get different buy and sell restrictions depending on their tags. |
| [Token Max Daily Trades Rule](../rules/TOKEN-MAX-DAILY-TRADES.md) | The token-max-daily-trades rule enforces a daily limit on the number of trades for each token within a collection. In the context of this rule, a "trade" is a transfer of a token from one address to another. Example uses of this rule: to mitigate price manipulation of tokens in the collection via the limitation of wash trading or the prevention of malfeasance for holders who transfer a token between addresses repeatedly. When this rule is active and the tradesAllowedPerDay is 0 this rule will act as a pseudo "soulBound" token, preventing all transfers of tokens in the collection.   |
| [Admin Min Token Balance](../rules/ADMIN-MIN-TOKEN-BALANCE.md) | The purpose of the admin-min-token-balance rule is to allow developers to prove to their community that they will hold a certain amount of tokens for a certain period of time. Adding this rule prevents developers from flooding the market with their supply and effectively "rug pulling" their community. |






<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron