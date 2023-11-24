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

    error OutOfTolerance(uint _contract, uint _python); //700e344e

    using Strings for uint256;
    uint256 constant PRECISION_DECIMALS = 8;
    uint256 constant ATTO = 10 ** 18;
    uint256 constant Y_MAX = 1_000_000_000_000_000_000_000_000 * ATTO;
    uint256 constant M_MAX = 1_000_000_000_000_000_000_000_000 * 10 ** PRECISION_DECIMALS;
    uint8 constant MAX_TOLERANCE = 5;
    uint8 constant TOLERANCE_PRECISION = 11;
    uint256 constant TOLERANCE_DEN = 10 ** TOLERANCE_PRECISION;
    //// tolerance = (MAX_TOLERANCE * 100) / TOLERANCE_PRECISION %;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        protocolAMMFactory = createProtocolAMMFactory();
        switchToAppAdministrator();
    }

    /**
    * This test is entirely centered on the math of the Dual Linear NFT AMM.
    */
    function testFuzzNFTAMMCalculatorMath(uint256 mBuy, uint256 bBuy, uint256 mSell, uint256 bSell, uint64 q, bool isSale ) public {
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

        /// we create the actual calculator with such curves
        ProtocolNFTAMMCalcDualLinear calc = ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));

        /// the price that will be returned by the calculator
        uint256 price;
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;

        /// we carry out the swap depending if it is a sale or a purchase
        if(isSale){
            /// we make sure q is at least 1 to avoid underflow (only for the sale case)
            if( q < 1) q = 1;
            /// we calculate the price through the calculator and store it in *price*
            price = calc.calculateSwap(0, q, 1, 0);

            /// we then call the Python script to calculate the price "offchain" and store it in *res*
            string[] memory inputs = _buildFFILinearCalculator(mSell, "8", bSell, q - 1);
            res = vm.ffi(inputs);
        } 
        else{
            /// we calculate the price through the calculator and store it in *price*
            price = calc.calculateSwap(0, q, 0, 1);

            /// we then call the Python script to calculate the price "offchain" and store it in *res*
            string[] memory inputs = _buildFFILinearCalculator(mBuy, "8", bBuy, q);
            res = vm.ffi(inputs); 
        }
        
        /// some debug logging 
        emit Log(res);
        emit Price(price);

        /// we determine if the response was returned as a possible ascii or a decimal
        bool isAscii = isPossiblyAnAscii(res);
        emit IsAscii(isAscii);

        /// if it is a possible ascii, then we decode it and start the comparison
        if(isAscii){

            uint resUint = decodeAsciiUint(res);
            emit Price(resUint);

            /// we calculate the difference beetween these 2 values
            uint diff = safeDiff(resUint,price);
            emit Diff(diff);
            /// we check if the difference is below the max tolerance percentage
            if(diff !=0 && (diff * TOLERANCE_DEN) / price > MAX_TOLERANCE ){
                /// if it is above tolerance, it is possible that we thought *res* was an ascii, but it was not.
                /// we compare the numbers again, but now as decimals, to see if they are within the tolerance
                _compareAsDecimals(price, res);
            }
        }
        /// if the response was not an ascii.
        else{
            /// we compare the numbers to see if they are within the tolerance
            _compareAsDecimals(price, res);
        }
        
        emit Passed();
    }

    /**
    * @dev creates the input array specifically for the linear_calculator.py script.
    */
    function _buildFFILinearCalculator(uint256 m, string memory decimals, uint256 b, uint64 q) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](7);
        inputs[0] = "python3";
        inputs[1] = "script/python/linear_calculator.py"; 
        inputs[2] = m.toString();
        inputs[3] = decimals; 
        inputs[4] = b.toString();
        inputs[5] = uint256(q).toString();
        inputs[6] = "1"; /// y formatted in atto
        return inputs;
    }

    /**
    * @dev compares if a uints is similar enough to an encoded uint. 
    * i.e. The encoded value: 0x23456 is actually decimal 23456 and not hex 0x23456 which is 144470
    * The tolerance parameters are global to the contract.
    */
    function _compareAsDecimals(uint256 price, bytes memory res) internal pure {
        /// we go from bytes to uint
        uint pythonPrice= decodeHexDecimalBytes(res);
        /// we compare the numbers to see if they are within the tolerance
            _compareWithTolerance(price, pythonPrice);
    }

    /**
    * @dev compares if 2 uints are similar enough. The tolerance parameters are global to the contract.
    */
    function _compareWithTolerance(uint x, uint y) internal pure {
        /// to avoid underflow, we check first which one is greater than the other one.
        uint diff = safeDiff(x,y);
        /// we calculate difference % as diff/(smaller number).
        if(diff !=0 && (diff * TOLERANCE_DEN) / ( x > y ? y : x)  > MAX_TOLERANCE){
            revert OutOfTolerance(x, y);
        }
    }

    

}
