// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IApplicationEvents, ICommonApplicationHandlerEvents, ITokenHandlerEvents} from "src/common/IEvents.sol";
import {IInputErrors, ITagInputErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import {StorageLib as lib} from "../diamond/StorageLib.sol";


struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}

struct FeeS{    
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}
    
bytes32 constant FEES_POSITION = bytes32(uint256(keccak256("fees-position")) - 1);

/**
 * @title Fees
 * @notice This contract serves as a storage for asset transfer fees
 * @dev This contract should not be accessed directly. All processing should go through its controlling asset(ProtocolERC20, ProtocolERC721, etc.)
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract Fees is IApplicationEvents, ITokenHandlerEvents, IInputErrors, ITagInputErrors, IOwnershipErrors, IZeroAddressError, AppAdministratorOnly {
    
    

    /**
     * @dev This function adds a fee to the token. Blank tags are allowed
     * @param _tag meta data tag for fee
     * @param _minBalance minimum balance for fee application
     * @param _maxBalance maximum balance for fee application
     * @param _feePercentage fee percentage to assess
     * @param _targetAccount fee percentage to assess
     */
    function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount) external appAdministratorOnly(lib.handlerBaseStorage().appManager) {
        if (_minBalance > _maxBalance) revert InvertedLimits();
        if (_feePercentage < -10000 || _feePercentage > 10000) revert ValueOutOfRange(uint24(_feePercentage));
        if (_feePercentage == 0) revert ZeroValueNotPermited();
        if (_targetAccount == address(0) && _feePercentage > 0) revert ZeroValueNotPermited();
        // if the fee did not already exist, then increment total
        FeeS storage data = lib.feeStorage();
        if (data.feesByTag[_tag].feePercentage == 0) {
            data.feeTotal += 1;
        }
        // if necessary, default the max balance
        if (_maxBalance == 0) _maxBalance = type(uint256).max;
        // add the fee to the mapping. If it already exists, it will replace the old one.
        data.feesByTag[_tag] = Fee(_minBalance, _maxBalance, _feePercentage, _targetAccount);
        emit FeeType(_tag, true, _minBalance, _maxBalance, _feePercentage, _targetAccount);
    }

    /**
     * @dev This function removes a fee to the token
     * @param _tag meta data tag for fee
     */
    function removeFee(bytes32 _tag) external appAdministratorOnly(lib.handlerBaseStorage().appManager) {
        FeeS storage data = lib.feeStorage();
        // feePercentage must always not be 0 so it can be used to check rule existence
        if (data.feesByTag[_tag].feePercentage != 0) {
            delete (data.feesByTag[_tag]);
            emit FeeType(_tag, false, 0, 0, 0, address(0));
            // if the fee existed, then decrement total
            data.feeTotal -= 1;
        }
    }

    /**
     * @dev returns the full mapping of fees
     * @param _tag meta data tag for fee
     * @return fee struct containing fee data
     */
    function getFee(bytes32 _tag) public view returns (Fee memory) {
        return lib.feeStorage().feesByTag[_tag];
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeTotal total number of fees
     */
    function getFeeTotal() external view returns (uint256) {
        return lib.feeStorage().feeTotal;
    }

}
