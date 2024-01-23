# Tags Guide
[![Project Version][version-image]][version-url]
--- 

## Tag Information Documentation: 

The protocol uses tags to assess fees and facilitate rule checks for account and addresses. Tags are applied to accounts or addresses via an addTag function in the app manager by application administators. Tags are stored as bytes32 in a mapping inside the tags data contract. A maximum of 10 tags may be applied to each address or account. 

The tag data contract is deployed with and owned by the application manager contract. In the event of an upgrade the data contract can be migrated through a two step migration process. [App administrators](../permissions/ADMIN-ROLES.md) are the only ones who can migrate the data contracts to a new app manager contract. 


- [PROTOCOL TAG STRUCTURE](./PROTOCOL-TAGS-STRUCTURE.md)
- [Tagged Rules](./TAGGED-RULES.md)


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron