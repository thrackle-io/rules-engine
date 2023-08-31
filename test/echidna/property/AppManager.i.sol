// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/application/AppManager.sol";

/**
 * @title ApplicationAppManager Internal Echidna Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the internal tests for ApplicationAppManager
 */
contract TestAppManager is AppManager {
    constructor() AppManager(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, "TestApp", false) {}

    /* ------------------------------ INVARIANTS -------------------------------- */
    /**
     * App Name should never be blank
     */
    function echidna_appNameNotBlank() public returns (bool) {
        if (bytes(appName).length != 0) return true;
        return false;
    }

    /**
     * Accounts address should never be 0x
     */
    function echidna_accountsNotZero() public returns (bool) {
        if (address(accounts) != address(0)) return true;
        return false;
    }

    /**
     * General Tags address should never be 0x
     */
    function echidna_generalTagsNotZero() public returns (bool) {
        if (address(accounts) != address(0)) return true;
        return false;
    }

    /**
     * AccessLevels address should never be 0x
     */
    function echidna_accessLevelsNotZero() public returns (bool) {
        if (address(accessLevels) != address(0)) return true;
        return false;
    }

    /**
     * RiskScores address should never be 0x
     */
    function echidna_riskScoresNotZero() public returns (bool) {
        if (address(riskScores) != address(0)) return true;
        return false;
    }

    /**
     * PauseRules address should never be 0x
     */
    function echidna_pauseRulesNotZero() public returns (bool) {
        if (address(pauseRules) != address(0)) return true;
        return false;
    }
}
