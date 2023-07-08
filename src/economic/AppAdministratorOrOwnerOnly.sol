// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// import "./IAppAdministratorOrOwnerOnly.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IAppManager} from "../application/IAppManager.sol";
import { IAppAdministratorOnlyErrors } from "../interfaces/IErrors.sol";

/**
 * @title App Admin or Owner Permission module
 * @notice This contract performs permission controls where admin or owner permissions are required.
 * @dev Allows for proper permissioning parent/child contract relationships so that owner and app admins may have permission.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract AppAdministratorOrOwnerOnly is Ownable, IAppAdministratorOnlyErrors {
    /**
     * @dev Modifier ensures function caller is a Application Administrators or the parent contract
     */
    modifier appAdministratorOrOwnerOnly(address _permissionModuleAppManagerAddress) {
        _appAdministratorOrOwnerOnly(_permissionModuleAppManagerAddress);
        _;
    }

    function _appAdministratorOrOwnerOnly(address _permissionModuleAppManagerAddress) private view {
        if (_permissionModuleAppManagerAddress == address(0)) revert AppManagerNotConnected();
        IAppManager appManager = IAppManager(_permissionModuleAppManagerAddress);

        if (!appManager.isAppAdministrator(_msgSender()) && owner() != _msgSender()) revert NotAppAdministratorOrOwner();
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner The address to receive ownership
     * @param appManagerAddress address of the app manager for permission check
     * Can only be called by the current owner.
     */
    function transferPermissionOwnership(address newOwner, address appManagerAddress) internal {
        _appAdministratorOrOwnerOnly(appManagerAddress);
        transferOwnership(newOwner);
    }
}
