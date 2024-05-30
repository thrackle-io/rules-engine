// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//import "src/client/token/ERC20/upgradeable/IProtocolERC20UMin.sol";  <---- These two are essentially the same interface, I think we can move forward just using IProtocolTokenMin instead of having to use IProtocolERC20UMin
import "src/client/token/IProtocolTokenMin.sol";                   //  <----
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import "src/client/token/ProtocolTokenCommonU.sol";


/**
 * @title ERC20 Upgradeable Minimal Protocol Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4
 * @notice This is the base contract for all protocol ERC721Upgradeable Minimals. 
 */
contract ProtocolERC20UMin is Initializable, ERC20Upgradeable, ProtocolTokenCommonU, ReentrancyGuard, IProtocolTokenMin{
    address private handlerAddress;
    IProtocolTokenHandler private handler;
    /// memory placeholders to allow variable addition without affecting client upgradeability
    // slither-disable-next-line shadowing-local
    uint256[49] __gap;

    /**
     * @dev Initializer sets the the App Manager
     * @param _appManagerAddress Address of App Manager
     */
    function __ProtocolERC20_init(address _appManagerAddress) internal onlyInitializing {
        __ProtocolERC20_init_unchained(_appManagerAddress);
    }

    function __ProtocolERC20_init_unchained(address _appManagerAddress) internal onlyInitializing {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        emit AD1467_NewTokenDeployed(_appManagerAddress);
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param amount number of tokens to be transferred
     */
    // slither-disable-next-line calls-loop
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        /// Rule Processor Module Check
        require(handler.checkAllRules(balanceOf(from), balanceOf(to), from, to, _msgSender(), amount));
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external override appAdministratorOnly(appManagerAddress) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolTokenHandler(handlerAddress);
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }
}
