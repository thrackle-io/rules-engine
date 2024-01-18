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
    bytes32 constant BLANK_TAG = bytes32("");

    /**
     * @dev Check the minMaxAccoutBalace rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalanceERC721(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, bytes32[] memory toTags, bytes32[] memory fromTags) public view {
        fromTags.checkMaxTags();
        toTags.checkMaxTags();
        /// If the rule applies to all users, check blank only. Otherwise loop through tags and check for specific application
        /// This was done in a minimal way to allow for modifications later while not duplicating rule check logic.
        if(getMinMaxBalanceRuleERC721(ruleId, BLANK_TAG).maximum > 0){
            toTags = new bytes32[](1);
            toTags[0] = BLANK_TAG;
            fromTags = toTags;
        }
        minAccountBalanceERC721(balanceFrom, fromTags, ruleId);
        maxAccountBalanceERC721(balanceTo, toTags, ruleId);
    }

    /**
     * @dev Check if tagged account passes minAccountBalanceERC721 rule
     * @param balanceFrom Number of tokens held by sender address
     * @param fromTags Account tags applied to sender via App Manager
     * @param ruleId Rule identifier for rule arguments
     */
    function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] memory fromTags, uint32 ruleId) internal view {
        /// This Function checks the min account balance for accounts depending on GeneralTags.
        /// Function will revert if a transaction breaks a single tag-dependent rule
        for (uint256 i; i < fromTags.length; ) {
            uint256 min = getMinMaxBalanceRuleERC721(ruleId, fromTags[i]).minimum;
            /// if a min is 0 then no need to check.
            if (min > 0 && balanceFrom <= min) revert BalanceBelowMin();
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
    function maxAccountBalanceERC721(uint256 balanceTo, bytes32[] memory toTags, uint32 ruleId) internal view {
        for (uint256 i = 0; i < toTags.length; ) {
            uint256 max = getMinMaxBalanceRuleERC721(ruleId, toTags[i]).maximum;
            // if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0
            if (max > 0 && balanceTo >= max) revert MaxBalanceExceeded();
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Function get the purchase rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountType Type of Accounts
     * @return MinMaxBalanceRule at index location in array
     */
    function getMinMaxBalanceRuleERC721(uint32 _index, bytes32 _accountType) public view returns (TaggedRules.MinMaxBalanceRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalMinMaxBalanceRulesERC721());
        RuleS.MinMaxBalanceRuleS storage data = Storage.minMaxBalanceStorage();
        if (_index >= data.minMaxBalanceRuleIndex) revert IndexOutOfRange();
        return data.minMaxBalanceRulesPerUser[_index][_accountType];
    }

    /**
     * @dev Function gets total Balance Limit rules
     * @return Total length of array
     */
    function getTotalMinMaxBalanceRulesERC721() public view returns (uint32) {
        RuleS.MinMaxBalanceRuleS storage data = Storage.minMaxBalanceStorage();
        return data.minMaxBalanceRuleIndex;
    }

    /**
     * @dev This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.
     * @param ruleId Rule identifier for rule arguments
     * @param transfersWithinPeriod Number of transfers within the time period
     * @param nftTags NFT tags
     * @param lastTransferTime block.timestamp of most recent transaction from sender.
     */
    function checkNFTTransferCounter(uint32 ruleId, uint256 transfersWithinPeriod, bytes32[] memory nftTags, uint64 lastTransferTime) public view returns (uint256) {
        nftTags.checkMaxTags();
        uint256 cumulativeTotal;
        /// If the rule applies to all users, check blank only. Otherwise loop through tags and check for specific application
        /// This was done in a minimal way to allow for modifications later while not duplicating rule check logic.
        if(getNFTTransferCounterRule(ruleId, BLANK_TAG).startTs > 0){
            nftTags = new bytes32[](1);
            nftTags[0] = BLANK_TAG;
        }
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
