// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/utils/Context.sol";
import "../AppAdministratorOnly.sol";
import {RuleStoragePositionLib as Storage} from "./RuleStoragePositionLib.sol";
import {IFeeRules as Fee} from "./RuleDataInterfaces.sol";
import {IRuleStorage as RuleS} from "./IRuleStorage.sol";
import {IEconomicEvents} from "../../interfaces/IEvents.sol";
import "./RuleCodeData.sol";

/**
 * @title Fee Rules Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Contains the setters and getters for fee rules
 * @notice This contract sets and gets the Fee Rules for the protocol
 */
contract FeeRuleDataFacet is Context, AppAdministratorOnly, IEconomicEvents {
    error InputArraysMustHaveSameLength();
    error IndexOutOfRange();
    error ValueOutOfRange(uint256 percentage);
    error ZeroValueNotPermited();
    error PageOutOfRange();

    /************ AMM Fee Getters/Setters ***********/

    /**
     * @dev Function add an AMM Fee rule
     * @param _appManagerAddr Address of App Manager
     * @param _feePercentage percentage of collateralized token to be assessed for fees
     * @return ruleId position of rule in storage
     */
    function addAMMFeeRule(address _appManagerAddr, uint256 _feePercentage) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_feePercentage < 1 || _feePercentage > 10000) revert ValueOutOfRange(_feePercentage);
        RuleS.AMMFeeRuleS storage data = Storage.ammFeeRuleStorage();
        Fee.AMMFeeRule memory rule = Fee.AMMFeeRule(_feePercentage);
        uint32 ruleId = data.ammFeeRuleIndex;
        data.ammFeeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(AMM_FEE, ruleId, empty);
        ++data.ammFeeRuleIndex;
        return ruleId;
    }

    /**s
     * @dev Function get AMM Fee Rule by index
     * @param _index Position of rule in storage
     * @return AMMFeeRule at index
     */
    function getAMMFeeRule(uint32 _index) external view returns (Fee.AMMFeeRule memory) {
        RuleS.AMMFeeRuleS storage data = Storage.ammFeeRuleStorage();
        return data.ammFeeRules[_index];
    }

    /**
     * @dev Function get total AMM Fee rules
     * @return total ammFeeRules array length
     */
    function getTotalAMMFeeRules() external view returns (uint32) {
        RuleS.AMMFeeRuleS storage data = Storage.ammFeeRuleStorage();
        return data.ammFeeRuleIndex;
    }
}
