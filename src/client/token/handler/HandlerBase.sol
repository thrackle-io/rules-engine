// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Rule} from "./DataStructures.sol";
import {ActionTypes} from "../../../protocol/economic/ruleProcessor/ActionEnum.sol";
import "src/protocol/economic/AppAdministratorOrOwnerOnly.sol";
import {StorageLib as lib} from "./facets/StorageLib.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import {IAssetHandlerErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";

/**
 * @title Protocol Handler Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 */

 struct HandlerBaseS{
    address newAppManagerAddress;
    address appManagerAddress;
    address ruleProcessor;
    address appManager;
 }

bytes32 constant HANDLER_BASE_POSITION = bytes32(uint256(keccak256("handler-base-position")) - 1);

 contract HandlerBase is AppAdministratorOrOwnerOnly, ITokenHandlerEvents, IOwnershipErrors, IZeroAddressError{
    /// This is used to set the max action for an efficient check of all actions in the enum
    uint8 constant LAST_POSSIBLE_ACTION = uint8(ActionTypes.P2P_TRANSFER);
    uint16 constant MAX_ORACLE_RULES = 10;
    bytes32 constant BLANK_TAG = bytes32("");
    
    /**
     * @dev this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process
     * @param _newAppManagerAddress the new address being proposed
     */
    function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManagerAddress) {
        if (_newAppManagerAddress == address(0)) revert ZeroAddress();
        lib.handlerBaseStorage().newAppManagerAddress = _newAppManagerAddress;
        emit AppManagerAddressProposed(_newAppManagerAddress);
    }

    /**
     * @dev this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        HandlerBaseS storage data = lib.handlerBaseStorage();
        if (data.newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != data.newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        data.appManagerAddress = data.newAppManagerAddress;
        data.appManager = lib.handlerBaseStorage().appManagerAddress;
        delete data.newAppManagerAddress;
        emit AppManagerAddressSet(lib.handlerBaseStorage().appManagerAddress);
    }

    /**
     * @dev determines if a transfer is:
     *          mint
     *          burn
     *          sell
     *          purchase
     *          p2p transfer 
     * @param _from the address where the tokens are being moved from
     * @param _to the address where the tokens are going to
     * @param _sender the address triggering the transaction
     * @return action intended in the transfer
     */
    function determineTransferAction(address _from, address _to, address _sender) internal view returns (ActionTypes action){
        if(_from == address(0)){
            action = ActionTypes.MINT;
        } else if(_to == address(0)){
            action = ActionTypes.BURN;
        } else if(!(_sender == _from)){ 
            action = ActionTypes.SELL;
        } else if(isContract(_from)) {
            action = ActionTypes.BUY;
        }
    }  
    /**
     * @dev Check if the addresss is a contract
     * @param account address to check
     * @return contract yes/no
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }


 }