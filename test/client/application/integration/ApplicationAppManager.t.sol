// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

contract ApplicationAppManagerTest is TestCommonFoundry {

    uint8[] RISKSCORES = [10, 20, 30, 40, 50, 60, 70, 80];
    uint8[] ACCESSLEVELS = [1, 1, 1, 2, 2, 2, 3, 4];
    ApplicationERC20 frank;
    ApplicationERC20 applicationCoinA;
    ApplicationERC20 applicationCoinB;
    ApplicationERC20 applicationCoinC;
    HandlerDiamond frankCoinHandler;
    HandlerDiamond applicationCoinHandlerA;
    HandlerDiamond applicationCoinHandlerB;
    HandlerDiamond applicationCoinHandlerC;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        switchToAppAdministrator();
        vm.warp(Blocktime); // set block.timestamp
        frank = _createERC20("FRANK", "FRK", applicationAppManager);
        frankCoinHandler = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(frankCoinHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(frank));
        frank.connectHandlerToToken(address(frankCoinHandler));

        applicationCoinA = _createERC20("CoinA", "A", applicationAppManager);
        applicationCoinHandlerA = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandlerA)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoinA));
        applicationCoinA.connectHandlerToToken(address(applicationCoinHandlerA));

        applicationCoinB = _createERC20("CoinB", "B", applicationAppManager);
        applicationCoinHandlerB = _createERC20HandlerDiamond();
            ERC20HandlerMainFacet(address(applicationCoinHandlerB)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoinB));
        applicationCoinB.connectHandlerToToken(address(applicationCoinHandlerB));

        applicationCoinC = _createERC20("coinC", "C", applicationAppManager);
        applicationCoinHandlerC = _createERC20HandlerDiamond();
            ERC20HandlerMainFacet(address(applicationCoinHandlerC)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoinC));
        applicationCoinC.connectHandlerToToken(address(applicationCoinHandlerC));

    }

    function testAppManagerAndHandlerVersions() public {
        string memory version = applicationAppManager.version();
        assertEq(version, "1.1.0");
        version = applicationHandler.version();
        assertEq(version, "1.1.0");
    }

    function testIsSuperAdmin() public {
        assertEq(applicationAppManager.isSuperAdmin(superAdmin), true);
        assertEq(applicationAppManager.isSuperAdmin(appAdministrator), false);
    }

    function testIsAppAdministrator() public {
        assertEq(applicationAppManager.isAppAdministrator(superAdmin), true);
    }

    function testMigratingSuperAdmin() public {
        address newSuperAdmin = address(0xACE);
        switchToRiskAdmin();
        /// first let's check that a non superAdmin can't propose a new SuperAdmin
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

    function testFailAddAppAdministrator() public {
        applicationAppManager.addAppAdministrator(appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.isAppAdministrator(user), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user
        applicationAppManager.addAppAdministrator(address(88));
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
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        applicationAppManager.addAppAdministrator(address(77)); //set an additional app administrator
        assertEq(applicationAppManager.isAppAdministrator(address(77)), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, address(77)), true); // verify it was added as a app administrator

        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(user); //interact as a user
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000ddd is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, address(77)); // try to revoke other app administrator
    }

    function testRenounceAppAdministrator() public {
        switchToSuperAdmin(); 
        applicationAppManager.revokeRole(APP_ADMIN_ROLE,superAdmin);
        switchToAppAdministrator(); 
        applicationAppManager.renounceAppAdministrator();
    }

    function testRenounceAppAdministratorAdminMinTokenBalanceERC20() public {
        vm.warp(Blocktime);
        // add admin withdrawal rule that covers current time period
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 1_000_000 * (10 ** 18), block.timestamp + 365 days);
        // apply admin withdrawal rule to an ERC20
        ERC20HandlerMainFacet(address(applicationCoinHandler)).setAdminMinTokenBalanceId(_createActionsArray(), _index);
        switchToRuleBypassAccount();
        // try to renounce ruleBypassAccount
        vm.expectRevert(0x4ba7941c);
        applicationAppManager.renounceRuleBypassAccount();
        // try revoking from superAdmin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0x4ba7941c);
        applicationAppManager.revokeRole(RULE_BYPASS_ACCOUNT, appAdministrator);
        // try to deactivate the rule
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.expectRevert(0x4ba7941c);
        ERC20HandlerMainFacet(address(applicationCoinHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
        // try to set the rule to a different one.
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 5_000_000 * (10 ** 18), block.timestamp + 365 days);
        vm.expectRevert(0x4ba7941c);
        ERC20HandlerMainFacet(address(applicationCoinHandler)).setAdminMinTokenBalanceId(_createActionsArray(), _index);
        // move a year into the future so that the rule is expired
        vm.warp(block.timestamp + (366 days));
        switchToRuleBypassAccount(); 
        // try to renounce AppAdmin(this one should work)
        applicationAppManager.renounceRuleBypassAccount();
    }

    function testRenounceAppAdministratorAdminMinTokenBalanceERC721() public {
        vm.warp(Blocktime);
        // add admin withdrawal rule that covers current time period
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 1_000_000 * (10 ** 18), block.timestamp + 365 days);
        // apply admin withdrawal rule to an ERC721
         ERC721HandlerMainFacet(address(applicationNFTHandler)).setAdminMinTokenBalanceId(_createActionsArray(), _index);
        switchToRuleBypassAccount();
        // try to renounce ruleBypassAccount
        vm.expectRevert(0x4ba7941c);
        applicationAppManager.renounceRuleBypassAccount();
        // try revoking from superAdmin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0x4ba7941c);
        applicationAppManager.revokeRole(RULE_BYPASS_ACCOUNT, appAdministrator);
        // try to deactivate the rule
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.expectRevert(0x4ba7941c);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
        // try to set the rule to a different one.
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 5_000_000 * (10 ** 18), block.timestamp + 365 days);
        vm.expectRevert(0x4ba7941c);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setAdminMinTokenBalanceId(_createActionsArray(), _index);
        // move a year into the future so that the rule is expired
        vm.warp(block.timestamp + (366 days));
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        // try to renounce RuleBypassAccount(this one should work)
        applicationAppManager.renounceRuleBypassAccount();
    }

    function testAddRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
    }

    function testAddMultipleRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addMultipleRiskAdmin(ADDRESSES); //add risk admins
        /// check only addresses in array are risk admins
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.isRiskAdmin(ADDRESSES[i]), true);
        }
        assertEq(applicationAppManager.isRiskAdmin(address(0xFF9)), false);
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
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(riskAdmin); //interact as the created risk admin
        applicationAppManager.renounceRiskAdmin();
    }

    function testRevokeRiskAdminA() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);
        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), false);
    }

    function testFailRevokeRiskAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(address(0xB0B)); //add risk admin
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(0xB0B)), true);
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

    function testAddMultipleaccessLevelAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addMultipleAccessLevelAdmins(ADDRESSES); //add AccessLevel admin address array
        /// check addresses in array are added as access level admins
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.isAccessLevelAdmin(ADDRESSES[i]), true);
        }
        /// address not in array should = false
        assertEq(applicationAppManager.isAccessLevelAdmin(address(0xFF77)), false);
    }

    function testFailAddaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        applicationAppManager.addAccessLevelAdmin(address(88)); //add AccessLevel admin
    }

    function testRenounceaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
        applicationAppManager.renounceAccessLevelAdmin();
    }

    function testRevokeaccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);
        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), false);
    }

    function testFailRevokeaccessLevelAdmin() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        applicationAppManager.addAccessLevelAdmin(address(0xB0B)); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessLevelAdmin(accessLevelAdmin), true);
        assertEq(applicationAppManager.isAccessLevelAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
    }

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
        applicationAppManager.addAccessLevelAdmin(address(0));
        vm.expectRevert();
        applicationAppManager.addRiskAdmin(address(0));

        vm.expectRevert();
        new ApplicationHandler(address(0), address(applicationAppManager));

        vm.expectRevert();
        new ApplicationHandler(address(ruleProcessor), address(0x0));

        vm.expectRevert();
        applicationAppManager.addAccessLevel(address(0), 1);
        vm.expectRevert();
        applicationAppManager.addTag(address(0), "TESTZERO");
        vm.expectRevert();
        applicationAppManager.addRiskScore(address(0), 4);
    }

    function testAddAccessLevel() public {
        switchToAccessLevelAdmin(); // create an access level admin and make it the sender.
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testAddAccessLevelToMultipleAccounts() public {
        switchToAccessLevelAdmin(); // create an access level admin and make it the sender.

        applicationAppManager.addAccessLevelToMultipleAccounts(ADDRESSES, 4);
        /// check addresses in array are correct access level
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getAccessLevel(ADDRESSES[i]), 4);
        }
        assertEq(applicationAppManager.getAccessLevel(address(0xFF9)), 0);
        assertEq(applicationAppManager.getAccessLevel(address(user)), 0);
    }

    function testAddMultipleAccessLevels() public {
        switchToAccessLevelAdmin(); // create a access level admin and make it the sender.

        applicationAppManager.addMultipleAccessLevels(ADDRESSES, ACCESSLEVELS);
        /// ACCESSLEVELS ARRAY [1, 1, 1, 2, 2, 2, 3, 4]
        /// check addresses in array are correct access level
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getAccessLevel(ADDRESSES[i]), ACCESSLEVELS[i]);
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
        switchToAccessLevelAdmin(); // create a access level admin and make it the sender.
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

    function testAddTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addTag(user, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(user, "TAG1"));

        applicationAppManager.addTag(user, "TAG1"); //add tag again to test event emission for TagAlreadyApplied event
    }

    function testAddTagToMultipleAccounts() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        applicationAppManager.addTagToMultipleAccounts(ADDRESSES, "TAG1"); //add tag
        assertTrue(applicationAppManager.hasTag(address(0xFF1), "TAG1"));

        applicationAppManager.addTag(address(0xFF1), "TAG1"); //add tag again to test event emission for TagAlreadyApplied event
    }

    // Test adding multiple tags to multiple accounts
    function testAddMultipleTagsToMultipleAccouns() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.

        /// Create Tag Array
        bytes32[] memory genTags = createBytes32Array(bytes32("TAG"), bytes32("TAG1"), bytes32("TAG2"), bytes32("TAG3"), bytes32("TAG4"), bytes32("TAG5"), bytes32("TAG6"), bytes32("TAG7"));
        /// create mismatch tag array
        bytes32[] memory misMatchArray = createBytes32Array("TAG1", "TAG2");
        /// create mistmatch address array
        address[] memory misMatchAddressArray = createAddressArray(user, address(0xFF77), address(0xFF88));

        applicationAppManager.addMultipleTagToMultipleAccounts(ADDRESSES, genTags); //add tags
        assertTrue(applicationAppManager.hasTag(address(0xFF1), "TAG"));
        assertTrue(applicationAppManager.hasTag(address(0xFF2), "TAG1"));
        assertTrue(applicationAppManager.hasTag(address(0xFF8), "TAG7"));

        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleTagToMultipleAccounts(misMatchAddressArray, genTags);

        vm.expectRevert(0x028a6c58);
        applicationAppManager.addMultipleTagToMultipleAccounts(ADDRESSES, misMatchArray);

        applicationAppManager.addTag(address(0xFF1), "TAG1"); //add tag again to test event emission for TagAlreadyApplied event
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

    function testOverAllTags() public {
        switchToAppAdministrator();
        /// test adding a singular Tag
        applicationAppManager.addTag(user, "TAG1"); //add tag
        /// add one tag to multiple addresses
        applicationAppManager.addTagToMultipleAccounts(ADDRESSES, "TAG2"); //add tags
        /// add multiple tags to multiple addresses
        address[] memory addresses = createAddressArray(address(0xBABE), address(0xDADD));
        bytes32[] memory tags = createBytes32Array(bytes32("BABE"), bytes32("DADD"));

        applicationAppManager.addMultipleTagToMultipleAccounts(addresses, tags);

        assertTrue(applicationAppManager.hasTag(user, "TAG1"));
        assertFalse(applicationAppManager.hasTag(user, "TAG2"));
        assertFalse(applicationAppManager.hasTag(user, "BABE"));
        assertFalse(applicationAppManager.hasTag(user, "DADD"));
        applicationAppManager.addTag(user, "TAG2");
        applicationAppManager.addTag(user, "BABE");
        applicationAppManager.addTag(user, "DADD");
        applicationAppManager.addTag(user, "FIFTH");

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

        applicationAppManager.removeTag(user, "TAG1");
        assertFalse(applicationAppManager.hasTag(user, "TAG1"));
        assertTrue(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "BABE"));
        assertTrue(applicationAppManager.hasTag(user, "DADD"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));
        applicationAppManager.removeTag(address(0xFF1), "TAG2");
        assertFalse(applicationAppManager.hasTag(address(0xFF1), "TAG2"));
        applicationAppManager.removeTag(address(0xBABE), "BABE");
        assertFalse(applicationAppManager.hasTag(address(0xBABE), "BABE"));
        applicationAppManager.removeTag(address(0xDADD), "DADD");
        assertFalse(applicationAppManager.hasTag(address(0xDADD), "DADD"));

        /// remove last tag
        applicationAppManager.removeTag(user, "DADD");
        assertFalse(applicationAppManager.hasTag(user, "DADD"));
        assertTrue(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "BABE"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));

        /// remove tag in the middle
        applicationAppManager.removeTag(user, "BABE");
        assertFalse(applicationAppManager.hasTag(user, "BABE"));
        assertTrue(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));

        /// remove last tag again
        applicationAppManager.removeTag(user, "TAG2");
        assertFalse(applicationAppManager.hasTag(user, "TAG2"));
        assertTrue(applicationAppManager.hasTag(user, "FIFTH"));

        /// remove only tag
        applicationAppManager.removeTag(user, "FIFTH");
        assertFalse(applicationAppManager.hasTag(user, "FIFTH"));
    }

    /// Test the register token.
    function test_AppManagerRegisterToken() public {
        
        /// register the tokens
        applicationAppManager.registerToken("FRANK", address(frank));
        assertEq(address(frank), applicationAppManager.getTokenAddress("FRANK"));

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
        applicationAppManager.registerToken("FRANK", address(frank));
        assertEq(address(frank), applicationAppManager.getTokenAddress("FRANK"));

        address[] memory list = applicationAppManager.getTokenList();
        uint len = list.length;
        // deregister the first coin
        applicationAppManager.deregisterToken("FRANK");
        assertEq(address(0), applicationAppManager.getTokenAddress("FRANK"));
        list = applicationAppManager.getTokenList();
        assertEq(list.length, len - 1);

        // deregister coinB
        applicationAppManager.deregisterToken("CoinB");
        assertEq(address(0), applicationAppManager.getTokenAddress("CoinB"));
        list = applicationAppManager.getTokenList();
        assertEq(list.length, len - 2);

        // deregister CoinC
        applicationAppManager.deregisterToken("CoinC");
        assertEq(address(0), applicationAppManager.getTokenAddress("CoinC"));
        list = applicationAppManager.getTokenList();
        assertEq(list.length, len - 3);

        // deregister CoinA
        applicationAppManager.deregisterToken("CoinA");
        assertEq(address(0), applicationAppManager.getTokenAddress("CoinA"));
        list = applicationAppManager.getTokenList();
        assertEq(list.length, len - 4);
    }

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

    function testUpgradeAppManagerAppManager() public {
        /// create user addresses
        address upgradeUser1 = address(100);
        address upgradeUser2 = address(101);
        /// put data in the old app manager
        /// AccessLevel data
        switchToAccessLevelAdmin(); // create a access level admin and make it the sender.
        applicationAppManager.addAccessLevel(upgradeUser1, 4);
        assertEq(applicationAppManager.getAccessLevel(upgradeUser1), 4);
        applicationAppManager.addAccessLevel(upgradeUser2, 3);
        assertEq(applicationAppManager.getAccessLevel(upgradeUser2), 3);
        /// Risk Data
        vm.stopPrank();
        vm.startPrank(superAdmin);
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        applicationAppManager.addRiskScore(upgradeUser1, 75);
        assertEq(75, applicationAppManager.getRiskScore(upgradeUser1));
        applicationAppManager.addRiskScore(upgradeUser2, 65);
        assertEq(65, applicationAppManager.getRiskScore(upgradeUser2));
        /// Account Data
        switchToAppAdministrator(); // create a app administrator and make it the sender.
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

    function testSetNewTagProvider() public {
        switchToAppAdministrator(); // create an app administrator and make it the sender.
        Tags dataMod = new Tags(address(applicationAppManager));
        applicationAppManager.proposeTagsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.TAG);
        assertEq(address(dataMod), applicationAppManager.getTagProvider());
    }

    // Test setting access level provider contract address
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
}
