# List Of Error Selectors

This list comprehends the selectors of the custom errors inside the contracts. The method to get this selectors is the following:

Selector = (Keccak-256(CUSTOM_ERROR_FUNCTION))[:4]

As explained above, the selector is the result of the hash of the custom error function. This error function must have no spaces, and if arguments, they must specify only the type. Finally, only the first 4 bytes of the hash are used. For example:

CUSTOM_ERROR_FUNCTION = InvalidDateWindow(uint256,uint256)

Keccak-256 Hash = 0x702434261a75c3efd3a36189e63f0a9e0be4005d6d10e0bca897577de20f33b4

Selector (first 4 bytes of hash) = 0x70243426

An online Keccak-256 hash digester can be found at https://emn178.github.io/online-tools/keccak_256.html

| SELECTOR   | ERROR                                                            |
| ---------- | ---------------------------------------------------------------- |
| 0xb3cbc6f3 | riskScoreOutOfRange(uint8)                                       |
| 0x70243426 | InvalidDateWindow(uint256,uint256)                               |
| 0x17a84242 | NotAdmin(address)                                                |
| 0x1f821969 | NotDefaultAdmin(address)                                         |
| 0xd66c3008 | NotRuleAdministrator()                                           |
| 0x27e2cba4 | NotAppAdministrator(address)                                     |
| 0xba80c9e5 | NotAppAdministrator()                                            |
| 0xebb4658e | NotAccessTierAdministrator(address)                              |
| 0x820879ac | NotRiskAdmin(address)                                            |
| 0x9c363e25 | NotAUser(address)                                                |
| 0xfd12da91 | AccessLevelIsNotValid(uint8)                                     |
| 0xd7be2be3 | BlankTag()                                                       |
| 0x5416eb98 | FunctionNotFound(bytes4)                                         |
| 0x68842d15 | BlankContractName()                                              |
| 0xd92e233d | ZeroAddress()                                                    |
| 0x2ecfa8ed | ContractAddressNotFound()                                        |
| 0xeb6ba048 | NoSelectorsGivenToAdd()                                          |
| 0xff4127cb | NotContractOwner(address,address)                                |
| 0xe767f91f | NoSelectorsProvidedForFacetForCut(address)                       |
| 0x0ae3681c | CannotAddSelectorsToZeroAddress(bytes4[])                        |
| 0x919834b9 | NoBytecodeAtAddress(address,string)                              |
| 0x7fe9a41e | IncorrectFacetCutAction(uint8)                                   |
| 0xebbf5d07 | CannotAddFunctionToDiamondThatAlreadyExists(bytes4)              |
| 0xcd98a96f | CannotReplaceFunctionsFromFacetWithZeroAddress(bytes4[])         |
| 0x520300da | CannotReplaceImmutableFunction(bytes4)                           |
| 0x358d9d1a | CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(bytes4) |
| 0x7479f939 | CannotReplaceFunctionThatDoesNotExists(bytes4)                   |
| 0xd091bc81 | RemoveFacetAddressMustBeZeroAddress(address)                     |
| 0x7a08a22d | CannotRemoveFunctionThatDoesNotExist(bytes4)                     |
| 0x6fafeb08 | CannotRemoveImmutableFunction(bytes4)                            |
| 0x192105d7 | InitializationFunctionReverted(address,bytes)                    |
| 0x24691f6b | MaxBalanceExceeded()                                             |
| 0xf1737570 | BalanceBelowMin()                                                |
| 0x4bdf3b46 | RuleDoesNotExist()                                               |
| 0x70311aa2 | BelowMinTransfer()                                               |
| 0x68cf9ce3 | GlobalControllerNotConnected()                                   |
| 0x028a6c58 | InputArraysMustHaveSameLength()                                  |
| 0x1390f2a1 | IndexOutOfRange()                                                |
| 0x7d9b7dbc | PercentageValueLessThan100()                                     |
| 0x984cc2a2 | PageOutOfRange()                                                 |
| 0xeeb9d4f7 | InvertedLimits()                                                 |
| 0x5b2790b5 | AmountsAreZero()                                                 |
| 0xd4c6aa81 | TokenInvalid(address)                                            |
| 0xf1ec5eb7 | AmountExceedsBalance(uint256)                                    |
| 0x6bdfffc0 | AddressIsRestricted()                                            |
| 0x7304e213 | AddressNotOnAllowedList()                                        |
| 0x2a15491e | OracleTypeInvalid()                                              |
| 0x930bba61 | NotAnNFTContract(address)                                        |
| 0x454f1bd4 | ZeroValueNotPermited()                                           |
| 0x0e0449c8 | DateInThePast(uint256)                                           |
| 0x0e0449c8 | DateInThePast(uint256)                                           |
| 0xa7fb7b4b | TxnInFreezeWindow()                                              |
| 0xc11d5f20 | TemporarySellRestriction()                                       |
| 0x522df7fd | StartTimeNotValid()                                              |
| 0x3dcf1b35 | MaxTxSizePerPeriodReached(uint8,uint256,uint8)                   |
| 0xd3bfb295 | InvalidHourOfTheDay()                                            |
| 0x3cb71ef6 | WrongArrayOrder()                                                |
| 0x79cacff1 | DepositFailed()                                                  |
| 0x6624e6b4 | NotStakingEnough(uint256)                                        |
| 0xcba8072d | NotStakingForAnyTime()                                           |
| 0x22ddaa04 | RewardPoolLow(uint256)                                           |
| 0x73380d99 | NoRewardsToClaim()                                               |
| 0x6fd3eddf | RewardsWillBeZero()                                              |
| 0x54dc89b0 | actionCheckFailed()                                              |
| 0x00b223e3 | MaxNFTTransferReached                                            |
| 0xdd76c810 | BalanceExceedsAccessLevelAllowedLimit()                          |
| 0x77743e4a | PricingModuleNotConfigured(address,address)                      |
| 0x6f65fbb7 | BalanceAmountsShouldHave5Levels(uint8)                           |
| 0x9fe6aeac | TransactionExceedsRiskScoreLimit()                               |
| 0x58b13098 | BalanceExceedsRiskScoreLimit()                                   |
| 0x2b3f1e6e | InvalidTimeUnit()                                                |
| 0x90b8ec18 | TransferFailed()                                                 |
| 0xfe5d1090 | RiskLevelCannotExceed99()                                        |
| 0x06b5c782 | TokenNotAvailableToWithdraw()                                    |
| 0x3fac082d | NotAllowedForAccessLevel()                                       |
| 0xab6a6402 | InsufficientPoolDepth(uint256,int256)                            |
| 0x1a4a3f34 | CannotTurnOffAccessLevel0WithAccessLevelBalanceActive()          |
| 0x15bd01b6 | ValueOutOfRange(uint256)                                         |
| 0x8f802168 | CallerNotAuthorizedToMint()                                      |
| 0x4f2f02d2 | ApplicationPaused(uint,uint)                                     |
| 0xfd2ac9bc | InputArraysSizesNotValid()                                       |
| 0x77d0d408 | TagAlreadyApplied()                                              |
| 0x2bbc9aea | WithdrawalExceedsAccessLevelAllowedLimit()                       |
| 0x346120b1 | TagAlreadyExists()                                               |
| 0xa3afb2e2 | MaxTagLimitReached()                                             |
| 0xf9432cf8 | WithdrawalAmountsShouldHave5Levels(uint8)                        |
| 0xb634aad9 | PurchasePercentageReached()                                      |
| 0xb17ff693 | SellPercentageReached()                                          |
| 0x3627495d | TransferExceedsMaxVolumeAllowed()                                |
| 0xa93074f9 | MintFeeNotReached()                                              |
| 0x834f37b6 | TreasuryAddressCannotBeTokenContract()                           |
| 0xbd1c60b0 | OnlyOwnerCanMint()                                               |
| 0xf726ee2d | TreasuryAddressNotSet()                                          |
| 0x81af27fa | TotalSupplyVolatilityLimitReached()                              |
| 0x6d12e45a | MinimumHoldTimePeriodNotReached()                                |
| 0x771d7f93 | PeriodExceeds5Years()                                            |
| 0x2d42c772 | AddressAlreadyRegistered()                                       |
| 0x41284967 | ConfirmerDoesNotMatchProposedAddress()                           |
| 0x821e0eeb | NoProposalHasBeenMade()                                          |
| 0x46b2bfeb | BatchMintBurnNotSupported()                                      |
| 0x23a87520 | AdminWithdrawalRuleisActive()                                    |
| 0x6a7d5e35 | InvalidOracleType(uint8)                                         |
| 0x57a7068b | InvalidRuleInput()                                               |
| 0xe8ada65f | NotRegisteredHandler(address)                                    |
| 0x248ee764 | FeesAreGreaterThanTransactionAmount(address)                     |
| 0x27515afa | PriceNotSet()                                                    |
| 0xc3771360 | CannotWithdrawZero()                                             |
| 0xa9ad62f8 | FunctionDoesNotExist()                                           |
| 0xad3a8b9e | NotEnoughBalance()                                               |
| 0xac28d0b2 | NotProposedTreasury(address proposedTreasury)                    |
| 0xb19c6749 | TrasferFailed(bytes reason)                                      |
| 0x202409e9 | NoMintsAvailable()                                               |
| 0x2a79d188 | NotAppAdministratorOrOwner()                                     |