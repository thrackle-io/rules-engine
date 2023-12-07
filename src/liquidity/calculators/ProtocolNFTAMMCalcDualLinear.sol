// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {LinearWholeB, LinearInput, Curve} from "./libraries/Curve.sol";
import {CurveErrors} from "../../interfaces/IErrors.sol";

/**
 * @title Automated Market Maker Swap Linear Calculator for NFT Pools
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed. It contains an example linear. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolNFTAMMCalcDualLinear is IProtocolAMMFactoryCalculator, CurveErrors {

    using Curve for LinearWholeB;

    uint256 constant M_PRECISION_DECIMALS = 8;
    uint256 constant ATTO = 10 ** 18;
    uint256 constant Y_MAX = 1_000_000_000_000_000_000_000_000 * ATTO;
    uint256 constant M_MAX = 1_000_000_000_000_000_000_000_000 * 10 ** M_PRECISION_DECIMALS;
    LinearWholeB public buyCurve;
    LinearWholeB public sellCurve;

    /**
    * @dev tracks how many NFTs have been put in circulation by the AMM.
    * If the AMM has sold 10 NFTs and then "bought" back 7, then the value of q will be 3.
    * @notice that q is a unit, which means we are assuming that the AMM is the ONLY source of NFTs.
    * In other words, q = ERC721Contract.totalSupply() - ERC721Contract.balanceOf(AMM_ADDRESS).
    */
    uint256 public q;

    /**
    * @dev constructor
    * @param _buyCurve the definition of the buyCurve
    * @param _sellCurve the definition of the sellCurve
    * @param _appManagerAddress the address of the appManager
    */
    constructor(LinearInput memory _buyCurve, LinearInput memory _sellCurve, address _appManagerAddress) {
            // validation block
            if (_appManagerAddress == address(0)) revert ZeroAddress();
            _validateSingleCurve(_buyCurve);
            _validateSingleCurve(_sellCurve);
            _validateCurvePair(_buyCurve, _sellCurve);

            // setting variables
            buyCurve.fromInput(_buyCurve, M_PRECISION_DECIMALS);
            sellCurve.fromInput(_sellCurve, M_PRECISION_DECIMALS);
            appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev This performs the swap from ERC20s to NFTs. It is a linear calculation.
     * @param _reserve0 not used in this case.
     * @param _reserve1 not used in this case.
     * @param _amountERC20 amount of ERC20 coming out of the pool
     * @param _amountNFT amount of NFTs coming out of the pool (restricted to 1 for now)
     * @return price
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amountERC20, uint256 _amountNFT) external override returns (uint256 price) {
        _reserve0;
        _reserve1;
        if (_amountERC20 == 0 && _amountNFT == 0) revert AmountsAreZero();
        
        price =  simulateSwap( _reserve0,  _reserve1,  _amountERC20,  _amountNFT);
        _amountERC20 == 0 ? ++q : --q ;
    }

    /**
     * @dev This performs the swap from ERC20s to NFTs. It is a linear calculation.
     * @param _reserve0 not used in this case.
     * @param _reserve1 not used in this case.
     * @param _amountERC20 amount of ERC20 coming out of the pool
     * @param _amountNFT amount of NFTs coming out of the pool (restricted to 1 for now)
     * @return price
     */
    function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amountERC20, uint256 _amountNFT) public view override returns (uint256 price) {
        _reserve0;
        _reserve1;
        if (_amountERC20 == 0)  
            price = _calculateBuy(_amountNFT);
        else 
            price = _calculateSell();
    }

    /**
     * @dev sets the value of q
     * @param _q the new value of q.
     * @notice only AppAdministrators can perform this operation
     */
    function set_q(uint256 _q) external appAdministratorOnly(appManagerAddress){
        q = _q;
    }

    /**
     * @dev calculates the price for a buy with current q
     * @param _amountNFT the amount of NFTs coming out of the pool in the transaction
     */
    function _calculateBuy(uint256 _amountNFT) internal view returns (uint256 price) {
        // we enforce the 1-NFT-per-swap rule
        if (_amountNFT > 1) revert ValueOutOfRange(_amountNFT);
        price = buyCurve.getY(q);
    }

    /**
     * @dev calculates the price for a sell with current q
     */
    function _calculateSell() internal view returns (uint256 price) {
        // we validate against overflow
        if (q < 1) revert ValueOutOfRange(q);
        price = sellCurve.getY(q - 1);
    }

    /**
    * @dev sets the buyCurve
    * @param _buyCurve the definition of the new buyCurve
    */
    function setBuyCurve(LinearInput memory _buyCurve) external appAdministratorOnly(appManagerAddress){
        _validateSingleCurve(_buyCurve);
        _validateCurvePair(_buyCurve, sellCurve);
        buyCurve.fromInput(_buyCurve, M_PRECISION_DECIMALS);
    }

    /**
    * @dev sets the sellCurve
    * @param _sellCurve the definition of the new sellCurve
    */
    function setSellCurve(LinearInput memory _sellCurve) external appAdministratorOnly(appManagerAddress){
        _validateSingleCurve(_sellCurve);
        _validateCurvePair(buyCurve, _sellCurve);
        sellCurve.fromInput(_sellCurve, M_PRECISION_DECIMALS);
    }

    /// #### Validation Functions ####
    /**
    * @dev validates that the definition of a curve is within the safe mathematical limits
    * @param curve the definition of the curve
    */
    function _validateSingleCurve(LinearInput memory curve) internal pure {
        if (curve.m > M_MAX) revert ValueOutOfRange(curve.m);
        if (curve.b > Y_MAX) revert ValueOutOfRange(curve.b);
    }

    /**
    * @dev validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve, 
    * that they don't intersect, and that they tend to diverge.
    * @notice this is an overloaded function. In this case, both parameters are of the LinearInput type
    * @param _buyCurve the definition of the buyCurve input
    * @param _sellCurve the definition of the sellCurve input
    */
     function _validateCurvePair(LinearInput memory _buyCurve, LinearInput memory _sellCurve) internal pure {
        if(_buyCurve.m < _sellCurve.m) revert CurvesInvertedOrIntersecting(); 
        if(_buyCurve.b < _sellCurve.b) revert CurvesInvertedOrIntersecting(); 
    }

    /**
    * @dev validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve, 
    * that they don't intersect, and that they tend to diverge.
    * @notice this is an overloaded function. In this case, the buyCurve is of the LinearInput type while the sellCurve
    * is of the Line type
    * @param _buyCurve the definition of the buyCurve stored in the contract
    * @param _sellCurve the definition of the sellCurve input
    */
    function _validateCurvePair(LinearInput memory _buyCurve, LinearWholeB memory _sellCurve) internal pure {
        if(_buyCurve.m * (_sellCurve.m_den / (10 ** M_PRECISION_DECIMALS)) < _sellCurve.m_num) revert CurvesInvertedOrIntersecting(); 
        if( _buyCurve.b < _sellCurve.b) revert CurvesInvertedOrIntersecting(); 
    }

    /**
    * @dev validates that, on the positive side of the abscissa axis on the plane, the buyCurve is above the sellCurve, 
    * that they don't intersect, and that they tend to diverge.
    * @notice this is an overloaded function. In this case, the buyCurve is of the Line type while the sellCurve
    * is of the LinearInput type
    * @param _buyCurve the definition of the buyCurve input
    * @param _sellCurve the definition of the sellCurve stored in the contract
    */
    function _validateCurvePair(LinearWholeB memory _buyCurve, LinearInput memory _sellCurve) internal pure {
        if(_buyCurve.m_num < _sellCurve.m * (_buyCurve.m_den / (10 ** M_PRECISION_DECIMALS)))  revert CurvesInvertedOrIntersecting(); 
        if(_buyCurve.b < _sellCurve.b) revert CurvesInvertedOrIntersecting(); 
    }

  
}
