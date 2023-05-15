// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/utils/Context.sol";
import {ERC173} from "../../../diamond/implementations/ERC173/ERC173.sol";
import {TaggedRuleProcessorDiamondLib as TaggedRulesDiamondLib, RuleDataStorage} from "./TaggedRuleProcessorDiamondLib.sol";
import {TaggedRuleDataFacet} from "../../ruleStorage/TaggedRuleDataFacet.sol";
import {ITaggedRules as TaggedRules} from "../../ruleStorage/RuleDataInterfaces.sol";

/**
 * @title ERC20 Tagged Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Contract implements rules to be checked by Handler.
 * @notice  Implements Token Rules on Tagged Accounts.
 */
contract ERC20TaggedRuleProcessorFacet is Context, ERC173 {
    uint8 public constant VERSION = 1;

    error MaxBalanceExceeded();
    error BalanceBelowMin();
    error RuleDoesNotExist();
    error TxnInFreezeWindow();
    error TemporarySellRestriction();

    /**
     * @dev Check if tagged account passes maxAccountBalance rule
     * @param balanceTo Number of tokens held by recipient address
     * @param toTags Account tags applied to recipient via App Manager
     * @param amount Number of tokens to be transferred
     * @param ruleId Rule identifier for rule arguments
     */
    function maxAccountBalanceCheck(uint256 balanceTo, bytes32[] calldata toTags, uint256 amount, uint32 ruleId) external view {
        /// This Function checks the max account balance for accounts depending on GeneralTags.
        /// Function will revert if a transaction breaks a single tag-dependent rule
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        uint totalRules = data.getTotalBalanceLimitRules();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();

        for (uint i = 0; i < toTags.length; ) {
            uint256 max = data.getBalanceLimitRule(ruleId, toTags[i]).maximum;
            /// if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0
            if (max > 0) {
                if (balanceTo + amount > max) {
                    revert MaxBalanceExceeded();
                }
            }
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
    function minAccountBalanceCheck(uint256 balanceFrom, bytes32[] calldata fromTags, uint256 amount, uint32 ruleId) external view {
        /// This Function checks the min account balance for accounts depending on GeneralTags.
        /// Function will revert if a transaction breaks a single tag-dependent rule
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        uint totalRules = data.getTotalBalanceLimitRules();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();

        for (uint i = 0; i < fromTags.length; ) {
            uint256 min = data.getBalanceLimitRule(ruleId, fromTags[i]).minimum;
            /// if a min is 0 then no need to check.
            if (min > 0) {
                if (balanceFrom - amount < min) {
                    revert BalanceBelowMin();
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Rule checks if recipient balance + amount exceeded purchaseAmount during purchase period, prevent purchases for freeze period
     * @param ruleId Rule identifier for rule arguments
     * @param purchasedWithinPeriod Number of tokens purchased within purchase Period
     * @param amount Number of tokens to be transferred
     * @param toTags Account tags applied to sender via App Manager
     * @param lastUpdateTime block.timestamp of most recent transaction from sender.
     * @return cumulativePurchaseTotal Total tokens sold within sell period.
     */
    function purchaseLimit(uint32 ruleId, uint256 purchasedWithinPeriod, uint256 amount, bytes32[] calldata toTags, uint64 lastUpdateTime) external view returns (uint256) {
        uint256 cumulativeTotal;
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        uint totalRules = data.getTotalPurchaseRule();
        if (totalRules > ruleId) {
            for (uint i = 0; i < toTags.length; ) {
                TaggedRules.PurchaseRule memory purchaseRule = data.getPurchaseRule(ruleId, toTags[i]);
                uint32 purchasePeriod = purchaseRule.purchasePeriod;
                uint256 purchaseAmount = purchaseRule.purchaseAmount;
                uint64 startTime = purchaseRule.startTime;
                if (purchasePeriod > 0) {
                    if (((block.timestamp - startTime) % (purchasePeriod * 1 hours)) >= block.timestamp - lastUpdateTime) cumulativeTotal = purchasedWithinPeriod + amount;
                    else cumulativeTotal = amount;
                    if (cumulativeTotal > purchaseAmount) revert TxnInFreezeWindow();
                }
                unchecked {
                    ++i;
                }
            }
        } else {
            revert RuleDoesNotExist();
        }
        return cumulativeTotal;
    }

    /**
     * @dev Sell rule functions similar to purchase rule but "resets" at 12 utc after sellAmount is exceeded
     * @param ruleId Rule identifier for rule arguments
     * @param amount Number of tokens to be transferred
     * @param fromTags Account tags applied to sender via App Manager
     * @param lastUpdateTime block.timestamp of most recent transaction from sender.
     * @return cumulativeSalesTotal Total tokens sold within sell period.
     */
    function sellLimit(uint32 ruleId, uint256 salesWithinPeriod, uint256 amount, bytes32[] calldata fromTags, uint256 lastUpdateTime) external view returns (uint256) {
        uint256 cumulativeSalesTotal;
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        for (uint i = 0; i < fromTags.length; ) {
            try data.getSellRuleByIndex(ruleId, fromTags[i]) returns (TaggedRules.SellRule memory sellRule) {
                uint256 sellAmount = sellRule.sellAmount;
                uint256 sellPeriod = sellRule.sellPeriod;
                uint64 startTime = sellRule.startTime;
                if (sellPeriod > 0) {
                    if (((block.timestamp - startTime) % (sellPeriod * 1 hours)) >= block.timestamp - lastUpdateTime) cumulativeSalesTotal = salesWithinPeriod + amount;
                    else cumulativeSalesTotal = amount;
                    if (cumulativeSalesTotal > sellAmount) revert TemporarySellRestriction();
                }
            } catch {
                revert RuleDoesNotExist();
            }
            unchecked {
                ++i;
            }
        }
        return cumulativeSalesTotal;
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
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);

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
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        uint totalRules = data.getTotalMinBalByDateRule();
        if (totalRules > ruleId) {
            for (uint i = 0; i < toTags.length; ) {
                if (toTags[i] != "") {
                    TaggedRules.MinBalByDateRule memory minBalByDateRule = data.getMinBalByDateRule(ruleId, toTags[i]);
                    uint256 holdPeriod = minBalByDateRule.holdPeriod;
                    /// first check to see if still in the hold period
                    if ((block.timestamp - (holdPeriod * 1 hours)) < minBalByDateRule.startTimeStamp) {
                        uint256 holdAmount = minBalByDateRule.holdAmount;
                        /// If the transaction will violate the rule, then revert
                        if (balance - amount < holdAmount) revert TxnInFreezeWindow();
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
