// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import {IApplicationEvents} from "../../interfaces/IEvents.sol";
import {IInputErrors, ITagInputErrors, IOwnershipErrors, IZeroAddressError} from "../../interfaces/IErrors.sol";
import "../../economic/AppAdministratorOnly.sol";

/**
 * @title Fees
 * @notice This contract serves as a storage for asset transfer fees
 * @dev This contract should not be accessed directly. All processing should go through its controlling asset(ProtocolERC20, ProtocolERC721, etc.)
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract Fees is Ownable, IApplicationEvents, IInputErrors, ITagInputErrors, IOwnershipErrors, IZeroAddressError, AppAdministratorOnly {
    string private constant VERSION="0.0.6";
    int256 defaultFee;
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    address newOwner; // This is used for data contract migration
    struct Fee {
        uint256 minBalance;
        uint256 maxBalance;
        int24 feePercentage;
        address feeCollectorAccount;
        bool isValue; // this is just for housekeeping purposes
    }

    /**
     * @dev This function adds a fee to the token
     * @param _tag meta data tag for fee
     * @param _minBalance minimum balance for fee application
     * @param _maxBalance maximum balance for fee application
     * @param _feePercentage fee percentage to assess
     * @param _targetAccount fee percentage to assess
     */
    function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount) external onlyOwner {
        if (_minBalance > _maxBalance) revert InvertedLimits();
        if (_feePercentage < -10000 || _feePercentage > 10000) revert ValueOutOfRange(uint24(_feePercentage));
        if (_tag == "") revert BlankTag();
        if (_feePercentage == 0) revert ZeroValueNotPermited();
        if (_targetAccount == address(0) && _feePercentage > 0) revert ZeroValueNotPermited();
        // if the fee did not already exist, then increment total
        if (!feesByTag[_tag].isValue) {
            feeTotal += 1;
        }
        // if necessary, default the max balance
        if (_maxBalance == 0) _maxBalance = type(uint256).max;
        // add the fee to the mapping. If it already exists, it will replace the old one.
        feesByTag[_tag] = Fee(_minBalance, _maxBalance, _feePercentage, _targetAccount, true);
        emit FeeTypeAdded(_tag, _minBalance, _maxBalance, _feePercentage, _targetAccount, block.timestamp);
    }

    /**
     * @dev This function removes a fee to the token
     * @param _tag meta data tag for fee
     */
    function removeFee(bytes32 _tag) external onlyOwner {
        if (_tag == "") revert BlankTag();
        if (feesByTag[_tag].isValue) {
            delete (feesByTag[_tag]);
            emit FeeTypeRemoved(_tag, block.timestamp);
            // if the fee existed, then decrement total
            if (feeTotal > 0) {
                feeTotal -= 1;
            }
        }
    }

    /**
     * @dev returns the full mapping of fees
     * @param _tag meta data tag for fee
     * @return fee struct containing fee data
     */
    function getFee(bytes32 _tag) public view onlyOwner returns (Fee memory) {
        return feesByTag[_tag];
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeTotal total number of fees
     */
    function getFeeTotal() external view onlyOwner returns (uint256) {
        return feeTotal;
    }

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }

    /**
     * @dev this function proposes a new owner that is put in storage to be confirmed in a separate process
     * @param _newOwner the new address being proposed
     */
    function proposeOwner(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert ZeroAddress();
        newOwner = _newOwner;
    }

    /**
     * @dev this function confirms a new asset handler address that was put in storage. It can only be confirmed by the proposed address
     */
    function confirmOwner() external {
        if (newOwner == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != newOwner) revert ConfirmerDoesNotMatchProposedAddress();
        _transferOwnership(newOwner);
    }
}
