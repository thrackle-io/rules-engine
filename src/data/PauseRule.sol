// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/**
 * @title Pause Rule
 * @notice Contains data structure for a pause rule
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
struct PauseRule {
    uint256 dateCreated;
    uint256 pauseStart;
    uint256 pauseStop;
}
