// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonEchidna.sol";

contract TestAppManager is TestCommonEchidna {
    address public addr;

    constructor() public {
        applicationAppManager = _createAppManager(address(this));
    }

    /// Test the Default Admin roles
    function testIsSuperAdmin() public {
        assert(applicationAppManager.isSuperAdmin(address(this)));
        assert(!applicationAppManager.isSuperAdmin(address(0)));
    }

    // Test the Application Administrators roles(only SUPER_ADMIN can add app administrator)
    function testAddAppAdministrator() public {
        applicationAppManager.addAppAdministrator(user);
        assert(applicationAppManager.isAppAdministrator(user));
    }

    // WARNING: Does not function as you expect it to!!!! See testAddRiskAdmin2 for correct test
    // Test adding the Risk Admin roles
    function testAddRiskAdmin() public {
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assert(applicationAppManager.isRiskAdmin(riskAdmin) == true);
    }

    // Test adding the Risk Admin roles
    function testAddRiskAdmin2() public {
        try applicationAppManager.addRiskAdmin(riskAdmin) {
            assert(applicationAppManager.isRiskAdmin(riskAdmin) == true);
        } catch {
            assert(false);
        }
    }
}
