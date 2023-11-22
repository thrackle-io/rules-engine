// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {Line, LineInput, Curve} from "./libraries/Curve.sol";
import {CurveErrors} from "../../interfaces/IErrors.sol";

/**
 * @title Automated Market Maker Swap Linear Calculator for NFT Pools
 * @dev This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
 *      as needed. It contains an example linear. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolNFTAMMCalcLinear is IProtocolAMMFactoryCalculator, CurveErrors {

    using Curve for Line;

    uint8 constant PRECISION_DECIMALS = 8;
    uint256 constant ATTO = 10 ** 18;
    uint256 constant Y_MAX = 1_000_000_000_000_000_000_000_000 * ATTO;
    uint256 constant M_MAX = 1_000_000_000_000_000_000_000_000 * 10 ** PRECISION_DECIMALS;
    Line public buyCurve;
    Line public sellCurve;

    /**
    * @dev constructor
    * @param _buyCurve the definition of the buyCurve
    * @param _sellCurve the definition of the sellCurve
    * @param _appManagerAddress the address of the appManager
    */
    constructor(LineInput memory _buyCurve, LineInput memory _sellCurve, address _appManagerAddress) {
            // validation block
            if (_appManagerAddress == address(0)) revert ZeroAddress();
            _validateSingleCurve(_buyCurve);
            _validateSingleCurve(_sellCurve);
            _validateCurvePair(_buyCurve, _sellCurve);

            // setting variables
            buyCurve.fromInput(_buyCurve, PRECISION_DECIMALS);
            sellCurve.fromInput(_sellCurve, PRECISION_DECIMALS);
            appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev This performs the swap from ERC20s to NFTs. It is a linear calculation.
     * @param _reserve0 not used in this case.
     * @param _q tracker of amount of NFTs released by the pool
     * @param _amountERC20 amount of ERC20 coming out of the pool
     * @param _amountNFT amount of token1 coming out of the pool
     * @return price
     */
    function calculateSwap(uint256 _reserve0, uint256 _q, uint256 _amountERC20, uint256 _amountNFT) external view override returns (uint256 price) {
        _reserve0;
        if (_amountERC20 == 0 && _amountNFT == 0) {
            revert AmountsAreZero();
        }
        // user is trying to SELL an NFT to get ERC20s in return
        if (_amountERC20 != 0) {
            // we validate against overflow
            if (_q < 1) revert ValueOutOfRange(_q);
            // we then calculate the price
            price = sellCurve.getY(_q - 1);
        // user is trying to BUY an NFT in exchange for ERC20s
        } else {
            // we enforce the 1-NFT-per-swap rule
            if (_amountNFT > 1) revert ValueOutOfRange(_amountNFT);
            // we then calculate the price
            price = buyCurve.getY(_q);
        }
    }

    /**
    * @dev sets the buyCurve
    * @param _buyCurve the definition of the new buyCurve
    */
    function setBuyCurve(LineInput memory _buyCurve) external appAdministratorOnly(appManagerAddress){
        _validateSingleCurve(_buyCurve);
        _validateCurvePair(_buyCurve, sellCurve);
        buyCurve.fromInput(_buyCurve, PRECISION_DECIMALS);
    }

    /**
    * @dev sets the sellCurve
    * @param _sellCurve the definition of the new sellCurve
    */
    function setSellCurve(LineInput memory _sellCurve) external appAdministratorOnly(appManagerAddress){
        _validateSingleCurve(_sellCurve);
        _validateCurvePair(buyCurve, _sellCurve);
        sellCurve.fromInput(_sellCurve, PRECISION_DECIMALS);
    }

    /// #### Validation Functions ####
    /**
    * @dev validates that the definition of a curve is within the save mathematical limits
    * @param curve the definition of the curve
    */
    function _validateSingleCurve(LineInput memory curve) internal pure {
        if (curve.m > M_MAX) revert ValueOutOfRange(curve.m);
        if (curve.b > Y_MAX) revert ValueOutOfRange(curve.b);
    }

    /**
    * @dev validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve, 
    * that they don't intersect, and that they tend to diverge.
    * @notice this is an overloaded function. In this case, both parameters are of the LineInput type
    * @param _buyCurve the definition of the buyCurve input
    * @param _sellCurve the definition of the sellCurve input
    */
     function _validateCurvePair(LineInput memory _buyCurve, LineInput memory _sellCurve) internal pure {
        if(_buyCurve.m <= _sellCurve.m) revert CurvesInvertedOrIntersecting(); 
        if(_buyCurve.b <= _sellCurve.b) revert CurvesInvertedOrIntersecting(); 
    }

    /**
    * @dev validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve, 
    * that they don't intersect, and that they tend to diverge.
    * @notice this is an overloaded function. In this case, the buyCurve is of the LineInput type while the sellCurve
    * is of the Line type
    * @param _buyCurve the definition of the buyCurve stored in the contract
    * @param _sellCurve the definition of the sellCurve input
    */
    function _validateCurvePair(LineInput memory _buyCurve, Line memory _sellCurve) internal pure {
        if(_buyCurve.m * (_sellCurve.m_den / PRECISION_DECIMALS) <= _sellCurve.m_num) revert CurvesInvertedOrIntersecting(); 
        if( _buyCurve.b <= _sellCurve.b) revert CurvesInvertedOrIntersecting(); 
    }

    /**
    * @dev validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve, 
    * that they don't intersect, and that they tend to diverge.
    * @notice this is an overloaded function. In this case, the buyCurve is of the Line type while the sellCurve
    * is of the LineInput type
    * @param _buyCurve the definition of the buyCurve input
    * @param _sellCurve the definition of the sellCurve stored in the contract
    */
    function _validateCurvePair(Line memory _buyCurve, LineInput memory _sellCurve) internal pure {
        if(_buyCurve.m_num <= _sellCurve.m * (_buyCurve.m_den / PRECISION_DECIMALS))  revert CurvesInvertedOrIntersecting(); 
        if(_buyCurve.b <= _sellCurve.b) revert CurvesInvertedOrIntersecting(); 
    }

  
}
