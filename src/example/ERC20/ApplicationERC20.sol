// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "src/client/token/IProtocolToken.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import {IZeroAddressError} from "src/common/IErrors.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _tokenAdmin are set in constructor
 */
contract ApplicationERC20 is ERC20, AccessControl, IProtocolToken, IZeroAddressError {

    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    address private handlerAddress;
    IProtocolTokenHandler private handler;

    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol Symbol of the token
     * @param _tokenAdmin Token Manager address
     */
     // slither-disable-next-line shadowing-local
    constructor(string memory _name, string memory _symbol, address _tokenAdmin) ERC20(_name, _symbol) {
        _grantRole(TOKEN_ADMIN_ROLE, _tokenAdmin);
    }

    /**
     * @dev Function mints new tokens. 
     * @param to recipient address
     * @param amount number of tokens to mint
     */
    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
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
        require(IProtocolTokenHandler(handlerAddress).checkAllRules(balanceOf(from), balanceOf(to), from, to, _msgSender(), amount));
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
    function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolTokenHandler(handlerAddress);
        emit HandlerConnected(_deployedHandlerAddress, address(this));
    }
}
