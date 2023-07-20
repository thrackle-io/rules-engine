// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/data/PauseRule.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";

contract ApplicationAppManagerTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationAppManager public applicationAppManager;
    ApplicationAppManager public applicationAppManager2;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationHandler public applicationHandler;
    ApplicationHandler public applicationHandler2;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    uint256 public constant TEST_DATE = 1666706998;
    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];
    uint8[] RISKSCORES = [10, 20, 30, 40, 50, 60, 70, 80];
    uint8[] ACCESSTIERS = [1, 1, 1, 2, 2, 2, 3, 4];
    string tokenName = "FEUD";

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));
        vm.stopPrank();
        vm.startPrank(address(88));
        applicationAppManager2 = new ApplicationAppManager(address(88), "Castlevania2", false);
        applicationHandler2 = new ApplicationHandler(address(ruleProcessor), address(applicationAppManager));
        applicationAppManager2.setNewApplicationHandlerAddress(address(applicationHandler2));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationAppManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler));
        /// add Risk Admin
        applicationAppManager.addRiskAdmin(riskAdmin);

        vm.warp(TEST_DATE); // set block.timestamp
    }

    // Test deployment of data contracts
    function testDeployDataContracts5() public {
        assertEq(applicationAppManager.isUser(user), false);
    }

    ///---------------DEFAULT ADMIN--------------------
    /// Test the Default Admin roles
    function testIsDefaultAdmin() public {
        assertEq(applicationAppManager.isAdmin(defaultAdmin), true);
        assertEq(applicationAppManager.isAdmin(appAdministrator), false);
    }

    /// Test the Application Administrators roles
    function testIsAppAdministrator() public {
        assertEq(applicationAppManager.isAppAdministrator(defaultAdmin), true);
    }

    function testRenounceDefaultAdmin() public {
        applicationAppManager.renounceRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    ///---------------APP ADMIN--------------------
    // Test the Application Administrators roles(only DEFAULT_ADMIN can add app administrator)
    function testAddAppAdministrator() public {
        applicationAppManager.addAppAdministrator(appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.isAppAdministrator(user), false);
    }

    // Test the Application Administrators roles(only DEFAULT_ADMIN can add app administrator)
    function testAddAppAdministrator2() public {
        vm.stopPrank();
        vm.startPrank(address(88));
        applicationAppManager2.addAppAdministrator(user);
        assertEq(applicationAppManager2.isAppAdministrator(user), true);
        assertEq(applicationAppManager2.isAppAdministrator(address(99)), false);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
    }

    function testAddMultipleAppAdministrators() public {
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
    function testRevokeAppAdministrator() public {
        applicationAppManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        applicationAppManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), false);
    }

    /// Test failed revoke Application Administrators role
    function testFailRevokeAppAdministrator() public {
        applicationAppManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        applicationAppManager.addAppAdministrator(address(77)); //set an additional app administrator
        assertEq(applicationAppManager.isAppAdministrator(address(77)), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, address(77)), true); // verify it was added as a app administrator

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(user); //interact as a user

        applicationAppManager.revokeRole(APP_ADMIN_ROLE, address(77)); // try to revoke other app administrator
    }

    /// Test renounce Application Administrators role
    function testRenounceAppAdministrator() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
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
    function testRevokeRiskAdmin() public {
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
        applicationAppManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);
        assertEq(applicationAppManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
    }

    ///---------------ACCESS TIER--------------------
    // Test adding the Access Tier roles
    function testAddAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(AccessTier), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);
    }

    function testAddMultipleAccessTier() public {
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
    function testFailAddAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(AccessTier), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        applicationAppManager.addAccessTier(address(88)); //add AccessLevel admin
    }

    /// Test renounce Access Tier role
    function testRenounceAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(AccessTier), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(AccessTier); //interact as the created AccessLevel admin
        applicationAppManager.renounceAccessTier();
    }

    /// Test revoke Access Tier role
    function testRevokeAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(AccessTier), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);

        applicationAppManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, AccessTier);
        assertEq(applicationAppManager.isAccessTier(AccessTier), false);
    }

    /// Test attempt to revoke Access Tier role from non app administrator
    function testFailRevokeAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(AccessTier), true);
        assertEq(applicationAppManager.isAccessTier(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        applicationAppManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, AccessTier);
    }

    ///---------------USER ADMIN--------------------
    // Test adding the User roles
    function testAddUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addUser(user); //add user
        assertEq(applicationAppManager.isUser(user), true);
        assertEq(applicationAppManager.isUser(address(88)), false);
    }

    // Test adding the User roles
    function testFailAddUser() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(user); //interact as a stamdard user
        applicationAppManager.addUser(address(77)); //add another user
    }

    // Test removing the User roles
    function testRemoveUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addUser(user); //add user
        assertEq(applicationAppManager.isUser(user), true);
        assertEq(applicationAppManager.isUser(address(88)), false);
        applicationAppManager.removeUser(user);
        assertEq(applicationAppManager.isUser(user), false);
    }

    // Test non app administrator attempt at removing the User roles
    function testFailRemoveUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addUser(user); //add user
        assertEq(applicationAppManager.isUser(user), true);
        assertEq(applicationAppManager.isUser(address(88)), false);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(88)); //interact as a different user

        applicationAppManager.removeUser(user);
    }

    // Test getting the User roles
    function testGetUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addUser(user); //add user
        assertEq(applicationAppManager.isUser(user), true);
        assertEq(applicationAppManager.isUser(address(88)), false);
    }

    ///---------------AccessLevel LEVEL MAINTENANCE--------------------
    function testAddAccessLevel() public {
        switchToAccessTier(); // create a access tier and make it the sender.
        console.log("Access Tier Address");
        console.log(AccessTier);
        applicationAppManager.addAccessLevel(user, 4);
        uint8 retLevel = applicationAppManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testAddAccessLevelToMultipleAccounts() public {
        switchToAccessTier(); // create a access tier and make it the sender.

        applicationAppManager.addAccessLevelToMultipleAccounts(ADDRESSES, 4);
        /// check addresses in array are correct access tier level
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getAccessLevel(ADDRESSES[i]), 4);
        }
        assertEq(applicationAppManager.getAccessLevel(address(0xFF9)), 0);
        assertEq(applicationAppManager.getAccessLevel(address(user)), 0);
    }

    function testAddMultipleAccessLevels() public {
        switchToAccessTier(); // create a access tier and make it the sender.

        applicationAppManager.addMultipleAccessLevels(ADDRESSES, ACCESSTIERS);
        /// ACCESSTIERS ARRAY [1, 1, 1, 2, 2, 2, 3, 4]
        /// check addresses in array are correct access tier level
        for (uint256 i; i < ADDRESSES.length; ++i) {
            assertEq(applicationAppManager.getAccessLevel(ADDRESSES[i]), ACCESSTIERS[i]);
        }

        assertEq(applicationAppManager.getAccessLevel(address(0xFF9)), 0);
        assertEq(applicationAppManager.getAccessLevel(address(user)), 0);

        /// create mismatch tag array
        uint8[] memory misMatchArray = new uint8[](2);
        misMatchArray[0] = uint8(3);
        misMatchArray[1] = uint8(77);

        /// create mistmatch address array
        address[] memory misMatchAddressArray = new address[](3);
        misMatchAddressArray[0] = address(user);
        misMatchAddressArray[1] = address(0xFF77);
        misMatchAddressArray[2] = address(0xFF88);

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
        switchToAccessTier(); // create a access tier and make it the sender.
        console.log("Access Tier Address");
        console.log(AccessTier);
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
        uint8[] memory misMatchArray = new uint8[](2);
        misMatchArray[0] = uint8(3);
        misMatchArray[1] = uint8(77);

        /// create mistmatch address array
        address[] memory misMatchAddressArray = new address[](3);
        misMatchAddressArray[0] = address(user);
        misMatchAddressArray[1] = address(0xFF77);
        misMatchAddressArray[2] = address(0xFF88);
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
        switchToAppAdministrator();
        applicationAppManager.addPauseRule(1769924800, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
    }

    function testRemovePauseRule() public {
        switchToAppAdministrator();
        applicationAppManager.addPauseRule(1769924800, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        applicationAppManager.removePauseRule(1769924800, 1769984800);
        PauseRule[] memory removeTest = applicationAppManager.getPauseRules();
        assertTrue(removeTest.length == 0);
    }

    function testAutoCleaningRules() public {
        vm.warp(TEST_DATE);

        switchToAppAdministrator();
        applicationAppManager.addPauseRule(TEST_DATE + 100, TEST_DATE + 200);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        PauseRule[] memory noRule = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);

        vm.warp(TEST_DATE + 201);
        console.log("block's timestamp", block.timestamp);
        assertEq(block.timestamp, TEST_DATE + 201);
        applicationAppManager.addPauseRule(TEST_DATE + 300, TEST_DATE + 400);
        test = applicationAppManager.getPauseRules();
        console.log("test2 length", test.length);
        noRule = applicationAppManager.getPauseRules();
        console.log("noRule2 length", noRule.length);
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);
        vm.warp(TEST_DATE);
    }

    function testRuleSizeLimit() public {
        switchToAppAdministrator();
        vm.warp(TEST_DATE);
        for (uint8 i; i < 15; ) {
            applicationAppManager.addPauseRule(TEST_DATE + (i + 1) * 10, TEST_DATE + (i + 2) * 10);
            unchecked {
                ++i;
            }
        }
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.expectRevert(0xd30bd9c5);
        applicationAppManager.addPauseRule(TEST_DATE + 150, TEST_DATE + 160);
        vm.warp(TEST_DATE);
    }

    function testManualCleaning() public {
        switchToAppAdministrator();
        vm.warp(TEST_DATE);
        for (uint256 i; i < 15; ) {
            applicationAppManager.addPauseRule(TEST_DATE + (i + 1) * 10, TEST_DATE + (i + 2) * 10);
            unchecked {
                ++i;
            }
        }
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.warp(TEST_DATE + 200);
        applicationAppManager.cleanOutdatedRules();
        test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 0);
        vm.warp(TEST_DATE);
    }

    function testAnotherManualCleaning() public {
        switchToAppAdministrator();
        vm.warp(TEST_DATE);
        applicationAppManager.addPauseRule(TEST_DATE + 1000, TEST_DATE + 1010);
        applicationAppManager.addPauseRule(TEST_DATE + 1020, TEST_DATE + 1030);
        applicationAppManager.addPauseRule(TEST_DATE + 40, TEST_DATE + 45);
        applicationAppManager.addPauseRule(TEST_DATE + 1060, TEST_DATE + 1070);
        applicationAppManager.addPauseRule(TEST_DATE + 1080, TEST_DATE + 1090);
        applicationAppManager.addPauseRule(TEST_DATE + 10, TEST_DATE + 20);
        applicationAppManager.addPauseRule(TEST_DATE + 2000, TEST_DATE + 2010);
        applicationAppManager.addPauseRule(TEST_DATE + 2020, TEST_DATE + 2030);
        applicationAppManager.addPauseRule(TEST_DATE + 55, TEST_DATE + 66);
        applicationAppManager.addPauseRule(TEST_DATE + 2060, TEST_DATE + 2070);
        applicationAppManager.addPauseRule(TEST_DATE + 2080, TEST_DATE + 2090);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 11);
        vm.warp(TEST_DATE + 150);
        applicationAppManager.cleanOutdatedRules();
        test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 8);
        vm.warp(TEST_DATE);
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
        bytes32[] memory genTags = new bytes32[](8);
        genTags[0] = bytes32("TAG");
        genTags[1] = bytes32("TAG1");
        genTags[2] = bytes32("TAG2");
        genTags[3] = bytes32("TAG3");
        genTags[4] = bytes32("TAG4");
        genTags[5] = bytes32("TAG5");
        genTags[6] = bytes32("TAG6");
        genTags[7] = bytes32("TAG7");
        /// create mismatch tag array
        bytes32[] memory misMatchArray = new bytes32[](2);
        misMatchArray[0] = bytes32("TAG");
        misMatchArray[1] = bytes32("TAG1");

        /// create mistmatch address array
        address[] memory misMatchAddressArray = new address[](3);
        misMatchAddressArray[0] = address(user);
        misMatchAddressArray[1] = address(0xFF77);
        misMatchAddressArray[2] = address(0xFF88);

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

    ///---------------AccessLevel PROVIDER---------------
    // Test setting access levelprovider contract address
    function testAccessLevelProviderSet() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.setAccessLevelProvider(address(88));
        assertEq(address(88), applicationAppManager.getAccessLevelProvider());
    }

    /// Test the register token.
    function testRegisterToken() public {
        applicationAppManager.registerToken("Frankenstein", address(77));
        assertEq(address(77), applicationAppManager.getTokenAddress("Frankenstein"));
    }

    /// Test the deregister token.
    function testDeregisterToken() public {
        applicationAppManager.registerToken("Frankenstein", address(77));
        assertEq(address(77), applicationAppManager.getTokenAddress("Frankenstein"));
        applicationAppManager.deregisterToken("Frankenstein");
        assertEq(address(0), applicationAppManager.getTokenAddress("Frankenstein"));

        /// test _removeAddress with multiple tokens 
        address testToken1 = address(0x111);
        address testToken2 = address(0x222);
        address testToken3 = address(0x333);
        address testToken4 = address(0x444);
        /// register multiple tokens 
        applicationAppManager.registerToken("TestCoin1", testToken1);
        applicationAppManager.registerToken("TestCoin2", testToken2);
        applicationAppManager.registerToken("TestCoin3", testToken3);

        /// remove token 2 
        applicationAppManager.deregisterToken("TestCoin2");
        /// call the token list and check the length 
        address[] memory list = applicationAppManager.getTokenList();
        assertEq(list.length, 2);
        /// try to register same token twice 
        applicationAppManager.registerToken("TestCoin4", testToken4);
        vm.expectRevert();
        applicationAppManager.registerToken("TestCoin4", testToken4);
    }

    /// Test the register AMM.
    function testRegisterAMM() public {
        applicationAppManager.registerAMM(address(77));
        assertTrue(applicationAppManager.isRegisteredAMM(address(77)));
        /// this is expected to fail because you cannot register same address more than once
        vm.expectRevert(); 
        applicationAppManager.registerAMM(address(77));
    }

    /// Test the deregister AMM.
    function testDeregisterAMM() public {
        applicationAppManager.registerAMM(address(77));
        assertTrue(applicationAppManager.isRegisteredAMM(address(77)));
        applicationAppManager.deRegisterAMM(address(77));
        assertFalse(applicationAppManager.isRegisteredAMM(address(77)));
    }

    function testRegisterAddresses() public {
        /// check registration of staking and treasury 
        applicationAppManager.registerTreasury(address(0x111));
        assertTrue(applicationAppManager.isTreasury(address(0x111)));  
        vm.expectRevert();
        applicationAppManager.registerTreasury(address(0x111));

        applicationAppManager.registerTreasury(address(0x222));
        applicationAppManager.registerTreasury(address(0x333));
        applicationAppManager.deRegisterTreasury(address(0x111));

        applicationAppManager.registerStaking(address(0x222));
        assertTrue(applicationAppManager.isRegisteredStaking(address(0x222)));
        vm.expectRevert();
        applicationAppManager.registerStaking(address(0x222));

        applicationAppManager.registerStaking(address(0x111));
        applicationAppManager.registerStaking(address(0x333));

    }

    ///---------------UTILITY--------------------
    function switchToAppAdministrator() public {
        applicationAppManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);
        assertEq(applicationAppManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(appAdministrator); //interact as the created app administrator
    }

    function switchToAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(AccessTier), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(AccessTier); //interact as the created AccessLevel admin
    }

    function switchToRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add Risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(riskAdmin); //interact as the created Risk admin
    }

    function switchToUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addUser(user); //add AccessLevel admin
        assertEq(applicationAppManager.isUser(user), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(user); //interact as the created AccessLevel admin
    }

    ///-----------------------PAUSE ACTIONS-----------------------------///
    /// Test the checkAction. This tests all AccessLevel application compliance
    function testCheckActionWithPauseActive() public {
        // check if users can use system when not paused
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can not use system when paused
        applicationAppManager.addPauseRule(1769924800, 1769984800);
        vm.warp(1769924800); // set block.timestamp
        vm.expectRevert();
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system after the pause rule expires
        vm.warp(1769984801); // set block.timestamp
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system when in pause block but the pause has been deleted
        applicationAppManager.removePauseRule(1769924800, 1769984800);
        PauseRule[] memory removeTest = applicationAppManager.getPauseRules();
        assertTrue(removeTest.length == 0);
        vm.warp(1769924800); // set block.timestamp
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);
    }

    function testBalanceLimitByRiskScoreFuzzAtAppManagerLevel(uint8 _addressIndex, uint24 _amountSeed) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];
        // set up amounts(accounting for too big and too small numbers)
        if (_amountSeed == 0) {
            _amountSeed = 1;
        }
        if (_amountSeed > 167770) {
            _amountSeed = 167770;
        }
        // add the rule.
        uint8[] memory _riskLevel = new uint8[](4);
        uint48[] memory balanceAmounts = new uint48[](5);
        _riskLevel[0] = 25;
        _riskLevel[1] = 50;
        _riskLevel[2] = 75;
        _riskLevel[3] = 90;
        uint48 riskBalance1 = _amountSeed + 1000;
        uint48 riskBalance2 = _amountSeed + 500;
        uint48 riskBalance3 = _amountSeed + 100;
        uint48 riskBalance4 = _amountSeed;

        balanceAmounts[0] = riskBalance1;
        balanceAmounts[1] = riskBalance2;
        balanceAmounts[2] = riskBalance3;
        balanceAmounts[3] = riskBalance4;
        balanceAmounts[4] = 1;

        ///Register rule with application Handler
        uint32 ruleId = AppRuleDataFacet(address(ruleStorageDiamond)).addAccountBalanceByRiskScore(address(applicationAppManager), _riskLevel, balanceAmounts);
        ///Activate rule
        applicationHandler.setAccountBalanceByRiskRuleId(ruleId);

        /// we set a risk score for user2, user3 and user4
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        applicationAppManager.addRiskScore(_user2, _riskLevel[3]);
        applicationAppManager.addRiskScore(_user3, _riskLevel[2]);
        applicationAppManager.addRiskScore(_user4, _riskLevel[1]);

        ///Execute transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        ///Max riskScore allows for single token balance
        //applicationCoin.transfer(_user2, 1 * (10 ** 18));
        applicationAppManager.checkApplicationRules(ActionTypes.TRADE, _user1, _user2, 0, 1 * (10 ** 18));
        ///Transfer more than Risk Score allows
        vm.expectRevert();
        //applicationCoin.transfer(_user2, riskBalance4 * (10 ** 18) + 1);
        applicationAppManager.checkApplicationRules(ActionTypes.TRADE, _user1, _user2, 1 * (10 ** 18), riskBalance4 * (10 ** 18) + 1);

        vm.expectRevert();
        //applicationCoin.transfer(_user3, riskBalance3 * (10 ** 18) + 1);
        applicationAppManager.checkApplicationRules(ActionTypes.TRADE, _user1, _user3, 0, riskBalance3 * (10 ** 18) + 1);
        ///Transfer more than Risk Score allows
        vm.expectRevert();
        //applicationCoin.transfer(_user4, riskBalance1 * (10 ** 18) + 1);
        applicationAppManager.checkApplicationRules(ActionTypes.TRADE, _user1, _user4, 0, riskBalance1 * (10 ** 18) + 1);
    }

    /**
     * @dev this function ensures that unique addresses can be randomly retrieved from the address array.
     */
    function getUniqueAddresses(uint256 _seed, uint8 _number) public view returns (address[] memory _addressList) {
        _addressList = new address[](ADDRESSES.length);
        // first one will simply be the seed
        _addressList[0] = ADDRESSES[_seed];
        uint256 j;
        if (_number > 1) {
            // loop until all unique addresses are returned
            for (uint256 i = 1; i < _number; i++) {
                // find the next unique address
                j = _seed;
                do {
                    j++;
                    // if end of list reached, start from the beginning
                    if (j == ADDRESSES.length) {
                        j = 0;
                    }
                    if (!exists(ADDRESSES[j], _addressList)) {
                        _addressList[i] = ADDRESSES[j];
                        break;
                    }
                } while (0 == 0);
            }
        }
        return _addressList;
    }

    // Check if an address exists in the list
    function exists(address _address, address[] memory _addressList) public pure returns (bool) {
        for (uint256 i = 0; i < _addressList.length; i++) {
            if (_address == _addressList[i]) {
                return true;
            }
        }
        return false;
    }
}
