// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title Application NFT Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an example for how to implement the ProtocolERC721Handler. All ERC721 rules are set up through this contract
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */
import "../../src/token/ProtocolERC721Handler.sol";

contract ApplicationERC721HandlerMod is ProtocolERC721Handler {
    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _ruleProcessorProxyAddress of Rule processor Proxy
     * @param _appManagerAddress Address of App Manager
     * @param _assetAddress Address of the controlling address
     * @param _upgradeMode specifies whether this is a fresh Handler or an upgrade replacement.
     */
    constructor(
        address _ruleProcessorProxyAddress,
        address _appManagerAddress,
        address _assetAddress,
        bool _upgradeMode
    ) ProtocolERC721Handler(_ruleProcessorProxyAddress, _appManagerAddress, _assetAddress, _upgradeMode) {}

    /**
     * This function is used for testing the upgradability of the Handler contract.
     */
    function newTestFunction() public view returns (address) {
        return (address(this));
    }
}
