// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/application/AppManager.sol";
import "src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "src/data/GeneralTags.sol";
import "src/data/PauseRules.sol";
import "src/data/AccessLevels.sol";
import "src/data/RiskScores.sol";
import "src/data/Accounts.sol";
import "src/data/IDataModule.sol";

contract AppManagerTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    AppManager public appManager;
    ApplicationHandler public applicationHandler;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    uint256 public constant TEST_DATE = 1666706998;
    string tokenName = "FEUD";

    function setUp() public {
        vm.startPrank(defaultAdmin); //set up as the default admin
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        // Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));

        appManager = new AppManager(defaultAdmin, "Castlevania", false);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));
        vm.warp(TEST_DATE); // set block.timestamp
    }

    // Test deployment of data contracts
    function testDeployDataContracts2() public {
        assertEq(appManager.isUser(user), false);
    }

    ///---------------DEFAULT ADMIN--------------------
    /// Test the Default Admin roles
    function testIsDefaultAdmin() public {
        assertEq(appManager.isAdmin(defaultAdmin), true);
        assertEq(appManager.isAdmin(appAdministrator), false);
    }

    /// Test the Application Administrators roles
    function testIsAppAdministrator() public {
        assertEq(appManager.isAppAdministrator(defaultAdmin), true);
    }

    function testRenounceDefaultAdmin() public {
        appManager.renounceRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    ///---------------APP ADMIN--------------------
    // Test the Application Administrators roles(only DEFAULT_ADMIN can add app administrator)
    function testAddAppAdministratorAppManager() public {
        appManager.addAppAdministrator(appAdministrator);
        assertEq(appManager.isAppAdministrator(appAdministrator), true);
        assertEq(appManager.isAppAdministrator(user), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(appAdministrator); //interact as a different user
        appManager.addAppAdministrator(address(77));
        assertTrue(appManager.isAppAdministrator(address(77)));
    }

    // Commented out because the UHGDA style admin role is not required for EVM Product
    // /// Test non default admin attempt to add app administrator
    // function testFailAddAppAdministrator() public {
    //     appManager.addAppAdministrator(appAdministrator);
    //     assertEq(appManager.isAppAdministrator(appAdministrator), true);
    //     assertEq(appManager.isAppAdministrator(user), false);
    //     vm.stopPrank(); //stop interacting as the app administrator
    //     vm.startPrank(address(77)); //interact as a different user
    //     appManager.addAppAdministrator(address(88));
    // }

    /// Test revoke Application Administrators role
    function testRevokeAppAdministrator() public {
        appManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(appManager.isAppAdministrator(appAdministrator), true);
        assertEq(appManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        appManager.revokeRole(APP_ADMIN_ROLE, appAdministrator);
        assertEq(appManager.isAppAdministrator(appAdministrator), false);
    }

    /// Test failed revoke Application Administrators role
    function testFailRevokeAppAdministrator() public {
        appManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(appManager.isAppAdministrator(appAdministrator), true);
        assertEq(appManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        appManager.addAppAdministrator(address(77)); //set an additional app administrator
        assertEq(appManager.isAppAdministrator(address(77)), true);
        assertEq(appManager.hasRole(APP_ADMIN_ROLE, address(77)), true); // verify it was added as a app administrator

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(user); //interact as a normal user

        appManager.revokeRole(APP_ADMIN_ROLE, address(77)); // try to revoke other app administrator
    }

    /// Test renounce Application Administrators role
    function testRenounceAppAdministrator() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.renounceAppAdministrator();
    }

    ///---------------Risk ADMIN--------------------
    // Test adding the Risk Admin roles
    function testAddRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(appManager.isRiskAdmin(riskAdmin), true);
        assertEq(appManager.isRiskAdmin(address(88)), false);
    }

    // Test non app administrator attempt to add the Risk Admin roles
    function testFailAddRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addRiskAdmin(riskAdmin); //add Risk admin
        assertEq(appManager.isRiskAdmin(riskAdmin), true);
        assertEq(appManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        appManager.addRiskAdmin(address(88)); //add risk admin
    }

    /// Test renounce risk Admin role
    function testRenounceRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(appManager.isRiskAdmin(riskAdmin), true);
        assertEq(appManager.isRiskAdmin(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(riskAdmin); //interact as the created risk admin
        appManager.renounceRiskAdmin();
    }

    /// Test revoke risk Admin role
    function testRevokeRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(appManager.isRiskAdmin(riskAdmin), true);
        assertEq(appManager.isRiskAdmin(address(88)), false);

        appManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
        assertEq(appManager.isRiskAdmin(riskAdmin), false);
    }

    /// Test attempt to revoke risk Admin role from non app administrator
    function testFailRevokeRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addRiskAdmin(riskAdmin); //add risk admin
        assertEq(appManager.isRiskAdmin(riskAdmin), true);
        assertEq(appManager.isRiskAdmin(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        appManager.revokeRole(RISK_ADMIN_ROLE, riskAdmin);
    }

    ///---------------ACCESS TIER--------------------
    // Test adding the Access Tier roles
    function testAddAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(appManager.isAccessTier(AccessTier), true);
        assertEq(appManager.isAccessTier(address(88)), false);
    }

    // Test non app administrator attempt to add the Access Tier roles
    function testFailAddAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(appManager.isAccessTier(AccessTier), true);
        assertEq(appManager.isAccessTier(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a non app administrator

        appManager.addAccessTier(address(88)); //add AccessLevel admin
    }

    /// Test renounce Access Tier role
    function testRenounceAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(appManager.isAccessTier(AccessTier), true);
        assertEq(appManager.isAccessTier(address(88)), false);
        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(AccessTier); //interact as the created AccessLevel admin
        appManager.renounceAccessTier();
    }

    /// Test revoke Access Tier role
    function testRevokeAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(appManager.isAccessTier(AccessTier), true);
        assertEq(appManager.isAccessTier(address(88)), false);

        appManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, AccessTier);
        assertEq(appManager.isAccessTier(AccessTier), false);
    }

    /// Test attempt to revoke Access Tier role from non app administrator
    function testFailRevokeAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(appManager.isAccessTier(AccessTier), true);
        assertEq(appManager.isAccessTier(address(88)), false);

        vm.stopPrank(); //stop interacting as the app administrator
        vm.startPrank(address(77)); //interact as a different user

        appManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, AccessTier);
    }

    ///---------------USER ADMIN--------------------
    // Test adding the User roles
    function testAddUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addUser(user); //add user
        assertEq(appManager.isUser(user), true);
        assertEq(appManager.isUser(address(88)), false);
    }

    // Test adding the User roles
    function testFailAddUser() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(user); //interact as a stamdard user
        appManager.addUser(address(77)); //add another user
    }

    // Test removing the User roles
    function testRemoveUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addUser(user); //add user
        assertEq(appManager.isUser(user), true);
        assertEq(appManager.isUser(address(88)), false);

        appManager.removeUser(user);
        assertEq(appManager.isUser(user), false);
    }

    // Test non app administrator attempt at removing the User roles
    function testFailRemoveUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addUser(user); //add user
        assertEq(appManager.isUser(user), true);
        assertEq(appManager.isUser(address(88)), false);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(88)); //interact as a different user

        appManager.removeUser(user);
    }

    // Test getting the User roles
    function testGetUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addUser(user); //add user
        assertEq(appManager.isUser(user), true);
        assertEq(appManager.isUser(address(88)), false);
    }

    ///---------------AccessLevel LEVEL MAINTENANCE--------------------
    function testAddAccessLevel() public {
        switchToAccessTier(); // create a access tier and make it the sender.
        console.log("Access Tier Address");
        console.log(AccessTier);
        appManager.addAccessLevel(user, 4);
        uint8 retLevel = appManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testFailAddAccessLevel() public {
        switchToUser(); // create a user and make it the sender.
        appManager.addAccessLevel(user, 4);
        uint8 retLevel = appManager.getAccessLevel(user);
        assertEq(retLevel, 4);
    }

    function testUpdateAccessLevel() public {
        switchToAccessTier(); // create a access tier and make it the sender.
        console.log("Access Tier Address");
        console.log(AccessTier);
        appManager.addAccessLevel(user, 4);
        uint8 retLevel = appManager.getAccessLevel(user);
        assertEq(retLevel, 4);

        appManager.addAccessLevel(user, 1);
        retLevel = appManager.getAccessLevel(user);
        assertEq(retLevel, 1);
    }

    ///---------------RISK SCORE MAINTENANCE--------------------
    function testAddRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        appManager.addRiskScore(user, 75);
        assertEq(75, appManager.getRiskScore(user));
    }

    function testGetRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        appManager.addRiskScore(user, 75);
        assertEq(75, appManager.getRiskScore(user));
    }

    function testFailAddRiskScore() public {
        switchToUser(); // create a user and make it the sender.
        appManager.addRiskScore(user, 44);
        assertEq(44, appManager.getRiskScore(user));
    }

    function testUpdateRiskScore() public {
        switchToRiskAdmin(); // create a risk admin and make it the sender.
        appManager.addRiskScore(user, 75);
        assertEq(75, appManager.getRiskScore(user));
        // update the score
        appManager.addRiskScore(user, 55);
        assertEq(55, appManager.getRiskScore(user));
    }

    ///---------------GENERAL TAGS--------------------
    // Test adding the general tags
    function testAddGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addGeneralTag(user, "TAG1"); //add tag
        assertTrue(appManager.hasTag(user, "TAG1"));
    }

    // Test when tag is invalid
    function testFailAddGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addGeneralTag(user, ""); //add blank tag
    }

    // Test scenarios for checking specific tags.
    function testHasGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addGeneralTag(user, "TAG1"); //add tag
        appManager.addGeneralTag(user, "TAG3"); //add tag
        assertTrue(appManager.hasTag(user, "TAG1"));
        assertFalse(appManager.hasTag(user, "TAG2"));
        assertTrue(appManager.hasTag(user, "TAG3"));
    }

    // Test removal of the tag
    function testRemoveGeneralTag() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addGeneralTag(user, "TAG1"); //add tag
        assertTrue(appManager.hasTag(user, "TAG1"));
        appManager.removeGeneralTag(user, "TAG1");
        assertFalse(appManager.hasTag(user, "TAG1"));
    }

    ///---------------PAUSE RULES----------------
    // Test setting/listing/removing pause rules
    function testAddPauseRule() public {
        switchToAppAdministrator();
        appManager.addPauseRule(1769924800, 1769984800);
        PauseRule[] memory test = appManager.getPauseRules();
        PauseRule[] memory noRule = appManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);
    }

    function testRemovePauseRule() public {
        switchToAppAdministrator();
        appManager.addPauseRule(1769924800, 1769984800);
        PauseRule[] memory test = appManager.getPauseRules();
        assertTrue(test.length == 1);
        appManager.removePauseRule(1769924800, 1769984800);
        PauseRule[] memory removeTest = appManager.getPauseRules();
        assertTrue(removeTest.length == 0);
    }

    function testAutoCleaningRules() public {
        vm.warp(TEST_DATE);

        switchToAppAdministrator();
        appManager.addPauseRule(TEST_DATE + 100, TEST_DATE + 200);
        PauseRule[] memory test = appManager.getPauseRules();
        PauseRule[] memory noRule = appManager.getPauseRules();
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);

        vm.warp(TEST_DATE + 201);
        console.log("block's timestamp", block.timestamp);
        assertEq(block.timestamp, TEST_DATE + 201);
        appManager.addPauseRule(TEST_DATE + 300, TEST_DATE + 400);
        test = appManager.getPauseRules();
        console.log("test2 length", test.length);
        noRule = appManager.getPauseRules();
        console.log("noRule2 length", noRule.length);
        assertTrue(test.length == 1);
        assertTrue(noRule.length == 1);
        vm.warp(TEST_DATE);
    }

    function testRuleSizeLimit() public {
        switchToAppAdministrator();
        vm.warp(TEST_DATE);
        for (uint8 i; i < 15; i++) {
            appManager.addPauseRule(TEST_DATE + (i + 1) * 10, TEST_DATE + (i + 2) * 10);
        }
        PauseRule[] memory test = appManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.expectRevert(0xd30bd9c5);
        appManager.addPauseRule(TEST_DATE + 150, TEST_DATE + 160);
        vm.warp(TEST_DATE);
    }

    function testManualCleaning() public {
        switchToAppAdministrator();
        vm.warp(TEST_DATE);
        for (uint8 i; i < 15; i++) {
            appManager.addPauseRule(TEST_DATE + (i + 1) * 10, TEST_DATE + (i + 2) * 10);
        }
        PauseRule[] memory test = appManager.getPauseRules();
        assertTrue(test.length == 15);
        vm.warp(TEST_DATE + 200);
        appManager.cleanOutdatedRules();
        test = appManager.getPauseRules();
        assertTrue(test.length == 0);
        vm.warp(TEST_DATE);
    }

    function testAnotherManualCleaning() public {
        switchToAppAdministrator();
        vm.warp(TEST_DATE);
        appManager.addPauseRule(TEST_DATE + 1000, TEST_DATE + 1010);
        appManager.addPauseRule(TEST_DATE + 1020, TEST_DATE + 1030);
        appManager.addPauseRule(TEST_DATE + 40, TEST_DATE + 45);
        appManager.addPauseRule(TEST_DATE + 1060, TEST_DATE + 1070);
        appManager.addPauseRule(TEST_DATE + 1080, TEST_DATE + 1090);
        appManager.addPauseRule(TEST_DATE + 10, TEST_DATE + 20);
        appManager.addPauseRule(TEST_DATE + 2000, TEST_DATE + 2010);
        appManager.addPauseRule(TEST_DATE + 2020, TEST_DATE + 2030);
        appManager.addPauseRule(TEST_DATE + 55, TEST_DATE + 66);
        appManager.addPauseRule(TEST_DATE + 2060, TEST_DATE + 2070);
        appManager.addPauseRule(TEST_DATE + 2080, TEST_DATE + 2090);
        PauseRule[] memory test = appManager.getPauseRules();
        assertTrue(test.length == 11);
        vm.warp(TEST_DATE + 150);
        appManager.cleanOutdatedRules();
        test = appManager.getPauseRules();
        assertTrue(test.length == 8);
        vm.warp(TEST_DATE);
    }

    ///--------------- PROVIDER UPGRADES ---------------

    // Test setting General Tag provider contract address
    function testSetNewGeneralTagProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        GeneralTags dataMod = new GeneralTags(address(appManager));
        appManager.proposeGeneralTagsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.GENERAL_TAG);
        assertEq(address(dataMod), appManager.getGeneralTagProvider());
    }

    // Test setting access level provider contract address
    function testSetNewAccessLevelProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        AccessLevels dataMod = new AccessLevels(address(appManager));
        appManager.proposeAccessLevelsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCESS_LEVEL);
        assertEq(address(dataMod), appManager.getAccessLevelProvider());
    }

    // Test setting account  provider contract address
    function testSetNewAccountProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        Accounts dataMod = new Accounts(address(appManager));
        appManager.proposeAccountsProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.ACCOUNT);
        assertEq(address(dataMod), appManager.getAccountProvider());
    }

    // Test setting risk provider contract address
    function testSetNewRiskScoreProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        RiskScores dataMod = new RiskScores(address(appManager));
        appManager.proposeRiskScoresProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.RISK_SCORE);
        assertEq(address(dataMod), appManager.getRiskScoresProvider());
    }

    // Test setting pause provider contract address
    function testSetNewPauseRulesProvider() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        PauseRules dataMod = new PauseRules(address(appManager));
        appManager.proposePauseRulesProvider(address(dataMod));
        dataMod.confirmDataProvider(IDataModule.ProviderType.PAUSE_RULE);
        assertEq(address(dataMod), appManager.getPauseRulesProvider());
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
        switchToAccessTier(); // create a access tier and make it the sender.
        appManager.addAccessLevel(upgradeUser1, 4);
        assertEq(appManager.getAccessLevel(upgradeUser1), 4);
        appManager.addAccessLevel(upgradeUser2, 3);
        assertEq(appManager.getAccessLevel(upgradeUser2), 3);
        /// Risk Data
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        switchToRiskAdmin(); // create a access tier and make it the sender.
        appManager.addRiskScore(upgradeUser1, 75);
        assertEq(75, appManager.getRiskScore(upgradeUser1));
        appManager.addRiskScore(upgradeUser2, 65);
        assertEq(65, appManager.getRiskScore(upgradeUser2));
        /// Account Data
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addUser(upgradeUser1); //add user
        assertEq(appManager.isUser(upgradeUser1), true);
        appManager.addUser(upgradeUser2); //add user
        assertEq(appManager.isUser(upgradeUser2), true);
        /// General Tags Data
        appManager.addGeneralTag(upgradeUser1, "TAG1"); //add tag
        assertTrue(appManager.hasTag(upgradeUser1, "TAG1"));
        appManager.addGeneralTag(upgradeUser2, "TAG2"); //add tag
        assertTrue(appManager.hasTag(upgradeUser2, "TAG2"));
        /// Pause Rule Data
        appManager.addPauseRule(1769924800, 1769984800);
        PauseRule[] memory test = appManager.getPauseRules();
        assertTrue(test.length == 1);

        /// create new app manager
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        AppManager appManagerNew = new AppManager(defaultAdmin, "Castlevania", false);
        /// migrate data contracts to new app manager
        /// set a app administrator in the new app manager
        appManagerNew.addAppAdministrator(appAdministrator);
        switchToAppAdministrator(); // create a app admin and make it the sender.
        appManager.proposeDataContractMigration(address(appManagerNew));
        appManagerNew.confirmDataContractMigration(address(appManager));
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
        assertEq(appManagerNew.isUser(upgradeUser1), true);
        assertEq(appManagerNew.isUser(upgradeUser2), true);
    }

    ///---------------UTILITY--------------------
    function switchToAppAdministrator() public {
        appManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(appManager.isAppAdministrator(appAdministrator), true);
        assertEq(appManager.hasRole(APP_ADMIN_ROLE, appAdministrator), true); // verify it was added as a app administrator

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(appAdministrator); //interact as the created app administrator
    }

    function switchToAccessTier() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addAccessTier(AccessTier); //add AccessLevel admin
        assertEq(appManager.isAccessTier(AccessTier), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(AccessTier); //interact as the created AccessLevel admin
    }

    function switchToRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addRiskAdmin(riskAdmin); //add Risk admin
        assertEq(appManager.isRiskAdmin(riskAdmin), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(riskAdmin); //interact as the created Risk admin
    }

    function switchToUser() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        appManager.addUser(user); //add AccessLevel admin
        assertEq(appManager.isUser(user), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(user); //interact as the created AccessLevel admin
    }
}
