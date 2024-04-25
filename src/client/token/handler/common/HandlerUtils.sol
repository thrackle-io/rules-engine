// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ActionTypes} from "src/common/ActionEnum.sol";
import {ISmartContractAccount4337, UserOperation} from "src/common/ISmartContractAccount4337.sol";

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
        } else if(!(_sender == _from)){ 
            action = ActionTypes.SELL;
            emit Action(uint8(ActionTypes.SELL));
        } else if(_isContract(_from) && !_isSmartContractAccount(_from)) {
            action = ActionTypes.BUY;
            emit Action(uint8(ActionTypes.BUY));
        } else {
            emit Action(uint8(ActionTypes.P2P_TRANSFER));
        }
    } 

    /**
     * @dev Check if the addresss is a contract
     * @param account address to check
     * @return contract yes/no
     */
    function _isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.
        return account.code.length > 0;
    }

    // effectively a view but due to the compiler and _hasUserOpValidation technically being able to modify state we need to mark as state changing
    function _isSmartContractAccount(address account) internal returns (bool) {
        // try majority way
        try ISmartContractAccount4337(account).entryPoint() returns (address entryPoint) {
            return correctEntryPointAndHasUserOpValidation(entryPoint, account);
        } catch {
            // try Gnosis way
            try ISmartContractAccount4337(account).SUPPORTED_ENTRYPOINT() returns (address entryPoint) {
                return correctEntryPointAndHasUserOpValidation(entryPoint, account);
            } catch {
                // try zerodev way
                try ISmartContractAccount4337(account).entrypoint() returns (address entryPoint) {
                    return correctEntryPointAndHasUserOpValidation(entryPoint, account);
                } catch {
                    // return false if it doesn't have any of the entrypoints
                    return false;
                }
            }
        }
    }

    function correctEntryPointAndHasUserOpValidation(address entryPoint, address account) private returns (bool) {
        return entryPoint == address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789) && _hasUserOpValidation(account);
    }

    function _hasUserOpValidation(address account) private returns (bool) {
        // dummy value
        UserOperation memory userOp = UserOperation({
            sender: account,
            nonce: 0,
            initCode: "",
            callData: "",
            accountGasLimits: "",
            preVerificationGas: 0,
            gasFees: "",
            paymasterAndData: "",
            signature: ""
        });
        // we expect this to fail but we want it to fail a custom error or require string reasoning to determine if it has validateUserOp
        try ISmartContractAccount4337(account).validateUserOp(userOp, keccak256(abi.encode(userOp)), 0) returns (uint256) {
            // should not reach here
            revert();
        } catch Error(string memory) {
            // catch failing revert() and require()
            return true;
        } catch (bytes memory reason) {
            // If the reason is not 0x then it's failing with a custom error message and thus it has validateUserOp
            return (reason.length != 0);
        }
    }
}