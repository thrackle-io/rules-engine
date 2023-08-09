# THE PROTOCOL
[![Project Version][version-image]][version-url]

---

## Token Specific Economic Rules

Token Specific rules are those that apply at the token(ERC20 and ERC721) level within the application. These rules are created through the protocol and applied in the Token Handlers. 

| Rule                             | Create Function                                                                                                                                                                      | Activation Function                          | Application Function                            | Applicability | 
|:---------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------|:------------------------------------------------| :--- |
| Minimum Account Balance By Date  | addMinBalByDateRule(address _appManagerAddr, bytes32[] calldata _accountTags, uint256[] calldata _holdAmounts, uint16[] calldata _holdPeriods, uint64[] calldata _startTimestamps) | activateMinBalByDateRule(bool _on)           | setMinBalByDateRuleId(uint32 _ruleId)           | NFT |
| Minimum/Maximum Account Balances | addBalanceLimitRules(address _appManagerAddr, bytes32[] calldata _accountTypes,      uint256[] calldata _minimum, uint256[] calldata _maximum)                                       | activateMinMaxBalanceRule(bool _on)          | setMinMaxBalanceRuleId(uint32 _ruleId)          | NFT |
| Transaction Size Limits by Risk  | addTransactionLimitByRiskScore(address _appManagerAddr, uint8[] calldata _riskScores, uint48[] calldata _txnLimits)                                                                  | activateTransactionLimitByRiskRule(bool _on) | setTransactionLimitByRiskRuleId(uint32 _ruleId) | NFT |
| Withdrawal                       | addWithdrawalRule(address _appManagerAddr, bytes32[] calldata _accountTypes, uint256[] calldata amount, uint256[] calldata _releaseDate)                                             | addActivation                                | addApplication                                  | NFT |
| Oracle                           | addOracleRule(address _appManagerAddr, uint8 _type, address _oracleAddress)                                                                                                          | activateOracleRule(bool _on)                 | setOracleRuleId(uint32 _ruleId)                 | NFT |
| NFT Transfer Counter             | addNFTTransferCounterRule(address _appManagerAddr, bytes32[] calldata _nftTypes, uint8[] calldata _tradesAllowed, uint64 _startTs)                                                              | activateTradeCounterRule(bool _on)          | setTradeCounterRuleId(uint32 _ruleId)        |  NFT |
|




<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron