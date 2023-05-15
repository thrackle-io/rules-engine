// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./IDataModule.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IAppManager} from "../application/IAppManager.sol";

/**
 * @title Data Module
 * @notice This contract serves as a template for all data modules.
 * @dev Allows for proper permissioning for both internal and external data sources.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract DataModule is IDataModule, Ownable {
    ///Data Module
    address public dataModuleAppManagerAddress;

    /**
     * @dev Modifier ensures function caller is a Application Administrators or the parent contract
     */
    modifier appAdminstratorOrOwnerOnly() {
        if (dataModuleAppManagerAddress == address(0)) revert AppManagerNotConnected();
        IAppManager appManager = IAppManager(dataModuleAppManagerAddress);

        if (!appManager.isAppAdministrator(_msgSender()) && owner() != _msgSender()) revert NotAppAdministratorOrOwner();
        _;
    }

    function setAppManagerAddress(address _appManagerAddress) external appAdminstratorOrOwnerOnly {
        dataModuleAppManagerAddress = _appManagerAddress;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferDataOwnership(address newOwner) public appAdminstratorOrOwnerOnly {
        transferOwnership(newOwner);
    }
}
