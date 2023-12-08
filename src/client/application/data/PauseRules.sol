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
    uint8 constant MAX_RULES = 15;

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     * @param _dataModuleAppManagerAddress address of the owning app manager
     */
    constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress) {
        _transferOwnership(_dataModuleAppManagerAddress);
    }

    /**
     * @dev Add the pause rule to the account. Restricted to the owner
     * @param _pauseStart pause window start timestamp
     * @param _pauseStop pause window stop timestamp
     */
    function addPauseRule(uint64 _pauseStart, uint64 _pauseStop) public virtual onlyOwner {
        if (pauseRules.length >= MAX_RULES) revert MaxPauseRulesReached();

        cleanOutdatedRules();
        if (_pauseStop <= _pauseStart || _pauseStart <= block.timestamp) {
            revert InvalidDateWindow(_pauseStart, _pauseStop);
        }
        PauseRule memory pauseRule = PauseRule(_pauseStart, _pauseStop);
        pauseRules.push(pauseRule);
        emit PauseRuleEvent(_pauseStart, _pauseStop, true);
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
    function removePauseRule(uint64 _pauseStart, uint64 _pauseStop) external virtual onlyOwner {
        uint256 i;
        while (i < pauseRules.length) {
            bool exit;
            while (pauseRules.length > 0 && i < pauseRules.length && !exit) {
                PauseRule memory rule = pauseRules[i];
                if (rule.pauseStart == _pauseStart && rule.pauseStop == _pauseStop) {
                    _removePauseRule(i);
                    emit PauseRuleEvent(_pauseStart, _pauseStop, false);
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
    function cleanOutdatedRules() public virtual {
        uint256 i;
        while (i < pauseRules.length) {
            while (pauseRules.length > 0 && i < pauseRules.length && pauseRules[i].pauseStop <= block.timestamp) {
                emit PauseRuleEvent(pauseRules[i].pauseStart, pauseRules[i].pauseStop, false);
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
    function getPauseRules() external view virtual onlyOwner returns (PauseRule[] memory) {
        return (pauseRules);
    }

    /**
     * @dev Return a bool for if the PauseRule array is empty
     * @notice return true if pause rules is empty and return false if array contains rules
     * @return true if empty
     */
    function isPauseRulesEmpty() external view virtual onlyOwner returns (bool) {
        return pauseRules.length == 0;
    }
}
