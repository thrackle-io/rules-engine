// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/**
 * @title App Manager User Interface
 * @dev This interface is implemented by all contracts that use AppManager. It provides the common function for setting up a new link to an AppManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice Interface for app manager user functions.
 */
interface IAppManagerUser {
    /**
     * @dev This function confirms a new appManagerAddress that was put in storage. It can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external;
}
