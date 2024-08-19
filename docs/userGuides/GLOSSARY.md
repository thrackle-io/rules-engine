# Glossary

---

[![Project Version][version-image]][version-url]


---

| Term                      | Definition                                                                                                                                                  |
|:--------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AppManager                | Allows for creation/maintenance of permission roles, application rules, pause windows, user account metadata. |
| ApplicationHandler        | Connection to Rules Protocol for the AppManager. Assesses and reads the rules that are activated for an application |
| TokenHandler              | Allows for applying, activating, and deactivating token specific rules.          |
| Pricing Module            | Where prices for ERC20 and ERC721 tokens are derived. It can be the default protocol pricer or a custom pricing solution.                                    |
| Protocol Supported ERC721 | An ERC721 token that implements the protocol IProtocolToken and contains the protocol hook.                                                                                                |
| Protocol Supported ERC20  | An ERC20 token that implements the protocol IProtocolToken and contains the protocol hook.                                                                                                |
| Access-Level Provider     | An external provider that rates or segments users based on external criteria for access level solutions. Default access level mechanisms allow developers to set user access levels.        |
| Permission Roles          | Roles used by AppManager. They include: Admin, Access Level Admin, Risk Admin, Rule Admin, and Treasury Account.                                                                            |
| Application Rule          | Rule applied to all protocol supported assets. They are created using the protocol's RuleProcessorDiamond and applied in the application's AppManager.        |
| Token Specific Rule       | Rule applied to a specific protocol supported entity. They are created using the protocol's RuleProcessorDiamond and applied in the token's Handler.        |
| Tag | Bytes32 strings that can be attached to accounts via AppManager. Think of it as labels or badges that accounts can have. |



<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.3.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-engine