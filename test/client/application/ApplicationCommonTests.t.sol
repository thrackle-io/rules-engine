// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/util/RuleCreation.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";

abstract contract ApplicationCommonTests is Test, TestCommonFoundry, ERC721Util {
    function testApplication_ApplicationCommonTests_IsSuperAdmin() public view ifDeploymentTestsEnabled {
        assertEq(applicationAppManager.isSuperAdmin(superAdmin), true);
        assertEq(applicationAppManager.isSuperAdmin(appAdministrator), false);
    }

    function testApplication_ApplicationCommonTests_IsAppAdministrator_Negative() public view ifDeploymentTestsEnabled {
        assertEq(applicationAppManager.isAppAdministrator(superAdmin), false);
    }

    function testApplication_ApplicationCommonTests_IsAppAdministrator_Positive() public view ifDeploymentTestsEnabled {
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
    }

    function testApplication_ApplicationCommonTests_ProposeNewSuperAdmin_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRiskAdmin();
        /// check that a non superAdmin cannot propose a newSuperAdmin
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ccc is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
        applicationAppManager.proposeNewSuperAdmin(newSuperAdmin);
    }

    function testApplication_ApplicationCommonTests_ProposeSuperAdmin() public endWithStopPrank ifDeploymentTestsEnabled {
        /// propose superAdmins to make sure that only one will ever be in the app
        switchToSuperAdmin();
        /// track the Proposed Admin role proposals and number of proposed admins (should not be > 1)
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 0);
        applicationAppManager.proposeNewSuperAdmin(address(0x677));
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
        applicationAppManager.proposeNewSuperAdmin(address(0xABC));
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
        applicationAppManager.proposeNewSuperAdmin(newSuperAdmin);
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
    }

    function testApplication_ApplicationCommonTests_RevokeSuperAdmin_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        /// proposed super admin cannot revoke the super admin role.
        vm.stopPrank();
        vm.startPrank(newSuperAdmin);
        vm.expectRevert(abi.encodeWithSignature("BelowMinAdminThreshold()"));
        applicationAppManager.revokeRole(SUPER_ADMIN_ROLE, superAdmin);
    }

    function testApplication_ApplicationCommonTests_MigratingSuperAdmin() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToSuperAdmin();
        applicationAppManager.proposeNewSuperAdmin(newSuperAdmin);
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
        /// accept the role through newSuperAdmin
        vm.stopPrank();
        vm.startPrank(newSuperAdmin);
        applicationAppManager.confirmSuperAdmin();
        /// Confirm old super admin role was revoked and granted to new super admin
        assertFalse(applicationAppManager.isSuperAdmin(superAdmin));
        assertTrue(applicationAppManager.isSuperAdmin(newSuperAdmin));
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 0);
    }

    function testApplication_ApplicationCommonTests_MigratingSuperAdminRevokeAppAdmin() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToSuperAdmin();
        applicationAppManager.proposeNewSuperAdmin(newSuperAdmin);
        assertEq(applicationAppManager.getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE), 1);
        vm.stopPrank();
        vm.startPrank(newSuperAdmin);
        applicationAppManager.confirmSuperAdmin();
        applicationAppManager.addAppAdministrator(address(0xB0b));
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, address(0xB0b));
        assertEq(applicationAppManager.isAppAdministrator(address(0xB0b)), false);
    }

    function testApplication_ApplicationCommonTests_AddAppAdministratorAppManager() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.isAppAdministrator(user), false);
    }

    function testApplication_ApplicationCommonTests_AddAppAdministratorAppManager_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        vm.expectRevert("AccessControl: account 0x000000000000000000000000000000000000dead is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
        applicationAppManager.addAppAdministrator(address(77));
        assertFalse(applicationAppManager.isAppAdministrator(address(77)));
    }

    function testApplication_ApplicationCommonTests_RevokeAppAdministrator_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator); //set an app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as an app administrator
        /// we renounce so there can be only one appAdmin
        applicationAppManager.renounceAppAdministrator();
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), false);
    }

    function testApplication_ApplicationCommonTests_RevokeAppAdministrator_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, address(77)); // try to revoke other app administrator
    }

    function testApplication_ApplicationCommonTests_RenounceAppAdministrator() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        applicationAppManager.renounceAppAdministrator();
        assertFalse(applicationAppManager.isAppAdministrator(appAdministrator));
    }

    function testApplication_ApplicationCommonTests_RevokeAppAdministrator() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToSuperAdmin();
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        assertFalse(applicationAppManager.isAppAdministrator(appAdministrator));
    }

    function testApplication_ApplicationCommonTests_AddRiskAdmin_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRiskAdmin();
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
    }

    function testApplication_ApplicationCommonTests_AddRiskAdmin_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.addRiskAdmin(address(88)); //add risk admin
    }

    function testApplication_ApplicationCommonTests_RenounceRiskAdmin() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRiskAdmin(); //interact as the created risk admin
        applicationAppManager.renounceRiskAdmin();
        assertFalse(applicationAppManager.isRiskAdmin(riskAdmin));
    }

    function testApplication_ApplicationCommonTests_RevokeRiskAdmin_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        applicationAppManager.addRiskAdmin(address(0xB0B)); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), false);
    }

    function testApplication_ApplicationCommonTests_RevokeRiskAdmin_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser(); //interact as a user
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
    }

    function testApplication_ApplicationCommonTests_AddaccessLevelAdmin_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAccessLevelAdmin();
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);
    }

    function testApplication_ApplicationCommonTests_AddaccessLevelAdmin_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.addAccessLevelAdmin(address(88)); //add AccessLevel admin
    }

    function testApplication_ApplicationCommonTests_RenounceAccessLevelAdmin() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAccessLevelAdmin();
        applicationAppManager.renounceAccessLevelAdmin();
        assertFalse(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin));
    }

    function testApplication_ApplicationCommonTests_RevokeAccessLevelAdmin_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAccessLevelAdmin();
        switchToAppAdministrator();
        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), false);
    }

    function testApplication_ApplicationCommonTests_RevokeAccessLevelAdmin_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
    }

    function testApplication_ApplicationCommonTests_AddAccessLevel_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testApplication_ApplicationCommonTests_AddAccessLevel_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser(); // create a user and make it the sender.
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x2104bd22bc71f1a868806c22aa1905dad25555696bbf4456c5b464b8d55f7335");
        applicationAppManager.addAccessLevel(user, 4);
    }

    function testApplication_ApplicationCommonTests_UpdateAccessLevel() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user, 4);
        uint8 userAccessLevel = applicationAppManager.getAccessLevel(user);
        assertEq(userAccessLevel, 4);
        applicationAppManager.addAccessLevel(user, 1);
        userAccessLevel = applicationAppManager.getAccessLevel(user);
        assertEq(userAccessLevel, 1);
    }

    function testApplication_ApplicationCommonTests_AddRiskScore_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_AddRiskScore_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f");
        applicationAppManager.addRiskScore(user, 44);
    }

    function testApplication_ApplicationCommonTests_GetRiskScore() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_AddAndRemoveRiskScore() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
        applicationAppManager.removeRiskScore(user);
        assertEq(0, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_UpdateRiskScore() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
        applicationAppManager.addRiskScore(user, 55);
        assertEq(55, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_UpdateRiskScore_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f");
        applicationAppManager.addRiskScore(user, 75);
        assertEq(0, applicationAppManager.getRiskScore(user));
    }

    function testApplication_ApplicationCommonTests_AddTag_Positive() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
    }

    function testApplication_ApplicationCommonTests_AddTag_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        vm.expectRevert(0xd7be2be3);
        applicationAppManager.addTag(user, ""); //add blank tag
    }

    function testApplication_ApplicationCommonTests_AddTagAsUser_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.addTag(user, ""); //add blank tag
    }

    function testApplication_ApplicationCommonTests_HasTag() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "TAG1");
        applicationAppManager.addTag(user, "TAG3");
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        assertFalse(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "TAG3"));
    }

    function testApplication_ApplicationCommonTests_RemoveTag() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "TAG1");
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        applicationAppManager.removeTag(user, "TAG1");
        assertFalse(applicationAppManager.hasTag(user, "TAG1"));
    }

    function testApplication_ApplicationCommonTests_RemoveTagAsUser_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "TAG1");
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.removeTag(user, "Tag1"); //add blank tag
    }

    function testApplication_ApplicationCommonTests_AddPauseRule() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        PauseRule[] memory noRule = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);
    }

    function testApplication_ApplicationCommonTests_RemovePauseRule() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        applicationAppManager.removePauseRule(1769955500, 1769984800);
        PauseRule[] memory removeTest = applicationAppManager.getPauseRules();
        assertTrue(removeTest.length == 0);
    }

    function testApplication_ApplicationCommonTests_AutoCleaningRules() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 100, Blocktime + 200);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        PauseRule[] memory noRule = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);

        vm.warp(Blocktime + 201);
        assertEq(block.timestamp, Blocktime + 201);
        applicationAppManager.addPauseRule(Blocktime + 300, Blocktime + 400);
        test = applicationAppManager.getPauseRules();
        noRule = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);
    }

    function testApplication_ApplicationCommonTests_RuleSizeLimit() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRuleAdmin();
        for (uint8 i; i < 15; i++) {
            applicationAppManager.addPauseRule(Blocktime + (i + 1) * 10, Blocktime + (i + 2) * 10);
        }
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.expectRevert(0xd30bd9c5);
        applicationAppManager.addPauseRule(Blocktime + 150, Blocktime + 160);
    }

    function testApplication_ApplicationCommonTests_ManualCleaning() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRuleAdmin();
        for (uint8 i; i < 15; i++) {
            applicationAppManager.addPauseRule(Blocktime + (i + 1) * 10, Blocktime + (i + 2) * 10);
        }
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.warp(Blocktime + 200);
        applicationAppManager.cleanOutdatedRules();
        test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 0);
    }

    function testApplication_ApplicationCommonTests_AnotherManualCleaning() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1010);
        applicationAppManager.addPauseRule(Blocktime + 1020, Blocktime + 1030);
        applicationAppManager.addPauseRule(Blocktime + 1060, Blocktime + 1070);
        applicationAppManager.addPauseRule(Blocktime + 40, Blocktime + 45);
        applicationAppManager.addPauseRule(Blocktime + 10, Blocktime + 20);
        applicationAppManager.addPauseRule(Blocktime + 55, Blocktime + 66);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 6);
        vm.warp(Blocktime + 150);
        applicationAppManager.cleanOutdatedRules();
        test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 3);
    }

    function testApplication_ApplicationCommonTests_SetNewTagProvider() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        Tags dataMod = new Tags(address(applicationAppManager));
        applicationAppManager.proposeTagsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.TAG);
        assertEq(address(dataMod), applicationAppManager.getTagProvider());
    }

    function testApplication_ApplicationCommonTests_SetNewTagProvider_Nagative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.proposeTagsProvider(address(0xD0D));
    }

    function testApplication_ApplicationCommonTests_SetNewAccessLevelProvider() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        AccessLevels dataMod = new AccessLevels(address(applicationAppManager));
        applicationAppManager.proposeAccessLevelsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCESS_LEVEL);
        assertEq(address(dataMod), applicationAppManager.getAccessLevelProvider());
    }

    function testApplication_ApplicationCommonTests_SetNewAccessLevelProvider_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.proposeAccessLevelsProvider(address(0xD0D));
    }

    function testApplication_ApplicationCommonTests_SetNewAccountProvider() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        Accounts dataMod = new Accounts(address(applicationAppManager));
        applicationAppManager.proposeAccountsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCOUNT);
        assertEq(address(dataMod), applicationAppManager.getAccountProvider());
    }

    function testApplication_ApplicationCommonTests_SetNewAccountProvider_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.proposeAccountsProvider(address(0xD0D));
    }

    function testApplication_ApplicationCommonTests_SetNewRiskScoreProvider() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        RiskScores dataMod = new RiskScores(address(applicationAppManager));
        applicationAppManager.proposeRiskScoresProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.RISK_SCORE);
        assertEq(address(dataMod), applicationAppManager.getRiskScoresProvider());
    }

    function testApplication_ApplicationCommonTests_SetNewPauseRulesProvider() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        PauseRules dataMod = new PauseRules(address(applicationAppManager));
        applicationAppManager.proposePauseRulesProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.PAUSE_RULE);
        assertEq(address(dataMod), applicationAppManager.getPauseRulesProvider());
    }

    function testApplication_ApplicationCommonTests_SetNewPauseRulesProvider_Negative() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToUser();
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60");
        applicationAppManager.proposePauseRulesProvider(address(0xD0D));
    }

    function upgradeAppManger() internal returns (AppManager appManagerNew) {
        /// create new app manager
        switchToSuperAdmin();
        appManagerNew = new AppManager(superAdmin, "Castlevania", false);
        /// migrate data contracts to new app manager
        /// set an app administrator in the new app manager
        appManagerNew.addAppAdministrator(appAdministrator);
        switchToAppAdministrator(); // create an app admin and make it the sender.
        applicationAppManager.proposeDataContractMigration(address(appManagerNew));
        appManagerNew.confirmDataContractMigration(address(applicationAppManager));
        return appManagerNew;
    }

    function testApplication_ApplicationCommonTests_UpgradeAppManagerRiskScoreData() public endWithStopPrank ifDeploymentTestsEnabled {
        /// Risk Data
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user1, 75);
        assertEq(75, applicationAppManager.getRiskScore(user1));
        applicationAppManager.addRiskScore(user2, 65);
        assertEq(65, applicationAppManager.getRiskScore(user2));
        /// create new app manager
        AppManager appManagerNew = upgradeAppManger();
        /// test that the data is accessible only from the new app manager
        assertEq(75, appManagerNew.getRiskScore(user1));
        assertEq(65, appManagerNew.getRiskScore(user2));
    }

    function testApplication_ApplicationCommonTests_UpgradeAppManagerTagsData() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        /// Tags Data
        applicationAppManager.addTag(user1, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(user1, "TAG1"));
        applicationAppManager.addTag(user2, "TAG2"); //add tag
        assertTrue(applicationAppManager.hasTag(user2, "TAG2"));
        /// create new app manager
        AppManager appManagerNew = upgradeAppManger();
        /// test that the data is accessible only from the new app manager
        assertTrue(appManagerNew.hasTag(user1, "TAG1"));
        assertTrue(appManagerNew.hasTag(user2, "TAG2"));
    }

    function testApplication_ApplicationCommonTests_UpgradeAppManagerPasueRuleData() public endWithStopPrank ifDeploymentTestsEnabled {
        /// Pause Rule Data
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        /// create new app manager
        AppManager appManagerNew = upgradeAppManger();
        /// test that the data is accessible only from the new app manager
        test = appManagerNew.getPauseRules();
        assertTrue(test.length == 1);
    }

    function testApplication_ApplicationCommonTests_UpgradeAppManagerAccessLevelData() public endWithStopPrank ifDeploymentTestsEnabled {
        /// AccessLevel
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 4);
        assertEq(applicationAppManager.getAccessLevel(user1), 4);
        applicationAppManager.addAccessLevel(user2, 3);
        assertEq(applicationAppManager.getAccessLevel(user2), 3);
        /// create new app manager
        AppManager appManagerNew = upgradeAppManger();
        /// test that the data is accessible only from the new app manager
        assertEq(appManagerNew.getAccessLevel(user1), 4);
        assertEq(appManagerNew.getAccessLevel(user2), 3);
    }

    function testApplication_ApplicationCommonTests_RuleAdminEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        vm.expectEmit(true, true, false, false);
        emit AD1467_RuleAdmin(ruleAdmin, true);
        applicationAppManager.addRuleAdministrator(ruleAdmin);
    }

    function testApplication_ApplicationCommonTests_RiskAdminEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        vm.expectEmit(true, true, false, false);
        emit AD1467_RiskAdmin(riskAdmin, true);
        applicationAppManager.addRiskAdmin(riskAdmin);
    }

    function testApplication_ApplicationCommonTests_AccessLevelAdminEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        vm.expectEmit(true, true, false, false);
        emit AD1467_AccessLevelAdmin(accessLevelAdmin, true);
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin);
    }

    function testApplication_ApplicationCommonTests_AppAdminEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToSuperAdmin();
        vm.expectEmit(true, true, false, false);
        emit AD1467_AppAdministrator(appAdministrator, true);
        applicationAppManager.addAppAdministrator(appAdministrator);
    }

    function testApplication_ApplicationCommonTests_RuleBypassAccountEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        vm.expectEmit(true, true, false, false);
        emit AD1467_RuleAdmin(ruleAdmin, true);
        applicationAppManager.addRuleAdministrator(ruleAdmin);
    }

    function testApplication_ApplicationCommonTests_AppNameEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        string memory appName = "CoolApp";
        vm.expectEmit(true, false, false, false);
        emit AD1467_AppNameChanged(appName);
        applicationAppManager.setAppName(appName);
    }

    function testApplication_ApplicationCommonTests_RegisterAmmEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        address amm = address(0x577777);
        vm.expectEmit(true, false, false, false);
        emit AD1467_AMMRegistered(amm);
        applicationAppManager.registerAMM(amm);
    }

    function testApplication_ApplicationCommonTests_RegisterTreasuryEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        address appTreasury = address(0xAAAAA);
        vm.expectEmit(true, false, false, false);
        emit AD1467_TreasuryRegistered(appTreasury);
        applicationAppManager.registerTreasury(appTreasury);
    }

    function testApplication_ApplicationCommonTests_TradingRulesAddressAllowListEventEmission() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToAppAdministrator();
        address tradingRulesAllowList = address(0xAAAAAA);
        vm.expectEmit(true, true, false, false);
        emit AD1467_TradingRuleAddressAllowlist(tradingRulesAllowList, true);
        applicationAppManager.approveAddressToTradingRuleAllowlist(tradingRulesAllowList, true);
    }

    function testApplication_ApplicationCommonTests_ApplicationHandlerConnected() public endWithStopPrank ifDeploymentTestsEnabled {
        assertEq(applicationAppManager.getHandlerAddress(), address(applicationHandler));
        assertEq(applicationHandler.appManagerAddress(), address(applicationAppManager));
    }

    function testApplication_ApplicationCommonTests_ERC20HandlerConnections() public endWithStopPrank ifDeploymentTestsEnabled {
        switchToSuperAdmin();
        assertEq(applicationCoin.getHandlerAddress(), address(applicationCoinHandler));
        assertEq(ERC173Facet(address(applicationCoinHandler)).owner(), address(applicationCoin));
        assertEq(applicationCoin.getAppManagerAddress(), address(applicationAppManager));
        assertTrue(applicationAppManager.isRegisteredHandler(address(applicationCoinHandler)));
    }

    function testApplication_ApplicationCommonTests_VerifyPricingContractsConnectedToHandler() public view ifDeploymentTestsEnabled {
        assertEq(applicationHandler.erc20PricingAddress(), address(erc20Pricer));
        assertEq(applicationHandler.nftPricingAddress(), address(erc721Pricer));
    }

    function testApplication_ApplicationCommonTests_VerifyRuleAdmin() public view ifDeploymentTestsEnabled {
        assertTrue(applicationAppManager.isRuleAdministrator(ruleAdmin));
    }

    function testApplication_ApplicationCommonTests_VerifyTreasury() public view ifDeploymentTestsEnabled {
        assertTrue(applicationAppManager.isTreasury(feeTreasury));
    }

    function testApplication_ApplicationCommonTests_VerifyTokensRegistered() public view ifDeploymentTestsEnabled {
        assertEq(applicationAppManager.getTokenID(address(applicationCoin)), "FRANK");
        assertEq(applicationAppManager.getTokenID(address(applicationNFT)), "Clyde");
    }

    function testApplication_ApplicationCommonTests_ERC721HandlerConnections() public endWithStopPrank ifDeploymentTestsEnabled {
        assertEq(applicationNFT.getAppManagerAddress(), address(applicationAppManager));
        assertEq(applicationNFT.getHandlerAddress(), address(applicationNFTHandler));
        assertTrue(applicationAppManager.isRegisteredHandler(address(applicationNFTHandler)));
    }

    /*********************** Atomic Rule Setting Tests ************************************/
    /* These tests ensure that the atomic setting/application of rules is functioning properly */
    /* AccountMaxValueByAccessLevel */
    function testApplication_ApplicationCommonTests_AccountMaxValueByAccessLevelAtomicFullSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](3);
        // Set up rule
        ruleIds[0] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 300);
        ruleIds[1] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 400);
        ruleIds[2] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 500);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setAccountMaxValueByAccessLevelRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < actions.length; i++) assertEq(applicationHandler.getAccountMaxValueByAccessLevelId(actions[i]), ruleIds[i]);
        // Verify that all the rules were activated
        for (uint i; i < actions.length; i++) assertTrue(applicationHandler.isAccountMaxValueByAccessLevelActive(actions[i]));
    }

    function testApplication_ApplicationCommonTests_AccountMaxValueByAccessLevelAtomicFullReSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](3);
        // Set up rule
        ruleIds[0] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 300);
        ruleIds[1] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 400);
        ruleIds[2] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 500);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setAccountMaxValueByAccessLevelRuleFull(actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 800);
        ruleIds[1] = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 900);
        actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY);
        // Apply the new set of rules
        setAccountMaxValueByAccessLevelRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < actions.length; i++) assertEq(applicationHandler.getAccountMaxValueByAccessLevelId(actions[i]), ruleIds[i]);
        // Verify that the old ones were cleared
        assertEq(applicationHandler.getAccountMaxValueByAccessLevelId(ActionTypes.MINT), 0);
        // Verify that the new rules were activated
        for (uint i; i < actions.length; i++) assertTrue(applicationHandler.isAccountMaxValueByAccessLevelActive(actions[i]));
        // Verify that the old rules are not activated
        assertFalse(applicationHandler.isAccountMaxValueByAccessLevelActive(ActionTypes.MINT));
    }

    /* AccountMaxValueByRiskScore */
    function testApplication_ApplicationCommonTests_AccountMaxValueByRiskScoreAtomicFullSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](3);
        uint8[] memory riskScores = createUint8Array(10, 25, 50, 75, 90);
        // Set up rule
        ruleIds[0] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(10_000_000, 100_000, 1_000, 500, 10));
        ruleIds[1] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(20_000_000, 100_000, 1_000, 500, 10));
        ruleIds[2] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(30_000_000, 100_000, 1_000, 500, 10));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setAccountMaxValueByRiskRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < actions.length; i++) assertEq(applicationHandler.getAccountMaxValueByRiskScoreId(actions[i]), ruleIds[i]);
        // Verify that all the rules were activated
        for (uint i; i < actions.length; i++) assertTrue(applicationHandler.isAccountMaxValueByRiskScoreActive(actions[i]));
    }

    function testApplication_ApplicationCommonTests_AccountMaxValueByRiskScoreAtomicFullReSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](3);
        uint8[] memory riskScores = createUint8Array(10, 25, 50, 75, 90);
        // Set up rule
        ruleIds[0] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(10_000_000, 100_000, 1_000, 500, 10));
        ruleIds[1] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(20_000_000, 100_000, 1_000, 500, 10));
        ruleIds[2] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(30_000_000, 100_000, 1_000, 500, 10));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setAccountMaxValueByRiskRuleFull(actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(60_000_000, 100_000, 1_000, 500, 10));
        ruleIds[1] = createAccountMaxValueByRiskRule(riskScores, createUint48Array(70_000_000, 100_000, 1_000, 500, 10));
        actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY);
        // Apply the new set of rules
        setAccountMaxValueByRiskRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < actions.length; i++) assertEq(applicationHandler.getAccountMaxValueByRiskScoreId(actions[i]), ruleIds[i]);
        // Verify that the old ones were cleared
        assertEq(applicationHandler.getAccountMaxValueByRiskScoreId(ActionTypes.MINT), 0);
        // Verify that the new rules were activated
        for (uint i; i < actions.length; i++) assertTrue(applicationHandler.isAccountMaxValueByRiskScoreActive(actions[i]));
        // Verify that the old rules are not activated
        assertFalse(applicationHandler.isAccountMaxValueByRiskScoreActive(ActionTypes.MINT));
    }

    /* AccountMaxTxValueByRiskScore */
    function testApplication_ApplicationCommonTests_AccountMaxTxValueByRiskScoreAtomicFullSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](4);
        // Set up rule
        ruleIds[0] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 99), createUint48Array(70, 50, 40, 30, 20));
        ruleIds[1] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 98), createUint48Array(70, 50, 40, 30, 20));
        ruleIds[2] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 97), createUint48Array(70, 50, 40, 30, 20));
        ruleIds[3] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 96), createUint48Array(70, 50, 40, 30, 20));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setAccountMaxTxValueByRiskRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < actions.length; i++) assertEq(applicationHandler.getAccountMaxTxValueByRiskScoreId(actions[i]), ruleIds[i]);
        // Verify that all the rules were activated
        for (uint i; i < actions.length; i++) assertTrue(applicationHandler.isAccountMaxTxValueByRiskScoreActive(actions[i]));
    }

    function testApplication_ApplicationCommonTests_AccountMaxTxValueByRiskScoreAtomicFullReSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](4);
        // Set up rule
        ruleIds[0] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 99), createUint48Array(70, 50, 40, 30, 20));
        ruleIds[1] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 98), createUint48Array(70, 50, 40, 30, 20));
        ruleIds[2] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 97), createUint48Array(70, 50, 40, 30, 20));
        ruleIds[3] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 96), createUint48Array(70, 50, 40, 30, 20));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setAccountMaxTxValueByRiskRuleFull(actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 94), createUint48Array(70, 50, 40, 30, 20));
        ruleIds[1] = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 93), createUint48Array(70, 50, 40, 30, 20));
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setAccountMaxTxValueByRiskRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(applicationHandler.getAccountMaxTxValueByRiskScoreId(ActionTypes.SELL), ruleIds[0]);
        assertEq(applicationHandler.getAccountMaxTxValueByRiskScoreId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(applicationHandler.getAccountMaxTxValueByRiskScoreId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(applicationHandler.getAccountMaxTxValueByRiskScoreId(ActionTypes.MINT), 0);
        assertEq(applicationHandler.getAccountMaxTxValueByRiskScoreId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(applicationHandler.isAccountMaxTxValueByRiskScoreActive(ActionTypes.SELL));
        assertTrue(applicationHandler.isAccountMaxTxValueByRiskScoreActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(applicationHandler.isAccountMaxTxValueByRiskScoreActive(ActionTypes.P2P_TRANSFER));
        assertFalse(applicationHandler.isAccountMaxTxValueByRiskScoreActive(ActionTypes.MINT));
        assertFalse(applicationHandler.isAccountMaxTxValueByRiskScoreActive(ActionTypes.BURN));
    }

    /* AccountMaxValueOutByAccessLevel */
    function testApplication_ApplicationCommonTests_AccountMaxValueOutByAccessLevelAtomicFullSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](4);
        // Set up rule
        ruleIds[0] = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 250);
        ruleIds[1] = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 350);
        ruleIds[2] = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 450);
        ruleIds[3] = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 550);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setAccountMaxValueOutByAccessLevelRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < actions.length; i++) assertEq(applicationHandler.getAccountMaxValueOutByAccessLevelId(actions[i]), ruleIds[i]);
        // Verify that all the rules were activated
        for (uint i; i < actions.length; i++) assertTrue(applicationHandler.isAccountMaxValueOutByAccessLevelActive(actions[i]));
    }

    function testApplication_ApplicationCommonTests_AccountMaxValueOutByAccessLevelAtomicFullReSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](2);
        // Set up rule
        ruleIds[0] = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 250);
        ruleIds[1] = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 350);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL);
        console.log("here!");
        // Apply the rules to all actions
        setAccountMaxValueOutByAccessLevelRuleFull(actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](1);
        ruleIds[0] = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 750);
        actions = createActionTypeArray(ActionTypes.SELL);
        // Apply the new set of rules
        setAccountMaxValueOutByAccessLevelRuleFull(actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(applicationHandler.getAccountMaxValueOutByAccessLevelId(ActionTypes.SELL), ruleIds[0]);
        // Verify that the old ones were cleared
        assertEq(applicationHandler.getAccountMaxValueOutByAccessLevelId(ActionTypes.P2P_TRANSFER), 0);
        // Verify that the new rules were activated
        assertTrue(applicationHandler.isAccountMaxValueOutByAccessLevelActive(ActionTypes.SELL));
        // Verify that the old rules are not activated
        assertFalse(applicationHandler.isAccountMaxValueOutByAccessLevelActive(ActionTypes.P2P_TRANSFER));
    }

    /* AccountDenyForNoAccessLevel */
    function testApplication_ApplicationCommonTests_AccountDenyForNoAccessLevelAtomicFullSet() public ifDeploymentTestsEnabled {
        // Set up rule
        createAccountDenyForNoAccessLevelRule();
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountDenyForNoAccessLevelRuleFull(actions);
        // Verify that all the rules were activated
        for (uint i; i < 5; i++) assertTrue(applicationHandler.isAccountDenyForNoAccessLevelActive(ActionTypes(i)));
    }

    function testApplication_ApplicationCommonTests_AccountDenyForNoAccessLevelAtomicFullReSet() public ifDeploymentTestsEnabled {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        createAccountDenyForNoAccessLevelRule();
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountDenyForNoAccessLevelRuleFull(actions);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setAccountDenyForNoAccessLevelRuleFull(actions);
        // Verify that the new rules were activated
        assertTrue(applicationHandler.isAccountDenyForNoAccessLevelActive(ActionTypes.SELL));
        assertTrue(applicationHandler.isAccountDenyForNoAccessLevelActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(applicationHandler.isAccountDenyForNoAccessLevelActive(ActionTypes.P2P_TRANSFER));
        assertFalse(applicationHandler.isAccountDenyForNoAccessLevelActive(ActionTypes.MINT));
        assertFalse(applicationHandler.isAccountDenyForNoAccessLevelActive(ActionTypes.BURN));
    }
}
