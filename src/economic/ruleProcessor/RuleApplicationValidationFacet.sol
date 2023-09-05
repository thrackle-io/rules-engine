// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {FeeRuleDataFacet} from "../ruleStorage/FeeRuleDataFacet.sol";
import {TaggedRuleDataFacet} from "../ruleStorage/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "../ruleStorage/RuleDataFacet.sol";
import {AppRuleDataFacet} from "../ruleStorage/AppRuleDataFacet.sol";
import {IFeeRules as Fee, ITaggedRules as TaggedRules, INonTaggedRules as NonTaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";
import "../ruleStorage/RuleStorageCommonLib.sol";
import "../../data/PauseRule.sol";
import "../../application/IAppManager.sol";
import "forge-std/console.sol";

/**
 * @title Fee Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check fee rule compliance
 * @notice Implements Token Fee Rules on Accounts.
 */
contract RuleApplicationValidationFacet {
    using RuleStorageCommonLib for uint32;

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAMMFee(uint32 _ruleId) external view {
        FeeRuleDataFacet data = FeeRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalAMMFeeRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTransactionLimitByRiskScore(uint32 _ruleId) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalTransactionLimitByRiskRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinMaxAccountBalanceERC721(uint32 _ruleId) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalBalanceLimitRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateNFTTransferCounter(uint32 _ruleId) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalNFTTransferCounterRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinMaxAccountBalance(uint32 _ruleId) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalBalanceLimitRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validatePurchaseLimit(uint32 _ruleId) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalPurchaseRule());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSellLimit(uint32 _ruleId) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalSellRule());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAdminWithdrawal(uint32 _ruleId) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalAdminWithdrawalRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinBalByDate(uint32 _ruleId) external view {
        TaggedRuleDataFacet data = TaggedRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalMinBalByDateRule());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMinTransfer(uint32 _ruleId) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        console.log("validateMinBalByDate _ruleId", _ruleId);
        console.log("getTotalMinimumTransferRules", data.getTotalMinimumTransferRules());
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalMinimumTransferRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateOracle(uint32 _ruleId) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalOracleRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validatePurchasePercentage(uint32 _ruleId) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalPctPurchaseRule());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSellPercentage(uint32 _ruleId) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalPctSellRule());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateTokenTransferVolume(uint32 _ruleId) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalTransferVolumeRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateSupplyVolatility(uint32 _ruleId) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalSupplyVolatilityRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateAccBalanceByRisk(uint32 _ruleId) external view {
        AppRuleDataFacet data = AppRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalAccountBalanceByRiskScoreRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateMaxTxSizePerPeriodByRisk(uint32 _ruleId) external view {
        AppRuleDataFacet data = AppRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalMaxTxSizePerPeriodRules());
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
        AppRuleDataFacet data = AppRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalAccessLevelBalanceRules());
    }

    /**
     * @dev Validate the existence of the rule
     * @param _ruleId Rule Identifier
     */
    function validateWithdrawalLimitsByAccessLevel(uint32 _ruleId) external view {
        AppRuleDataFacet data = AppRuleDataFacet(Diamond.ruleDataStorage().rules);
        // Check to make sure the rule exists within rule storage
        _ruleId.checkRuleExistence(data.getTotalAccessLevelWithdrawalRules());
    }
}
