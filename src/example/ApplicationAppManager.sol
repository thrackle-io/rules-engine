// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../application/AppManager.sol";

/**
 * @title Application specific app manager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs can use.
 * @dev During deployment _ownerAddress = First Application Administrators set in constructor
 */
contract ApplicationAppManager is AppManager {
    /**
     * @dev constructor sets the owner address, application name, and upgrade mode at deployment
     * @param _ownerAddress Address of deployer wallet
     * @param _appName Application Name String
     * @param _ruleProcessorProxyAddress of the Protocol's rule processor
     * @param upgradeMode specifies whether this is a fresh AppManager or an upgrade replacement.
     */
    constructor(address _ownerAddress, string memory _appName, address _ruleProcessorProxyAddress, bool upgradeMode) AppManager(_ownerAddress, _appName, _ruleProcessorProxyAddress, upgradeMode) {}
}
