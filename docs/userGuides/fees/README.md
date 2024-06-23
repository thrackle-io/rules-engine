# Fee Guide
[![Project Version][version-image]][version-url]

---

| Fee Type | Purpose |
|:-|:-| 
| [Protocol Fee Structure](./PROTOCOL_FEE_STRUCTURE.md) | This document outlines the overall fee structure of the protocol, how fees are applied and at what level the fees are applied. Each fee type has its own documentation associated to the specifics of that Fee type and are stored in this document.|
| [Transfer Fee](./TRANSFER_FEE.md) | The purpose of the Transfer Fee is to assess fees when protocol supported tokens are transferred. Application developers can utilize fees to influence their application's economy through incentivizing behavior. Fees are assigned via tags applied to accounts through the App Manager. A blank tag may be used when adding a fee to apply to all accounts as a "default" fee. Token fees are added and activated through the token handler contract. Token transfer fees are assessed and taken from the token when fees are active in the token handler. | 

A Fee data contract is deployed at the same time as the token handler. All supporting fee data is stored in this contract and owned by the handler. Data contracts can be migrated to a new handler in the event of an upgrade so that fee data is not lost. Only the previous handler owner or [app administrators](../permissions/ADMIN-ROLES.md) can migrate the data contracts. Migrations to a new handler are completed through a two step migration process.
Fees are applied to accounts via general tags in the [AppMananger](../../../src/client/application/AppManager.sol). Each Fee applied via tags to an account can be additive (increase the fee amount owed) or subtractive (reduce the fee amount owed) and are expressed in basis points.
Protocol supported tokens will always assess all fees asigned to the account executing the current function. If a token has fees active and an account is tagged with applicable fees or a blank tag is used to assign a default fee, those fees are assessed on token transfers (additive). Token fees are assessed and taken from the token itself, not a collateralized token, when fees are active in the token handler. | 




<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.3.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron