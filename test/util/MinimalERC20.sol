// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import "src/client/token/ProtocolTokenCommon.sol";
import "src/client/token/handler/diamond/ERC20HandlerMainFacet.sol";

/**
 * @title Minimal ERC20 Protocol Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract MinimalERC20 is ERC20, ProtocolTokenCommon, ERC20Burnable {
    IProtocolTokenHandler _handler;

    constructor(string memory _name, string memory _symbol, address _appManagerAddress) ERC20(_name, _symbol) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
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
        require(ERC20HandlerMainFacet(address(_handler)).checkAllRules(balanceOf(from), balanceOf(to), from, to, _msgSender(), amount));
        super._beforeTokenTransfer(from, to, amount);
    }

        /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _handlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _handlerAddress) external override(ProtocolTokenCommon) appAdministratorOnly(appManagerAddress) {
        if (_handlerAddress == address(0)) revert ZeroAddress();
        _handler = IProtocolTokenHandler(_handlerAddress);
        emit AD1467_HandlerConnected(_handlerAddress, address(this));
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override(ProtocolTokenCommon) returns (address) {
        return address(address(_handler));
    }

        /**
     * @dev Function mints new tokens.
     * @param to recipient address
     * @param amount number of tokens to mint
     */
    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }
}