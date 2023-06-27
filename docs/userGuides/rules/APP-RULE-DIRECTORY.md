# Application Rules Directory
[![Project Version][version-image]][version-url]

---
Application rules are those that apply to every token(ERC20 and ERC721) within the application. Application Rules are created through the protocol and applied in the AppHandler. They include: Account Balance by Risk Score, Balance by Access Level, and Transaction Size Per Time Period by Risk Score. 

| Rule         | Create Function | Activation Function |
| :--- | :---  | :--- | 
| Account Balance By Risk Score | addAccountBalanceByRiskScore(address _appHandlerAddr, uint8[] calldata _riskScores, uint48[] calldata balanceLimits)| activateAccountBalanceByRiskRule(bool _on) |
| Max Transaction Size Per Period By Risk Score | addMaxTxSizePerPeriodByRiskRule(address _appHandlerAddr, uint48[] calldata maxSize, uint8[] calldata _riskLevel, uint8 _period, uint8 _startingTime) | activateMaxTxSizePerPeriodByRiskRule(bool _on) |
| Balance by Access Level | addAccessLevelBalanceRule(address _appHandlerAddr, uint48[] calldata _balanceAmounts) external appAdministratorOnly(_appHandlerAddr) | activateAccountBalanceByAccessLevelRule(bool _on) |
| Pause Window | applicationAppManager.addPauseRule(1769924800, 1769984800) | n/a |

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron