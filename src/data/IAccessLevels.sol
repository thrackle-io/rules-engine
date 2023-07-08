// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./IDataModule.sol";
import { IAccessLevelErrors } from "../interfaces/IErrors.sol";

/**
 * @title AccessLevel Levels interface
 * @notice interface to define the functionality of the AccessLevel Levels data contract
 * @dev AccessLevel score storage and retrieval functions are defined here
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IAccessLevels is IDataModule, IAccessLevelErrors {
    /**
     * @dev Add the Access Level to the account. Restricted to the owner
     * @param _address address of the account
     * @param _level access levellevel(0-4)
     */
    function addLevel(address _address, uint8 _level) external;

    /**
     * @dev Remove the Access Level for the account. Restricted to the owner
     * @param _account address of the account
     */
    function removelevel(address _account) external;

    /**
     * @dev Get the Access Level for the account. Restricted to the owner
     * @param _account address of the account
     * @return level Access Level(0-4)
     */
    function getAccessLevel(address _account) external view returns (uint8);

    /**
     * @dev Check if an account has a Access Level
     * @param _address address of the account
     * @return hasAccessLevel true if it has a level, false if it doesn't
     */
    function hasAccessLevel(address _address) external view returns (bool);

    /**
     * @dev Add the Access Level(0-4) to multiple accounts. Restricted to Access Tiers.
     * @param _accounts address upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external;
}
