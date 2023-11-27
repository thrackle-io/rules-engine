/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/liquidity/ProtocolAMM.sol";
import "src/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/liquidity/calculators/ProtocolAMMCalcCP.sol";
import "src/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/helpers/TestCommonFoundry.sol";
import {LineInput} from "../../src/liquidity/calculators/dataStructures/CurveDataStructures.sol";
import "../../src/liquidity/calculators/ProtocolNFTAMMCalcDualLinear.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../helpers/Utils.sol";

/**
 * @title Test all AMM Calculator Factory related functions
 * @notice This tests every function related to the AMM Calculator Factory including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolNFTAMMFactoryFuzzTest is TestCommonFoundry, Utils {

    event Log(bytes data);
    event Tens(uint);
    event Units(uint);
    event PythonPrice(uint);
    event IsFormatted(bool);
    event Price(uint);
    event Diff(uint);
    event IsAscii(bool);
    event Passed();

    error OutOfTolerance(uint256 _contractPrice, uint256 _pythonPrice); // 0x700e344e

    using Strings for uint256;
    uint256 constant PRECISION_DECIMALS = 8;
    uint256 constant ATTO = 10 ** 18;
    uint256 constant Y_MAX = 1_000_000_000_000_000_000_000_000 * ATTO;
    uint256 constant M_MAX = 1_000_000_000_000_000_000_000_000 * 10 ** PRECISION_DECIMALS;
    uint8 constant MAX_TOLERANCE = 5;
    uint8 constant TOLERANCE_PRECISION = 11;
    uint256 constant TOLERANCE_DEN = 10 ** TOLERANCE_PRECISION;
    //// tolerance percentage = ((MAX_TOLERANCE * 100) / TOLERANCE_DEN) %;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        protocolAMMFactory = createProtocolAMMFactory();
        switchToAppAdministrator();
    }

    /**
    * This test is entirely centered on the math of the Dual Linear NFT AMM.
    */
    function testFuzzNFTAMMCalculatorMathDualLinear(uint256 mBuy, uint256 bBuy, uint256 mSell, uint256 bSell, uint88 q, bool isSale ) public {
        /// we make sure that variables are within the bounderies to avoid unintended reverts
        mBuy = mBuy%M_MAX;
        bBuy = bBuy%Y_MAX;
        mSell = mSell%M_MAX;
        bSell = bSell%Y_MAX;

        /// we make sure the curves comply with the premises mB > mS, and bB > bS.
        if(mSell >= mBuy){
            if(mBuy == 0) mBuy = 1;
            mSell = mBuy - 1;
        }
        if(bSell >= bBuy){
            if(bBuy == 0) bBuy = 1;
            bSell = bBuy - 1;
        }
         
        /// we create the factory
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        
        /// we create the buy and line curves with the fuzz variables
        LineInput memory buy = LineInput(mBuy, bBuy);
        LineInput memory sell = LineInput(mSell, bSell);

        /// we create the actual calculator with these curves
        ProtocolNFTAMMCalcDualLinear calc = ProtocolNFTAMMCalcDualLinear(
                                                protocolAMMCalculatorFactory.
                                                    createDualLinearNFT(
                                                        buy, 
                                                        sell, 
                                                        address(applicationAppManager)
                                                    )
                                                );

        /// the price that will be returned by the calculator
        uint256 price;
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;

        /// we carry out the swap depending if it is a sale or a purchase
        if(isSale){
            /// we make sure q is at least 1 to avoid underflow (only for the sale case)
            if( q < 1) q = 1;
            /// we calculate the price through the calculator and store it in *price*
            price = calc.calculateSwap(0, q, 1, 0); //(reserves0, q, ERC20s out, NFTs out)

            /// we then call the Python script to calculate the price "offchain" and store it in *res*
            string[] memory inputs = _buildFFILinearCalculator(sell, "8", q - 1); // sel always is q-1
            res = vm.ffi(inputs);
        } 
        else{
            /// we calculate the price through the calculator and store it in *price*
            price = calc.calculateSwap(0, q, 0, 1); //(reserves0, q, ERC20s out, NFTs out)

            /// we then call the Python script to calculate the price "offchain" and store it in *res*
            string[] memory inputs = _buildFFILinearCalculator(buy, "8", q);
            res = vm.ffi(inputs); 
        }
        
        /// some debug logging 
        emit Log(res);
        emit Price(price);

        /// we determine if the response was returned as a possible ascii or a decimal
        bool isAscii = isPossiblyAnAscii(res);
        emit IsAscii(isAscii);
        
        /// if it is a possible ascii, then we decode it and check if the difference is within tolerance
        if(isAscii){
            _checkPriceAsAsciiWithinTolerance(price, res);
        }
        /// if the response was not an ascii.
        else{
            /// we decode the fake decimal and check if the difference is within tolerance
            _checkPriceAsFakeDecimalWithinTolerance(price, res);
        }
        /// if the check above did not revert, then the test passed
        emit Passed();
    }

    /**
    * @dev creates the input array specifically for the linear_calculator.py script.
    * @param lineInput the lineIput struct that defines the curve function ƒ.
    * @param decimals the amount of decimals of precision for *m*.
    * @param q in this case, the value of x to solve ƒ(x).
    */
    function _buildFFILinearCalculator(LineInput memory lineInput, string memory decimals, uint88 q) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](7);
        inputs[0] = "python3";
        inputs[1] = "script/python/linear_calculator.py"; 
        inputs[2] = lineInput.m.toString();
        inputs[3] = decimals; 
        inputs[4] = lineInput.b.toString();
        inputs[5] = uint256(q).toString();
        inputs[6] = "1"; /// y formatted in atto
        return inputs;
    }

    /**
    * @dev compares a uint with an ascii encoded uint to check if they are within tolerance. 
    * i.e. The encoded value: 0x31303030 is actually the number 1000 in the decimal system.
    * The tolerance parameters are global to the contract.
    * @notice this function will attempt a comparison with *res* as a fake decimal if
    * the initial comparison results with a difference greater than the tolerance.
    * This is because it is impossible to know with total certainty if a number is written as
    * an ascii or a fake decimal. This function will ultimately revert in the case of a final
    * difference above tolerance.
    * @param price the price from the calculator contract
    * @param res the response from the Python script
    */
    function _checkPriceAsAsciiWithinTolerance(uint256 price, bytes memory res) internal pure {

        /// we decode the ascii into a uint
        uint resUint = decodeAsciiUint(res);

        if(!_areWithinTolerance(price, resUint)){
            /// if it is above tolerance, it is possible that we thought *res* was an ascii, but it was not.
            /// we compare the numbers again, but now as decimals, to see if they are within the tolerance
            _checkPriceAsFakeDecimalWithinTolerance(price, res);
        }
    }

    /**
    * @dev compares if a uint is similar enough to an encoded uint. 
    * i.e. The encoded value: 0x23456 is actually decimal 23456 and not hex 0x23456 which is 144470
    * The tolerance parameters are global to the contract.
    * @notice this function will revert in the case of a difference above tolerance.
    * @param price the price from the calculator contract
    * @param res the response from the Python script
    */
    function _checkPriceAsFakeDecimalWithinTolerance(uint256 price, bytes memory res) internal pure {
        /// we go from bytes to uint
        uint resUint= decodeFakeDecimalBytes(res);
        /// we compare the numbers to see if they are within the tolerance. If not, then revert.
        _revertIfNotWithinTolerance(price, resUint);
    }

    /**
    * @dev compares if 2 uints are similar enough. The tolerance parameters are global to the contract.
    * @notice this function will revert in the case of a difference above tolerance
    * @param x value to compare against *y*
    * @param y value to compare against *x*
    */
    function _revertIfNotWithinTolerance(uint x, uint y) internal pure {
        if(!_areWithinTolerance(x, y))
            revert OutOfTolerance(x, y); 
    }

    /**
    * compares if 2 uints are similar enough. The tolerance parameters are global to the contract.
    * @param x value to compare against *y*
    * @param y value to compare against *x*
    * @return true if the difference expressed as a normalized value is less or equal than the tolerance.
    */
    function _areWithinTolerance(uint x, uint y) internal pure returns (bool){
        /// we calculate the absolute difference to avoid overflow/underflow
        uint diff = absoluteDiff(x,y);
        /// we calculate difference percentage as diff/(smaller number) to get the bigger difference "percentage".
        return diff == 0 || (diff * TOLERANCE_DEN) / ( x > y ? y : x)  <= MAX_TOLERANCE;
    }
}
