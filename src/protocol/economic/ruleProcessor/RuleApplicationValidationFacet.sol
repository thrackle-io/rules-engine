// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "./RuleProcessorDiamondImports.sol";
import "src/client/application/data/PauseRule.sol";
import "src/client/application/IAppManager.sol";
import {FeeRuleDataFacet} from "./FeeRuleDataFacet.sol";
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
    function validateAMMFee(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllAMMFeeRules());
    }

    /**
     * @dev Function get all AMM Fee rules for validation
     * @return total ammFeeRules array length
     */
    function getAllAMMFeeRules() internal view returns (uint32) {
        RuleS.AMMFeeRuleS storage data = Storage.ammFeeRuleStorage();
        return data.ammFeeRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTransactionLimitByRiskScore(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllTransactionLimitByRiskRules());
    }

    /**
     * @dev Function to get all Transaction Limit by Risk Score rules for validation
     * @return Total length of array
     */
    function getAllTransactionLimitByRiskRules() internal view returns (uint32) {
        RuleS.TxSizeToRiskRuleS storage data = Storage.txSizeToRiskStorage();
        return data.txSizeToRiskRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinMaxAccountBalanceERC721(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllMinMaxBalanceRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinMaxAccountBalance(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllMinMaxBalanceRules());
    }

    /**
     * @dev Function gets total Balance Limit rules
     * @return Total length of array
     */
    function getAllMinMaxBalanceRules() internal view returns (uint32) {
        RuleS.MinMaxBalanceRuleS storage data = Storage.minMaxBalanceStorage();
        return data.minMaxBalanceRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateNFTTransferCounter(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllNFTTransferCounterRules());
    }

    /**
     * @dev Function gets total NFT Trade Counter rules
     * @return Total length of array
     */
    function getAllNFTTransferCounterRules() internal view returns (uint32) {
        RuleS.NFTTransferCounterRuleS storage data = Storage.nftTransferStorage();
        return data.NFTTransferCounterRuleIndex;
    }


    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validatePurchaseLimit(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllPurchaseRule());
    }

    /**
     * @dev Function to get total purchase rules
     * @return Total length of array
     */
    function getAllPurchaseRule() internal view returns (uint32) {
        RuleS.PurchaseRuleS storage data = Storage.purchaseStorage();
        return data.purchaseRulesIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSellLimit(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllSellRule());
    }

    /**
     * @dev Function to get total Sell rules
     * @return Total length of array
     */
    function getAllSellRule() internal view returns (uint32) {
        RuleS.SellRuleS storage data = Storage.sellStorage();
        return data.sellRulesIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAdminWithdrawal(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllAdminWithdrawalRules());
    }

    /**
     * @dev Function to get total Admin withdrawal rules
     * @return adminWithdrawalRulesPerToken total length of array
     */
    function getAllAdminWithdrawalRules() internal view returns (uint32) {
        RuleS.AdminWithdrawalRuleS storage data = Storage.adminWithdrawalStorage();
        return data.adminWithdrawalRulesIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateWithdrawal(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllWithdrawalRule());
    }
    
    /**
     * @dev Function to get total withdrawal rules
     * @return withdrawalRulesIndex total length of array
     */
    function getAllWithdrawalRule() internal view returns (uint32) {
        RuleS.WithdrawalRuleS storage data = Storage.withdrawalStorage();
        return data.withdrawalRulesIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinBalByDate(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllMinBalByDateRule());
    }

    /**
     * @dev Function to get total minimum balance by date rules
     * @return Total length of array
     */
    function getAllMinBalByDateRule() internal view returns (uint32) {
        RuleS.MinBalByDateRuleS storage data = Storage.minBalByDateRuleStorage();
        return data.minBalByDateRulesIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinTransfer(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllMinimumTransferRules());
    }

    /**
     * @dev Function to get total Minimum Transfer rules
     * @return Total length of array
     */
    function getAllMinimumTransferRules() internal view returns (uint32) {
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        return data.minimumTransferRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateOracle(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllOracleRules());
    }

    /**
     * @dev Function get total Oracle rules
     * @return total oracleRules array length
     */
    function getAllOracleRules() internal view returns (uint32) {
        RuleS.OracleRuleS storage data = Storage.oracleStorage();
        return data.oracleRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validatePurchasePercentage(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllPctPurchaseRule());
    }

    /**
     * @dev Function to get total Token Purchase Percentage
     * @return Total length of array
     */
    function getAllPctPurchaseRule() internal view returns (uint32) {
        RuleS.PctPurchaseRuleS storage data = Storage.pctPurchaseStorage();
        return data.percentagePurchaseRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSellPercentage(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllPctSellRule());
    }

    /**
     * @dev Function to get total Token Percentage Sell
     * @return Total length of array
     */
    function getAllPctSellRule() internal view returns (uint32) {
        RuleS.PctSellRuleS storage data = Storage.pctSellStorage();
        return data.percentageSellRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenTransferVolume(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllTransferVolumeRules());
    }

    /**
     * @dev Function to get total Token Transfer Volume rules
     * @return Total length of array
     */
    function getAllTransferVolumeRules() internal view returns (uint32) {
        RuleS.TransferVolRuleS storage data = Storage.volumeStorage();
        return data.transferVolRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSupplyVolatility(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllSupplyVolatilityRules());
    }

    /**
     * @dev Function to get total Supply Volitility rules
     * @return supplyVolatilityRules total length of array
     */
    function getAllSupplyVolatilityRules() internal view returns (uint32) {
        RuleS.SupplyVolatilityRuleS storage data = Storage.supplyVolatilityStorage();
        return data.supplyVolatilityRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccBalanceByRisk(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllAccountBalanceByRiskScoreRules());
    }

    /**
     * @dev Function to get total Transaction Limit by Risk Score rules
     * @return Total length of array
     */
    function getAllAccountBalanceByRiskScoreRules() internal view returns (uint32) {
        RuleS.AccountBalanceToRiskRuleS storage data = Storage.accountBalanceToRiskStorage();
        return data.balanceToRiskRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMaxTxSizePerPeriodByRisk(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllMaxTxSizePerPeriodRules());
    }

    /**
     * @dev Function to get total Max Tx Size Per Period By Risk rules
     * @return Total length of array
     */
    function getAllMaxTxSizePerPeriodRules() internal view returns (uint32) {
        RuleS.TxSizePerPeriodToRiskRuleS storage data = Storage.txSizePerPeriodToRiskStorage();
        return data.txSizePerPeriodToRiskRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     * @param _dataServer address of the appManager contract
     */
    function validatePause(uint32 _ruleId, address _dataServer) external view {
        PauseRule[] memory pauseRules = IAppManager(_dataServer).getPauseRules();
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(uint32(pauseRules.length));
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccBalanceByAccessLevel(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllAccessLevelBalanceRules());
    }

    /**
     * @dev Function to get total AccessLevel Balance rules
     * @return Total length of array
     */
    function getAllAccessLevelBalanceRules() internal view returns (uint32) {
        RuleS.AccessLevelRuleS storage data = Storage.accessStorage();
        return data.accessRuleIndex;
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateWithdrawalLimitsByAccessLevel(uint32 _ruleId) external view {
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(getAllAccessLevelWithdrawalRules());
    }

    /**
     * @dev Function to get total AccessLevel withdrawal rules
     * @return Total number of access level withdrawal rules
     */
    function getAllAccessLevelWithdrawalRules() internal view returns (uint32) {
        RuleS.AccessLevelWithrawalRuleS storage data = Storage.accessLevelWithdrawalRuleStorage();
        return data.accessLevelWithdrawalRuleIndex;
    }
}
