// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IPauseRules.sol";
import "./DataModule.sol";

/**
 * @title Pause Rules Data Contract
 * @notice Data contract to store Pause for user accounts
 * @dev This contract stores and serves pause rules via an internal mapping
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract PauseRules is IPauseRules, DataModule {
    PauseRule[] private pauseRules;

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     */
    constructor() {
        dataModuleAppManagerAddress = owner();
    }

    /**
     * @dev Add the pause rule to the account. Restricted to the owner
     * @param _pauseStart pause window start timestamp
     * @param _pauseStop pause window stop timestamp
     */
    function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) public onlyOwner {
        require(pauseRules.length < 15, "Max rules reached");
        cleanOutdatedRules();
        require(_pauseStart > block.timestamp && _pauseStop > _pauseStart, "bad dates");
        PauseRule memory pauseRule = PauseRule(block.timestamp, _pauseStart, _pauseStop, true);
        pauseRules.push(pauseRule);
        emit PauseRuleAdded(_pauseStart, _pauseStop);
    }

    /**
     * @dev Helper function to remove pause rule
     * @param i index of pause rule to remove
     */
    function _removePauseRule(uint256 i) internal {
        uint256 ruleCount = pauseRules.length;
        pauseRules[i] = pauseRules[ruleCount - 1];
        pauseRules.pop();
    }

    /**
     * @dev Remove the pause rule from the account. Restricted to the owner
     * @param _pauseStart pause window start timestamp
     * @param _pauseStop pause window stop timestamp
     */
    function removePauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyOwner {
        uint256 i;
        while (i < pauseRules.length) {
            bool exit;
            while (pauseRules.length > 0 && i < pauseRules.length && !exit) {
                PauseRule memory rule = pauseRules[i];
                if (rule.pauseStart == _pauseStart && rule.pauseStop == _pauseStop) {
                    _removePauseRule(i);
                    emit PauseRuleRemoved(_pauseStart, _pauseStop);
                } else {
                    exit = true;
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Cleans up outdated pause rules by removing them from the mapping
     */
    function cleanOutdatedRules() public {
        uint256 i;
        while (i < pauseRules.length) {
            while (pauseRules.length > 0 && i < pauseRules.length && pauseRules[i].pauseStop <= block.timestamp) {
                emit PauseRuleRemoved(pauseRules[i].pauseStart, pauseRules[i].pauseStop);
                _removePauseRule(uint8(i));
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Get the pauseRules data for a given tokenName.
     * @return pauseRules all the pause rules for the token
     */
    function getPauseRules() external view onlyOwner returns (PauseRule[] memory) {
        return (pauseRules);
    }
}
