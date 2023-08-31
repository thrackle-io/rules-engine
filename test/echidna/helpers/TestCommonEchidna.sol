// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/example/ApplicationAppManager.sol";

abstract contract TestCommonEchidna {
    // common addresses
    address superAdmin = address(0xDaBEEF);
    address appAdministrator = address(0xDEAD);
    address ruleAdmin = address(0xACDC);
    address accessLevelAdmin = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address user = address(0xDDD);
    address priorAddress;

    // common block time
    uint64 Blocktime = 1769924800;

    // shared objects
    ApplicationAppManager applicationAppManager;

    /**
     * @dev Deploy and set up an AppManager
     * @return _appManager fully configured app manager
     */
    function _createAppManager() public returns (ApplicationAppManager _appManager) {
        _appManager = new ApplicationAppManager(superAdmin, "Castlevania", false);
        return _appManager;
    }
}
