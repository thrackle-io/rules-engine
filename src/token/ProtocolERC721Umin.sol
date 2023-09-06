// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./IProtocolERC721Handler.sol";
import "./ProtocolTokenCommonU.sol";

/**
 * @title ERC721 Upgradeable Protocol Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721Upgradeables
 */
contract ProtocolERC721Umin is Initializable, ERC721EnumerableUpgradeable, ProtocolTokenCommonU {
    address private handlerAddress;
    IProtocolERC721Handler private handler;
    /// memory placeholders to allow variable addition without affecting client upgradeability
    uint256[49] __gap;

    /**
     * @dev Initializer sets the the App Manager
     * @param _appManagerAddress Address of App Manager
     */
    function __ProtocolERC721_init(address _appManagerAddress) internal onlyInitializing {
        __ProtocolERC721_init_unchained(_appManagerAddress);
    }

    function __ProtocolERC721_init_unchained(address _appManagerAddress) internal onlyInitializing {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        emit NewNFTDeployed(address(this), _appManagerAddress);
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param tokenId Id of token to be transferred
     * @param batchSize the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will
     * represent the first id to start the batch.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual override {
        // Rule Processor Module Check
        require(handler.checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, batchSize, tokenId, ActionTypes.TRADE));
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolERC721Handler(handlerAddress);
        emit HandlerConnectedForUpgrade(_deployedHandlerAddress, address(this));
    }
}
