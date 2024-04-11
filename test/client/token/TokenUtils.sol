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
    /** APPLICATION LEVEL RULES */
    function setAccountMaxTxValueByRiskRule(uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BURN);
        applicationHandler.setAccountMaxTxValueByRiskScoreId(actionTypes, ruleId);
    }

    function setAccountMaxTxValueByRiskRuleSingleAction(ActionTypes action, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxTxValueByRiskScoreId(createActionTypeArray(action), ruleId);
    }

    function setAccountMaxTxValueByRiskRuleFull(ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxTxValueByRiskScoreIdFull(actions, ruleIds);
    }

    function setAccountMaxValueByAccessLevelRule(uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.MINT);
        applicationHandler.setAccountMaxValueByAccessLevelId(actionTypes, ruleId);
    }

    function setAccountMaxValueByAccessLevelSingleAction(ActionTypes action, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByAccessLevelId(createActionTypeArray(action), ruleId);
    }

    function setAccountMaxValueByAccessLevelRuleSingleAction(ActionTypes _action, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = createActionTypeArray(_action);
        applicationHandler.setAccountMaxValueByAccessLevelId(actionTypes, ruleId);
    }

    function setAccountMaxValueByAccessLevelRuleFull(ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByAccessLevelIdFull(actions, ruleIds);
    }

    function setAccountMaxValueByRiskRule(uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByRiskScoreId(createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.MINT), ruleId);
    }

    function setAccountMaxValueByRiskRuleSingleAction(ActionTypes action, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByRiskScoreId(createActionTypeArray(action), ruleId);
    }

    function setAccountMaxValueByRiskRuleFull(ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByRiskScoreIdFull(actions, ruleIds);
    }

    function setAccountMaxValueOutByAccessLevelRule(uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueOutByAccessLevelId(createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL), ruleId);
    }

    function setAccountMaxValueOutByAccessLevelSingleAction(ActionTypes action, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueOutByAccessLevelId(createActionTypeArray(action), ruleId);
    }

    function setAccountMaxValueOutByAccessLevelRuleFull(ActionTypes[] memory actions, uint32[] memory ruleIds) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueOutByAccessLevelIdFull(actions, ruleIds);
    }

    function setAccountDenyForNoAccessLevelRuleFull(ActionTypes[] memory actions) public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.setAccountDenyForNoAccessLevelIdFull(actions);
    }

    function setTokenMaxBuySellVolumeRule(address assetHandler, ActionTypes[] memory actions, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setTokenMaxBuySellVolumeId(actions, ruleId);
    }

    function setAccountMaxTradeSizeRule(address assetHandler, ActionTypes[] memory actions, uint32 ruleId) public endWithStopPrank {
        switchToRuleAdmin();
        TradingRuleFacet(address(assetHandler)).setAccountMaxTradeSizeId(actions, ruleId);
    }
}
