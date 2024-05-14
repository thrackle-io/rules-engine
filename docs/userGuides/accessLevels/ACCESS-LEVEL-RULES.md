# Access Level Rules
[![Project Version][version-image]][version-url]

---

| Access Level Rules | Purpose |
|:-|:-| 
| [Maximum Account Balance By Access Level Rule](../rules/ACCOUNT-MAX-VALUE-BY-ACCESS-LEVEL.md) | The purpose of this rule is to provide balance limits for accounts at the application level based on an application defined segment of users. The segments are defined as the access levels of the accounts. This rule may be used to provided gated accumulation of assets to ensure accounts cannot accumulate more assets without performing other actions defined by the application. For example, the application may decide users may not accumulate any assets without performing specific onboarding activities. The application developer may set a maximum balance of $0 for the default access level and $1000 for the next access level. As accounts are introduced to the ecosystem, they may not receive any assets until the application changes their access level to a higher value. |
| [Withdrawal Limit By Access Level](../rules/ACCOUNT-MAX-VALUE-OUT-BY-ACCESS-LEVEL.md) | The purpose of this rule is to provide limits on the amount of funds that an account can remove from the application's economy based on an application defined segment of users. The segments are defined as the access levels of the accounts. This rule may be used to provide gated withdrawal limits of assets to ensure accounts cannot withdraw more US Dollars or chain native tokens without first performing other actions defined by the application. For example, the application may decide users may not withdraw without performing specific onboarding activities. The application developer may set the most restrictive withdraw limit of $0 for the default access level and $1000 for the next access level. As accounts are introduced to the ecosystem, they may not withdraw from the ecosystem until the application changes their access level to a higher value. This rule does not prevent the accumulation of protocol supported assets. |
| [Account Deny For No Access Level](../rules/ACCOUNT-DENY-FOR-NO-ACCESS-LEVEL.md) | The purpose of this rule is to provide a way to prevent the transfer of assets for accounts that do not have an access level or whose access level has been set to 0. For example, the application may decide users may not accumulate or transfer any assets without first performing specific onboarding activities. The application developer may set the account deny for no access level rule to active. As accounts are introduced to the ecosystem, they may not receive any assets until the application changes their access level to a higher value. |



<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron