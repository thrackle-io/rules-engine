// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IAppLevelEvents} from "../interfaces/IEvents.sol";

/**
 * @title Data Module
 * @notice This contract serves as a template for all data modules.
 * @dev Allows for proper permissioning for both internal and external data sources.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IDataModule is IAppLevelEvents {
    ///Data Module
    error AppManagerNotConnected();
    error NotAppAdministratorOrOwner();
    enum ProviderType {
        ACCESS_LEVEL,
        ACCOUNT,
        GENERAL_TAG,
        PAUSE_RULE,
        RISK_SCORE
    }

    /**
     * @dev this function proposes a new owner that is put in storage to be confirmed in a separate process
     * @param _newOwner the new address being proposed
     */
    function proposeOwner(address _newOwner) external;

    /**
     * @dev this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address
     */
    function confirmOwner() external;

    /**
     * @dev Part of the two step process to set a new Data Provider within a Protocol AppManager
     * @param _providerType the type of data provider
     */
    function confirmDataProvider(ProviderType _providerType) external;
}
