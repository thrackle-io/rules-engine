// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {RuleDataFacet} from "../ruleStorage/RuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";

/**
 * @title NFT Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev facet in charge of the logic to check non-fungible token rules compliance
 * @notice Implements NFT Rule checks for rules
 */
contract ERC721RuleProcessorFacet {
    error MaxNFTTransferReached();
    error RuleDoesNotExist();

    //TODO: Min/Max account balance rule for NFT (META - no tag/ use tokenId)

    /**
     * @dev Check if transaction passes minAccountBalanceERC721 rule
     * @param balanceFrom Number of tokens held by sender address
     * @param tokenId Token ID being transferred
     * @param amount Number of tokens being transferred
     * @param ruleId Rule identifier for rule arguments
     */
    function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] calldata tokenId, uint256 amount, uint32 ruleId) external view {
        //update if there are  rules that apply to ERC721/ERC721A
    }

    /**
     * @dev This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.
     * @param ruleId Rule identifier for rule arguments
     * @param transfersWithinPeriod Number of transfers within the time period
     * @param nftTags NFT tags
     * @param lastTransferTime block.timestamp of most recent transaction from sender.
     */
    function checkNFTTransferCounter(uint32 ruleId, uint256 transfersWithinPeriod, bytes32[] calldata nftTags, uint64 lastTransferTime) public view returns (uint256) {
        uint256 cumulativeTotal;
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalNFTTransferCounterRules();
        for (uint i = 0; i < nftTags.length; ) {
            // if the tag is blank, then ignore
            if (bytes32(nftTags[i]).length != 0) {
                cumulativeTotal = 0;
                if (totalRules > ruleId) {
                    NonTaggedRules.NFTTradeCounterRule memory rule = data.getNFTTransferCounterRule(ruleId, nftTags[i]);
                    // check to see if the rule is active(this is to account for zero tradesAllowedPerDay)
                    if (rule.active) {
                        uint32 period = 1 days; // set purchase period to one day
                        uint256 tradesAllowedPerDay = rule.tradesAllowedPerDay;
                        // if within time period, add to cumulative
                        if (lastTransferTime > 0) {
                            if ((block.timestamp % period) >= block.timestamp - lastTransferTime) {
                                cumulativeTotal = transfersWithinPeriod + 1;
                            } else {
                                cumulativeTotal = 1;
                            }
                        } else {
                            cumulativeTotal = 1;
                        }
                        if (cumulativeTotal > tradesAllowedPerDay) {
                            revert MaxNFTTransferReached();
                        }
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
}
