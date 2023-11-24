// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/liquidity/ProtocolAMM.sol";
import "src/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/liquidity/calculators/ProtocolAMMCalcCP.sol";
import "src/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/helpers/TestCommonFoundry.sol";
import {LineInput} from "../../src/liquidity/calculators/dataStructures/CurveDataStructures.sol";
import "../../src/liquidity/calculators/ProtocolNFTAMMCalcLinear.sol";
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

    //error OutOfTolerance(bytes _contract, bytes _python);
    error OutOfTolerance(uint _contract, uint _python);

    using Strings for uint256;
    uint256 constant PRECISION_DECIMALS = 8;
    uint256 constant ATTO = 10 ** 18;
    uint256 constant Y_MAX = 1_000_000_000_000_000_000_000_000 * ATTO;
    uint256 constant M_MAX = 1_000_000_000_000_000_000_000_000 * 10 ** PRECISION_DECIMALS;
    uint8 constant MAX_TOLERANCE = 1;
    uint8 constant TOLERANCE_PRECISION = 8;
    uint256 constant TOLERANCE_DEN = 10 ** TOLERANCE_PRECISION;
    /// tolerance = (MAX_TOLERANCE * 100) / TOLERANCE_PRECISION %;

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
        mBuy = mBuy%M_MAX;
        bBuy = bBuy%Y_MAX;
        mSell = mSell%M_MAX;
        bSell = bSell%Y_MAX;

        // we make sure the curves comply with the premises mB > mS, and bB > bS.
        if(mSell >= mBuy){
            if(mBuy == 0) mBuy = 1;
            mSell = mBuy - 1;
        }
        if(bSell >= bBuy){
            if(bBuy == 0) bBuy = 1;
            bSell = bBuy - 1;
        }
         
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        
        LineInput memory buy = LineInput(mBuy, bBuy);
        LineInput memory sell = LineInput(mSell, bSell);

        ProtocolNFTAMMCalcLinear calc = ProtocolNFTAMMCalcLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));

        uint256 price;
        bytes memory res;

        if(isSale){
            if( q < 2) q = 2;
            price = calc.calculateSwap(0, q, 1, 0);

            {
                string[] memory inputs = new string[](7);
                inputs[0] = "python3";
                inputs[1] = "script/python/linear_calculator.py"; 
                inputs[2] = mSell.toString();
                inputs[3] = "8"; // decimals
                inputs[4] = bSell.toString();
                inputs[5] = uint256(q - 1).toString();
                inputs[6] = "1"; // y formatted in atto
                res = vm.ffi(inputs);
            }
        } 
        else{

            price = calc.calculateSwap(0, q, 0, 1);

            {
                string[] memory inputs = new string[](7);
                inputs[0] = "python3";
                inputs[1] = "script/python/linear_calculator.py"; 
                inputs[2] = mBuy.toString();
                inputs[3] = "8"; // decimals
                inputs[4] = bBuy.toString();
                inputs[5] = uint256(q).toString();
                inputs[6] = "1"; // y formatted in atto
                res = vm.ffi(inputs);
            }
        }
        bytes memory priceBytes = bytes(price.toString());

        emit Log(res);
        emit Log(priceBytes);
        emit Price(price);

        bool isAscii = isPossiblyAnAscii(res);
        emit IsAscii(isAscii);

        if(isAscii){
            // we compare if both results are exactly the same
            if(areBytesEqual(priceBytes, res)){
                // if they are then we're done here. Test passed.
                emit Passed();
                return;
            // If they are not, then we calculate the difference...
            }else{
                uint diff;
                assembly{
                    diff := xor(priceBytes, res)
                }
                emit Diff(diff);
                // ... and we see if that difference is within the percentage tolerance
                if(((uint(diff) * TOLERANCE_DEN)) / price > MAX_TOLERANCE ){
                    // if it is not, it is possible that what we thought was an ascii, was not.
                    // so we treat the number as adecimal string that needs to be decoded.
                    uint pythonPrice = decodeHexDecimalBytes(res);
                    // now we compare if the decoded number is exactly the same as the price from the calculator
                    if(price != pythonPrice){
                        // if they are not, we then proceed to check if the difference is within tolerance
                        // to avoid underflow, we check which one is greater than the other one
                        if(price  > pythonPrice){
                            if(((price - pythonPrice) * TOLERANCE_DEN) / pythonPrice  > MAX_TOLERANCE){
                                revert OutOfTolerance(price, pythonPrice);
                            }
                        }else{
                            if(((pythonPrice - price) * TOLERANCE_DEN) / price  > MAX_TOLERANCE){
                                revert OutOfTolerance(price, pythonPrice);
                            }
                        }
                        
                    }else{
                        // if they are the same, then we passed the test.
                        emit Passed();
                        return;
                    }
                }else{
                    // if the difference is within the tolerance, then we passed the test.
                    emit Passed();
                    return;
                } 
            }
        }
        /// if the response was not an ascii.
        else{
            // we go from bytes to uint
            uint pythonPrice= decodeHexDecimalBytes(res);
            // if the prices are not exactly the same, we see if they are at least within the tolerance
             if(price != pythonPrice){
                // to avoid underflow, we check first which one is greater than the other one.
                if(price  > pythonPrice){
                    if(((price - pythonPrice) * TOLERANCE_DEN) / pythonPrice  > MAX_TOLERANCE){
                        revert OutOfTolerance(price, pythonPrice);
                    }
                }else{
                    if(((pythonPrice - price) * TOLERANCE_DEN) / price  > MAX_TOLERANCE){
                        revert OutOfTolerance(price, pythonPrice);
                    }
                }
                }else{
                    // if they are, then we passed the test.
                    emit Passed();
                    return;
                }
        }
        
    }

}
