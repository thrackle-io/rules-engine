// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DataModule.sol";
import "./IAccessLevels.sol";

/**
 * @title AccessLevel Levels Contract
 * @notice Data contract to store AccessLevel Levels for user accounts
 * @dev This contract stores and serves Access Levels via an internal mapping
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract AccessLevels is IAccessLevels, DataModule {
    mapping(address => uint8) public levels;

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     */
    constructor() {
        dataModuleAppManagerAddress = owner();
    }

    /**
     * @dev Add the Access Level to the account. Restricted to the owner
     * @param _address address of the account
     * @param _level access levellevel(0-4)
     */
    function addLevel(address _address, uint8 _level) public onlyOwner {
        levels[_address] = _level;
    }

    /**
     * @dev Remove the Access Level for the account. Restricted to the owner
     * @param _account address of the account
     */
    function removelevel(address _account) external onlyOwner {
        delete levels[_account];
        emit AccessLevelRemoved(_account, block.timestamp);
    }

    /**
     * @dev Get the Access Level for the account. Restricted to the owner
     * @param _account address of the account
     * @return level Access Level(0-4)
     */
    function getAccessLevel(address _account) external view returns (uint8) {
        return (levels[_account]);
    }

    /**
     * @dev Check if an account has a Access Level
     * @param _address address of the account
     * @return hasAccessLevel true if it has a level, false if it doesn't
     */
    function hasAccessLevel(address _address) external view returns (bool) {
        return levels[_address] > 0;
    }
}
