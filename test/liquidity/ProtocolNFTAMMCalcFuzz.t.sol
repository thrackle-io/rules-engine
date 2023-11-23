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

/**
 * @title Test all AMM Calculator Factory related functions
 * @notice This tests every function related to the AMM Calculator Factory including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolNFTAMMFactoryFuzzTest is TestCommonFoundry {

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
    uint8 constant MAX_TOLERANCE = 70;

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
        emit Log(res);
        bytes memory priceBytes = bytes(price.toString());
        emit Log(priceBytes);
        emit Price(price);
        bool isAscii = true;
        for (uint i; i < res.length; i++){
            if (uint(uint8(res[i])) < 0x30 || uint(uint8(res[i])) > 0x39) {
                isAscii = false;
                emit Tens(uint(uint8(res[i])));
                emit IsAscii(isAscii);
                break;
            }
        }
        emit IsAscii(isAscii);
        if(isAscii){
            if(areTheyEqual(priceBytes, res)){
                emit Passed();
                return;
            }else{
                //if(uint(bytes(price.toString())) < uint(res) - 3 || uint(bytes(price.toString())) > uint(res) + 3){
                uint diff;
                
                assembly{
                    diff := xor(priceBytes, res)
                }
                emit Diff(diff);
                if((uint(diff) * 10000) / 100000000 > MAX_TOLERANCE ){
                    uint pythonPrice;
                    for (uint i; i < res.length; i++){
                        //emit Log(bytes(res[i]));
                        uint tens = ((uint(uint8(res[i])) / 16 ) * 10);
                        emit Tens(tens);
                        uint units = ( uint(uint8(res[i])) - ((uint(uint8(res[i])) / 16 ) * 16));
                        emit Units(units);
                        if (i != res.length - 1) pythonPrice += ( tens + units) * (10 ** ((res.length - i - 1 )*2));
                        else pythonPrice += ( tens + units);
                        emit PythonPrice(pythonPrice);
                    }
                    if(price != pythonPrice){
                        if(price  > pythonPrice){
                            if(((price - pythonPrice) * 10000) / pythonPrice  > MAX_TOLERANCE){
                                revert OutOfTolerance(price, pythonPrice);
                            }
                        }else{
                            if(((pythonPrice - price) * 10000) / price  > MAX_TOLERANCE){
                                revert OutOfTolerance(price, pythonPrice);
                            }
                        }
                        
                    }else{
                        emit Passed();
                        return;
                    }
                    //revert OutOfTolerance(bytes(price.toString()), res);
                }else{
                    emit Passed();
                    return;
                } 
            }
        }else{
            uint pythonPrice;
             for (uint i; i < res.length; i++){
                //emit Log(bytes(res[i]));
                uint tens = ((uint(uint8(res[i])) / 16 ) * 10);
                emit Tens(tens);
                uint units = ( uint(uint8(res[i])) - ((uint(uint8(res[i])) / 16 ) * 16));
                emit Units(units);
                if (i != res.length - 1) pythonPrice += ( tens + units) * (10 ** ((res.length - i - 1 )*2));
                else pythonPrice += ( tens + units);
                emit PythonPrice(pythonPrice);
             }
             if(price != pythonPrice){
                if(price  > pythonPrice){
                    if(((price - pythonPrice) * 10000) / pythonPrice  > MAX_TOLERANCE){
                        revert OutOfTolerance(price, pythonPrice);
                    }
                }else{
                    if(((pythonPrice - price) * 10000) / price  > MAX_TOLERANCE){
                        revert OutOfTolerance(price, pythonPrice);
                    }
                }
                }else{
                    emit Passed();
                    return;
                }
        }


        // if(isAscii){
        //     emit IsFormatted(false);
        //     uint pythonPrice;
        //      for (uint i; i < res.length; i++){
        //         //emit Log(bytes(res[i]));
        //         uint tens = ((uint(uint8(res[i])) / 16 ) * 10);
        //         emit Tens(tens);
        //         uint units = ( uint(uint8(res[i])) - ((uint(uint8(res[i])) / 16 ) * 16));
        //         emit Units(units);
        //         if (i != res.length - 1) pythonPrice += ( tens + units) * (10 ** ((res.length - i - 1 )*2));
        //         else pythonPrice += ( tens + units);
        //         emit PythonPrice(pythonPrice);
        //      }
        //     //pythonPrice = uint256(bytes32(res));
        //     assertEq(price, pythonPrice);
        // }else{
        //     emit IsFormatted(true);
        //     //uint pythonPrice;
        //     // string memory pythonPrice = abi.decode(res, (string));
        //     // console.log(pythonPrice);
        //     emit PythonPrice(price);
        //     assertEq(bytes(price.toString()), res);
        //     // pythonPrice = uint256(bytes32(res));
        //     // assertEq(price, pythonPrice);
        // }

        
    }

    function areTheyEqual(bytes memory x, bytes memory y) internal pure returns(bool) {
        return keccak256(x) == keccak256(y);
    }
}
