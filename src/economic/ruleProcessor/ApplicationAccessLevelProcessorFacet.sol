// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RuleProcessorDiamondLib as processorDiamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {AppRuleDataFacet} from "./AppRuleDataFacet.sol";
import {RuleStoragePositionLib as Storage} from "./RuleStoragePositionLib.sol";
import {IRuleStorage as RuleS} from "./IRuleStorage.sol";
import {IApplicationRules as Application} from "./RuleDataInterfaces.sol";
import {IInputErrors, IRuleProcessorErrors, IAccessLevelErrors} from "../../interfaces/IErrors.sol";
import "./RuleProcessorCommonLib.sol"; 

/**
 * @title AccessLevel Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract implements rules to be checked by Handler.
 * @notice Implements AccessLevel Rule Checks. AccessLevel rules are measured in
 * in terms of USD with 18 decimals of precision.
 */
contract ApplicationAccessLevelProcessorFacet is IInputErrors, IRuleProcessorErrors, IAccessLevelErrors {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8; 
    
    /**
     * @dev Check if transaction passes Balance by AccessLevel rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param _accessLevel the Access Level of the account
     * @param _balance account's beginning balance in USD with 18 decimals of precision
     * @param _amountToTransfer total USD amount to be transferred with 18 decimals of precision
     */
    function checkAccBalanceByAccessLevel(uint32 _ruleId, uint8 _accessLevel, uint128 _balance, uint128 _amountToTransfer) external view {
        /// Get the account's AccessLevel
        if (getTotalAccessLevelBalanceRules() != 0) {
            uint48 max = getAccessLevelBalanceRule(_ruleId, _accessLevel);
            /// max has to be multiplied by 10 ** 18 to take decimals in token pricing into account
            if (_amountToTransfer + _balance > (uint256(max) * (10 ** 18))) revert BalanceExceedsAccessLevelAllowedLimit();
        }
    }

    /**
     * @dev Function to get the AccessLevel Balance rule in the rule set that belongs to the Access Level
     * @param _index position of rule in array
     * @param _accessLevel AccessLevel Level to check
     * @return balanceAmount balance allowed for access levellevel
     */
    function getAccessLevelBalanceRule(uint32 _index, uint8 _accessLevel) public view returns (uint48) {
        RuleS.AccessLevelRuleS storage data = Storage.accessStorage();
        if (_index >= data.accessRuleIndex) revert IndexOutOfRange();
        return data.accessRulesPerToken[_index][_accessLevel];
    }

    /**
     * @dev Function to get total AccessLevel Balance rules
     * @return Total length of array
     */
    function getTotalAccessLevelBalanceRules() public view returns (uint32) {
        RuleS.AccessLevelRuleS storage data = Storage.accessStorage();
        return data.accessRuleIndex;
    }

    /**
     * @dev Check if transaction passes Withdrawal by AccessLevel rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param _accessLevel the Access Level of the account
     * @param _usdWithdrawalTotal account's total amount withdrawn in USD with 18 decimals of precision
     * @param _usdAmountTransferring total USD amount to be transferred with 18 decimals of precision
     */
    function checkwithdrawalLimitsByAccessLevel(uint32 _ruleId, uint8 _accessLevel, uint128 _usdWithdrawalTotal, uint128 _usdAmountTransferring) external view returns (uint128) {
        uint48 max = getAccessLevelWithdrawalRules(_ruleId, _accessLevel);
        /// max has to be multiplied by 10 ** 18 to take decimals in token pricing into account
       if (_usdAmountTransferring + _usdWithdrawalTotal > (uint256(max) * (10 ** 18))) revert WithdrawalExceedsAccessLevelAllowedLimit();
        else _usdWithdrawalTotal += _usdAmountTransferring;
        return _usdWithdrawalTotal;
    }
    
    /**
     * @dev Function to get the Access Level Withdrawal rule in the rule set that belongs to the Access Level
     * @param _index position of rule in array
     * @param _accessLevel AccessLevel Level to check
     * @return balanceAmount balance allowed for access levellevel
     */
    function getAccessLevelWithdrawalRules(uint32 _index, uint8 _accessLevel) public view returns (uint48) {
        RuleS.AccessLevelWithrawalRuleS storage data = Storage.accessLevelWithdrawalRuleStorage();
        if (_index >= data.accessLevelWithdrawalRuleIndex) revert IndexOutOfRange();
        return data.accessLevelWithdrawal[_index][_accessLevel];
    }

    /**
     * @dev Function to get total AccessLevel withdrawal rules
     * @return Total number of access level withdrawal rules
     */
    function getTotalAccessLevelWithdrawalRule() external view returns (uint32) {
        RuleS.AccessLevelWithrawalRuleS storage data = Storage.accessLevelWithdrawalRuleStorage();
        return data.accessLevelWithdrawalRuleIndex;
    }

    /**
     * @dev Check if transaction passes AccessLevel 0 rule.This has no stored rule as there are no additional variables needed.
     * @param _accessLevel the Access Level of the account
     */
    function checkAccessLevel0Passes(uint8 _accessLevel) external pure {
        if (_accessLevel == 0) {
            revert NotAllowedForAccessLevel();
        }
    }
}
