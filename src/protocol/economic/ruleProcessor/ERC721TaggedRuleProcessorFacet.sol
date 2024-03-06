// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./RuleProcessorDiamondImports.sol";

/**
 * @title NFT Tagged Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by a Token Handler.
 * @notice Implements Non-Fungible Token Checks on Tagged Accounts.
 */
contract ERC721TaggedRuleProcessorFacet is IInputErrors, IERC721Errors, IRuleProcessorErrors, ITagRuleErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for bytes32[];
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8;
    bytes32 constant BLANK_TAG = bytes32("");

    /**
     * @dev Check the minMaxAccoutBalance rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     * @notice If the rule applies to all users, it checks blank tag only. Otherwise loop through 
     * tags and check for specific application. This was done in a minimal way to allow for  
     * modifications later while not duplicating rule check logic.
     */
    function checkMinMaxAccountBalanceERC721(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, bytes32[] memory toTags, bytes32[] memory fromTags) public view {
        fromTags.checkMaxTags();
        toTags.checkMaxTags();
        if(getAccountMinMaxTokenBalanceERC721(ruleId, BLANK_TAG).max > 0){
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
     * @notice most restrictive tag will be enforced.
     */
    function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] memory fromTags, uint32 ruleId) internal view {
        for (uint256 i; i < fromTags.length; ) {
            uint256 min = getAccountMinMaxTokenBalanceERC721(ruleId, fromTags[i]).min;
            if (min > 0 && balanceFrom <= min) revert UnderMinBalance();
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
            uint256 max = getAccountMinMaxTokenBalanceERC721(ruleId, toTags[i]).max;
            if (max > 0 && balanceTo >= max) revert OverMaxBalance();
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Function get the Account Min Max Token Balance ERC721 rule in the rule set that belongs to a specific tag.
     * @param _index position of rule in array
     * @param _nftTag nft tag for rule application
     * @return AccountMinMaxTokenBalance at index location in array
     */
    function getAccountMinMaxTokenBalanceERC721(uint32 _index, bytes32 _nftTag) public view returns (TaggedRules.AccountMinMaxTokenBalance memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalAccountMinMaxTokenBalancesERC721());
        RuleS.AccountMinMaxTokenBalanceS storage data = Storage.accountMinMaxTokenBalanceStorage();
        if (_index >= data.accountMinMaxTokenBalanceIndex) revert IndexOutOfRange();
        return data.accountMinMaxTokenBalanceRules[_index][_nftTag];
    }

    /**
     * @dev Function gets total Account Min Max Token Balance ERC721 rules
     * @return Total length of array
     */
    function getTotalAccountMinMaxTokenBalancesERC721() public view returns (uint32) {
        RuleS.AccountMinMaxTokenBalanceS storage data = Storage.accountMinMaxTokenBalanceStorage();
        return data.accountMinMaxTokenBalanceIndex;
    }

    /**
     * @dev This function receives a rule id, which it uses to get the Token Max Daily Trades rule to check if the transfer is valid.
     * @param ruleId Rule identifier for rule arguments
     * @param transfersWithinPeriod Number of transfers within the time period
     * @param nftTags NFT tags
     * @param lastTransferTime block.timestamp of most recent transaction from sender.
     * @notice If the rule applies to all users, it checks blank tag only. Otherwise loop through 
     * tags and check for specific application. This was done in a minimal way to allow for  
     * modifications later while not duplicating rule check logic.
     */
    function checkTokenMaxDailyTrades(uint32 ruleId, uint256 transfersWithinPeriod, bytes32[] memory nftTags, uint64 lastTransferTime) public view returns (uint256) {
        nftTags.checkMaxTags();
        uint256 cumulativeTotal = 0;
        if(getTokenMaxDailyTrades(ruleId, BLANK_TAG).startTime > 0){
            nftTags = new bytes32[](1);
            nftTags[0] = BLANK_TAG;
        }
        for (uint i = 0; i < nftTags.length; ) {
            // if the tag is blank, then ignore
            if (bytes32(nftTags[i]).length != 0) {
                cumulativeTotal = 0;
                TaggedRules.TokenMaxDailyTrades memory rule = getTokenMaxDailyTrades(ruleId, nftTags[i]);
                uint32 period = 24; // set purchase period to one day(24 hours)
                uint256 tradesAllowedPerDay = rule.tradesAllowedPerDay;
                cumulativeTotal = rule.startTime.isWithinPeriod(period, lastTransferTime) ? 
                transfersWithinPeriod + 1 : 1;
                if (cumulativeTotal > tradesAllowedPerDay) revert OverMaxDailyTrades();
                unchecked {
                    ++i;
                }
            }
        }
        return cumulativeTotal;
    }

    /**
     * @dev Function get the Token Max Daily Trades rule in the rule set that belongs to an NFT type
     * @param _index position of rule in array
     * @param _nftType Type of NFT
     * @return TokenMaxDailyTrades at index location in array
     */
    function getTokenMaxDailyTrades(uint32 _index, bytes32 _nftType) public view returns (TaggedRules.TokenMaxDailyTrades memory) {
        RuleS.TokenMaxDailyTradesS storage data = Storage.TokenMaxDailyTradesStorage();
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalTokenMaxDailyTrades());
        return data.tokenMaxDailyTradesRules[_index][_nftType];
    }

    /**
     * @dev Function gets total Token Max Daily Trades rules
     * @return Total length of array
     */
    function getTotalTokenMaxDailyTrades() public view returns (uint32) {
        RuleS.TokenMaxDailyTradesS storage data = Storage.TokenMaxDailyTradesStorage();
        return data.tokenMaxDailyTradesIndex;
    }

}
