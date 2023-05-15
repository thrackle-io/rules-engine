// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {TaggedRuleProcessorDiamondLib as TaggedRulesDiamondLib, RuleDataStorage} from "./TaggedRuleProcessorDiamondLib.sol";
import {TaggedRuleDataFacet} from "../../ruleStorage/TaggedRuleDataFacet.sol";

/**
 * @title NFT Tagged Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements Non-Fungible Token Checks on Tagged Accounts.
 */
contract ERC721TaggedRuleProcessorFacet {
    error RuleDoesNotExist();
    error BalanceBelowMin();
    error MaxBalanceExceeded();

    /**
     * @dev Check if tagged account passes minAccountBalanceERC721 rule
     * @param balanceFrom Number of tokens held by sender address
     * @param fromTags Account tags applied to sender via App Manager
     * @param ruleId Rule identifier for rule arguments
     */
    function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] calldata fromTags, uint32 ruleId) external view {
        /// This Function checks the min account balance for accounts depending on GeneralTags.
        /// Function will revert if a transaction breaks a single tag-dependent rule
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        uint256 totalRules = data.getTotalBalanceLimitRules();
        if (totalRules != 0) {
            if (totalRules <= ruleId) revert RuleDoesNotExist();
        }
        for (uint256 i = 0; i < fromTags.length; ) {
            uint256 min = data.getBalanceLimitRule(ruleId, fromTags[i]).minimum;
            /// if a min is 0 then no need to check.
            if (min > 0) {
                if (balanceFrom - 1 < min) revert BalanceBelowMin();
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Check if tagged account passes maxAccountBalanceERC721 rule
     * @param balanceTo Number of tokens held by recipient address
     * @param toTags Account tags applied to recipient via App Manager
     * @param ruleId Rule identifier for rule arguments
     */
    function maxAccountBalanceERC721(uint256 balanceTo, bytes32[] calldata toTags, uint32 ruleId) external view {
        // This Function checks the max account balance for accounts depending on GeneralTags.
        // Function will revert if a transaction breaks a single tag-dependent rule
        TaggedRuleDataFacet data = TaggedRuleDataFacet(TaggedRulesDiamondLib.ruleDataStorage().taggedRules);
        uint256 totalRules = data.getTotalBalanceLimitRules();
        if (totalRules != 0) {
            if (totalRules <= ruleId) revert RuleDoesNotExist();
        }
        for (uint256 i = 0; i < toTags.length; ) {
            uint256 max = data.getBalanceLimitRule(ruleId, toTags[i]).maximum;
            // if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0
            if (max > 0) {
                if (balanceTo + 1 > max) revert MaxBalanceExceeded();
            }
            unchecked {
                ++i;
            }
        }
    }
}
