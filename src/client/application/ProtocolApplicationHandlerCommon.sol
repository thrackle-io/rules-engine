// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "src/common/ActionEnum.sol";
import "src/client/token/HandlerTypeEnum.sol";
import {IInputErrors} from "src/common/IErrors.sol";

/**
 * @title ProtocolApplicationHandlerCommon
 * @dev This contains common functions for the protocol application handler
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @notice This contract is the permissions contract
 */
abstract contract ProtocolApplicationHandlerCommon is IInputErrors{

    uint8 constant lastPossibleAction = 4;

    /**
     * @dev Validate the full atomic rule setter function parameters
     * @notice The actions and ruleIds lists must be the same length and at least one action must be present
     * @param _actions list of applicable actions
     * @param _ruleIds list of ruleIds for each action
     */
    function validateRuleInputFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) internal pure {
        if(_actions.length == 0) revert InputArraysSizesNotValid();
        if(_actions.length != _ruleIds.length) revert InputArraysMustHaveSameLength();
    }
}
