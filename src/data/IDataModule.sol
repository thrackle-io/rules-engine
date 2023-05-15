// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IAppLevelEvents} from "../interfaces/IEvents.sol";

/**
 * @title Data Module
 * @notice This contract serves as a template for all data modules.
 * @dev Allows for proper permissioning for both internal and external data sources.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IDataModule is IAppLevelEvents {
    ///Data Module
    error AppManagerNotConnected();
    error NotAppAdministratorOrOwner();

    function setAppManagerAddress(address _appManagerAddress) external;

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferDataOwnership(address newOwner) external;
}
