// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IDataModule.sol";
import {IAccessLevelErrors, IInputErrors} from "src/common/IErrors.sol";

/**
 * @title Access Levels interface
 * @notice interface to define the functionality of the Access Levels data contract
 * @dev Access Level storage and retrieval functions are defined here
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IAccessLevels is IDataModule, IAccessLevelErrors, IInputErrors {
    /**
     * @dev Add the Access Level to the account. Restricted to the owner
     * @param _address address of the account
     * @param _level access level(0-4)
     */
    function addLevel(address _address, uint8 _level) external;
    
    /**
     * @dev Add the Access Level(0-4) to the list of account. Restricted to the owner.
     * @param _accounts address array upon which to apply the Access Level
     * @param _level Access Level array to add
     */
    function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external;

    /**
     * @dev Get the Access Level for the account.
     * @param _account address of the account
     * @return level Access Level(0-4)
     */
    function getAccessLevel(address _account) external view returns (uint8);

    /**
     * @dev Add the Access Level(0-4) to multiple accounts. Restricted to the owner.
     * @param _accounts addresses upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external;

        /**
     * @dev Remove the Access Level for the account. Restricted to the owner
     * @param _account address of the account
     */
    function removeAccessLevel(address _account) external;
}
