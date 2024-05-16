# Oracle Rules
[![Project Version][version-image]][version-url]

---

| Oracle Rules | Purpose |
|:-|:-| 

| [Oracle](../rules/ACCOUNT-APPROVE-DENY-ORACLE.md) | The purpose of the account-approve-deny-oracle rule is to check if an address in the transaction is an approved or denied address. Addresses are added to the oracle lists by the owner of the oracle contract for any reason that the owner deems necessary. Oracle rules are applied per [action type](../rules/ACTION-TYPES.md) and for burn and sell actions the sender address is checked. For all other actions, the receiver address is checked. If an address is not on an approved oracle list, they will be denied from receiving application tokens. This rule can be used to restrict transfers to only specific contract addresses or wallets that are approved by the oracle owner. An example is NFT exchanges that support ERC2981 royalty payments. The deny list is designed as a tool to reduce the risk of malicious actors in the ecosystem. If an address is on the deny oracle list they are denied receiving tokens. Any address not on the deny list will pass this rule check. |


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron