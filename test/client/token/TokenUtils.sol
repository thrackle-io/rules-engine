// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/RuleCreation.sol";


/**
 * @title Rule Creation Functions  
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests.
 * This contract holds the functions for adding a protocol rule for tests.  
 */

abstract contract TokenUtils is RuleCreation {


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

    function setTokenMaxBuyVolumeRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setTokenMaxBuyVolumeId(ruleId);
        switchToOriginalUser();
    }

    function setTokenMaxSellVolumeRule(address assetHandler, uint32 ruleId) public {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setTokenMaxSellVolumeId(ruleId);
        switchToOriginalUser();
    }

}