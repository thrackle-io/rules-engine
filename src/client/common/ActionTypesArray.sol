// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/common/ActionEnum.sol";

contract ActionTypesArray {
    function createActionTypesArray(ActionTypes _arg1) internal pure returns (ActionTypes[] memory) {
        ActionTypes[] memory array = new ActionTypes[](1);
        array[0] = _arg1;
        return array;
    }

    function createActionTypesArray(ActionTypes _arg1, ActionTypes _arg2) internal pure returns (ActionTypes[] memory) {
        ActionTypes[] memory array = new ActionTypes[](2);
        array[0] = _arg1;
        array[1] = _arg2;
        return array;
    }

    function createActionTypesArray(ActionTypes _arg1, ActionTypes _arg2, ActionTypes _arg3) internal pure returns (ActionTypes[] memory) {
        ActionTypes[] memory array = new ActionTypes[](3);
        array[0] = _arg1;
        array[1] = _arg2;
        array[2] = _arg3;
        return array;
    }

    function createActionTypesArray(ActionTypes _arg1, ActionTypes _arg2, ActionTypes _arg3, ActionTypes _arg4) internal pure returns (ActionTypes[] memory) {
        ActionTypes[] memory array = new ActionTypes[](4);
        array[0] = _arg1;
        array[1] = _arg2;
        array[2] = _arg3;
        array[3] = _arg4;
        return array;
    }

    function createActionTypesArray(ActionTypes _arg1, ActionTypes _arg2, ActionTypes _arg3, ActionTypes _arg4, ActionTypes _arg5) internal pure returns (ActionTypes[] memory) {
        ActionTypes[] memory array = new ActionTypes[](5);
        array[0] = _arg1;
        array[1] = _arg2;
        array[2] = _arg3;
        array[3] = _arg4;
        array[4] = _arg5;
        return array;
    }
}
