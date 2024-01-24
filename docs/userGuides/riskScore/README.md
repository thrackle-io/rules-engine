# Risk Score Guide
[![Project Version][version-image]][version-url]
--- 

## Risk Score and Rules Information: 

Risk administators may assign accounts or contracts with a risk score via the application manager contract. These scores range from 0-99. [Risk administrators](../permissions/ADMIN-ROLES.md) are the only admins who can assign risk scores to accounts and addresses. These risk scores facilitate the protocol's risk rule checks. The application will pass the risk score, rule id, and value of the transaction to the protocol for risk rule evaluations. 

Risk rules are dependant on the application having deployed [pricing contracts](../pricing/README.md) and connected to the application handler. The protocol will then check that the transaction is valid for the user's assigned risk score. 


- [RISK SCORE STRUCTURE](./RISK-SCORE-STRUCTURE.md)
- [Risk Rules](./RISK-SCORE-RULES.md)


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron