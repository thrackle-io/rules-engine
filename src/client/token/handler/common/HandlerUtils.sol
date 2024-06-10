// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ActionTypes} from "src/common/ActionEnum.sol";

contract HandlerUtils{
    event Action(uint8 _type);

    /**
    * @dev determines if a transfer is:
    * p2p transfer
    * buy
    * sell
    * mint
    * burn
    * @notice p2p transfer is position 0 and will be default unless other conditions are met.
    * @param _from the address where the tokens are being moved from
    * @param _to the address where the tokens are going to
    * @param _sender the address triggering the transaction
    * @return action intended in the transfer
    */
    function determineTransferAction(address _from, address _to, address _sender) internal returns (ActionTypes action){
        if(_from == address(0)){
            action = ActionTypes.MINT;
            emit Action(uint8(ActionTypes.MINT));
        } else if(_to == address(0)){
            action = ActionTypes.BURN;
            emit Action(uint8(ActionTypes.BURN));
        } else if(isContract(_sender) ){
            if (tx.origin == _from) {
                action = ActionTypes.SELL;
                emit Action(uint8(ActionTypes.SELL));
            } else {
                action = ActionTypes.BUY;
                emit Action(uint8(ActionTypes.BUY));
            } 
        } else {
            // action = ActionTypes.P2P_TRANSFER; default is 0
            emit Action(uint8(ActionTypes.P2P_TRANSFER));
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