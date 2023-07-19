// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../token/ProtocolERC20Handler.sol";

/**
 * @title Example ApplicationERC20Handler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the rule checks related to the the ERC20 that implements it. This implementation is all that is needed
 * to deploy in order to gain all the rule functionality for a token
 * @notice Any rule checks may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.
 */
contract ApplicationERC20Handler is ProtocolERC20Handler {
    /**
     * @dev Constructor sets params
     * @param _ruleProcessorProxyAddress address of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _assetAddress address of the controlling asset.
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(
        address _ruleProcessorProxyAddress,
        address _appManagerAddress,
        address _assetAddress,
        bool _upgradeMode
    ) ProtocolERC20Handler(_ruleProcessorProxyAddress, _appManagerAddress, _assetAddress, _upgradeMode) {}
}
