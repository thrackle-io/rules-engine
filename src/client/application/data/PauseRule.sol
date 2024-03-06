// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/**
 * @title Pause Rule
 * @notice Contains data structure for a pause rule
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
struct PauseRule {
    uint64 pauseStart;
    uint64 pauseStop;
}
