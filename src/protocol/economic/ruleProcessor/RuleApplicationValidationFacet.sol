// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "./RuleProcessorDiamondImports.sol";
import "src/client/application/data/PauseRule.sol";
import "src/client/application/IAppManager.sol";
import {TaggedRuleDataFacet} from "./TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "./RuleDataFacet.sol";
import {AppRuleDataFacet} from "./AppRuleDataFacet.sol";


/**
 * @title Rule Application Validation Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check rule existence
 * @notice Check that a rule in fact exists.
 */
contract RuleApplicationValidationFacet {
    using RuleProcessorCommonLib for uint32;


    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMinMaxTokenBalanceERC721(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountMinMaxTokenBalance());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMinMaxTokenBalance(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountMinMaxTokenBalance());
    }

    /**
     * @dev Function gets total AccountMinMaxTokenBalance rules
     * @return Total length of array
     */
    function getTotalAccountMinMaxTokenBalance() internal view returns (uint32) {
        RuleS.AccountMinMaxTokenBalanceS storage data = Storage.accountMinMaxTokenBalanceStorage();
        return data.accountMinMaxTokenBalanceIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenMaxDailyTrades(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getTotalTokenMaxDailyTradesRules());
    }

    /**
     * @dev Function gets total tokenMaxDailyTrades rules
     * @return Total length of array
     */
    function getTotalTokenMaxDailyTradesRules() internal view returns (uint32) {
        RuleS.TokenMaxDailyTradesS storage data = Storage.TokenMaxDailyTradesStorage();
        return data.tokenMaxDailyTradesIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMaxBuySize(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountMaxBuySize());
    }

    /**
     * @dev Function to get total account max buy size rules
     * @return Total length of array
     */
    function getTotalAccountMaxBuySize() internal view returns (uint32) {
        RuleS.AccountMaxBuySizeS storage data = Storage.accountMaxBuySizeStorage();
        return data.accountMaxBuySizeIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMaxSellSize(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getTotalAccountMaxSellSize());
    }

    /**
     * @dev Function to get total Account Max Sell Size rules
     * @return Total length of array
     */
    function getTotalAccountMaxSellSize() internal view returns (uint32) {
        RuleS.AccountMaxSellSizeS storage data = Storage.accountMaxSellSizeStorage();
        return data.AccountMaxSellSizesIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAdminMinTokenBalance(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAdminMinTokenBalance());
    }

    /**
     * @dev Function to get total Admin Min Token Balance rules
     * @return adminMinTokenBalanceRules total length of array
     */
    function getTotalAdminMinTokenBalance() internal view returns (uint32) {
        RuleS.AdminMinTokenBalanceS storage data = Storage.adminMinTokenBalanceStorage();
        return data.adminMinTokenBalanceIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenMinTxSize(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalTokenMinTxSize());
    }

    /**
     * @dev Function to get total Token Min Tx Size rules
     * @return Total length of array
     */
    function getTotalTokenMinTxSize() internal view returns (uint32) {
        RuleS.TokenMinTxSizeS storage data = Storage.tokenMinTxSizePosition();
        return data.tokenMinTxSizeIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountApproveDenyOracle(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountApproveDenyOracle());
    }

    /**
     * @dev Function get total Account Approve Deny Oracle rules
     * @return total accountApproveDenyOracleRules array length
     */
    function getTotalAccountApproveDenyOracle() internal view returns (uint32) {
        RuleS.AccountApproveDenyOracleS storage data = Storage.accountApproveDenyOracleStorage();
        return data.accountApproveDenyOracleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenMaxBuyVolume(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalTokenMaxBuyVolume());
    }

    /**
     * @dev Function to get total Token Max Buy Volume
     * @return Total length of array
     */
    function getTotalTokenMaxBuyVolume() internal view returns (uint32) {
        RuleS.TokenMaxBuyVolumeS storage data = Storage.accountMaxBuyVolumeStorage();
        return data.tokenMaxBuyVolumeIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenMaxSellVolume(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalTokenMaxSellVolume());
    }

    /**
     * @dev Function to get total Token Max Sell Volume
     * @return Total length of array
     */
    function getTotalTokenMaxSellVolume() internal view returns (uint32) {
        RuleS.TokenMaxSellVolumeS storage data = Storage.accountMaxSellVolumeStorage();
        return data.tokenMaxSellVolumeIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenMaxTradingVolume(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalTokenMaxTradingVolume());
    }

    /**
     * @dev Function to get total Token Max Trading Volume
     * @return Total length of array
     */
    function getTotalTokenMaxTradingVolume() internal view returns (uint32) {
        RuleS.TokenMaxTradingVolumeS storage data = Storage.tokenMaxTradingVolumeStorage();
        return data.tokenMaxTradingVolumeIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenMaxSupplyVolatility(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getTotalTokenMaxSupplyVolatility());
    }

    /**
     * @dev Function to get total Token Max Supply Volitility rules
     * @return tokenMaxSupplyVolatilityRules total length of array
     */
    function getTotalTokenMaxSupplyVolatility() internal view returns (uint32) {
        RuleS.TokenMaxSupplyVolatilityS storage data = Storage.tokenMaxSupplyVolatilityStorage();
        return data.tokenMaxSupplyVolatilityIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMaxValueByRiskScore(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountMaxValueByRiskScore());
    }

    /**
     * @dev Function to get total Account Max Value by Risk Score rules
     * @return Total length of array
     */
    function getTotalAccountMaxValueByRiskScore() internal view returns (uint32) {
        RuleS.AccountMaxValueByRiskScoreS storage data = Storage.accountMaxValueByRiskScoreStorage();
        return data.accountMaxValueByRiskScoreIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMaxTxValueByRiskScore(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountMaxTxValueByRiskScore());
    }

    /**
     * @dev Function to get total Account Max Transaction Value by Risk rules
     * @return Total length of array
     */
    function getTotalAccountMaxTxValueByRiskScore() internal view returns (uint32) {
        RuleS.AccountMaxTxValueByRiskScoreS storage data = Storage.accountMaxTxValueByRiskScoreStorage();
        return data.accountMaxTxValueByRiskScoreIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     * @param _dataServer address of the appManager contract
     */
    function validatePause(uint32 _ruleId, address _dataServer) external view {
        PauseRule[] memory pauseRules = IAppManager(_dataServer).getPauseRules();
        _ruleId.checkRuleExistence(uint32(pauseRules.length));
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMaxValueByAccessLevel(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountMaxValueByAccessLevel());
    }

    /**
     * @dev Function to get total Account Max Value By Access Level rules
     * @return Total length of array
     */
    function getTotalAccountMaxValueByAccessLevel() internal view returns (uint32) {
        RuleS.AccountMaxValueByAccessLevelS storage data = Storage.accountMaxValueByAccessLevelStorage();
        return data.accountMaxValueByAccessLevelIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccountMaxValueOutByAccessLevel(uint32 _ruleId) external view {
        _ruleId.checkRuleExistence(getTotalAccountMaxValueOutByAccessLevel());
    }

    /**
     * @dev Function to get total Account Max Value Out By Access Level rules
     * @return Total number of access level withdrawal rules
     */
    function getTotalAccountMaxValueOutByAccessLevel() internal view returns (uint32) {
        RuleS.AccountMaxValueOutByAccessLevelS storage data = Storage.accountMaxValueOutByAccessLevelStorage();
        return data.accountMaxValueOutByAccessLevelIndex;
    }
}
