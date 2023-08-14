// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/data/PauseRule.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import "src/data/GeneralTags.sol";
import "src/data/PauseRules.sol";
import "src/data/AccessLevels.sol";
import "src/data/RiskScores.sol";
import "src/data/Accounts.sol";
import "src/data/IDataModule.sol";
import "src/example/ApplicationERC20.sol";
import "src/example/ApplicationERC20Handler.sol";
import "src/example/ApplicationERC721.sol";
import "src/example/ApplicationERC721Handler.sol";
import "src/token/IAdminWithdrawalRuleCapable.sol";
import "test/helpers/TestCommon.sol";

contract ApplicationAppManagerTest is TestCommon {
    ApplicationAppManager public applicationAppManager2;

    ApplicationHandler public applicationHandler2;
    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    uint256 public constant TEST_DATE = 1666706998;
    uint8[] RISKSCORES = [10, 20, 30, 40, 50, 60, 70, 80];
    uint8[] ACCESSTIERS = [1, 1, 1, 2, 2, 2, 3, 4];
    string tokenName = "FEUD";

    function setUp() public {
        vm.startPrank(superAdmin);
        /// Set up the protocol and an applicationAppManager
        setUpProtocolAndAppManager();
        vm.stopPrank();
        vm.startPrank(address(88));
        applicationAppManager2 = new ApplicationAppManager(address(88), "Castlevania2", false);
        applicationHandler2 = new ApplicationHandler(address(ruleProcessor), address(applicationAppManager2));
        applicationAppManager2.setNewApplicationHandlerAddress(address(applicationHandler2));

        switchToAppAdministrator();
        /// add Risk Admin
        applicationAppManager.addRiskAdmin(riskAdmin);
        /// add rule Admin
        applicationAppManager.addRuleAdministrator(ruleAdmin);

        vm.warp(TEST_DATE); // set block.timestamp
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

    function testRenounceSuperAdmin() public {
        switchToSuperAdmin();
        applicationAppManager.renounceRole(SUPER_ADMIN_ROLE, superAdmin);
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
    function testRevokeAppAdministrator() public {
        switchToSuperAdmin();
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

    /// Test renounce Application Administrators role when Admin Withdrawal rule is active
    function testRenounceAppAdministratorAdminWithdrawalERC20() public {
        vm.warp(TEST_DATE);
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        // Deploy a fully configured ERC20
        ApplicationERC20 applicationCoin = new ApplicationERC20("application", "FRANK", address(applicationAppManager));
        ApplicationERC20Handler applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(applicationCoin), false);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationAppManager.registerToken("FRANK", address(applicationCoin));

        // Deploy a fully configured ERC721
        ApplicationERC721 applicationNFT = new ApplicationERC721("PudgyParakeet", "THRK", address(applicationAppManager), "https://SampleApp.io");
        ApplicationERC721Handler applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(applicationNFT), false);
        applicationNFT.connectHandlerToToken(address(applicationNFTHandler));
        applicationAppManager.registerToken("THRK", address(applicationNFT));

        // add admin withdrawal rule that covers current time period
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 1_000_000 * (10 ** 18), block.timestamp + 365 days);

        // apply admin withdrawal rule to an ERC20
        applicationCoinHandler.setAdminWithdrawalRuleId(_index);
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        // try to renounce AppAdmin
        vm.expectRevert(0x23a87520);
        applicationAppManager.renounceAppAdministrator();
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // try to deactivate the rule
        vm.expectRevert(0x23a87520);
        applicationCoinHandler.activateAdminWithdrawalRule(false);
        // try to set the rule to a different one.
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 5_000_000 * (10 ** 18), block.timestamp + 365 days);
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
        vm.warp(TEST_DATE);
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        // Deploy a fully configured ERC20
        ApplicationERC20 applicationCoin = new ApplicationERC20("application", "FRANK", address(applicationAppManager));
        ApplicationERC20Handler applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(applicationCoin), false);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationAppManager.registerToken("FRANK", address(applicationCoin));

        // Deploy a fully configured ERC721
        ApplicationERC721 applicationNFT = new ApplicationERC721("PudgyParakeet", "THRK", address(applicationAppManager), "https://SampleApp.io");
        ApplicationERC721Handler applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(applicationNFT), false);
        applicationNFT.connectHandlerToToken(address(applicationNFTHandler));
        applicationAppManager.registerToken("THRK", address(applicationNFT));

        // add admin withdrawal rule that covers current time period
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 1_000_000 * (10 ** 18), block.timestamp + 365 days);

        // apply admin withdrawal rule to an ERC721
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        // try to renounce AppAdmin
        vm.expectRevert(0x23a87520);
        applicationAppManager.renounceAppAdministrator();
        // try to deactivate the rule
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.expectRevert(0x23a87520);
        applicationNFTHandler.activateAdminWithdrawalRule(false);
        // try to set the rule to a different one.
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 5_000_000 * (10 ** 18), block.timestamp + 365 days);
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
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769924800, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
    }

    function testRemovePauseRule() public {
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769924800, 1769984800);
        PauseRule[] memory test = applicationAppManager.getPauseRules();
        assertTrue(test.length == 1);
        applicationAppManager.removePauseRule(1769924800, 1769984800);
        PauseRule[] memory removeTest = applicationAppManager.getPauseRules();
        assertTrue(removeTest.length == 0);
    }

    function testAutoCleaningRules() public {
        vm.warp(TEST_DATE);

        switchToRuleAdmin();
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
        switchToRuleAdmin();
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
        switchToRuleAdmin();
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
        switchToRuleAdmin();
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
        /// check registration of treasury
        applicationAppManager.registerTreasury(address(0x111));
        assertTrue(applicationAppManager.isTreasury(address(0x111)));
        vm.expectRevert();
        applicationAppManager.registerTreasury(address(0x111));

        applicationAppManager.registerTreasury(address(0x222));
        applicationAppManager.registerTreasury(address(0x333));
        applicationAppManager.deRegisterTreasury(address(0x111));
    }

    ///-----------------------PAUSE ACTIONS-----------------------------///
    /// Test the checkAction. This tests all AccessLevel application compliance
    function testCheckActionWithPauseActive() public {
        // check if users can use system when not paused
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can not use system when paused
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769924800, 1769984800);
        switchToAppAdministrator();
        vm.warp(1769924800); // set block.timestamp
        vm.expectRevert();
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system after the pause rule expires
        vm.warp(1769984801); // set block.timestamp
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system when in pause block but the pause has been deleted
        switchToRuleAdmin();
        applicationAppManager.removePauseRule(1769924800, 1769984800);
        switchToAppAdministrator();
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
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
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
        applicationAppManager.addPauseRule(1769924800, 1769984800);
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
