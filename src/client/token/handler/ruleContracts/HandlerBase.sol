// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import {StorageLib as lib} from "../diamond/StorageLib.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import {IAssetHandlerErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import "../common/AppAdministratorOrOwnerOnlyForDiamond.sol";

/**
 * @title Protocol Handler Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 */

 struct HandlerBaseS{
    address newAppManagerAddress;
    address ruleProcessor;
    address appManager;
 }

bytes32 constant HANDLER_BASE_POSITION = bytes32(uint256(keccak256("handler-base-position")) - 1);

 contract HandlerBase is AppAdministratorOrOwnerOnlyForDiamond, ITokenHandlerEvents, IOwnershipErrors, IZeroAddressError{
    /// This is used to set the max action for an efficient check of all actions in the enum
    uint8 constant LAST_POSSIBLE_ACTION = uint8(ActionTypes.P2P_TRANSFER);
    uint16 constant MAX_ORACLE_RULES = 10;
    bytes32 constant BLANK_TAG = bytes32("");
    
    /**
     * @dev this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process
     * @param _newAppManagerAddress the new address being proposed
     */
    function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager) {
        if (_newAppManagerAddress == address(0)) revert ZeroAddress();
        lib.handlerBaseStorage().newAppManagerAddress = _newAppManagerAddress;
        emit AppManagerAddressProposed(_newAppManagerAddress);
    }

    /**
     * @dev this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        HandlerBaseS storage data = lib.handlerBaseStorage();
        if (data.newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != data.newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        data.appManager = data.newAppManagerAddress;
        data.appManager = lib.handlerBaseStorage().appManager;
        delete data.newAppManagerAddress;
        emit AppManagerAddressSet(lib.handlerBaseStorage().appManager);
    }

 }