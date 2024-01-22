// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "src/client/token/ERC20/IERC20Decimals.sol";
import "src/protocol/economic/ruleProcessor/RuleCodeData.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "src/client/application/IAppManager.sol";
import "src/protocol/economic/AppAdministratorOrOwnerOnly.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import "src/client/application/IAppManagerUser.sol";
import "./IAdminWithdrawalRuleCapable.sol";
import "./IProtocolTokenHandler.sol";
import "src/client/token/IAdminWithdrawalRuleCapable.sol";
import "src/client/token/HandlerTypeEnum.sol";
import "src/client/token/ITokenInterface.sol";
import {IAssetHandlerErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";

/**
 * @title Protocol Handler Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 */

abstract contract ProtocolHandlerCommon is 
    IAppManagerUser, 
    IOwnershipErrors, 
    IZeroAddressError, 
    ITokenHandlerEvents, 
    ICommonApplicationHandlerEvents, 
    IAssetHandlerErrors,  
    AppAdministratorOrOwnerOnly
{
    string private constant VERSION="1.1.0";
    address private newAppManagerAddress;
    address public appManagerAddress;
    IRuleProcessor ruleProcessor;
    IAppManager appManager;
    /// All rule references
    struct Rule {
        uint32 ruleId;
        bool active;
    }
    /// This is used to set the max action for an efficient check of all actions in the enum
    uint8 constant LAST_POSSIBLE_ACTION = uint8(ActionTypes.P2P_TRANSFER);
    uint16 constant MAX_ORACLE_RULES = 10;
    bytes32 constant BLANK_TAG = bytes32("");
    


    /**
     * @dev this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process
     * @param _newAppManagerAddress the new address being proposed
     */
    function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_newAppManagerAddress == address(0)) revert ZeroAddress();
        newAppManagerAddress = _newAppManagerAddress;
        emit AppManagerAddressProposed(_newAppManagerAddress);
    }

    /**
     * @dev this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        if (newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        appManagerAddress = newAppManagerAddress;
        appManager = IAppManager(appManagerAddress);
        delete newAppManagerAddress;
        emit AppManagerAddressSet(appManagerAddress);
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
        action = ActionTypes.P2P_TRANSFER;
        if(_from == address(0) && _to != address(0)){
            action = ActionTypes.MINT;
        } else if(_to == address(0) && _from != address(0)){
            action = ActionTypes.BURN;
        } else if(!(_sender == _from)){ 
            action = ActionTypes.SELL;
        } else if(!isContract(_from) && !isContract(_to)){
            action = ActionTypes.P2P_TRANSFER;
        } else if(isContract(_from)) {
            action = ActionTypes.PURCHASE;
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

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}
