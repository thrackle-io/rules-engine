// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/protocol/economic/AppAdministratorOnly.sol";
import {IApplicationEvents, IIntegrationEvents} from "src/common/IEvents.sol";
import {IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";

/**
 * @title Protocol Token Common Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Tokens
 */

abstract contract ProtocolTokenCommon is AppAdministratorOnly, IApplicationEvents, IZeroAddressError, IOwnershipErrors, IIntegrationEvents {
    address newAppManagerAddress;
    address appManagerAddress;
    address public handlerAddress;
    IAppManager appManager;

    /**
     * @dev This function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process
     * @param _newAppManagerAddress the new address being proposed
     */
    function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_newAppManagerAddress == address(0)) revert ZeroAddress();
        newAppManagerAddress = _newAppManagerAddress;
    }

    /**
     * @dev This function confirms a new appManagerAddress that was put in storage. It can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        if (newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        appManagerAddress = newAppManagerAddress;
        appManager = IAppManager(appManagerAddress);
        emit AD1467_AppManagerAddressSet(newAppManagerAddress);
        delete newAppManagerAddress;
    }

    /**
     * @dev Function to get the appManagerAddress
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function getAppManagerAddress() external view returns (address) {
        return appManagerAddress;
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view virtual returns (address);

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external virtual appAdministratorOnly(appManagerAddress) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }

}
