// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./PauseRule.sol";
import "./IDataModule.sol";
import {IPauseRuleErrors} from "src/common/IErrors.sol";

/**
 * @title Pause Rule Interface
 * @notice Contains data structure for a pause rule and the interface
 * @dev Contains Pause Rule Storage and retrieval function definitions
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IPauseRules is IDataModule, IPauseRuleErrors {
    /**
     * @dev Add the pause rule to the account. Restricted to the owner
     * @param _pauseStart pause window start timestamp
     * @param _pauseStop pause window stop timestamp
     */
    function addPauseRule(uint64 _pauseStart, uint64 _pauseStop) external;

    /**
     * @dev Remove the pause rule from the account. Restricted to the owner
     * @param _pauseStart pause window start timestamp
     * @param _pauseStop pause window stop timestamp
     */
    function removePauseRule(uint64 _pauseStart, uint64 _pauseStop) external;

    /**
     * @dev Cleans up outdated pause rules by removing them from the mapping
     */
    function cleanOutdatedRules() external;

    /**
     * @dev Get the pauseRules data for a given tokenName.
     * @return pauseRules all the pause rules for the token
     */
    function getPauseRules() external view returns (PauseRule[] memory);

    /**
     * @dev Return a bool for if the PauseRule array is empty
     * @notice return true if pause rules is empty and return false if array contains rules 
     * @return true if empty 
     */
    function isPauseRulesEmpty() external view returns(bool);
}
