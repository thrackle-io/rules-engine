// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/liquidity/ProtocolAMMHandler.sol";

/**
 * @title Example ApplicationAMMHandler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the rule checks related to the the AMM that implements it.
 * @notice Any rule checks may be updated by modifying this contract and redeploying.
 */

contract ApplicationAMMHandler is ProtocolAMMHandler {
    /**
     * @dev Constructor sets the App Manager and token rule router Address
     * @param _appManagerAddress App Manager Address
     * @param _ruleProcessorProxyAddress Rule Router Proxy Address
     * @param _assetAddress address of the congtrolling address
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */ 
     constructor(address _appManagerAddress, address _ruleProcessorProxyAddress, address _assetAddress, bool _upgradeMode) ProtocolAMMHandler(_appManagerAddress, _ruleProcessorProxyAddress, _assetAddress, _upgradeMode) {}
}
