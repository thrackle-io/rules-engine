# Access Tier Rules
[![Project Version][version-image]][version-url]

---

| Access Tier Rules | Purpose |
|:-|:-| 
| [Maximum Account Balance By Access Level Rule](./MAX-BALANCE-BY-ACCESS-LEVEL.md) | The purpose of this rule is to provide balance limits for accounts at the application level based on an application defined segment of users. The segments are defined as the access levels of the accounts. This rule may be used to provided gated accumulation of assets to ensure accounts cannot accumulate more assets without performing other actions defined by the application. For example, the application may decide users may not accumulate any assets without performing specific onboarding activities. The application developer may set a maximum balance of $0 for the default access level and $1000 for the next access level. As accounts are introduced to the ecosystem, they may not receive any assets until the application changes their access level to a higher value. |




<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron