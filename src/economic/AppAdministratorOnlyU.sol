// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAppManager} from "../application/IAppManager.sol";
import {IPermissionModifierErrors} from "../interfaces/IErrors.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

/**
 * @title Application Administrators Only Modifier Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev appAdministratorOnly modifier encapsulated for easy imports.
 */
contract AppAdministratorOnlyU is ContextUpgradeable, IPermissionModifierErrors {
    /**
     * @dev Modifier ensures function caller is a App Admin
     * @param _appManagerAddr Address of App Manager
     */
    modifier appAdministratorOnly(address _appManagerAddr) {
        if (_appManagerAddr == address(0)) revert AppManagerNotConnected();

        IAppManager appManager = IAppManager(_appManagerAddr);

        if (!appManager.isAppAdministrator(_msgSender())) revert NotAppAdministrator();
        _;
    }
}
