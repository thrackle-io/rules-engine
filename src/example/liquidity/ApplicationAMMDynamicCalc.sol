// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/liquidity/IProtocolAMMCalculator.sol";
import "src/example/liquidity/DynamicCalc.sol";
import "openzeppelin-contracts/contracts/utils/math/Math.sol";

/**
 * @title Automated Market Maker Swap Dynamic Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
 *      as needed.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMDynamicCalc is IProtocolAMMCalculator {
    using Math for uint256;
    Operation[] private operations0for1;
    Operation[] private operations1for0;
    int256[] private savedResults;

    struct Operation {
        int256 x;
        int256 y;
        DynamicCalc.Variables xSubstitution;
        uint8 xSubstitutionStoragePosition; //substitute x with previous step result
        DynamicCalc.Variables ySubstitution;
        uint8 ySubstitutionStoragePosition; //substitute x with previous step result
        DynamicCalc.Operator operator;
        bool holdResult;
    }
    event Log(string _text, int256 _intNumber, uint256 _uintNumber, string _text2);

    /**
     * @dev This performs the swap from token0 to token1.
     *      Based on (x + a) * (y - b) = x * y
     *      This is sometimes simplified as xy = k
     *      x = _reserve0
     *      y = _reserve1
     *      a = _amount0
     *      b = _amount1
     *      k = _reserve0 * _reserve1
     *
     * @param _reserve0 total amount of token0 in reserve
     * @param _reserve1 total amount of token1 in reserve
     * @param _amount0 amount of token0 possibly coming into the pool
     * @param _amount1 amount of token1 possibly coming into the pool
     * @return _amountOut amount of alternate coming out of the pool
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) {
            revert AmountsAreZero();
        }
        if (_amount0 == 0) {
            return doCalculations(operations1for0, _reserve0, _reserve1, _amount0, _amount1);
        } else {
            return doCalculations(operations0for1, _reserve0, _reserve1, _amount0, _amount1);
        }
    }

    function doCalculations(Operation[] memory operations, uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) internal returns (uint256) {
        int256 _result;
        int256 _currentResult;
        int256 x;
        int256 y;
        savedResults = new int256[](operations.length);
        /// loop through all the calculations and calculate the swap
        for (uint i = 0; i < operations.length; i++) {
            emit Log("<><><><><>top of calc loop", 0, 0, "");
            (x, y) = doSubsitutions(operations[i], _reserve0, _reserve1, _amount0, _amount1, _result);
            emit Log("<><><><><>after doSubstitutions", 0, 0, "");
            if (operations[i].operator == DynamicCalc.Operator.ADD) _currentResult = addIt(x, y);
            if (operations[i].operator == DynamicCalc.Operator.SUBTRACT) _currentResult = subIt(x, y);
            if (operations[i].operator == DynamicCalc.Operator.MULTIPLY) _currentResult = multIt(x, y);
            if (operations[i].operator == DynamicCalc.Operator.DIVIDE) _currentResult = divIt(x, y);
            if (operations[i].operator == DynamicCalc.Operator.EXPONENT) _currentResult = powerIt(x, y);
            if (operations[i].operator == DynamicCalc.Operator.ROOT) _currentResult = sqrtIt(x);
            // if necessary, store result for later use
            if (operations[i].holdResult) savedResults[i] = _currentResult;
            emit Log("<><><><><>Result of current calculation", _currentResult, i, "");
            emit Log("<><><><><>Result after tally", _result, i, "");
        }

        return uint(_currentResult);
    }

    /**
     * @dev Add the two variables and return the sum
     * @param _x addend 1
     * @param _y addend 2
     * @return _return sum of operation
     */
    function addIt(int256 _x, int256 _y) internal pure returns (int256 _return) {
        _return = _x + _y;
        return _return;
    }

    /**
     * @dev Subtract the two variables and return the difference.
     * @param _x minuend
     * @param _y subtrahend
     * @return _return difference of operation
     */
    function subIt(int256 _x, int256 _y) internal pure returns (int256 _return) {
        _return = _x - _y;
        return _return;
    }

    /**
     * @dev Multiply the two variables and return the product.
     * @param _x multiplicand
     * @param _y multiplier
     * @return _return product of operation
     */
    function multIt(int256 _x, int256 _y) internal pure returns (int256 _return) {
        _return = _x * _y;
        return _return;
    }

    /**
     * @dev Divide the two variables and return the quotient.
     * @param _x dividend
     * @param _y divisor
     * @return _return quotient of operation
     */
    function divIt(int256 _x, int256 _y) internal pure returns (int256 _return) {
        _return = _x / _y;
        return _return;
    }

    /**
     * @dev Perform exponential operation on two variables and return the result.
     * @param _x base
     * @param _y exponent
     * @return _return result of operation
     */
    function powerIt(int256 _x, int256 _y) internal pure returns (int256 _return) {
        _return = int256(uint256(_x) ** uint256(_y));
        // preserve sign
        if ((_x < 0 && _y >= 0) || (_y < 0 && _x >= 0)) _return = _return * -1;
        return _return;
    }

    /**
     * @dev Perform square root operation on two variables and return the result.
     * @param _x radicand
     * @return _return result of operation
     */
    function sqrtIt(int256 _x) internal pure returns (int256 _return) {
        _return = int256(uint256(_x).sqrt());
        return _return;
    }

    function doSubsitutions(Operation memory _operation, uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1, int256 _result) internal returns (int256 _x, int256 _y) {
        emit Log("<><><><><>in doSubstitutions", 0, 0, "");
        emit Log("amount1", 0, _amount1, "");
        emit Log("_reserve0", 0, _reserve0, "");
        emit Log("_reserve1", 0, _reserve1, "");
        emit Log("_amount0", 0, _amount0, "");
        emit Log("_result", _result, 0, "");
        emit Log("_operation.xSubstitution", 0, uint8(_operation.xSubstitution), "");
        emit Log("_operation.ySubstitution", 0, uint8(_operation.ySubstitution), "");
        if (_operation.xSubstitution == DynamicCalc.Variables.RESERVE0) _x = int(_reserve0);
        if (_operation.xSubstitution == DynamicCalc.Variables.RESERVE1) _x = int(_reserve1);
        if (_operation.xSubstitution == DynamicCalc.Variables.AMOUNT0) _x = int(_amount0);
        if (_operation.xSubstitution == DynamicCalc.Variables.AMOUNT1) _x = int(_amount1);
        if (_operation.xSubstitution == DynamicCalc.Variables.RESULT) _x = int(_result);
        if (_operation.xSubstitution == DynamicCalc.Variables.SAVEDRESULT) _x = int(savedResults[_operation.xSubstitutionStoragePosition]);

        if (_operation.ySubstitution == DynamicCalc.Variables.RESERVE0) _y = int(_reserve0);
        if (_operation.ySubstitution == DynamicCalc.Variables.RESERVE1) _y = int(_reserve1);
        if (_operation.ySubstitution == DynamicCalc.Variables.AMOUNT0) _y = int(_amount0);
        if (_operation.ySubstitution == DynamicCalc.Variables.AMOUNT1) _y = int(_amount1);
        if (_operation.ySubstitution == DynamicCalc.Variables.RESULT) _y = int(_result);
        if (_operation.xSubstitution == DynamicCalc.Variables.SAVEDRESULT) _y = int(savedResults[_operation.ySubstitutionStoragePosition]);
        emit Log("<><><><><>end of doSubstitutions", _x, 0, "x");
        emit Log("<><><><><>end of doSubstitutions", _y, 0, "y");
        return (_x, _y);
    }

    function setEquation0for1(DynamicCalc.Equation memory eq) external {
        delete operations0for1;

        for (uint i = 0; i < eq._x.length; i++) {
            operations0for1.push(
                Operation(eq._x[i], eq._y[i], eq._xSubstitution[i], eq._xSubstitutionStoragePosition[i], eq._ySubstitution[i], eq._ySubstitutionStoragePosition[i], eq._operator[i], eq._holdResult[i])
            );
        }
    }
}
