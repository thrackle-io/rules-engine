// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IDataModule.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IAppManager} from "src/client/application/IAppManager.sol";
import {IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import {IAppManager} from "src/client/application/IAppManager.sol";

/**
 * @title Data Module
 * @notice This contract serves as a template for all data modules and is abstract as it is not intended to be deployed on its own.
 * @dev Allows for proper permissioning for both internal and external data sources.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
abstract contract DataModule is IDataModule, Ownable, IOwnershipErrors, IZeroAddressError {
    string private constant VERSION="1.1.0";
    address public immutable dataModuleAppManagerAddress;
    address newOwner; // This is used for data contract migration
    // slither-disable-next-line constable-states
    address newDataProviderOwner; // this is used for single new data provider

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     * @param _dataModuleAppManagerAddress address of the owning app manager
     */
    constructor(address _dataModuleAppManagerAddress) {
        dataModuleAppManagerAddress = _dataModuleAppManagerAddress;
    }

    /**
     * @dev Modifier ensures function caller is a Application Administrators or the parent contract
     */
    modifier appAdministratorOrOwnerOnly() {
        if (dataModuleAppManagerAddress == address(0)) revert AppManagerNotConnected();
        IAppManager appManager = IAppManager(dataModuleAppManagerAddress);

        if (!appManager.isAppAdministrator(_msgSender()) && owner() != _msgSender()) revert NotAppAdministratorOrOwner();
        _;
    }

    /**
     * @dev This function proposes a new owner that is put in storage to be confirmed in a separate process
     * @param _newOwner the new address being proposed
     */
    function proposeOwner(address _newOwner) external appAdministratorOrOwnerOnly {
        if (_newOwner == address(0)) revert ZeroAddress();
        newOwner = _newOwner;
    }

    /**
     * @dev This function confirms a new appManagerAddress that was put in storage. It can only be confirmed by the proposed address
     */
    function confirmOwner() external {
        if (newOwner == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != newOwner) revert ConfirmerDoesNotMatchProposedAddress();
        _transferOwnership(newOwner);
    }

    /**
     * @dev Part of the two step process to set a new Data Provider within a Protocol AppManager
     * @param _providerType the type of data provider
     */
    function confirmDataProvider(ProviderType _providerType) external virtual appAdministratorOrOwnerOnly {
        IAppManager(dataModuleAppManagerAddress).confirmNewDataProvider(_providerType);
    }

    /**
     * @dev Get the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}
