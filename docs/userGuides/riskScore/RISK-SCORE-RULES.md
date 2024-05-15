# Risk Score Rules
[![Project Version][version-image]][version-url]

---

| Tagged Rules | Purpose |
|:-|:-| 
| [Account Max Value by Risk Score](../rules/ACCOUNT-MAX-VALUE-BY-RISK.md) | The account-balance-by-risk rule enforces accumulated balance limits in U.S. dollars for user accounts based on a protocol assigned risk score to that account via the application manager. Risk scores are ranged between 0-99. Balance limits are set by range based on the risk scores given at rule creation. For example, if risk scores given in the array are: 25,50,75 and balance limits are: 500,250,100. The balance limit ranges are as follows: 0-24 = NO LIMIT, 25-49 = 500, 50-74 = 250, 75-99 = 100. |
| [Account Max Tx Value by Risk Score](../rules/ACCOUNT-MAX-TX-VALUE-BY-RISK-SCORE.md) | The purpose of this rule is to prevent accounts identified as "risky" from moving large amounts of US Dollars in tokens within a specified period of time. This attempts to mitigate the existential, ethical or legal risks to an economy posed by such accounts. |




<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron