// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../src/token/ProtocolERC20Handler.sol";

/**
 * @title Example ApplicationERC20Handler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the rule checks related to the the ERC20 that implements it. This implementation is all that is needed
 * to deploy in order to gain all the rule functionality for a token
 * @notice Any rule checks may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.
 */
contract ApplicationAssetHandlerMod is ProtocolERC20Handler {
    /**
     * @dev Constructor sets params
     * @param _ruleProcessorProxyAddress of the protocol's TokenRuleRouter contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, bool _upgradeMode) ProtocolERC20Handler(_ruleProcessorProxyAddress, _appManagerAddress, _upgradeMode) {}

    /**
     * This function is used for testing the upgradability of the Handler contract.
     */
    function newTestFunction() public view returns (address) {
        return (address(this));
    }
}
