// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title AMM Type Enum
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores the possible actions for the protocol
 */
enum AMM_TYPE {
    ERC20AMM,
    ERC721AMM
}

enum CALC_TYPE {
    LINEAR,
    DUAL_LINEAR,
    CONST_PROD,
    CONSTANT,
    SAMPLE,
    MULTIPLE_TYPES
}