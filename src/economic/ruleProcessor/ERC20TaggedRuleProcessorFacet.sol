// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import {ERC173} from "diamond-std/implementations/ERC173/ERC173.sol";
import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {TaggedRuleDataFacet} from "../ruleStorage/TaggedRuleDataFacet.sol";
import {ITaggedRules as TaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";
import {IRuleProcessorErrors, ITagRuleErrors, IMaxTagLimitError} from "../../interfaces/IErrors.sol";
import "./RuleProcessorCommonLib.sol";

/**
 * @title ERC20 Tagged Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Contract implements rules to be checked by Handler.
 * @notice  Implements Token Rules on Tagged Accounts.
 */
contract ERC20TaggedRuleProcessorFacet is IRuleProcessorErrors, ITagRuleErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for bytes32[];

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
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalBalanceLimitRules();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();

        for (uint i; i < toTags.length; ) {
            uint256 max = data.getBalanceLimitRule(ruleId, toTags[i]).maximum;
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
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalBalanceLimitRules();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();

        for (uint i = 0; i < fromTags.length; ) {
            uint256 min = data.getBalanceLimitRule(ruleId, fromTags[i]).minimum;
            /// if a min is 0 then no need to check.
            if (min > 0 && balanceFrom - amount < min) revert BalanceBelowMin();
            unchecked {
                ++i;
            }
        }
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
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);

        uint totalRules = data.getTotalAdminWithdrawalRules();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();

        TaggedRules.AdminWithdrawalRule memory rule = data.getAdminWithdrawalRule(ruleId);
        if ((block.timestamp < rule.releaseDate) && (currentBalance - amount < rule.amount)) revert BalanceBelowMin();
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
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalMinBalByDateRule();
        uint finalBalance = balance - amount;
        if (totalRules > ruleId) {
            for (uint i = 0; i < toTags.length; ) {
                if (toTags[i] != "") {
                    TaggedRules.MinBalByDateRule memory minBalByDateRule = data.getMinBalByDateRule(ruleId, toTags[i]);
                    uint256 holdPeriod = minBalByDateRule.holdPeriod;
                    /// first check to see if still in the hold period
                    if ((block.timestamp - (holdPeriod * 1 hours)) < minBalByDateRule.startTimeStamp) {
                        uint256 holdAmount = minBalByDateRule.holdAmount;
                        /// If the transaction will violate the rule, then revert
                        if (finalBalance < holdAmount) revert TxnInFreezeWindow();
                    }
                }
                unchecked {
                    ++i;
                }
            }
        } else {
            revert RuleDoesNotExist();
        }
    }
}
