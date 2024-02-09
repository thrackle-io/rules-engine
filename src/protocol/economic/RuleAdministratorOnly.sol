// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAppManager} from "src/client/application/IAppManager.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {IPermissionModifierErrors} from "src/common/IErrors.sol";

/**
 * @title Rule Administrators Only Modifier Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev ruleAdministratorOnly modifier encapsulated for easy imports.
 */
contract RuleAdministratorOnly is Context, IPermissionModifierErrors {
    /**
     * @dev Modifier ensures function caller is a App Admin
     * @param _appManagerAddr Address of App Manager
     */
    modifier ruleAdministratorOnly(address _appManagerAddr) {
        if (_appManagerAddr == address(0)) revert AppManagerNotConnected();

        IAppManager appManager = IAppManager(_appManagerAddr);

        if (!appManager.isRuleAdministrator(_msgSender())) revert NotRuleAdministrator();
        _;
    }
}
