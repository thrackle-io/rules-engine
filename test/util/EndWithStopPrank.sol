// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

/**
 * @title End With Stop Prank
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett @mpetersoCode55
 * @dev encapsulates the modifier used in the whole test directory to end a test function
 * with a stopPrank command.
 */

abstract contract EndWithStopPrank is Test {
    modifier endWithStopPrank() {
        _;
        vm.stopPrank();
    }
}