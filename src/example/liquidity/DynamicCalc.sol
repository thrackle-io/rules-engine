// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/**
 * @title Automated Market Maker Swap Dynamic Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
 *      as needed.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract DynamicCalc {
    enum Operator {
        ADD,
        SUBTRACT,
        MULTIPLY,
        DIVIDE,
        EXPONENT,
        ROOT
    }
    enum Variables {
        NONE,
        RESERVE0,
        RESERVE1,
        AMOUNT0,
        AMOUNT1,
        RESULT, // the ongoing tally
        SAVEDRESULT // a specific steps result
    }
    struct Equation {
        int256[] _x;
        int256[] _y;
        Variables[] _xSubstitution;
        uint8[] _xSubstitutionStoragePosition;
        Variables[] _ySubstitution;
        uint8[] _ySubstitutionStoragePosition;
        Operator[] _operator;
        bool[] _holdResult;
    }
}
