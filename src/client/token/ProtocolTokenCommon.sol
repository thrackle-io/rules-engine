// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/protocol/economic/AppAdministratorOnly.sol";
import {IApplicationEvents} from "src/common/IEvents.sol";
import {IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";

/**
 * @title Protocol Token Common Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Tokens
 */

abstract contract ProtocolTokenCommon is AppAdministratorOnly, IApplicationEvents, IZeroAddressError, IOwnershipErrors {
    address newAppManagerAddress;
    address appManagerAddress;
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
     * @dev This function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        if (newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        appManagerAddress = newAppManagerAddress;
        appManager = IAppManager(appManagerAddress);
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

}
