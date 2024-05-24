// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "src/client/application/ProtocolApplicationHandler.sol";

/**
 * @title AppManager Contract
 * @notice This contract is the connector between the AppManagerRulesDiamond and the Application App Managers. It is maintained by the client application.
 * Deployment happens automatically when the AppManager is deployed.
 * @dev This contract is injected into the appManagerss.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ApplicationHandler is ProtocolApplicationHandler {
    /**
     * @dev Initializes the contract setting the owner as the one provided.
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress) ProtocolApplicationHandler(_ruleProcessorProxyAddress, _appManagerAddress) {}
}
