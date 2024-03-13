// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../IProtocolTokenHandler.sol";
import "../../ProtocolTokenCommonU.sol";

/**
 * @title ERC721 Upgradeable Minimal Protocol Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721Upgradeable Minimals. 
 */
contract ProtocolERC721Umin is Initializable, ERC721EnumerableUpgradeable, ProtocolTokenCommonU, ReentrancyGuard {
    address private handlerAddress;
    IProtocolTokenHandler private handler;
    /// memory placeholders to allow variable addition without affecting client upgradeability
    // slither-disable-next-line shadowing-local
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
        emit AD1467_NewNFTDeployed(_appManagerAddress);
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param to recipient address
     * @param tokenId Id of token to be transferred
     * @param auth Auth argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     */
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        require(handler.checkAllRules(balanceOf(_msgSender()), to == address(0) ? 0 : balanceOf(to), _msgSender(), to, _msgSender(), tokenId));
        // Disabling this finding, it is a false positive. A reentrancy lock modifier has been 
        // applied to this function
        // slither-disable-next-line reentrancy-benign
        return ERC721EnumerableUpgradeable._update(to, tokenId, auth);
    }

    /**
     * @dev This function returns the handler address
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
        handler = IProtocolTokenHandler(handlerAddress);
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }
}
