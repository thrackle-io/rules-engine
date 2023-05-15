# Glossary

---

[![Project Version][version-image]][version-url]


---

| Term         | Definition  |
| :--- | :---        |
| AppManager      | Allows for creation/maintenance of permission roles, global Rules, pause windows, and user account metadata       |
| TokenHandler    | Deployed with Protocol Supported ERC721's and Protocol Supported ERC20 tokens. Allow for applying, activating, and deactivating token specific rules         |
| Pricing Module        | Where prices for ERC20 and ERC721 tokens are derived. It can be the default protocol pricer or a custom pricing solution        |
| Protocol Supported ERC721| An ERC721 token that implements the protocol ProtocolERC721.        |
| Access-Tier Provider          | External Know Your Customer(KYC) solution        |
| Permission Roles      | Roles used by AppManager. They include: Admin, KYC Admin, and Risk Admin        |
| Global Rule           | Rule applied to all protocol supported entities. They are created using the protocol's Rule Storage Diamond and applied in the applcation's AppManager        |
| Token Specific Rule   | Rule applied to a specific protocol supported entity. They are created using the protocol's Rule Storage  Diamond and applied in the token's Handler        |



<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron