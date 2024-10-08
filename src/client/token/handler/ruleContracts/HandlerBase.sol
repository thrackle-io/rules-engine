// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "src/client/token/handler/ruleContracts/HandlerRuleContractsCommonImports.sol";
import {IAssetHandlerErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import "src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol";
import "src/client/token/handler/ruleContracts/Fees.sol";


/**
 * @title Protocol Handler Base Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 */


 contract HandlerBase is IZeroAddressError, ITokenHandlerEvents, IOwnershipErrors, AppAdministratorOrOwnerOnlyDiamondVersion{
    
    uint16 constant MAX_ORACLE_RULES = 10;
    
    /**
     * @dev this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process
     * @param _newAppManagerAddress the new address being proposed
     */
    function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager) {
        if (_newAppManagerAddress == address(0)) revert ZeroAddress();
        lib.handlerBaseStorage().newAppManagerAddress = _newAppManagerAddress;
        emit AD1467_AppManagerAddressProposed(_newAppManagerAddress);
    }

    /**
     * @dev this function confirms a new appManagerAddress that was put in storage. It can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        HandlerBaseS storage data = lib.handlerBaseStorage();
        if (data.newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != data.newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        data.appManager = data.newAppManagerAddress;
        delete data.newAppManagerAddress;
        emit AD1467_AppManagerAddressSet(lib.handlerBaseStorage().appManager);
    }

    /**
     * @dev Set the last possible action for use in action validations.
     * @param _lastPossibleAction the highest number in the Action Enum
     */
    function setLastPossibleAction(uint8 _lastPossibleAction) external appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager){
        lib.handlerBaseStorage().lastPossibleAction = _lastPossibleAction;
    }

    
 }