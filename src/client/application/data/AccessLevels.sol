// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./DataModule.sol";
import "./IAccessLevels.sol";

/**
 * @title Access Levels Contract
 * @notice Data contract to store AccessLevel Levels for user accounts
 * @dev This contract stores and serves Access Levels via an internal mapping
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract AccessLevels is IAccessLevels, DataModule {
    mapping(address => uint8) public levels;

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     * @param _dataModuleAppManagerAddress address of the owning app manager
     */
    constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress) {
        _transferOwnership(_dataModuleAppManagerAddress);
    }

    /**
     * @dev Add the Access Level to the account. Restricted to the owner
     * @param _address address of the account
     * @param _level access level(0-4)
     */
    function addLevel(address _address, uint8 _level) public virtual onlyOwner {
        if (_level > 4) revert AccessLevelIsNotValid(_level);
        if (_address == address(0)) revert ZeroAddress();
        levels[_address] = _level;
        emit AD1467_AccessLevelAdded(_address, _level);
    }

    /**
     * @dev Add the Access Level(0-4) to the list of account. Restricted to the owner.
     * @param _accounts address array upon which to apply the Access Level
     * @param _level Access Level array to add
     */
    function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external onlyOwner {
        if (_level.length != _accounts.length) revert InputArraysMustHaveSameLength();
        for (uint256 i; i < _accounts.length; ++i) {            
            addLevel(_accounts[i], _level[i]);
        }
    }

    /**
     * @dev Add the Access Level(0-4) to multiple accounts. Restricted to the owner.
     * @param _accounts addresses upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external virtual onlyOwner {
        for (uint256 i; i < _accounts.length; ++i) {
            addLevel(_accounts[i], _level);
        }
    }

    /**
     * @dev Get the Access Level for the account.
     * @param _account address of the account
     * @return level Access Level(0-4)
     */
    function getAccessLevel(address _account) external view virtual returns (uint8) {
        return (levels[_account]);
    }

    /**
     * @dev Remove the Access Level for the account. Restricted to the owner
     * @param _account address of the account
     */
    function removeAccessLevel(address _account) external virtual onlyOwner {
        delete levels[_account];
        emit AD1467_AccessLevelRemoved(_account);
    }
}
