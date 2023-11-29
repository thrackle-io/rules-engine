// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";

/**
 * @title NFT Tagged Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements Non-Fungible Token Checks on Tagged Accounts.
 */
contract ERC721TaggedRuleProcessorFacet is IInputErrors, IERC721Errors, IRuleProcessorErrors, ITagRuleErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for bytes32[];
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8;

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
        /// we decrease the balance to check the rule
        --balanceFrom;
        for (uint256 i; i < fromTags.length; ) {
            uint256 min = getBalanceLimitRuleERC721(ruleId, fromTags[i]).minimum;
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
        /// we increase the balance to check the rule.
        ++balanceTo;
        for (uint256 i = 0; i < toTags.length; ) {
            uint256 max = getBalanceLimitRuleERC721(ruleId, toTags[i]).maximum;
            // if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0
            if (max > 0 && balanceTo > max) revert MaxBalanceExceeded();
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Function get the purchase rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountType Type of Accounts
     * @return BalanceLimitRule at index location in array
     */
    function getBalanceLimitRuleERC721(uint32 _index, bytes32 _accountType) public view returns (TaggedRules.BalanceLimitRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalBalanceLimitRulesERC721());
        RuleS.BalanceLimitRuleS storage data = Storage.balanceLimitStorage();
        if (_index >= data.balanceLimitRuleIndex) revert IndexOutOfRange();
        return data.balanceLimitsPerAccountType[_index][_accountType];
    }

    /**
     * @dev Function gets total Balance Limit rules
     * @return Total length of array
     */
    function getTotalBalanceLimitRulesERC721() public view returns (uint32) {
        RuleS.BalanceLimitRuleS storage data = Storage.balanceLimitStorage();
        return data.balanceLimitRuleIndex;
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
        for (uint i = 0; i < nftTags.length; ) {
            // if the tag is blank, then ignore
            if (bytes32(nftTags[i]).length != 0) {
                cumulativeTotal = 0;
                TaggedRules.NFTTradeCounterRule memory rule = getNFTTransferCounterRule(ruleId, nftTags[i]);
                uint32 period = 24; // set purchase period to one day(24 hours)
                uint256 tradesAllowedPerDay = rule.tradesAllowedPerDay;
                // if within time period, add to cumulative
                cumulativeTotal = rule.startTs.isWithinPeriod(period, lastTransferTime) ? 
                transfersWithinPeriod + 1 : 1;
                if (cumulativeTotal > tradesAllowedPerDay) revert MaxNFTTransferReached();
                unchecked {
                    ++i;
                }
            }
        }
        return cumulativeTotal;
    }

    /**
     * @dev Function get the NFT Transfer Counter rule in the rule set that belongs to an NFT type
     * @param _index position of rule in array
     * @param _nftType Type of NFT
     * @return NftTradeCounterRule at index location in array
     */
    function getNFTTransferCounterRule(uint32 _index, bytes32 _nftType) public view returns (TaggedRules.NFTTradeCounterRule memory) {
        RuleS.NFTTransferCounterRuleS storage data = Storage.nftTransferStorage();
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalNFTTransferCounterRules());
        return data.NFTTransferCounterRule[_index][_nftType];
    }

    /**
     * @dev Function gets total NFT Trade Counter rules
     * @return Total length of array
     */
    function getTotalNFTTransferCounterRules() public view returns (uint32) {
        RuleS.NFTTransferCounterRuleS storage data = Storage.nftTransferStorage();
        return data.NFTTransferCounterRuleIndex;
    }

}
