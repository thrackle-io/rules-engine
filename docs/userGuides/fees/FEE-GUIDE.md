# Fee Guide
[![Project Version][version-image]][version-url]

---

| Fee Type | Purpose |
|:-|:-| 
| [Protocol Fee Structure](./PROTOCOL-FEE-STRUCTURE.md) | This document outlines the overall fee structure of the protocol, how fees are applied and at what level the fees are applied. Each fee type has its own documentation associated to the specifics of that Fee type and are stored in the [FEE-GUIDE](./FEE-GUIDE.md). When an AMM or token handler is deployed a Fee data contract is deployed at the same time. All supporting fee data is stored in this contract and owned by the deployer. Data contracts can be migrated to a new handler in the event of an uprade so that fee data is not lost. Fees are applied to accounts via general tags in the [AppMananger](../../../src/client/application/AppManager.sol). Each Fee applied via tags to an account can be additive (increase the fee amount owed) or subtractive (reduce the fee amount owed).Protocol supported tokens and AMMs will always assess all fees applicable to the account executing the current function. If a token and AMM have fees active and an account is tagged with applicable fees or a blank tag is used to assign a default fee, those fees are assessed on token transfers and AMM swaps (additive). |
| [AMM Buy Fee](./AMM-BUY-FEE.md)  | The purpose of the AMM Buy Fee is to assess fees via the AMM swap function for purchases. A purchase via the AMM is defined as the user exchanging collateralized tokens for application tokens via the AMM. Collateralized tokens can be chain native tokens (ETH/MATC), non protocol supported ERC20 tokens (WETH/USDC) or protocol supported ERC20 tokens. AMM Fees are always taken from the collateralized token within the AMM. | 
| [AMM Sell Fee](./AMM-SELL-FEE.md) | The purpose of the AMM Sell Fee is to assess fees via the AMM swap function for purchases. A purchase via the AMM is defined as the user exchanging application tokens for collateralized tokens via the AMM. Collateralized tokens can be chain native tokens (ETH/MATC), non protocol supported ERC20 tokens (WETH/USDC) or protocol supported ERC20 tokens. AMM Fees are always taken from the collateralized token within the AMM. | 
| Transfer Fee |   | 




<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron