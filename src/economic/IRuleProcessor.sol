// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title IRuleProcessor
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev the light version of the Rule Processor for an efficient
 * import into the other contracts for calls to the checkAllRules function.
 * This is only used internally by the protocol.
 */

interface IRuleProcessor {
    /**
     * @dev Check the minimum/maximum rule. This rule ensures that both the to and from accounts do not
     * exceed the max balance or go below the min balance.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param amount total number of tokens to be transferred
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalancePasses(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, uint256 amount, bytes32[] calldata toTags, bytes32[] calldata fromTags) external view;

    /**
     * @dev Check the minimum transfer rule. This rule ensures accounts cannot transfer less than
     * the specified amount.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param amount total number of tokens to be transferred
     */
    function checkMinTransferPasses(uint32 ruleId, uint256 amount) external view;

    /**
     * @dev Check the minMaxAccoutBalace rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalanceERC721(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, bytes32[] memory toTags, bytes32[] memory fromTags) external view;

    /**
     * @dev This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param _address user address to be checked
     */
    function checkOraclePasses(uint32 _ruleId, address _address) external view;

    /**
     * @dev Check if transaction passes Balance by AccessLevel rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param _accessLevel the Access Level of the account
     * @param _balance account's beginning balance
     * @param _amountToTransfer total number of tokens to be transferred
     */
    function checkBalanceByAccessLevelPasses(uint32 _ruleId, uint8 _accessLevel, uint256 _balance, uint256 _amountToTransfer) external view;

    /**
     * @dev This function receives a rule id for Purchase Limit details and checks that transaction passes.
     * @param ruleId Rule identifier for rule arguments
     * @param purchasedWithinPeriod Number of tokens purchased within purchase Period
     * @param amount Number of tokens to be transferred
     * @param toTags Account tags applied to sender via App Manager
     * @param lastUpdateTime block.timestamp of most recent transaction from sender.
     */
    function checkPurchaseLimit(uint32 ruleId, uint256 purchasedWithinPeriod, uint256 amount, bytes32[] calldata toTags, uint64 lastUpdateTime) external view returns (uint256);

    /**
     * @dev This function receives a rule id for Sell Limit details and checks that transaction passes.
     * @param ruleId Rule identifier for rule arguments
     * @param amount Number of tokens to be transferred
     * @param fromTags Account tags applied to sender via App Manager
     * @param lastUpdateTime block.timestamp of most recent transaction from sender.
     */
    function checkSellLimit(uint32 ruleId, uint256 salesWithinPeriod, uint256 amount, bytes32[] calldata fromTags, uint256 lastUpdateTime) external view returns (uint256);

    /**
     * @dev Check the minimum/maximum rule through the AMM Swap
     * @param ruleIdToken0 Uint value of the ruleId storage pointer for applicable rule.
     * @param ruleIdToken1 Uint value of the ruleId storage pointer for applicable rule.
     * @param tokenBalance0 Token balance of the token being swapped
     * @param tokenBalance1 Token balance of the received token
     * @param amountIn total number of tokens to be swapped
     * @param amountOut total number of tokens to be received
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalancePassesAMM(
        uint32 ruleIdToken0,
        uint32 ruleIdToken1,
        uint256 tokenBalance0,
        uint256 tokenBalance1,
        uint256 amountIn,
        uint256 amountOut,
        bytes32[] calldata fromTags
    ) external view;

    /**
     * @dev This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.
     * @param ruleId Rule identifier for rule arguments
     * @param transfersWithinPeriod Number of transfers within the time period
     * @param nftTags NFT tags applied
     * @param lastTransferTime block.timestamp of most recent transaction from sender.
     */
    function checkNFTTransferCounter(uint32 ruleId, uint256 transfersWithinPeriod, bytes32[] calldata nftTags, uint64 lastTransferTime) external view returns (uint256);

    /**
     * @dev Check Transaction Limit for Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _riskScore the Risk Score of the account
     * @param _amountToTransfer total dollar amount to be transferred
     */
    function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view;

    /**
     * @dev Check Account balance for Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _riskScore the Risk Score of the account
     * @param _balance account's beginning balance
     * @param _amountToTransfer total dollar amount to be transferred
     */
    function checkAccountBalanceByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _balance, uint256 _amountToTransfer) external view;

    /**
     * @dev Assess the fee associated with the AMM Fee Rule
     * @param _ruleId Rule Identifier for rule arguments
     * @param _collateralizedTokenAmount total number of collateralized tokens to be swapped(this could be the "token in" or "token out" as the fees are always * assessed from the collateralized token)
     */
    function assessAMMFee(uint32 _ruleId, uint256 _collateralizedTokenAmount) external view returns (uint256);

    /**
     * @dev checks that an admin won't hold less tokens than promised until a certain date
     * @param _ruleId Rule identifier for rule arguments
     * @param _currentBalance of tokens held by the admin
     * @param _amountToTransfer Number of tokens to be transferred
     * @notice that the function will revert if the check finds a violation of the rule, but won't give anything
     * back if everything checks out.
     */
    function checkAdminWithdrawalRule(uint32 _ruleId, uint256 _currentBalance, uint256 _amountToTransfer) external view;

    /**
     * @dev Rule checks if the minimum balance by date rule will be violated. Tagged accounts must maintain a minimum balance throughout the period specified
     * @param ruleId Rule identifier for rule arguments
     * @param balance account's current balance
     * @param amount Number of tokens to be transferred from this account
     * @param toTags Account tags applied to sender via App Manager
     */
    function checkMinBalByDatePasses(uint32 ruleId, uint256 balance, uint256 amount, bytes32[] calldata toTags) external view;

    // --------------------------- APPLICATION LEVEL --------------------------------

    /**
     * @dev This function checks if the requested action is valid according to the AccountBalanceByRiskScore rule
     * @param _ruleId Rule Identifier
     * @param _toAddress Address of the recipient
     * @param _riskScoreTo the Risk Score of the recepient account
     * @param _totalValuationTo recepient account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total dollar amount to be transferred in USD with 18 decimals of precision
     */
    function checkAccBalanceByRisk(uint32 _ruleId, address _toAddress, uint8 _riskScoreTo, uint128 _totalValuationTo, uint128 _amountToTransfer) external view;

    /**
     * @dev This function checks if the requested action is valid according to the AccountBalanceByAccessLevel rule
     * @param _ruleId Rule Identifier
     * @param _accessLevelTo the Access Level of the recepient account
     * @param _totalValuationTo recepient account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total dollar amount to be transferred in USD with 18 decimals of precision
     */
    function checkAccBalanceByAccessLevel(uint32 _ruleId, uint8 _accessLevelTo, uint128 _totalValuationTo, uint128 _amountToTransfer) external view;

    /**
     * @dev rule that checks if the tx exceeds the limit size in USD for a specific risk profile
     * within a specified period of time.
     * @notice that these ranges are set by ranges.
     * @param ruleId to check against.
     * @param _usdValueTransactedInPeriod the cumulative amount of tokens recorded in the last period.
     * @param amount in USD of the current transaction with 18 decimals of precision.
     * @param lastTxDate timestamp of the last transfer of this token by this address.
     * @param riskScore of the address (0 -> 100)
     * @return updated value for the _usdValueTransactedInPeriod. If _usdValueTransactedInPeriod are
     * inside the current period, then this value is accumulated. If not, it is reset to current amount.
     * @dev this check will cause a revert if the new value of _usdValueTransactedInPeriod in USD exceeds
     * the limit for the address risk profile.
     */
    function checkMaxTxSizePerPeriodByRisk(uint32 ruleId, uint128 _usdValueTransactedInPeriod, uint128 amount, uint64 lastTxDate, uint8 riskScore) external view returns (uint128);

    /**
     * @dev Ensure that Access Level = 0 rule passes. This seems like an easy rule to check but it is still
     * abstracted to through the token rule router to allow for updates later(like special values)
     * @param _accessLevel account access level
     *
     */
    function checkAccessLevel0Passes(uint8 _accessLevel) external view;

    /**
     * @dev rule that checks if the withdrawal exceeds the limit size in USD for a specific access level
     * @notice that these ranges are set by ranges.
     * @param _ruleId to check against.
     * @param _accessLevel access level of the sending account
     * @param _withdrawal the amount, in USD, of previously withdrawn assets
     * @param _amountToTransfer total value of the transfer
     * @return Sending account's new total withdrawn.
     */
    function checkwithdrawalLimitsByAccessLevel(uint32 _ruleId, uint8 _accessLevel, uint128 _withdrawal, uint128 _amountToTransfer) external view returns (uint128);

    /**
     * @dev This function checks if the requested action is valid according to pause rules.
     * @param _dataServer address of the Application Rule Processor Diamond contract
     */
    function checkPauseRules(address _dataServer) external view;

    /**
     * @dev Rule checks if the token transfer volume rule will be violated.
     * @param _ruleId Rule identifier for rule arguments
     * @param _volume token's trading volume thus far
     * @param _amount Number of tokens to be transferred from this account
     * @param _supply Number of tokens in supply
     * @param _lastTransferTs the time of the last transfer
     * @return volumeTotal new accumulated volume
     */
    function checkTokenTransferVolumePasses(uint32 _ruleId, uint256 _volume, uint256 _supply, uint256 _amount, uint64 _lastTransferTs) external view returns (uint256);

    /**
     * @dev Rule checks if the total supply volatility rule will be violated.
     * @param _ruleId Rule identifier for rule arguments
     * @param _volumeTotalForPeriod token's increase/decreased volume total in period
     * @param _totalSupplyForPeriod token total supply updated at begining of period
     * @param _amount Number of tokens to be minted/burned
     * @param _supply Number of tokens in supply
     * @param _lastSupplyUpdateTime the time of the last transfer
     * @return volumeTotal new accumulated volume
     */
    function checkTotalSupplyVolatilityPasses(
        uint32 _ruleId,
        int256 _volumeTotalForPeriod,
        uint256 _totalSupplyForPeriod,
        uint256 _supply,
        int256 _amount,
        uint64 _lastSupplyUpdateTime
    ) external view returns (int256, uint256);

    /**
     * @dev This function receives data needed to check Minimum hold time rule. This a simple rule and thus is not stored in the rule storage diamond.
     * @param _holdHours minimum number of hours the asset must be held
     * @param _ownershipTs beginning of hold period
     */
    function checkNFTHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view;

    /* ---------------------------- Rule Validation Functions --------------------------------- */
    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAMMFee(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTransactionLimitByRiskScore(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinMaxAccountBalanceERC721(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateNFTTransferCounter(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinMaxAccountBalance(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validatePurchaseLimit(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSellLimit(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAdminWithdrawal(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinBalByDate(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinTransfer(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateOracle(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateStatusOracle(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validatePurchasePercentage(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSellPercentage(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenTransferVolume(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSupplyVolatility(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccBalanceByRisk(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMaxTxSizePerPeriodByRisk(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     * @param _dataServer address of the appManager contract
     */
    function validatePause(uint32 _ruleId, address _dataServer) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccBalanceByAccessLevel(uint32 _ruleId) external view;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateWithdrawalLimitsByAccessLevel(uint32 _ruleId) external view;
}
