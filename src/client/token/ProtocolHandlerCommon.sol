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
import "src/client/token/data/Fees.sol";

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
    AppAdministratorOrOwnerOnly,
    RuleAdministratorOnly
{
    string private constant VERSION="1.1.0";
    address private newAppManagerAddress;
    address public appManagerAddress;
    IRuleProcessor ruleProcessor;
    IAppManager appManager;    
    bytes32 constant BLANK_TAG = bytes32("");
    /// Data contracts
    Fees fees;
    bool feeActive;
    /// All rule references
    struct Rule {
        uint32 ruleId;
        bool active;
    }
    /// This is used to set the max action for an efficient check of all actions in the enum
    uint8 constant LAST_POSSIBLE_ACTION = uint8(ActionTypes.P2P_TRANSFER);
    uint16 constant MAX_ORACLE_RULES = 10;

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
     * @dev Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
     * different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.
     * @param _from originating address
     * @param _balanceFrom Token balance of the sender address
     * @return feeCollectorAccounts list of where the fees are sent
     * @return feePercentages list of all applicable fees/discounts
     */
    function getApplicableFees(address _from, uint256 _balanceFrom) public view returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages) {
        Fees.Fee memory fee;
        int24 totalFeePercent;
        uint24 discount;
        bytes32[] memory _fromTags;
        // Only adjust the tags if a default fee exists in order to save gas
        if (fees.getFee(BLANK_TAG).feePercentage != 0){
            _fromTags = _getTagsWithDefault(_from);
        } else {
            _fromTags = appManager.getAllTags(_from);
        }
        if (_fromTags.length != 0 && !appManager.isAppAdministrator(_from)) {
            uint feeCount;
            // size the dynamic arrays by maximum possible fees
            feeCollectorAccounts = new address[](_fromTags.length);
            feePercentages = new int24[](_fromTags.length);
            /// loop through and accumulate the fee percentages based on tags
            for (uint i; i < _fromTags.length; ) {
                fee = fees.getFee(_fromTags[i]);
                // fee must be active and the initiating account must have an acceptable balance
                if (fee.feePercentage != 0 && _balanceFrom < fee.maxBalance && _balanceFrom >= fee.minBalance) {
                    // if it's a discount, accumulate it for distribution among all applicable fees
                    if (fee.feePercentage < 0) {
                        discount = uint24((fee.feePercentage * -1)) + discount; // convert to uint
                    } else {
                        feePercentages[feeCount] = fee.feePercentage;
                        feeCollectorAccounts[feeCount] = fee.feeCollectorAccount;
                        // add to the total fee percentage
                        totalFeePercent += fee.feePercentage;
                        unchecked {
                            ++feeCount;
                        }
                    }
                }
                unchecked {
                    ++i;
                }
            }
            /// if an applicable discount(s) was found, then distribute it among all the fees
            if (discount > 0 && feeCount != 0) {
                // if there are fees to discount then do so
                uint24 discountSlice = ((discount * 100) / (uint24(feeCount))) / 100;
                for (uint i; i < feeCount; ) {
                    // if discount is greater than fee, then set to zero
                    if (int24(discountSlice) > feePercentages[i]) {
                        feePercentages[i] = 0;
                    } else {
                        feePercentages[i] -= int24(discountSlice);
                    }
                    unchecked {
                        ++i;
                    }
                }
            }
        }
        // if the total fees - discounts is greater than 100 percent, revert
        if (totalFeePercent - int24(discount) > 10000) {
            revert FeesAreGreaterThanTransactionAmount(_from);
        }
        return (feeCollectorAccounts, feePercentages);
    }

    /**
     * @dev Get all tags for a user and append blank tag for the default fee to work
     * @param _from originating address
     * @return _tags adjusted tag list
     */
    function _getTagsWithDefault(address _from) internal view returns(bytes32[] memory _tags){
        bytes32[] memory _fromTags = appManager.getAllTags(_from);
        // create an array one element longer
        _tags = new bytes32[](_fromTags.length+1);
        // copy the array to larger one
        for (uint i; i < _fromTags.length; ) {
            _tags[i] = _fromTags[i];
            unchecked {
                ++i;
            }
        }
        // append blank tag
        _tags[_fromTags.length] = BLANK_TAG;
    }

    /* <><><><><><><><><><><> Fee functions <><><><><><><><><><><><><><> */
    /**
     * @dev This function adds a fee to the token
     * @param _tag meta data tag for fee
     * @param _minBalance minimum balance for fee application
     * @param _maxBalance maximum balance for fee application
     * @param _feePercentage fee percentage to assess
     * @param _targetAccount target for the fee proceeds
     */
    function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount) external ruleAdministratorOnly(appManagerAddress) {
        fees.addFee(_tag, _minBalance, _maxBalance, _feePercentage, _targetAccount);
        feeActive = true;
    }

    /**
     * @dev This function removes a fee to the token
     * @param _tag meta data tag for fee
     */
    function removeFee(bytes32 _tag) external ruleAdministratorOnly(appManagerAddress) {
        fees.removeFee(_tag);
    }

    /**
     * @dev returns the full mapping of fees
     * @param _tag meta data tag for fee
     * @return fee struct containing fee data
     */
    function getFee(bytes32 _tag) external view returns (Fees.Fee memory) {
        return fees.getFee(_tag);
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeTotal total number of fees
     */
    function getFeeTotal() public view returns (uint256) {
        return fees.getFeeTotal();
    }

    /**
     * @dev Turn fees on/off
     * @param on_off value for fee status
     */
    function setFeeActivation(bool on_off) external ruleAdministratorOnly(appManagerAddress) {
        feeActive = on_off;
        emit FeeActivationSet(on_off);
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeActive fee activation status
     */
    function isFeeActive() external view returns (bool) {
        return feeActive;
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
