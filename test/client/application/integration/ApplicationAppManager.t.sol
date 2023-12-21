// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

contract ApplicationAppManagerTest is TestCommonFoundry {

    uint8[] RISKSCORES = [10, 20, 30, 40, 50, 60, 70, 80];
    uint8[] ACCESSTIERS = [1, 1, 1, 2, 2, 2, 3, 4];

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();
        vm.warp(Blocktime); // set block.timestamp
    }

    function testAppManagerAndHandlerVersions() public {
        string memory version = applicationAppManager.version();
        assertEq(version, "1.1.0");
        version = applicationHandler.version();
        assertEq(version, "1.1.0");
    }

    ///---------------DEFAULT ADMIN--------------------
    /// Test the Default Admin roles
    function testIsSuperAdmin() public {
        assertEq(applicationAppManager.isSuperAdmin(superAdmin), true);
        assertEq(applicationAppManager.isSuperAdmin(appAdministrator), false);
    }

    /// Test the Application Administrators roles
    function testIsAppAdministrator() public {
        assertEq(applicationAppManager.isAppAdministrator(superAdmin), true);
    }

    function testMigratingSuperAdmin() public {
        address newSuperAdmin = address(0xACE);
        switchToRiskAdmin();
        /// first let's check that a non superAdmin can't propose a newSuperAdmin
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ccc is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
        applicationAppManager.proposeNewSuperAdmin(newSuperAdmin);
        /// now let's propose some superAdmins to make sure that only one will ever be in the app
        switchToSuperAdmin();
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
        /// no let's test that the proposed super admin can't just revoke the super admin role.
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

    ///---------------APP ADMIN--------------------
    // Test the Application Administrators roles(only SUPER_ADMIN can add app administrator)
    function testAddAppAdministrator() public {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(user);
        assertTrue(applicationAppManager.isAppAdministrator(user));
    }

    function testAddMultipleAppAdministrators() public {
        switchToSuperAdmin();
        applicationAppManager.addMultipleAppAdministrator(ADDRESSES);
        assertEq(applicationAppManager.isAppAdministrator(address(0xFF1)), true);
        assertEq(applicationAppManager.isAppAdministrator(user), false);
    }

    /// Test non default admin attempt to add app administrator
    function testFailAddAppAdministrator() public {
        applicationAppManager.addAppAdministrator(appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.isAppAdministrator(user), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user
        applicationAppManager.addAppAdministrator(address(88));
    }

    /// Test revoke Application Administrators role
    function testRevokeAppAdministratorApp() public {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        /// we renounce so there can be only one appAdmin
        applicationAppManager.renounceAppAdministrator();
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), false);
    }

    /// Test failed revoke Application Administrators role
    function testNegativeRevokeAppAdministrator() public {
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator); //set an app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        applicationAppManager.addAppAdministrator(address(77)); //set an additional app administrator
        assertEq(applicationAppManager.isAppAdministrator(address(77)), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, address(77)), true); // verify it was added as a app administrator

        vm.stopPrank(); //stop interacting as the default admin
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

    /// Test renounce Application Administrators role when Admin Withdrawal rule is active
    function testRenounceAppAdministratorAdminWithdrawalERC20() public {
        vm.warp(Blocktime);
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        // add admin withdrawal rule that covers current time period
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 1_000_000 * (10 ** 18), block.timestamp + 365 days);
        // apply admin withdrawal rule to an ERC20
        applicationCoinHandler.setAdminWithdrawalRuleId(_index);
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        // try to renounce AppAdmin
        vm.expectRevert(0x23a87520);
        applicationAppManager.renounceAppAdministrator();
        // try revoking from superAdmin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0x23a87520);
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        // try to deactivate the rule
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.expectRevert(0x23a87520);
        applicationCoinHandler.activateAdminWithdrawalRule(false);
        // try to set the rule to a different one.
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 5_000_000 * (10 ** 18), block.timestamp + 365 days);
        vm.expectRevert(0x23a87520);
        applicationCoinHandler.setAdminWithdrawalRuleId(_index);
        // move a year into the future so that the rule is expired
        vm.warp(block.timestamp + (366 days));
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        // try to renounce AppAdmin(this one should work)
        applicationAppManager.renounceAppAdministrator();
    }

    /// Test renounce Application Administrators role when Admin Withdrawal rule is active
    function testRenounceAppAdministratorAdminWithdrawalERC721() public {
        vm.warp(Blocktime);
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        // add admin withdrawal rule that covers current time period
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 1_000_000 * (10 ** 18), block.timestamp + 365 days);
        // apply admin withdrawal rule to an ERC721
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        // try to renounce AppAdmin
        vm.expectRevert(0x23a87520);
        applicationAppManager.renounceAppAdministrator();
        // try revoking from superAdmin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0x23a87520);
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        // try to deactivate the rule
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.expectRevert(0x23a87520);
        applicationNFTHandler.activateAdminWithdrawalRule(false);
        // try to set the rule to a different one.
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 5_000_000 * (10 ** 18), block.timestamp + 365 days);
        vm.expectRevert(0x23a87520);
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);
        // move a year into the future so that the rule is expired
        vm.warp(block.timestamp + (366 days));
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        // try to renounce AppAdmin(this one should work)
        applicationAppManager.renounceAppAdministrator();
    }

    ///---------------Risk ADMIN--------------------
    // Test adding the Risk Admin roles
    function testAddRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
    }

    // Test adding the Risk Admin roles
    function testAddMultipleRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addMultipleRiskAdmin(ADDRESSES); //add risk admins
        /// check only addresses in array are risk admins
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.isRiskAdmin(ADDRESSES[i]), true);
        }
        assertEq(applicationAppManager.isRiskAdmin(address(0xFF9)), false);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
    }

    // Test non app administrator attempt to add the Risk Admin roles
    function testFailAddRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add Risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        applicationAppManager.addRiskAdmin(address(88)); //add risk admin
    }

    /// Test renounce risk Admin role
    function testRenounceRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(riskAdmin); //interact as the created risk admin
        applicationAppManager.renounceRiskAdmin();
    }

    /// Test revoke risk Admin role
    function testRevokeRiskAdminA() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), false);
    }

    /// Test attempt to revoke risk Admin role from non app administrator
    function testFailRevokeRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(address(0xB0B)); //add risk admin
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(0xB0B)), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
    }

    ///---------------ACCESS TIER--------------------
    // Test adding the Access Tier roles
    function testAddaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessTier(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);
    }

    function testAddMultipleaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addMultipleAccessTier(ADDRESSES); //add AccessLevel admin address array
        /// check addresses in array are added as access tier admins
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.isAccessTier(ADDRESSES[i]), true);
        }
        /// address not in array should = false
        assertEq(applicationAppManager.isAccessTier(address(0xFF77)), false);
    }

    // Test non app administrator attempt to add the Access Tier roles
    function testFailAddaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessTier(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        applicationAppManager.addAccessTier(address(88)); //add AccessLevel admin
    }

    /// Test renounce Access Tier role
    function testRenounceaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessTier(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
        applicationAppManager.renounceAccessTier();
    }

    /// Test revoke Access Tier role
    function testRevokeaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessTier(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);
        applicationAppManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, accessLevelAdmin);
        assertEq(applicationAppManager.isAccessTier(accessLevelAdmin), false);
    }

    /// Test attempt to revoke Access Tier role from non app administrator
    function testFailRevokeaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessTier(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessTier(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        applicationAppManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, accessLevelAdmin);
    }

    ///---------------Zero Address checks--------------------
    function testZeroAddressCheckAppManager() public {
        vm.expectRevert();
        applicationAppManager.setNewApplicationHandlerAddress(address(0));
        vm.expectRevert();
        applicationAppManager.registerTreasury(address(0));
        vm.expectRevert();
        applicationAppManager.registerAMM(address(0));
        vm.expectRevert();
        applicationAppManager.registerToken("FRANKS", address(0));

        vm.expectRevert();
        applicationAppManager.addAppAdministrator(address(0));
        vm.expectRevert();
        applicationAppManager.addAccessTier(address(0));
        vm.expectRevert();
        applicationAppManager.addRiskAdmin(address(0));

        vm.expectRevert();
        new ApplicationHandler(address(0), address(applicationAppManager));

        vm.expectRevert();
        new ApplicationHandler(address(ruleProcessor), address(0x0));

        vm.expectRevert();
        applicationAppManager.addAccessLevel(address(0), 1);
        vm.expectRevert();
        applicationAppManager.addGeneralTag(address(0), "TESTZERO");
        vm.expectRevert();
        applicationAppManager.addRiskScore(address(0), 4);
    }

    ///---------------AccessLevel LEVEL MAINTENANCE--------------------
    function testAddAccessLevel() public {
        switchToAccessLevelAdmin(); // create a access tier and make it the sender.
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testAddAccessLevelToMultipleAccounts() public {
        switchToAccessLevelAdmin(); // create a access tier and make it the sender.

        applicationAppManager.addAccessLevelToMultipleAccounts(ADDRESSES, 4);
        /// check addresses in array are correct access tier level
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getAccessLevel(ADDRESSES[i]), 4);
        }
        assertEq(applicationAppManager.getAccessLevel(address(0xFF9)), 0);
        assertEq(applicationAppManager.getAccessLevel(address(user)), 0);
    }

    function testAddMultipleAccessLevels() public {
        switchToAccessLevelAdmin(); // create a access tier and make it the sender.

        applicationAppManager.addMultipleAccessLevels(ADDRESSES, ACCESSTIERS);
        /// ACCESSTIERS ARRAY [1, 1, 1, 2, 2, 2, 3, 4]
        /// check addresses in array are correct access tier level
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getAccessLevel(ADDRESSES[i]), ACCESSTIERS[i]);
        }

        assertEq(applicationAppManager.getAccessLevel(address(0xFF9)), 0);
        assertEq(applicationAppManager.getAccessLevel(address(user)), 0);

        /// create mismatch tag array
        uint8[] memory misMatchArray = createUint8Array(3, 77);
        /// create mistmatch address array
        address[] memory misMatchAddressArray = createAddressArray(user, address(0xFF77), address(0xFF88));

        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleAccessLevels(misMatchAddressArray, RISKSCORES);
        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleAccessLevels(ADDRESSES, misMatchArray);
    }

    function testFailAddAccessLevel() public {
        switchToUser(); // create a user and make it the sender.
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testUpdateAccessLevel() public {
        switchToAccessLevelAdmin(); // create a access tier and make it the sender.
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);

        applicationAppManager.addAccessLevel(user, 1);
        retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 1);
    }

    ///---------------RISK SCORE MAINTENANCE--------------------
    function testAddRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
    }

    function testAddRiskScoreToMultipleAccounts() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.

        applicationAppManager.addRiskScoreToMultipleAccounts(ADDRESSES, 75);
        /// check addresses in array are correct risk score
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getRiskScore(ADDRESSES[i]), 75);
        }
    }

    function testAddMultipleRiskScores() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.

        applicationAppManager.addMultipleRiskScores(ADDRESSES, RISKSCORES);
        /// check addresses in array are correct risk score
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getRiskScore(ADDRESSES[i]), RISKSCORES[i]);
        }

        /// create mismatch tag array
        uint8[] memory misMatchArray = createUint8Array(3, 77);
        /// create mistmatch address array
        address[] memory misMatchAddressArray = createAddressArray(user, address(0xFF77), address(0xFF88));
        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleRiskScores(misMatchAddressArray, RISKSCORES);
        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleRiskScores(ADDRESSES, misMatchArray);
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

    function testUpdateRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(user, 75);
        assertEq(75, applicationAppManager.getRiskScore(user));
        // update the score
        applicationAppManager.addRiskScore(user, 55);
        assertEq(55, applicationAppManager.getRiskScore(user));
    }

    ///---------------PAUSE RULES----------------
    // Test setting/listing/removing pause rules
    function testAddPauseRule() public {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
    }

    function testRemovePauseRule() public {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(applicationHandler.isPauseRuleActive() == true);
        applicationAppManager.removePauseRule(1769955500, 1769984800);
        PauseRule[] memory removeTest = applicationAppManager.getPauseRules();
        assertTrue(removeTest.length == 0);
        /// test that when all rules are removed the check is skipped in the handler
        assertTrue(applicationHandler.isPauseRuleActive() == false);
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

    function testNonAdminAddingOrActivatingPauseRules() public {
        switchToUser();
        vm.expectRevert();
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 0);
        vm.expectRevert("Ownable: caller is not the owner");
        applicationHandler.activatePauseRule(true);
    }

    function testActivatePauseRulesFromAppManager() public {
        switchToRuleAdmin();
        /// add rule as rule admin
        applicationAppManager.addPauseRule(1769955500, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(applicationHandler.isPauseRuleActive() == true);
        /// test deactivation of rule while pause rule exists
        applicationAppManager.activatePauseRuleCheck(false);
        assertTrue(applicationHandler.isPauseRuleActive() == false);
        /// reactivate pause rule
        applicationAppManager.activatePauseRuleCheck(true);
        assertTrue(applicationHandler.isPauseRuleActive() == true);
        /// remove rule and ensure pause rule check is false
        applicationAppManager.removePauseRule(1769955500, 1769984800);
        assertTrue(applicationHandler.isPauseRuleActive() == false);
    }

    function testRuleSizeLimit() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        for (uint8 i; i < 15; ) {
            applicationAppManager.addPauseRule(Blocktime + (i + 1) * 10, Blocktime + (i + 2) * 10);
            unchecked {
                ++i;
            }
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
        for (uint64 i; i < 15; ) {
            applicationAppManager.addPauseRule(Blocktime + (i + 1) * 10, Blocktime + (i + 2) * 10);
            unchecked {
                ++i;
            }
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

    ///---------------GENERAL TAGS--------------------
    // Test adding the general tags
    function testAddGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addGeneralTag(user, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));

        applicationAppManager.addGeneralTag(user, "TAG1"); //add tag again to test event emission for TagAlreadyApplied event
    }

    // Test adding the general tag to multiple accounts
    function testAddGeneralTagToMultipleAccounts() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addGeneralTagToMultipleAccounts(ADDRESSES, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(address(0xFF1), "TAG1"));

        applicationAppManager.addGeneralTag(address(0xFF1), "TAG1"); //add tag again to test event emission for TagAlreadyApplied event
    }

    // Test adding multiple general tags to multiple accounts
    function testAddMultipleGeneralTagsToMultipleAccouns() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        /// Create Tag Array
        bytes32[] memory genTags = createBytes32Array(bytes32("TAG"), bytes32("TAG1"), bytes32("TAG2"), bytes32("TAG3"), bytes32("TAG4"), bytes32("TAG5"), bytes32("TAG6"), bytes32("TAG7"));
        /// create mismatch tag array
        bytes32[] memory misMatchArray = createBytes32Array("TAG1", "TAG2");
        /// create mistmatch address array
        address[] memory misMatchAddressArray = createAddressArray(user, address(0xFF77), address(0xFF88));

        applicationAppManager.addMultipleGeneralTagToMultipleAccounts(ADDRESSES, genTags); //add tags
        assertTrue(applicationAppManager.hasTag(address(0xFF1), "TAG"));
        assertTrue(applicationAppManager.hasTag(address(0xFF2), "TAG1"));
        assertTrue(applicationAppManager.hasTag(address(0xFF8), "TAG7"));

        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleGeneralTagToMultipleAccounts(misMatchAddressArray, genTags);

        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleGeneralTagToMultipleAccounts(ADDRESSES, misMatchArray);

        applicationAppManager.addGeneralTag(address(0xFF1), "TAG1"); //add tag again to test event emission for TagAlreadyApplied event
    }

    // Test when tag is invalid
    function testFailAddGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addGeneralTag(user, ""); //add blank tag
    }

    // Test scenarios for checking specific tags.
    function testHasGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addGeneralTag(user, "TAG1"); //add tag
        applicationAppManager.addGeneralTag(user, "TAG3"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        assertFalse(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "TAG3"));
    }

    // Test removal of the tag
    function testRemoveGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addGeneralTag(user, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        applicationAppManager.removeGeneralTag(user, "TAG1");
        assertFalse(applicationAppManager.hasTag(user, "TAG1"));
    }

    function testOverAllGeneralTags() public {
        switchToAppAdministrator();
        /// test adding a singular Tag
        applicationAppManager.addGeneralTag(user, "TAG1"); //add tag
        /// add one tag to multiple addresses
        applicationAppManager.addGeneralTagToMultipleAccounts(ADDRESSES, "TAG2"); //add tags
        /// add multiple tags to multiple addresses
        address[] memory addresses = createAddressArray(address(0xBABE), address(0xDADD));
        bytes32[] memory tags = createBytes32Array(bytes32("BABE"), bytes32("DADD"));

        applicationAppManager.addMultipleGeneralTagToMultipleAccounts(addresses, tags);

        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        assertFalse(applicationAppManager.hasTag(user, "TAG2"));
        assertFalse(applicationAppManager.hasTag(user, "BABE"));
        assertFalse(applicationAppManager.hasTag(user, "DADD"));
        applicationAppManager.addGeneralTag(user, "TAG2");
        applicationAppManager.addGeneralTag(user, "BABE");
        applicationAppManager.addGeneralTag(user, "DADD");
        applicationAppManager.addGeneralTag(user, "FIFTH");

        assertTrue(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "BABE"));
        assertTrue(applicationAppManager.hasTag(user, "DADD"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));

        assertTrue(applicationAppManager.hasTag(address(0xFF1), "TAG2"));
        assertFalse(applicationAppManager.hasTag(address(0xFF1), "TAG1"));
        assertTrue(applicationAppManager.hasTag(address(0xFF2), "TAG2"));
        assertFalse(applicationAppManager.hasTag(address(0xFF1), "TAG1"));
        assertTrue(applicationAppManager.hasTag(address(0xFF8), "TAG2"));
        assertFalse(applicationAppManager.hasTag(address(0xFF1), "TAG1"));

        assertTrue(applicationAppManager.hasTag(address(0xBABE), "BABE"));
        assertFalse(applicationAppManager.hasTag(address(0xBABE), "DADD"));
        assertTrue(applicationAppManager.hasTag(address(0xDADD), "DADD"));
        assertFalse(applicationAppManager.hasTag(address(0xDADD), "BABE"));

        applicationAppManager.removeGeneralTag(user, "TAG1");
        assertFalse(applicationAppManager.hasTag(user, "TAG1"));
        assertTrue(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "BABE"));
        assertTrue(applicationAppManager.hasTag(user, "DADD"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));
        applicationAppManager.removeGeneralTag(address(0xFF1), "TAG2");
        assertFalse(applicationAppManager.hasTag(address(0xFF1), "TAG2"));
        applicationAppManager.removeGeneralTag(address(0xBABE), "BABE");
        assertFalse(applicationAppManager.hasTag(address(0xBABE), "BABE"));
        applicationAppManager.removeGeneralTag(address(0xDADD), "DADD");
        assertFalse(applicationAppManager.hasTag(address(0xDADD), "DADD"));

        /// remove last tag
        applicationAppManager.removeGeneralTag(user, "DADD");
        assertFalse(applicationAppManager.hasTag(user, "DADD"));
        assertTrue(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "BABE"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));

        /// remove tag in the middle
        applicationAppManager.removeGeneralTag(user, "BABE");
        assertFalse(applicationAppManager.hasTag(user, "BABE"));
        assertTrue(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));

        /// remove last tag again
        applicationAppManager.removeGeneralTag(user, "TAG2");
        assertFalse(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));

        /// remove only tag
        applicationAppManager.removeGeneralTag(user, "FIFTH");
        assertFalse(applicationAppManager.hasTag(user, "FIFTH"));
    }

    /// Test the register token.
    function testRegisterToken() public {
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        applicationCoinHandler = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoin);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));

        ApplicationERC20 applicationCoinA = _createERC20("CoinA", "A", applicationAppManager);
        ApplicationERC20Handler applicationCoinHandlerA = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoinA);
        applicationCoinA.connectHandlerToToken(address(applicationCoinHandlerA));

        ApplicationERC20 applicationCoinB = _createERC20("CoinB", "B", applicationAppManager);
        ApplicationERC20Handler applicationCoinHandlerB = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoinB);
        applicationCoinB.connectHandlerToToken(address(applicationCoinHandlerB));

        ApplicationERC20 applicationCoinC = _createERC20("coinC", "C", applicationAppManager);
        ApplicationERC20Handler applicationCoinHandlerC = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoinC);
        applicationCoinC.connectHandlerToToken(address(applicationCoinHandlerC));

        /// register the tokens
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        assertEq(address(applicationCoin), applicationAppManager.getTokenAddress("FRANK"));

        applicationAppManager.registerToken("CoinA", address(applicationCoinA));
        assertEq(address(applicationCoinA), applicationAppManager.getTokenAddress("CoinA"));

        applicationAppManager.registerToken("CoinB", address(applicationCoinB));
        assertEq(address(applicationCoinB), applicationAppManager.getTokenAddress("CoinB"));

        applicationAppManager.registerToken("CoinC", address(applicationCoinC));
        assertEq(address(applicationCoinC), applicationAppManager.getTokenAddress("CoinC"));

        // test updating the token's name
        applicationAppManager.registerToken("FRANCISCOSTEIN", address(applicationCoin));
        assertEq(address(applicationCoin), applicationAppManager.getTokenAddress("FRANCISCOSTEIN"));
        // // back to black
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        assertEq(address(applicationCoin), applicationAppManager.getTokenAddress("FRANK"));

        // deregister the first coin
        applicationAppManager.deregisterToken("FRANK");
        assertEq(address(0), applicationAppManager.getTokenAddress("FRANK"));
        address[] memory list = applicationAppManager.getTokenList();
        assertEq(list.length, 5);

        // deregister coinB
        applicationAppManager.deregisterToken("CoinB");
        assertEq(address(0), applicationAppManager.getTokenAddress("CoinB"));
        list = applicationAppManager.getTokenList();
        assertEq(list.length, 4);

        // deregister CoinC
        applicationAppManager.deregisterToken("CoinC");
        assertEq(address(0), applicationAppManager.getTokenAddress("CoinC"));
        list = applicationAppManager.getTokenList();
        assertEq(list.length, 3);

        // deregister CoinA
        applicationAppManager.deregisterToken("CoinA");
        assertEq(address(0), applicationAppManager.getTokenAddress("CoinA"));
        list = applicationAppManager.getTokenList();
        assertEq(list.length, 2);
    }

    /// Test the register AMM.
    function testRegisterAMM() public {
        applicationAppManager.registerAMM(address(0xaaa));
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xaaa)));
        applicationAppManager.registerAMM(address(0xbbb));
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xbbb)));
        applicationAppManager.registerAMM(address(0xccc));
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xccc)));
        applicationAppManager.registerAMM(address(0xddd));
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xddd)));
        applicationAppManager.registerAMM(address(0xeee));
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xeee)));
        /// this is expected to fail because you cannot register same address more than once
        vm.expectRevert();
        applicationAppManager.registerAMM(address(0xaaa));

        /// deregistering the first address
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xaaa)));
        applicationAppManager.deRegisterAMM(address(0xaaa));
        assertFalse(applicationAppManager.isRegisteredAMM(address(0xaaa)));
        /// deregistering the last address (it is now the forth one, not the fifth one)
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xddd)));
        applicationAppManager.deRegisterAMM(address(0xddd));
        assertFalse(applicationAppManager.isRegisteredAMM(address(0xddd)));
        /// deregistering the address in the middle
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xbbb)));
        applicationAppManager.deRegisterAMM(address(0xbbb));
        assertFalse(applicationAppManager.isRegisteredAMM(address(0xbbb)));
        /// deregistering the last address again
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xccc)));
        applicationAppManager.deRegisterAMM(address(0xccc));
        assertFalse(applicationAppManager.isRegisteredAMM(address(0xccc)));
        /// deregistering the only address
        assertTrue(applicationAppManager.isRegisteredAMM(address(0xeee)));
        applicationAppManager.deRegisterAMM(address(0xeee));
        assertFalse(applicationAppManager.isRegisteredAMM(address(0xeee)));
    }

    /// Test the deregister AMM.
    function testDeregisterAMM() public {
        applicationAppManager.registerAMM(address(77));
        assertTrue(applicationAppManager.isRegisteredAMM(address(77)));
        applicationAppManager.deRegisterAMM(address(77));
        assertFalse(applicationAppManager.isRegisteredAMM(address(77)));
    }

    function testRegisterAddresses() public {
        /// check registration of treasury
        applicationAppManager.registerTreasury(address(0x111));
        assertTrue(applicationAppManager.isTreasury(address(0x111)));
        vm.expectRevert();
        applicationAppManager.registerTreasury(address(0x111));

        applicationAppManager.registerTreasury(address(0x222));
        assertTrue(applicationAppManager.isTreasury(address(0x222)));
        applicationAppManager.registerTreasury(address(0x333));
        assertTrue(applicationAppManager.isTreasury(address(0x333)));
        applicationAppManager.registerTreasury(address(0x444));
        assertTrue(applicationAppManager.isTreasury(address(0x444)));
        applicationAppManager.registerTreasury(address(0x555));
        assertTrue(applicationAppManager.isTreasury(address(0x555)));

        /// deregistering the first address
        assertTrue(applicationAppManager.isTreasury(address(0x111)));
        applicationAppManager.deRegisterTreasury(address(0x111));
        assertFalse(applicationAppManager.isTreasury(address(0x111)));
        /// deregistering the last address (it is now the forth one, not the fifth one)
        assertTrue(applicationAppManager.isTreasury(address(0x444)));
        applicationAppManager.deRegisterTreasury(address(0x444));
        assertFalse(applicationAppManager.isTreasury(address(0x444)));
        /// deregistering the address in the middle
        assertTrue(applicationAppManager.isTreasury(address(0x222)));
        applicationAppManager.deRegisterTreasury(address(0x222));
        assertFalse(applicationAppManager.isTreasury(address(0x222)));
        /// deregistering the last address again
        assertTrue(applicationAppManager.isTreasury(address(0x333)));
        applicationAppManager.deRegisterTreasury(address(0x333));
        assertFalse(applicationAppManager.isTreasury(address(0x333)));
        /// deregistering the only address
        assertTrue(applicationAppManager.isTreasury(address(0x555)));
        applicationAppManager.deRegisterTreasury(address(0x555));
        assertFalse(applicationAppManager.isTreasury(address(0x555)));
    }

    ///---------------UPGRADEABILITY---------------
    /**
     * @dev This function ensures that a app manager can be upgraded without losing its data
     */
    function testUpgradeAppManagerAppManager() public {
        /// create user addresses
        address upgradeUser1 = address(100);
        address upgradeUser2 = address(101);
        /// put data in the old app manager
        /// AccessLevel
        switchToAccessLevelAdmin(); // create a access tier and make it the sender.
        applicationAppManager.addAccessLevel(upgradeUser1, 4);
        assertEq(applicationAppManager.getAccessLevel(upgradeUser1), 4);
        applicationAppManager.addAccessLevel(upgradeUser2, 3);
        assertEq(applicationAppManager.getAccessLevel(upgradeUser2), 3);
        /// Risk Data
        vm.stopPrank();
        vm.startPrank(superAdmin);
        switchToRiskAdmin(); // create a access tier and make it the sender.
        applicationAppManager.addRiskScore(upgradeUser1, 75);
        assertEq(75, applicationAppManager.getRiskScore(upgradeUser1));
        applicationAppManager.addRiskScore(upgradeUser2, 65);
        assertEq(65, applicationAppManager.getRiskScore(upgradeUser2));
        /// Account Data
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        /// General Tags Data
        applicationAppManager.addGeneralTag(upgradeUser1, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(upgradeUser1, "TAG1"));
        applicationAppManager.addGeneralTag(upgradeUser2, "TAG2"); //add tag
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
        /// set a app administrator in the new app manager
        appManagerNew.addAppAdministrator(appAdministrator);
        switchToAppAdministrator(); // create a app admin and make it the sender.
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

    ///--------------- PROVIDER UPGRADES ---------------

    // Test setting General Tag provider contract address
    function testSetNewGeneralTagProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        GeneralTags dataMod = new GeneralTags(address(applicationAppManager));
        applicationAppManager.proposeGeneralTagsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.GENERAL_TAG);
        assertEq(address(dataMod), applicationAppManager.getGeneralTagProvider());
    }

    // Test setting access level provider contract address
    function testSetNewAccessLevelProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        AccessLevels dataMod = new AccessLevels(address(applicationAppManager));
        applicationAppManager.proposeAccessLevelsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCESS_LEVEL);
        assertEq(address(dataMod), applicationAppManager.getAccessLevelProvider());
    }

    // Test setting account  provider contract address
    function testSetNewAccountProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        Accounts dataMod = new Accounts(address(applicationAppManager));
        applicationAppManager.proposeAccountsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCOUNT);
        assertEq(address(dataMod), applicationAppManager.getAccountProvider());
    }

    // Test setting risk provider contract address
    function testSetNewRiskScoreProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        RiskScores dataMod = new RiskScores(address(applicationAppManager));
        applicationAppManager.proposeRiskScoresProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.RISK_SCORE);
        assertEq(address(dataMod), applicationAppManager.getRiskScoresProvider());
    }

    // Test setting pause provider contract address
    function testSetNewPauseRulesProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        PauseRules dataMod = new PauseRules(address(applicationAppManager));
        applicationAppManager.proposePauseRulesProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.PAUSE_RULE);
        assertEq(address(dataMod), applicationAppManager.getPauseRulesProvider());
    }
}
