// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../../src/liquidity/ProtocolAMMHandler.sol";

/**
 * @title Example ApplicationAMMHandler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the rule checks related to the the AMM that implements it.
 * @notice Any rule checks may be updated by modifying this contract and redeploying.
 */

contract ApplicationAMMHandlerMod is ProtocolAMMHandler {
    /**
     * @dev Constructor sets the App Manager and token rule router Address
     * @param _appManagerAddress App Manager Address
     * @param _tokenRuleRouterAddress Token Rule Router Proxy Address
     * @param _assetAddress address of the controlling asset
     */
    constructor(address _appManagerAddress, address _tokenRuleRouterAddress, address _assetAddress) ProtocolAMMHandler(_appManagerAddress, _tokenRuleRouterAddress, _assetAddress) {}

    /**
     * This function is used for testing the upgradability of the Handler contract.
     */
    function newTestFunction() public view returns (address) {
        return (address(this));
    }
}
