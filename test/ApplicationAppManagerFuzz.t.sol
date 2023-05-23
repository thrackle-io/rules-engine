// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/application/AppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "../src/data/IPauseRules.sol";
import "./DiamondTestUtil.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/economic/TokenRuleRouter.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import {TaggedRuleProcessorDiamondTestUtil} from "./TaggedRuleProcessorDiamondTestUtil.sol";

contract ApplicationAppManagerFuzzTest is TaggedRuleProcessorDiamondTestUtil, DiamondTestUtil, RuleProcessorDiamondTestUtil {
    AppManager public appManager;
    ApplicationHandler public applicationHandler;
    TokenRuleRouter tokenRuleRouter;
    TokenRuleRouterProxy ruleRouterProxy;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    RuleProcessorDiamond tokenRuleProcessorsDiamond;
    RuleStorageDiamond ruleStorageDiamond;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    uint256 public constant TEST_DATE = 1666706998;
    string tokenName = "FEUD";
    address[] ADDRESSES = [defaultAdmin, appAdministrator, AccessTier, riskAdmin, user, address(0xBEEF), address(0xC0FFEE), address(0xF00D)];

    function setUp() public {
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the token rule processor diamond
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        // Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // Deploy the token rule processor diamond
        taggedRuleProcessorDiamond = getTaggedRuleProcessorDiamond();
        //connect data diamond with Tagged Rule Processor diamond
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        tokenRuleRouter = new TokenRuleRouter();
        /// connect the TokenRuleRouter to its child Diamond
        ruleRouterProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        TokenRuleRouter(address(ruleRouterProxy)).initialize(payable(address(tokenRuleProcessorsDiamond)), payable(address(taggedRuleProcessorDiamond)));

        appManager = new AppManager(defaultAdmin, "Castlevania", address(ruleRouterProxy), false);
        applicationHandler = ApplicationHandler(appManager.getApplicationHandlerAddress());
        vm.startPrank(defaultAdmin); //set up as the default admin
        ruleProcessorDiamond = getApplicationProcessorDiamond();
        console.log(applicationHandler.owner());

        console.log("AppManager Address:");
        console.log(address(appManager));
        console.log("applicationHandler Address:");
        console.log(address(applicationHandler));

        vm.warp(TEST_DATE); // set block.timestamp
    }

    /**
     * ################### TEST FUNCTIONS SINGULARLY ####################
     */

    /// testing renouncing admin role
    function testRenounceDefaultAdmin(uint8 addressIndex) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        appManager.renounceRole(APP_ADMIN_ROLE, sender);
        if (sender == defaultAdmin) assertFalse(appManager.isAppAdministrator(sender));
    }

    ///---------------APP ADMIN--------------------
    // Test the Application Administrators roles(only DEFAULT_ADMIN can add app administrator)
    function testAddAppAdministrator(uint8 addressIndexA, uint8 addressIndexB) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            assertTrue(appManager.isAppAdministrator(admin));
            assertFalse(appManager.isAppAdministrator(address(0xBABE)));
        }
    }

    /// Test revoke Application Administrators role
    function testRevokeAppAdministrator(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin); //set a app administrator
        if (sender == defaultAdmin) {
            assertTrue(appManager.isAppAdministrator(admin));
            assertTrue(appManager.hasRole(APP_ADMIN_ROLE, admin)); // verify it was added as a app administrator
            vm.stopPrank();
            vm.startPrank(random);
            if (random != defaultAdmin && random != admin) vm.expectRevert();
            appManager.revokeRole(APP_ADMIN_ROLE, admin);
            if (random == defaultAdmin) assertFalse(appManager.isAppAdministrator(admin));
        }
    }

    /// Test renounce Application Administrators role
    function testRenounceAppAdministrator(uint8 addressIndexA, uint8 addressIndexB) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            assertTrue(appManager.isAppAdministrator(admin));
            assertTrue(appManager.hasRole(APP_ADMIN_ROLE, admin)); // verify it was added as a app administrator
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.renounceAppAdministrator();
            assertFalse(appManager.isAppAdministrator(admin));
        }
    }

    ///---------------Risk ADMIN--------------------
    // Test adding the Risk Admin roles
    function testAddRiskAdmin(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addRiskAdmin(random); //add risk admin
            assertTrue(appManager.isRiskAdmin(random));
            assertFalse(appManager.isRiskAdmin(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != defaultAdmin && random != admin) vm.expectRevert();
            appManager.addRiskAdmin(random); //add risk admin
        }
    }

    /// Test renounce risk Admin role
    function testRenounceRiskAdmin(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addRiskAdmin(random); //add risk admin
            assertTrue(appManager.isRiskAdmin(random));
            assertFalse(appManager.isRiskAdmin(address(88)));

            vm.stopPrank(); //stop interacting as the app administrator
            vm.startPrank(random); //interact as the created risk admin
            appManager.renounceRiskAdmin();
            assertFalse(appManager.isRiskAdmin(random));
        }
    }

    /// Test revoke risk Admin role
    function testRevokeRiskAdmin(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addRiskAdmin(random); //add risk admin
            assertTrue(appManager.isRiskAdmin(random));
            assertFalse(appManager.isRiskAdmin(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != defaultAdmin && random != admin) vm.expectRevert();
            appManager.revokeRole(RISK_ADMIN_ROLE, admin);
            if (random == defaultAdmin || random == admin) assertFalse(appManager.isRiskAdmin(admin));
        }
    }

    ///---------------ACCESS TIER--------------------
    // Test adding the Access Tier roles
    function testAddAccessTier(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addAccessTier(random); //add AccessLevel admin
            assertTrue(appManager.isAccessTier(random));
            assertFalse(appManager.isAccessTier(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != defaultAdmin && random != admin) vm.expectRevert();
            appManager.addAccessTier(address(0xBABE)); //add AccessLevel
        }
    }

    /// Test renounce Access Tier role
    function testRenounceAccessTier(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addAccessTier(random); //add AccessLevel admin
            assertTrue(appManager.isAccessTier(random));
            assertFalse(appManager.isAccessTier(address(88)));

            vm.stopPrank(); //stop interacting as the app administrator
            vm.startPrank(random); //interact as the created risk admin
            appManager.renounceAccessTier();
            assertFalse(appManager.isAccessTier(random));
        }
    }

    /// Test revoke Access Tier role
    function testRevokeAccessTier(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addAccessTier(random); //add AccessLevel admin
            assertTrue(appManager.isAccessTier(random));
            assertFalse(appManager.isAccessTier(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != defaultAdmin && random != admin) vm.expectRevert();
            appManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, admin);
            if (random == defaultAdmin || random == admin) assertFalse(appManager.isRiskAdmin(admin));
        }
    }

    ///---------------USER ADMIN--------------------
    // Test adding the User roles
    function testAddUser(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addUser(random); //add user
            assertTrue(appManager.isUser(random));
            assertFalse(appManager.isUser(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != defaultAdmin && random != admin) vm.expectRevert();
            appManager.addUser(address(0xBABE)); //add user
        }
    }

    // Test removing the User roles
    function testRemoveUser(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            appManager.addUser(random); //add user
            assertTrue(appManager.isUser(random));
            assertFalse(appManager.isUser(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != defaultAdmin && random != admin) vm.expectRevert();
            appManager.removeUser(random);
            if (random == defaultAdmin || random == admin) assertFalse(appManager.isUser(random));
        }
    }

    ///---------------AccessLevel LEVEL MAINTENANCE--------------------
    function testAddAccessLevel(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, uint8 AccessLevel) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAccessTier(admin);
        if (sender == defaultAdmin) {
            assertTrue(appManager.isAccessTier(admin));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != admin || (AccessLevel > 4 && AccessLevel < 255)) vm.expectRevert();
            appManager.addAccessLevel(address(0xBABE), AccessLevel);
            if (random == admin && (AccessLevel < 4 || AccessLevel == 255)) {
                assertEq(appManager.getAccessLevel(address(0xBABE)), AccessLevel);
                /// testing update
                appManager.addAccessLevel(address(0xBABE), 1);
                assertEq(appManager.getAccessLevel(address(0xBABE)), 1);
            }
        }
    }

    ///---------------RISK SCORE MAINTENANCE--------------------
    function testAddRiskScore(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, uint8 riskScore) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addRiskAdmin(admin);
        if (sender == defaultAdmin) {
            assertTrue(appManager.isRiskAdmin(admin));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != admin || riskScore > 100) vm.expectRevert();
            appManager.addRiskScore(address(0xBABE), riskScore);
            if (random == admin && riskScore <= 100) {
                assertEq(appManager.getRiskScore(address(0xBABE)), riskScore);
                /// testing update
                appManager.addRiskScore(address(0xBABE), 1);
                assertEq(appManager.getRiskScore(address(0xBABE)), 1);
            }
        }
    }

    ///---------------GENERAL TAGS--------------------
    // Test adding the general tags
    function testAddGeneralTag(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, bytes32 Tag1, bytes32 Tag2) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            if (Tag1 == "") vm.expectRevert();
            appManager.addGeneralTag(address(0xBABE), Tag1); //add tag
            if (Tag1 != "") assertTrue(appManager.hasTag(address(0xBABE), Tag1));
            vm.stopPrank();
            vm.startPrank(random);
            if ((random != admin && random != defaultAdmin) || Tag2 == "") vm.expectRevert();
            appManager.addGeneralTag(address(0xBABE), Tag2);
            if ((random == admin || random == defaultAdmin) && Tag2 != "") assertTrue(appManager.hasTag(address(0xBABE), Tag2));
        }
    }

    function testRemoveGeneralTag(uint8 addressIndexA, uint8 addressIndexB, bytes32 Tag1, bytes32 Tag2, bytes32 Tag3, bytes32 Tag4) public {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag3 && Tag3 != Tag4 && Tag4 != Tag1 && Tag4 != Tag2 && Tag3 != Tag1);

        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        appManager.addAppAdministrator(admin);
        vm.stopPrank();
        vm.startPrank(admin);
        /// add first tag
        if (Tag1 == "") vm.expectRevert();
        appManager.addGeneralTag(address(0xBABE), Tag1); //add tag
        if (Tag1 != "") {
            assertTrue(appManager.hasTag(address(0xBABE), Tag1));
            assertFalse(appManager.hasTag(address(0xBABE), Tag2));
        }
        /// add secind tag
        if (Tag2 == "") vm.expectRevert();
        appManager.addGeneralTag(address(0xBABE), Tag2); //add tag
        if (Tag2 != "") {
            assertTrue(appManager.hasTag(address(0xBABE), Tag2));
            assertFalse(appManager.hasTag(address(0xBABE), Tag3));
        }
        /// add a repeated third tag
        if (Tag3 == "") vm.expectRevert();
        appManager.addGeneralTag(address(0xBABE), Tag3); //add tag
        if (Tag3 == "") vm.expectRevert();
        appManager.addGeneralTag(address(0xBABE), Tag3); //add tag
        if (Tag3 != "") {
            assertTrue(appManager.hasTag(address(0xBABE), Tag3));
            assertFalse(appManager.hasTag(address(0xBABE), Tag4));
        }
        /// remove tags
        vm.stopPrank();
        vm.startPrank(sender);
        if ((sender != admin && sender != defaultAdmin)) vm.expectRevert();
        appManager.removeGeneralTag(address(0xBABE), Tag3);
        if ((sender == admin || sender == defaultAdmin)) assertFalse(appManager.hasTag(address(0xBABE), Tag3));
        if ((sender != admin && sender != defaultAdmin)) vm.expectRevert();
        appManager.removeGeneralTag(address(0xBABE), Tag2);
        if ((sender == admin || sender == defaultAdmin)) assertFalse(appManager.hasTag(address(0xBABE), Tag2));
        if ((sender != admin && sender != defaultAdmin)) vm.expectRevert();
        appManager.removeGeneralTag(address(0xBABE), Tag1);
        if ((sender == admin || sender == defaultAdmin)) {
            assertFalse(appManager.hasTag(address(0xBABE), Tag1));
        }
    }

    ///---------------PAUSE RULES----------------
    // Test setting/removing pause rules
    function testAddPauseRuleFuzz(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, uint start, uint end) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.addAppAdministrator(admin);
        if (sender == defaultAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            /// we are adding a repeated rule to test the reciliency of the
            /// contract to this scenario
            if (start >= end || start <= block.timestamp) vm.expectRevert();
            appManager.addPauseRule(start, end);
            if (start >= end || start <= block.timestamp) vm.expectRevert();
            appManager.addPauseRule(start, end);
            if (start < end && start > block.timestamp) {
                PauseRule[] memory test = appManager.getPauseRules();
                assertTrue(test.length == 2);

                /// test if not-an-admin can set a rule
                vm.stopPrank();
                vm.startPrank(random);
                /// testing onlyAppAdministrator
                if (random != admin && random != defaultAdmin) vm.expectRevert();
                appManager.addPauseRule(1769924800, 1769984800);
                if (random == admin || random == defaultAdmin) {
                    test = appManager.getPauseRules();
                    assertTrue(test.length == 3);
                }
                PauseRule[] memory total = appManager.getPauseRules();
                vm.stopPrank();
                vm.startPrank(admin);
                appManager.removePauseRule(start, end);
                test = appManager.getPauseRules();
                assertTrue(test.length == total.length - 2);
            }
        }
    }

    ///---------------AccessLevel PROVIDER---------------
    // Test setting access levelprovider contract address
    function testAccessLevelProviderSet(uint8 addressIndexA, uint8 addressIndexB, address provider) public {
        vm.stopPrank();
        vm.assume(provider != address(0));
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != defaultAdmin) vm.expectRevert();
        appManager.setAccessLevelProvider(provider);
        if (sender == defaultAdmin) {
            assertEq(provider, appManager.getAccessLevelProvider());
            vm.stopPrank();
            vm.startPrank(admin);
            if (admin != defaultAdmin) vm.expectRevert();
            appManager.setAccessLevelProvider(address(0xBABE));
            if (admin == defaultAdmin) assertEq(address(0xBABE), appManager.getAccessLevelProvider());
        }
    }

    /**
     * ################# TEST DIFFERENT SCENARIOS #####################
     */
    /// Test the checkAction. This tests all application compliance
    function testCheckActionFuzz(uint start, uint end, uint128 forward) public {
        /// add a pause rule
        if (start >= end || start <= block.timestamp) vm.expectRevert();
        appManager.addPauseRule(start, end);

        /// go to the future
        vm.warp(forward);

        /// check against the the actual rules. We consult because they might've not been added
        PauseRule[] memory pauseRules = appManager.getPauseRules();

        /// Now we check for access action depending on these rules.
        /// If we got a pause rule, then we check also against the AccessLevel score
        if (pauseRules.length > 0) {
            if (pauseRules[0].pauseStart <= block.timestamp && pauseRules[0].pauseStop > block.timestamp) vm.expectRevert();
            //appManager.checkAction(ApplicationHandlerLib.ActionTypes.SELL, user);
            appManager.checkApplicationRules(RuleProcessorDiamondLib.ActionTypes.SELL, user, user, 0, 0);
        }
    }
}
