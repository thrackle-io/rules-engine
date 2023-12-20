// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

enum CurveTypes{
    LINEAR_WHOLE_B,
    LINEAR_FRACTION_B,
    CONST_RATIO,
    CONST_PRODUCT
}

struct SectionCurve{
    CurveTypes curveType;
    uint8 index; // index in the curve array. i.e. in *linears* or *constRatios*
}