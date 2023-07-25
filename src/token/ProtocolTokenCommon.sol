// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "src/economic/AppAdministratorOnly.sol";
import {IApplicationEvents} from "../interfaces/IEvents.sol";
import {IZeroAddressError} from "../interfaces/IErrors.sol";

/**
 * @title Protocol Token Common Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Tokens
 */

contract ProtocolTokenCommon is AppAdministratorOnly, IApplicationEvents, IZeroAddressError {
    address public appManagerAddress;
    IAppManager appManager;

    /**
     * @dev Function to set the appManagerAddress and connect to the new appManager
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
    }
}
