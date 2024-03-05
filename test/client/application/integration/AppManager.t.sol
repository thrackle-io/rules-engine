// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";

contract AppManagerBaseTest is TestCommonFoundry {
    
    function setUp() public {
        vm.startPrank(superAdmin); //set up as the super admin
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        vm.warp(Blocktime); // set block.timestamp
    }

    function testIsSuperAdmin() public {
        assertEq(applicationAppManager.isSuperAdmin(superAdmin), true);
        assertEq(applicationAppManager.isSuperAdmin(appAdministrator), false);
    }

    function testIsAppAdministratorNegative() public {
        assertEq(applicationAppManager.isAppAdministrator(superAdmin), false);
    }

    function testIsAppAdministrator() public {
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
    }

    function testMigratingSuperAdmin() public {
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

    function testAddAppAdministratorAppManager() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationAppManager.addAppAdministrator(appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.isAppAdministrator(user), false);

        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.addAppAdministrator(address(77));
        assertFalse(applicationAppManager.isAppAdministrator(address(77)));
    }

    function testRevokeAppAdministratorApp() public {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator); //set an app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as an app administrator

        /// we renounce so there can be only one appAdmin
        applicationAppManager.renounceAppAdministrator();
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), false);
    }

    function testNegativeRevokeAppAdministrator() public {
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
    function testRenounceAppAdministrator() public {
        switchToSuperAdmin(); 
        applicationAppManager.revokeRole(APP_ADMIN_ROLE,superAdmin);
        switchToAppAdministrator(); 
        applicationAppManager.renounceAppAdministrator();
    }

    function testAddRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
    }

    function testFailAddRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add Risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        applicationAppManager.addRiskAdmin(address(88)); //add risk admin
    }

    function testRenounceRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        applicationAppManager.addRiskAdmin(address(0xB0B)); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(riskAdmin); //interact as the created risk admin
        applicationAppManager.renounceRiskAdmin();
    }

    function testRevokeRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        applicationAppManager.addRiskAdmin(address(0xB0B)); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), false);
    }

    function testFailRevokeRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
    }

    function testAddaccessLevelAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);
    }

    function testFailAddaccessLevelAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        applicationAppManager.addAccessLevelAdmin(address(88)); //add AccessLevel admin
    }

    function testRenounceAccessLevelAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessLevelAdmin(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
        applicationAppManager.renounceAccessLevelAdmin();
    }

    function testRevokeAccessLevelAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessLevelAdmin(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), false);
    }

    function testFailRevokeAccessLevelAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessLevelAdmin(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
    }

    function testAddAccessLevel() public {
        switchToAccessLevelAdmin();
        console.log("Access Level Admin Address");
        console.log(accessLevelAdmin);
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testFailAddAccessLevel() public {
        switchToUser(); // create a user and make it the sender.
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testUpdateAccessLevel() public {
        switchToAccessLevelAdmin(); // create a access level and make it the sender.
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);

        applicationAppManager.addAccessLevel(user, 1);
        retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 1);
    }

    function testAddRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
    }

    function testGetRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
    }

    function testFailAddRiskScore() public {
        switchToUser(); // create a user and make it the sender.
        applicationAppManager.addRiskScore(user, 44);
        assertEq(44, applicationAppManager.getRiskScore(user));
    }

    function testAddAndRemoveRiskScore() public {
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
        applicationAppManager.removeRiskScore(user);
        assertEq(0, applicationAppManager.getRiskScore(user));
    }

    function testUpdateRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
        // update the score
        applicationAppManager.addRiskScore(user, 55);
        assertEq(55, applicationAppManager.getRiskScore(user));
    }

    function testAddTag() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addTag(user, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
    }

    function testFailAddTag() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addTag(user, ""); //add blank tag
    }

    function testHasTag() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addTag(user, "TAG1"); //add tag
        applicationAppManager.addTag(user, "TAG3"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        assertFalse(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "TAG3"));
    }

    function testRemoveTag() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addTag(user, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        applicationAppManager.removeTag(user, "TAG1");
        assertFalse(applicationAppManager.hasTag(user, "TAG1"));
    }

    function testAddPauseRule() public {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        PauseRule[] memory noRule = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);
    }

    function testRemovePauseRule() public {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        applicationAppManager.removePauseRule(1769955500, 1769984800);
        PauseRule[] memory removeTest = applicationAppManager.getPauseRules();
        assertTrue(removeTest.length == 0);
    }

    function testAutoCleaningRules() public {
        vm.warp(Blocktime);

        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 100, Blocktime + 200);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        PauseRule[] memory noRule = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);

        vm.warp(Blocktime + 201);
        console.log("block's timestamp", block.timestamp);
        assertEq(block.timestamp, Blocktime + 201);
        applicationAppManager.addPauseRule(Blocktime + 300, Blocktime + 400);
        test = applicationAppManager.getPauseRules();
        console.log("test2 length", test.length);
        noRule = applicationAppManager.getPauseRules();
        console.log("noRule2 length", noRule.length);
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);
        vm.warp(Blocktime);
    }

    function testRuleSizeLimit() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        for (uint8 i; i < 15; i++) {
            applicationAppManager.addPauseRule(Blocktime + (i + 1) * 10, Blocktime + (i + 2) * 10);
        }
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.expectRevert(0xd30bd9c5);
        applicationAppManager.addPauseRule(Blocktime + 150, Blocktime + 160);
        vm.warp(Blocktime);
    }

    function testManualCleaning() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        for (uint8 i; i < 15; i++) {
            applicationAppManager.addPauseRule(Blocktime + (i + 1) * 10, Blocktime + (i + 2) * 10);
        }
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.warp(Blocktime + 200);
        applicationAppManager.cleanOutdatedRules();
        test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 0);
        vm.warp(Blocktime);
    }

    function testAnotherManualCleaning() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1010);
        applicationAppManager.addPauseRule(Blocktime + 1020, Blocktime + 1030);
        applicationAppManager.addPauseRule(Blocktime + 40, Blocktime + 45);
        applicationAppManager.addPauseRule(Blocktime + 1060, Blocktime + 1070);
        applicationAppManager.addPauseRule(Blocktime + 1080, Blocktime + 1090);
        applicationAppManager.addPauseRule(Blocktime + 10, Blocktime + 20);
        applicationAppManager.addPauseRule(Blocktime + 2000, Blocktime + 2010);
        applicationAppManager.addPauseRule(Blocktime + 2020, Blocktime + 2030);
        applicationAppManager.addPauseRule(Blocktime + 55, Blocktime + 66);
        applicationAppManager.addPauseRule(Blocktime + 2060, Blocktime + 2070);
        applicationAppManager.addPauseRule(Blocktime + 2080, Blocktime + 2090);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 11);
        vm.warp(Blocktime + 150);
        applicationAppManager.cleanOutdatedRules();
        test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 8);
        vm.warp(Blocktime);
    }

    function testSetNewTagProvider() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        Tags dataMod = new Tags(address(applicationAppManager));
        applicationAppManager.proposeTagsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.TAG);
        assertEq(address(dataMod), applicationAppManager.getTagProvider());
    }

    function testSetNewAccessLevelProvider() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        AccessLevels dataMod = new AccessLevels(address(applicationAppManager));
        applicationAppManager.proposeAccessLevelsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCESS_LEVEL);
        assertEq(address(dataMod), applicationAppManager.getAccessLevelProvider());
    }

    function testSetNewAccountProvider() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        Accounts dataMod = new Accounts(address(applicationAppManager));
        applicationAppManager.proposeAccountsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCOUNT);
        assertEq(address(dataMod), applicationAppManager.getAccountProvider());
    }

    function testSetNewRiskScoreProvider() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        RiskScores dataMod = new RiskScores(address(applicationAppManager));
        applicationAppManager.proposeRiskScoresProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.RISK_SCORE);
        assertEq(address(dataMod), applicationAppManager.getRiskScoresProvider());
    }

    function testSetNewPauseRulesProvider() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        PauseRules dataMod = new PauseRules(address(applicationAppManager));
        applicationAppManager.proposePauseRulesProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.PAUSE_RULE);
        assertEq(address(dataMod), applicationAppManager.getPauseRulesProvider());
    }

    function testUpgradeAppManagerBaseAppManager() public {
        /// create user addresses
        address upgradeUser1 = address(100);
        address upgradeUser2 = address(101);
        /// put data in the old app manager
        /// AccessLevel
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(upgradeUser1, 4);
        assertEq(applicationAppManager.getAccessLevel(upgradeUser1), 4);
        applicationAppManager.addAccessLevel(upgradeUser2, 3);
        assertEq(applicationAppManager.getAccessLevel(upgradeUser2), 3);
        /// Risk Data
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(upgradeUser1, 75);
        assertEq(75, applicationAppManager.getRiskScore(upgradeUser1));
        applicationAppManager.addRiskScore(upgradeUser2, 65);
        assertEq(65, applicationAppManager.getRiskScore(upgradeUser2));
        /// Account Data
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        /// Tags Data
        applicationAppManager.addTag(upgradeUser1, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(upgradeUser1, "TAG1"));
        applicationAppManager.addTag(upgradeUser2, "TAG2"); //add tag
        assertTrue(applicationAppManager.hasTag(upgradeUser2, "TAG2"));
        /// Pause Rule Data
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);

        /// create new app manager
        vm.stopPrank();
        vm.startPrank(superAdmin);
        AppManager appManagerNew = new AppManager(superAdmin, "Castlevania", false);
        /// migrate data contracts to new app manager
        /// set an app administrator in the new app manager
        appManagerNew.addAppAdministrator(appAdministrator);
        switchToAppAdministrator(); // create an app admin and make it the sender.
        applicationAppManager.proposeDataContractMigration(address(appManagerNew));
        appManagerNew.confirmDataContractMigration(address(applicationAppManager));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// test that the data is accessible only from the new app manager
        assertEq(appManagerNew.getAccessLevel(upgradeUser1), 4);
        assertEq(appManagerNew.getAccessLevel(upgradeUser2), 3);
        assertEq(75, appManagerNew.getRiskScore(upgradeUser1));
        assertEq(65, appManagerNew.getRiskScore(upgradeUser2));
        assertTrue(appManagerNew.hasTag(upgradeUser1, "TAG1"));
        assertTrue(appManagerNew.hasTag(upgradeUser2, "TAG2"));
        test = appManagerNew.getPauseRules();
        assertTrue(test.length == 1);
    }
}
