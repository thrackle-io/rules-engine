// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

// import "./IAppAdministratorOrOwnerOnly.sol";
import {IAppManager} from "src/client/application/IAppManager.sol";
import {ERC173Lib} from "diamond-std/implementations/ERC173/ERC173Lib.sol";
import "diamond-std/implementations/ERC173/ERC173.sol";
import "src/client/token/handler/common/FacetUtils.sol";
import "src/client/token/handler/common/RBACModifiersCommonImports.sol";

/**
 * @title App Admin or Owner Permission module
 * @dev Allows for proper permissioning parent/child contract relationships so that owner and app admins may have permission.
 * @notice This contract relies on an ERC173 facet already deployed in the diamond.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract AppAdministratorOrOwnerOnlyDiamondVersion is ERC173, RBACModifiersCommonImports, FacetUtils {

    
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

        if (!appManager.isAppAdministrator(_msgSender()) && ERC173Lib.s().owner != _msgSender()) revert NotAppAdministratorOrOwner();
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner The address to receive ownership
     * @param appManagerAddress address of the app manager for permission check
     * Can only be called by the current owner.
     */
    function transferPermissionOwnership(address newOwner, address appManagerAddress) internal {
        _appAdministratorOrOwnerOnly(appManagerAddress);
        callAnotherFacet(0xf2fde38b, abi.encodeWithSignature("transferOwnership(address)", newOwner));
    }
}
