// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../RuleAdministratorOnly.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../AppAdministratorOnly.sol";
import {RuleStoragePositionLib as Storage} from "./RuleStoragePositionLib.sol";
import {IFeeRules as Fee} from "./RuleDataInterfaces.sol";
import {IRuleStorage as RuleS} from "./IRuleStorage.sol";
import {IEconomicEvents} from "../../interfaces/IEvents.sol";
import {IInputErrors} from "../../interfaces/IErrors.sol";
import "./RuleCodeData.sol";

/**
 * @title Fee Rules Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Contains the setters and getters for fee rules
 * @notice This contract sets and gets the Fee Rules for the protocol
 */
contract FeeRuleDataFacet is Context, RuleAdministratorOnly, IEconomicEvents, IInputErrors {
    uint16 constant MAX_PERCENTAGE = 10000;

    /************ AMM Fee Getters/Setters ***********/

    /**
     * @dev Function add an AMM Fee rule
     * @param _appManagerAddr Address of App Manager
     * @param _feePercentage percentage of collateralized token to be assessed for fees
     * @return ruleId position of rule in storage
     */
    function addAMMFeeRule(address _appManagerAddr, uint256 _feePercentage) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_feePercentage < 1 || _feePercentage > MAX_PERCENTAGE) revert ValueOutOfRange(_feePercentage);
        RuleS.AMMFeeRuleS storage data = Storage.ammFeeRuleStorage();
        Fee.AMMFeeRule memory rule = Fee.AMMFeeRule(_feePercentage);
        uint32 ruleId = data.ammFeeRuleIndex;
        data.ammFeeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(AMM_FEE, ruleId, empty);
        ++data.ammFeeRuleIndex;
        return ruleId;
    }

}
