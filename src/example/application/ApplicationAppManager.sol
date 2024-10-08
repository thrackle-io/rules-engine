// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;

import {AppManager} from "src/client/application/AppManager.sol";

/**
 * @title Application specific app manager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs can use.
 * @dev During deployment _ownerAddress = First Application Administrators set in constructor
 */
contract ApplicationAppManager is AppManager {
    /**
     * @dev Constructor sets the owner address, application name, and upgrade mode at deployment
     * @param _ownerAddress Address of deployer wallet
     * @param _appName Application Name String
     * @param upgradeMode specifies whether this is a fresh AppManager or an upgrade replacement.
     */
    constructor(address _ownerAddress, string memory _appName, bool upgradeMode) AppManager(_ownerAddress, _appName, upgradeMode) {}
}
