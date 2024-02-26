// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/RuleCreation.sol";


/**
 * @title Rule Creation Functions  
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests.
 * This contract holds the functions for adding a protocol rule for tests.  
 */

abstract contract ERC721Util is RuleCreation {

    function setAccountApproveDenyOracleRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BURN, ActionTypes.MINT);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setAccountApproveDenyOracleId(actionTypes, ruleId);
    }

    function setAccountMaxBuySizeRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setAccountMaxBuySizeId(ruleId);
        switchToOriginalUser();
    }

    function setAccountMaxSellSizeRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setAccountMaxSellSizeId(ruleId);
        switchToOriginalUser();
    }

    function setAccountMaxTxValueByRiskRule(uint32 ruleId) public {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxTxValueByRiskScoreId(ruleId);
        switchToOriginalUser();
    }


    function setAccountMaxValueByAccessLevelRule(uint32 ruleId) public {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByAccessLevelId(ruleId);
        switchToOriginalUser();
    }

    function setAccountMaxValueByRiskRule(uint32 ruleId) public {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByRiskScoreId(ruleId);
        switchToOriginalUser();
    }


    function setAccountMaxValueOutByAccessLevelRule(uint32 ruleId) public {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueOutByAccessLevelId(ruleId);
        switchToOriginalUser();
    }

    function setAccountMinMaxTokenBalanceRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.MINT, ActionTypes.BURN);
        ERC721TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToOriginalUser();
    }


    function setAdminMinTokenBalanceRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721HandlerMainFacet(address(assetHandler)).setAdminMinTokenBalanceId(actionTypes, ruleId);
        switchToOriginalUser();
    }

    function setTokenMaxBuyVolumeRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setTokenMaxBuyVolumeId(ruleId);
        switchToOriginalUser();
    }

    function setTokenMaxDailyTradesRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxDailyTradesId(actionTypes, ruleId);
        switchToOriginalUser();
    }


    function setTokenMaxSellVolumeRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setTokenMaxSellVolumeId(ruleId);
        switchToOriginalUser();
    }

    function setTokenMaxSupplyVolatilityRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.MINT, ActionTypes.BURN);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxSupplyVolatilityId(actionTypes, ruleId);
        switchToOriginalUser();
    }

    function setTokenMaxTradingVolumeRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
        switchToOriginalUser();
    }

    function setTokenMinimumTransactionRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMinTxSizeId(actionTypes, ruleId);
        switchToOriginalUser();
    }

    function setTokenMinHoldTimeRule(uint8 period) public {
        switchToRuleAdmin();
        ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).setTokenMinHoldTime(_createActionsArray(), period);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER), period);
        switchToOriginalUser();
    }


}