// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IApplicationEvents, ICommonApplicationHandlerEvents, ITokenHandlerEvents} from "src/common/IEvents.sol";
import {IInputErrors, ITagInputErrors, IOwnershipErrors, IZeroAddressError, IFeesErrors} from "src/common/IErrors.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import "./HandlerRuleContractsCommonImports.sol";
import {StorageLib as lib} from "../diamond/StorageLib.sol";
import "../diamond/RuleStorage.sol";

/**
 * @title Fees
 * @notice This contract serves as a storage for asset transfer fees
 * @dev This contract should not be accessed directly. All processing should go through its controlling asset(ProtocolERC20, ProtocolERC721, etc.)
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract Fees is IApplicationEvents, ITokenHandlerEvents, IInputErrors, ITagInputErrors, IOwnershipErrors, IZeroAddressError, IFeesErrors, RuleAdministratorOnly {
    bytes32 constant BLANK_TAG = bytes32("");

    /**
     * @dev This function adds a fee to the token. Blank tags are allowed
     * @param _tag meta data tag for fee
     * @param _minBalance minimum balance for fee application
     * @param _maxBalance maximum balance for fee application
     * @param _feePercentage fee percentage to assess
     * @param _targetAccount fee percentage to assess
     */
    function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
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
        // once fee is added to mapping, set the fee to active
        lib.feeStorage().feeActive = true;
        emit AD1467_FeeType(_tag, true, _minBalance, _maxBalance, _feePercentage, _targetAccount);
    }

    /**
     * @dev This function removes a fee to the token
     * @param _tag meta data tag for fee
     */
    function removeFee(bytes32 _tag) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        FeeS storage data = lib.feeStorage();
        // feePercentage must always not be 0 so it can be used to check rule existence
        if (data.feesByTag[_tag].feePercentage != 0) {
            delete (data.feesByTag[_tag]);
            emit AD1467_FeeType(_tag, false, 0, 0, 0, address(0));
            // if the fee existed, then decrement total
            data.feeTotal -= 1;
        }
    }

    /**
     * @dev returns the fee struct for the given tag
     * @param _tag meta data tag for fee
     * @return fee struct containing fee data
     */
    function getFee(bytes32 _tag) public view returns (Fee memory) {
        return lib.feeStorage().feesByTag[_tag];
    }

    /**
     * @dev returns the total number of fees
     * @return feeTotal total number of fees
     */
    function getFeeTotal() external view returns (uint256) {
        return lib.feeStorage().feeTotal;
    }

    /**
     * @dev Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
     * different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.
     * @param _from originating address
     * @param _balanceFrom Token balance of the sender address
     * @return feeSinks list of where the fees are sent
     * @return feePercentages list of all applicable fees/discounts
     */
    function getApplicableFees(address _from, uint256 _balanceFrom) public view returns (address[] memory feeSinks, int24[] memory feePercentages) {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        Fee memory fee;
        bytes32[] memory fromTags = IAppManager(handlerBaseStorage.appManager).getAllTags(_from);
        bytes32[] memory _fromTags;
        int24 totalFeePercent = 0;
        uint24 discount = 0;
        /// To insure that default fees are checked when they're set, add a blank tag to the tag list.
        if (getFee(BLANK_TAG).feePercentage > 0) {
            _fromTags = new bytes32[](fromTags.length + 1);
            for (uint i; i < fromTags.length; ++i) {
                _fromTags[i] = fromTags[i];
            }
            _fromTags[_fromTags.length - 1] = BLANK_TAG;
        } else {
            _fromTags = fromTags;
        }
        if (_fromTags.length != 0 && !IAppManager(handlerBaseStorage.appManager).isAppAdministrator(_from)) {
            uint feeCount = 0;
            // size the dynamic arrays by maximum possible fees
            feeSinks = new address[](_fromTags.length);
            feePercentages = new int24[](_fromTags.length);
            /// loop through and accumulate the fee percentages based on tags
            for (uint i; i < _fromTags.length; ++i) {
                fee = getFee(_fromTags[i]);
                // fee must be active and the initiating account must have an acceptable balance
                if (fee.feePercentage != 0 && _balanceFrom < fee.maxBalance && _balanceFrom > fee.minBalance) {
                    // if it's a discount, accumulate it for distribution among all applicable fees
                    if (fee.feePercentage < 0) {
                        discount = uint24((fee.feePercentage * -1)) + discount; // convert to uint
                    } else {
                        feePercentages[feeCount] = fee.feePercentage;
                        feeSinks[feeCount] = fee.feeSink;
                        // add to the total fee percentage
                        totalFeePercent += fee.feePercentage;
                        unchecked {
                            ++feeCount;
                        }
                    }
                }
            }
            /// if an applicable discount(s) was found, then distribute it among all the fees
            if (discount > 0 && feeCount != 0) {
                // if there are fees to discount then do so
                uint24 discountSlice = ((discount * 100) / (uint24(feeCount))) / 100;
                for (uint i; i < feeCount; ++i) {
                    // if discount is greater than fee, then set to zero
                    if (int24(discountSlice) > feePercentages[i]) {
                        feePercentages[i] = 0;
                    } else {
                        feePercentages[i] -= int24(discountSlice);
                    }
                }
            }
        }
        // if the total fees - discounts is greater than 100 percent, revert
        if (totalFeePercent - int24(discount) > 10000) {
            revert FeesAreGreaterThanTransactionAmount(_from);
        }
        return (feeSinks, feePercentages);
    }
}
