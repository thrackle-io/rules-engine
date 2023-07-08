// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "./IDataModule.sol";
import {IInputErrors, IZeroAddressError} from  "../interfaces/IErrors.sol";

/**
 * @title User accounts
 * @notice This contract serves as a storage server for user accounts
 * @dev Uses IDataModule, which has basic ownable functionality. It will get created, and therefore owned, by the app manager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IAccounts is IDataModule, IInputErrors, IZeroAddressError {
    /**
     * @dev Add the account. Restricted to owner.
     * @param _account user address
     */
    function addAccount(address _account) external;

    /**
     * @dev Remove the account. Restricted to owner.
     * @param _account user address
     */
    function removeAccount(address _account) external;

    /**
     * @dev Checks to see if the account exists
     * @param _address user address
     * @return exists true if exists, false if not exists
     */
    function isUserAccount(address _address) external view returns (bool);
}
