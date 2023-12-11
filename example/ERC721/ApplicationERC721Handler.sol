// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title Application NFT Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an example for how to implement the ProtocolERC721Handler. All ERC721 rules are set up through this contract
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */
import "src/client/token/ERC721//ProtocolERC721Handler.sol";

contract ApplicationERC721Handler is ProtocolERC721Handler {
    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _ruleProcessorProxyAddress Address of Token Rule Router Proxy
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
}
