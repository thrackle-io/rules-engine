// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/TokenUtils.sol";


/**
 * @title Rule Creation Functions  
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests.
 * This contract holds the functions for adding a protocol rule for tests.  
 */

abstract contract ERC721Util is TokenUtils {

    function setAccountApproveDenyOracleRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BURN, ActionTypes.MINT);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setAccountApproveDenyOracleId(actionTypes, ruleId);
    }

    function setAdminMinTokenBalanceRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721HandlerMainFacet(address(assetHandler)).setAdminMinTokenBalanceId(actionTypes, ruleId);
    }

    function setTokenMaxDailyTradesRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxDailyTradesId(actionTypes, ruleId);
    }

    function setAccountMinMaxTokenBalanceRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.MINT, ActionTypes.BURN);
        ERC721TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
    }

    function setTokenMaxSupplyVolatilityRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.MINT, ActionTypes.BURN);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxSupplyVolatilityId(actionTypes, ruleId);
    }

    function setTokenMaxTradingVolumeRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
    }

    function setTokenMinimumTransactionRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMinTxSizeId(actionTypes, ruleId);
    }

    function setTokenMinHoldTimeRule(uint8 period) public endWithStopPrank() {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).setTokenMinHoldTime(_createActionsArray(), period);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER), period);
    }


}