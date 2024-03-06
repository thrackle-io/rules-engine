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


    function setAccountMaxBuySizeRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setAccountMaxBuySizeId(ruleId);
    }

    function setAccountMaxSellSizeRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setAccountMaxSellSizeId(ruleId);
    }

    function setAccountMaxTxValueByRiskRule(uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxTxValueByRiskScoreId(ruleId);
    }

    function setAccountMaxValueByAccessLevelRule(uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByAccessLevelId(ruleId);
    }

    function setAccountMaxValueByRiskRule(uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByRiskScoreId(ruleId);
    }


    function setAccountMaxValueOutByAccessLevelRule(uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueOutByAccessLevelId(ruleId);
    }

    function setTokenMaxBuyVolumeRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setTokenMaxBuyVolumeId(ruleId);
    }

    function setTokenMaxSellVolumeRule(address assetHandler, uint32 ruleId) public endWithStopPrank() {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setTokenMaxSellVolumeId(ruleId);
    }
}