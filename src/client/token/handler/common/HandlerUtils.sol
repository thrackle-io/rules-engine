// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ActionTypes} from "src/common/ActionEnum.sol";

contract HandlerUtils{

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