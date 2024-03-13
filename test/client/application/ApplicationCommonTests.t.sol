// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/util/RuleCreation.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";

abstract contract ApplicationCommonTests is Test, TestCommonFoundry {

    function testApplication_ApplicationCommonTests_IsSuperAdmin() public ifDeplomentTestsEnabled() {
        assertEq(applicationAppManager.isSuperAdmin(superAdmin), true);
        assertEq(applicationAppManager.isSuperAdmin(appAdministrator), false);
    }

    function testApplication_ApplicationCommonTests_IsAppAdministrator() public ifDeplomentTestsEnabled() {
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
    }

    function testApplication_ApplicationCommonTests_MigratingSuperAdmin() public endWithStopPrank() ifDeplomentTestsEnabled() {
        address newSuperAdmin = address(0xACE);
        switchToRiskAdmin();
        /// first let's check that a non superAdmin can't propose a newSuperAdmin
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ccc is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
        applicationAppManager.proposeNewSuperAdmin(newSuperAdmin);
        /// now let's propose some superAdmins to make sure that only one will ever be in the app
        switchToSuperAdmin(); 
        assertEq(applicationAppManager.getRoleMemberCount(SUPER_ADMIN_ROLE), 1);
        /// let's test that superAdmin can't just renounce to his/her role
        vm.expectRevert(abi.encodeWithSignature("BelowMinAdminThreshold()"));
        applicationAppManager.renounceRole(SUPER_ADMIN_ROLE, superAdmin);
        /// now let's keep track of the Proposed Admin role
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 0);
        applicationAppManager.proposeNewSuperAdmin(address(0x666));
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
        applicationAppManager.proposeNewSuperAdmin(address(0xABC));
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
        applicationAppManager.proposeNewSuperAdmin(newSuperAdmin);
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
        /// now let's test that the proposed super admin can't just revoke the super admin role.
        vm.stopPrank();
        vm.startPrank(newSuperAdmin);
        vm.expectRevert(abi.encodeWithSignature("BelowMinAdminThreshold()"));
        applicationAppManager.revokeRole(SUPER_ADMIN_ROLE, superAdmin);
        /// now let's confirm it, but let's make sure only the proposed
        /// address can accept the role
        vm.stopPrank();
        vm.startPrank(address(0xB0B));
        vm.expectRevert(abi.encodeWithSignature("ConfirmerDoesNotMatchProposedAddress()"));
        applicationAppManager.confirmSuperAdmin();
        /// ok, now let's actually accept the role through newSuperAdmin
        vm.stopPrank();
        vm.startPrank(newSuperAdmin);
        applicationAppManager.confirmSuperAdmin();
        /// let's make sure that it went as planned
        assertFalse(applicationAppManager.isSuperAdmin(superAdmin));
        assertTrue(applicationAppManager.isSuperAdmin(newSuperAdmin));
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 0);

        vm.expectRevert("Function disabled");
        applicationAppManager.grantRole("Oscar", address(0x123));

        // let's check that newSuperAdmin can in fact do superAdmin stuff
        applicationAppManager.addAppAdministrator(address(0xB0b));
        applicationAppManager.revokeRole(APP_ADMIN_ROLE,address(0xB0b));
    }

        function testApplication_ApplicationCommonTests_AddAppAdministratorAppManager() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.isAppAdministrator(user), false);

        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.addAppAdministrator(address(77));
        assertFalse(applicationAppManager.isAppAdministrator(address(77)));
    }

    function testApplication_ApplicationCommonTests_RevokeAppAdministrator_Positive() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator); //set an app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as an app administrator

        /// we renounce so there can be only one appAdmin
        applicationAppManager.renounceAppAdministrator();
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), false);
    }

    function testApplication_ApplicationCommonTests_RevokeAppAdministrator_Negative() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator); //set an app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as an app administrator

        applicationAppManager.addAppAdministrator(address(77)); //set an additional app administrator
        assertEq(applicationAppManager.isAppAdministrator(address(77)), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, address(77)), true); // verify it was added as an app administrator

        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(user); //interact as a user
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, address(77)); // try to revoke other app administrator
    }

    /// Test renounce Application Administrators role
    function testApplication_ApplicationCommonTests_RenounceAppAdministrator() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToSuperAdmin(); 
        applicationAppManager.revokeRole(APP_ADMIN_ROLE,superAdmin);
        switchToAppAdministrator(); 
        applicationAppManager.renounceAppAdministrator();
    }

    function testApplication_ApplicationCommonTests_AddRiskAdmin_Positive() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
    }

    function testApplication_ApplicationCommonTests_AddRiskAdmin_Negative() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add Risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        vm.expectRevert("AccessControl: account 0x000000000000000000000000000000000000004d is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.addRiskAdmin(address(88)); //add risk admin
    }

    function testApplication_ApplicationCommonTests_RenounceRiskAdmin() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        applicationAppManager.addRiskAdmin(address(0xB0B)); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(riskAdmin); //interact as the created risk admin
        applicationAppManager.renounceRiskAdmin();
    }

    function testApplication_ApplicationCommonTests_RevokeRiskAdmin_Positive() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        applicationAppManager.addRiskAdmin(address(0xB0B)); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), false);
    }

    function testApplication_ApplicationCommonTests_RevokeRiskAdmin_Negative() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        vm.expectRevert("AccessControl: account 0x000000000000000000000000000000000000004d is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
    }

    function testApplication_ApplicationCommonTests_AddaccessLevelAdmin_Positive() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);
    }

    function testApplication_ApplicationCommonTests_AddaccessLevelAdmin_Negative() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        vm.expectRevert("AccessControl: account 0x000000000000000000000000000000000000004d is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.addAccessLevelAdmin(address(88)); //add AccessLevel admin
    }

    function testApplication_ApplicationCommonTests_RenounceAccessLevelAdmin() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessLevelAdmin(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
        applicationAppManager.renounceAccessLevelAdmin();
    }

    function testApplication_ApplicationCommonTests_RevokeAccessLevelAdmin_Positive() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessLevelAdmin(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), false);
    }

    function testApplication_ApplicationCommonTests_RevokeAccessLevelAdmin_Negative() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessLevelAdmin(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        vm.expectRevert("AccessControl: account 0x000000000000000000000000000000000000004d is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
    }

    function testApplication_ApplicationCommonTests_AddAccessLevel_Positive() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAccessLevelAdmin();
        console.log("Access Level Admin Address");
        console.log(accessLevelAdmin);
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testApplication_ApplicationCommonTests_AddAccessLevel_Negative() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToUser(); // create a user and make it the sender.
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x2104bd22bc71f1a868806c22aa1905dad25555696bbf4456c5b464b8d55f7335");
        applicationAppManager.addAccessLevel(user, 4);
    }

    function testApplication_ApplicationCommonTests_UpdateAccessLevel() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToAccessLevelAdmin(); // create a access level and make it the sender.
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);

        applicationAppManager.addAccessLevel(user, 1);
        retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 1);
    }

    function testApplication_ApplicationCommonTests_AddRiskScore_Positive() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_GetRiskScore() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_AddRiskScore_Negative() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToUser(); // create a user and make it the sender.
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f");
        applicationAppManager.addRiskScore(user, 44);
    }

    function testApplication_ApplicationCommonTests_AddAndRemoveRiskScore() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
        applicationAppManager.removeRiskScore(user);
        assertEq(0, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_UpdateRiskScore() public endWithStopPrank() ifDeplomentTestsEnabled() {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
        // update the score
        applicationAppManager.addRiskScore(user, 55);
        assertEq(55, applicationAppManager.getRiskScore(user));
    }

}