// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {RuleDataFacet} from "../ruleStorage/RuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";
import {IERC721Errors, IRuleProcessorErrors, IMaxTagLimitError} from "../../interfaces/IErrors.sol";
import "./RuleProcessorCommonLib.sol";

/**
 * @title NFT Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev facet in charge of the logic to check non-fungible token rules compliance
 * @notice Implements NFT Rule checks for rules
 */
contract ERC721RuleProcessorFacet is IERC721Errors, IRuleProcessorErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for bytes32[];

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
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalNFTTransferCounterRules();
        for (uint i = 0; i < nftTags.length; ) {
            // if the tag is blank, then ignore
            if (bytes32(nftTags[i]).length != 0) {
                cumulativeTotal = 0;
                if (totalRules > ruleId) {
                    NonTaggedRules.NFTTradeCounterRule memory rule = data.getNFTTransferCounterRule(ruleId, nftTags[i]);
                    uint32 period = 24; // set purchase period to one day(24 hours)
                    uint256 tradesAllowedPerDay = rule.tradesAllowedPerDay;
                    // if within time period, add to cumulative
                    if (rule.startTs.isWithinPeriod(period, lastTransferTime)) {
                        cumulativeTotal = transfersWithinPeriod + 1;
                    } else {
                        cumulativeTotal = 1;
                    }
                    if (cumulativeTotal > tradesAllowedPerDay) {
                        revert MaxNFTTransferReached();
                    }
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

    /**
     * @dev This function receives data needed to check Minimum hold time rule. This a simple rule and thus is not stored in the rule storage diamond.
     * @param _holdHours minimum number of hours the asset must be held
     * @param _ownershipTs beginning of hold period
     */
    function checkNFTHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view {
        if (_ownershipTs > 0) {
            if ((block.timestamp - _ownershipTs) < _holdHours * 1 hours) {
                revert MinimumHoldTimePeriodNotReached();
            }
        }
    }
}
