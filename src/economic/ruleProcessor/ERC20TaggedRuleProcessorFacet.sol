// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import "./RuleProcessorDiamondImports.sol";
import {TaggedRuleDataFacet} from "./TaggedRuleDataFacet.sol";


/**
 * @title ERC20 Tagged Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Contract implements rules to be checked by Handler.
 * @notice  Implements Token Rules on Tagged Accounts.
 */
contract ERC20TaggedRuleProcessorFacet is IRuleProcessorErrors, IInputErrors, ITagRuleErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for bytes32[];
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8;

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
    function checkMinMaxAccountBalancePasses(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, uint256 amount, bytes32[] calldata toTags, bytes32[] calldata fromTags) external view {
        minAccountBalanceCheck(balanceFrom, fromTags, amount, ruleId);
        maxAccountBalanceCheck(balanceTo, toTags, amount, ruleId);
    }

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
    ) public view {
        // no need to check for max tags here since it is checked in the min and max functions
        minAccountBalanceCheck(tokenBalance0, fromTags, amountOut, ruleIdToken0);
        maxAccountBalanceCheck(tokenBalance1, fromTags, amountIn, ruleIdToken1);
    }

    /**
     * @dev Check if tagged account passes maxAccountBalance rule
     * @param balanceTo Number of tokens held by recipient address
     * @param toTags Account tags applied to recipient via App Manager
     * @param amount Number of tokens to be transferred
     * @param ruleId Rule identifier for rule arguments
     */
    function maxAccountBalanceCheck(uint256 balanceTo, bytes32[] calldata toTags, uint256 amount, uint32 ruleId) public view {
        /// This Function checks the max account balance for accounts depending on GeneralTags.
        /// Function will revert if a transaction breaks a single tag-dependent rule
        toTags.checkMaxTags();
        for (uint i; i < toTags.length; ) {
            uint256 max = getBalanceLimitRule(ruleId, toTags[i]).maximum;
            /// if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0
             if (max > 0 && balanceTo + amount > max) revert MaxBalanceExceeded();
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Check if tagged account passes minAccountBalance rule
     * @param balanceFrom Number of tokens held by sender address
     * @param fromTags Account tags applied to sender via App Manager
     * @param amount Number of tokens to be transferred
     * @param ruleId Rule identifier for rule arguments
     */
    function minAccountBalanceCheck(uint256 balanceFrom, bytes32[] calldata fromTags, uint256 amount, uint32 ruleId) public view {
        /// This Function checks the min account balance for accounts depending on GeneralTags.
        /// Function will revert if a transaction breaks a single tag-dependent rule
        fromTags.checkMaxTags();
        for (uint i = 0; i < fromTags.length; ) {
            uint256 min = getBalanceLimitRule(ruleId, fromTags[i]).minimum;
            /// if a min is 0 then no need to check.
            if (min > 0 && balanceFrom - amount < min) revert BalanceBelowMin();
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Function get the BalanceLimitRule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountType Type of Accounts
     * @return BalanceLimitRule at index location in array
     */
    function getBalanceLimitRule(uint32 _index, bytes32 _accountType) public view returns (TaggedRules.BalanceLimitRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalBalanceLimitRules());
        RuleS.BalanceLimitRuleS storage data = Storage.balanceLimitStorage();
        if (_index >= data.balanceLimitRuleIndex) revert IndexOutOfRange();
        return data.balanceLimitsPerAccountType[_index][_accountType];
    }

    /**
     * @dev Function gets total Balance Limit rules
     * @return Total length of array
     */
    function getTotalBalanceLimitRules() public view returns (uint32) {
        RuleS.BalanceLimitRuleS storage data = Storage.balanceLimitStorage();
        return data.balanceLimitRuleIndex;
    }

    /**
     * @dev checks that an admin won't hold less tokens than promised until a certain date
     * @param ruleId Rule identifier for rule arguments
     * @param currentBalance of tokens held by the admin
     * @param amount Number of tokens to be transferred
     * @notice that the function will revert if the check finds a violation of the rule, but won't give anything
     * back if everything checks out.
     */
    function checkAdminWithdrawalRule(uint32 ruleId, uint256 currentBalance, uint256 amount) external view {
        TaggedRules.AdminWithdrawalRule memory rule = getAdminWithdrawalRule(ruleId);
        if ((block.timestamp < rule.releaseDate) && (currentBalance - amount < rule.amount)) revert BalanceBelowMin();
    }

    /**
     * @dev Function gets Admin withdrawal rule at index
     * @param _index position of rule in array
     * @return adminWithdrawalRulesPerToken rule at indexed postion
     */
    function getAdminWithdrawalRule(uint32 _index) public view returns (TaggedRules.AdminWithdrawalRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalAdminWithdrawalRules());
        RuleS.AdminWithdrawalRuleS storage data = Storage.adminWithdrawalStorage();
        if (_index >= data.adminWithdrawalRulesIndex) revert IndexOutOfRange();
        return data.adminWithdrawalRulesPerToken[_index];
    }

    /**
     * @dev Function to get total Admin withdrawal rules
     * @return adminWithdrawalRulesPerToken total length of array
     */
    function getTotalAdminWithdrawalRules() public view returns (uint32) {
        RuleS.AdminWithdrawalRuleS storage data = Storage.adminWithdrawalStorage();
        return data.adminWithdrawalRulesIndex;
    }

    /**
     * @dev Rule checks if the minimum balance by date rule will be violated. Tagged accounts must maintain a minimum balance throughout the period specified
     * @param ruleId Rule identifier for rule arguments
     * @param balance account's current balance
     * @param amount Number of tokens to be transferred from this account
     * @param toTags Account tags applied to sender via App Manager
     */
    function checkMinBalByDatePasses(uint32 ruleId, uint256 balance, uint256 amount, bytes32[] calldata toTags) external view {
        toTags.checkMaxTags();
        uint256 finalBalance = balance - amount;
        for (uint i = 0; i < toTags.length; ) {
            if (toTags[i] != "") {
                (TaggedRules.MinBalByDateRule memory minBalByDateRule, uint64 startTime) = getMinBalByDateRule(ruleId, toTags[i]);
                uint256 holdPeriod = minBalByDateRule.holdPeriod;
                /// first check to see if still in the hold period
                if ((block.timestamp - (holdPeriod * 1 hours)) < startTime) {
                    uint256 holdAmount = minBalByDateRule.holdAmount;
                    /// If the transaction will violate the rule, then revert
                    if (finalBalance < holdAmount) revert TxnInFreezeWindow();
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Function get the minimum balance by date rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountTag Tag of account
     * @return Min BalanceByDate rule at index position
     * @return startTime rule start time
     */
    function getMinBalByDateRule(uint32 _index, bytes32 _accountTag) public view returns (TaggedRules.MinBalByDateRule memory, uint64 startTime) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalMinBalByDateRules());
        RuleS.MinBalByDateRuleS storage data = Storage.minBalByDateRuleStorage();
        if (_index >= data.minBalByDateRulesIndex) revert IndexOutOfRange();
        return (data.minBalByDateRulesPerUser[_index][_accountTag], data.startTime);
    }

    /**
     * @dev Function to get total minimum balance by date rules
     * @return Total length of array
     */
    function getTotalMinBalByDateRules() public view returns (uint32) {
        RuleS.MinBalByDateRuleS storage data = Storage.minBalByDateRuleStorage();
        return data.minBalByDateRulesIndex;
    }
}
