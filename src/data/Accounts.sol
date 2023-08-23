// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "./DataModule.sol";
import "./IAccounts.sol";

/**
 * @title User accounts
 * @notice This contract serves as a storage server for user accounts
 * @dev Uses DataModule, which has basic ownable functionality. It will get created, and therefore owned, by the app manager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract Accounts is DataModule, IAccounts {
    mapping(address => bool) public accounts;

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     * @param _dataModuleAppManagerAddress address of the owning app manager
     */
    constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress) {
        _transferOwnership(_dataModuleAppManagerAddress);
    }

    /**
     * @dev Add the account. Restricted to owner.
     * @param _account user address
     */
    function addAccount(address _account) external virtual onlyOwner {
        if (_account == address(0)) revert ZeroAddress();
        accounts[_account] = true;
        emit AccountAdded(_account, block.timestamp);
    }

    /**
     * @dev Remove the account. Restricted to owner.
     * @param _account user address
     */
    function removeAccount(address _account) external virtual onlyOwner {
        accounts[_account] = false;
        emit AccountRemoved(_account, block.timestamp);
    }

    /**
     * @dev Checks to see if the account exists
     * @param _address user address
     * @return exists true if exists, false if not exists
     */
    function isUserAccount(address _address) external view virtual returns (bool) {
        return accounts[_address];
    }
}
