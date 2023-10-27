// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {IApplicationEvents} from "../../interfaces/IEvents.sol";
import {IZeroAddressError} from "../../interfaces/IErrors.sol";
import "../ProtocolTokenCommon.sol";
import "./ProtocolERC1155Handler.sol";
import "../../economic/AppAdministratorOnly.sol";

/**
 * @title ERC1155 Base Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC1155's
 */
contract ProtocolERC1155 is ERC1155Burnable, Pausable, ProtocolTokenCommon {
    // address of the Handler
    ProtocolERC1155Handler handler;
    event Log(string _type, string _text, uint256 _value);

    /**
     * @dev Constructor sets name and symbol for the ERC1155 token and makes connections to the protocol.
     * @param _url metadata url
     * @param _appManagerAddress address of app manager contract
     * _upgradeMode is also passed to Handler contract to deploy a new data contract with the handler.
     */
    constructor(string memory _url, address _appManagerAddress) ERC1155(_url) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);

        emit NewTokenDeployed(address(this), _appManagerAddress);
    }

    /**
     * @dev pauses the contract. Only whenPaused modified functions will work once called.
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function pause() public virtual appAdministratorOnly(appManagerAddress) {
        _pause();
    }

    /**
     * @dev Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function unpause() public virtual appAdministratorOnly(appManagerAddress) {
        _unpause();
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param operator address of an account/contract that is approved to make the transfer
     * @param from sender address
     * @param to recipient address
     * @param ids tokenIds to transfer
     * @param amounts number of each tokenId to be transferred
     * @param data Additional data with no specified format
     */
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal override whenNotPaused {
        /// Rule Processor Module Check
        /// retrieve all the balances for each token
        uint256[] memory balanceFrom = new uint256[](ids.length);
        uint256[] memory balanceTo = new uint256[](ids.length);
        // For simplicity sake, not doing rule checks for burns or mints
        if (from != address(0) && to != address(0)) {
            // add up all the amounts and balances
            for (uint i = 0; i < ids.length; ) {
                balanceFrom[i] = balanceOf(from, ids[i]);
                balanceTo[i] = balanceOf(to, ids[i]);
                unchecked {
                    i++;
                }
            }
            require(handler.checkAllRules(balanceFrom, balanceTo, from, to, ids, amounts, ActionTypes.TRADE));
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _handlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _handlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_handlerAddress == address(0)) revert ZeroAddress();
        handler = ProtocolERC1155Handler(_handlerAddress);
        emit HandlerConnected(_handlerAddress, address(this));
    }

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override returns (address) {
        return address(handler);
    }
}
