// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAppManager} from "src/client/application/IAppManager.sol";
import "src/client/token/handler/common/RBACModifiersCommonImports.sol";

/**
 * @title Application Administrators Only Modifier Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev appAdministratorOnly modifier encapsulated for easy imports.
 */
contract AppAdministratorOnly is RBACModifiersCommonImports {
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
