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
    function setAccountApproveDenyOracleRule(address assetHandler, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BURN, ActionTypes.MINT);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setAccountApproveDenyOracleId(actionTypes, ruleId);
    }

    function setAccountApproveDenyOracleRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(assetHandler)).setAccountApproveDenyOracleIdFull(actions, ruleIds);
    }

    function setAdminMinTokenBalanceRule(address assetHandler, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721HandlerMainFacet(address(assetHandler)).setAdminMinTokenBalanceId(actionTypes, ruleId);
    }

    function setAdminMinTokenBalanceRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721HandlerMainFacet(address(assetHandler)).setAdminMinTokenBalanceIdFull(actions, ruleIds);
    }

    function setTokenMaxDailyTradesRule(address assetHandler, uint32 ruleId) public endWithStopPrank endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxDailyTradesId(actionTypes, ruleId);
    }

    function setTokenMaxDailyTradesRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxDailyTradesIdFull(actions, ruleIds);
    }

    function setAccountMinMaxTokenBalanceRule(address assetHandler, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.MINT, ActionTypes.BURN);
        ERC721TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
    }

    function setAccountMinMaxTokenBalanceRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceIdFull(actions, ruleIds);
    }

    function setTokenMaxSupplyVolatilityRule(address assetHandler, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.MINT, ActionTypes.BURN);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxSupplyVolatilityId(actionTypes, ruleId);
    }

    function setTokenMaxSupplyVolatilityRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxSupplyVolatilityIdFull(actions, ruleIds);
    }

    function setTokenMaxTradingVolumeRule(address assetHandler, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
    }

    function setTokenMaxTradingVolumeRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxTradingVolumeIdFull(actions, ruleIds);
    }

    function setTokenMinimumTransactionRule(address assetHandler, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMinTxSizeId(actionTypes, ruleId);
    }

    function setTokenMinimumTransactionRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMinTxSizeIdFull(actions, ruleIds);
    }

    function setTokenMinHoldTimeRule(uint8 period) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).setTokenMinHoldTime(_createActionsArray(), period);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER), period);
    }

    function setTokenMinHoldTimeRuleFull(address assetHandler, ActionTypes[] memory actions, uint32[] memory periods) public endWithStopPrank {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMinHoldTimeFull(actions, periods);
    }
}
