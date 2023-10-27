// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {TaggedRuleDataFacet} from "../ruleStorage/TaggedRuleDataFacet.sol";
import {ITaggedRules as TaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";
import {IERC721Errors, IRuleProcessorErrors, ITagRuleErrors, IMaxTagLimitError} from "../../interfaces/IErrors.sol";
import "./RuleProcessorCommonLib.sol";

/**
 * @title NFT Tagged Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements Non-Fungible Token Checks on Tagged Accounts.
 */
contract ERC721TaggedRuleProcessorFacet is IERC721Errors, IRuleProcessorErrors, ITagRuleErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for bytes32[];
    using RuleProcessorCommonLib for uint64;

    /**
     * @dev Check the minMaxAccoutBalace rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalanceERC721(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, bytes32[] calldata toTags, bytes32[] calldata fromTags) public view {
        fromTags.checkMaxTags();
        toTags.checkMaxTags();
        minAccountBalanceERC721(balanceFrom, fromTags, ruleId);
        maxAccountBalanceERC721(balanceTo, toTags, ruleId);
    }

    /**
     * @dev Check if tagged account passes minAccountBalanceERC721 rule
     * @param balanceFrom Number of tokens held by sender address
     * @param fromTags Account tags applied to sender via App Manager
     * @param ruleId Rule identifier for rule arguments
     */
    function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] calldata fromTags, uint32 ruleId) internal view {
        /// This Function checks the min account balance for accounts depending on GeneralTags.
        /// Function will revert if a transaction breaks a single tag-dependent rule
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        uint256 totalRules = data.getTotalBalanceLimitRules();
        if (totalRules <= ruleId) revert RuleDoesNotExist();
        /// we decrease the balance to check the rule
        --balanceFrom;
        for (uint256 i; i < fromTags.length; ) {
            uint256 min = data.getBalanceLimitRule(ruleId, fromTags[i]).minimum;
            /// if a min is 0 then no need to check.
            if (min > 0 && balanceFrom < min) revert BalanceBelowMin();
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
    function maxAccountBalanceERC721(uint256 balanceTo, bytes32[] calldata toTags, uint32 ruleId) internal view {
        // This Function checks the max account balance for accounts depending on GeneralTags.
        // Function will revert if a transaction breaks a single tag-dependent rule
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        uint256 totalRules = data.getTotalBalanceLimitRules();
        if (totalRules != 0 && totalRules <= ruleId) revert RuleDoesNotExist();
        /// we increase the balance to check the rule.
        ++balanceTo;
        for (uint256 i = 0; i < toTags.length; ) {
            uint256 max = data.getBalanceLimitRule(ruleId, toTags[i]).maximum;
            // if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0
            if (max > 0 && balanceTo > max) revert MaxBalanceExceeded();
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.
     * @param ruleId Rule identifier for rule arguments
     * @param transfersWithinPeriod Number of transfers within the time period
     * @param nftTags NFT tags
     * @param lastTransferTime block.timestamp of most recent transaction from sender.
     */
    function checkNFTTransferCounter(uint32 ruleId, uint256 transfersWithinPeriod, bytes32[] calldata nftTags, uint64 lastTransferTime) public view returns (uint256) {
        nftTags.checkMaxTags();
        uint256 cumulativeTotal;
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalNFTTransferCounterRules();
        for (uint i = 0; i < nftTags.length; ) {
            // if the tag is blank, then ignore
            if (bytes32(nftTags[i]).length != 0) {
                cumulativeTotal = 0;
                if (totalRules > ruleId) {
                    TaggedRules.NFTTradeCounterRule memory rule = data.getNFTTransferCounterRule(ruleId, nftTags[i]);
                    uint32 period = 24; // set purchase period to one day(24 hours)
                    uint256 tradesAllowedPerDay = rule.tradesAllowedPerDay;
                    // if within time period, add to cumulative
                    cumulativeTotal = rule.startTs.isWithinPeriod(period, lastTransferTime) ? 
                    transfersWithinPeriod + 1 : 1;
                    if (cumulativeTotal > tradesAllowedPerDay) revert MaxNFTTransferReached();
                    unchecked {
                        ++i;
                    }
                } else {
                    revert RuleDoesNotExist();
                }
            }
        }
        return cumulativeTotal;
    }

}
