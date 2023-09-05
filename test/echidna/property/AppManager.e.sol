// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonEchidna.sol";

contract TestAppManager is TestCommonEchidna {
    constructor() public {
        applicationAppManager = _createAppManager(address(this));
    }

    function echidna_versionNotBlank() public returns (bool) {
        if (bytes(applicationAppManager.version()).length != 0) return true;
        return false;
    }

    function echidna_superAdminNotLost() public returns (bool) {
        if (applicationAppManager.isSuperAdmin(address(this))) return true;
        return false;
    }

    function echidna_appAdminNotLost() public returns (bool) {
        if (applicationAppManager.isAppAdministrator(address(this))) return true;
        return false;
    }
}
