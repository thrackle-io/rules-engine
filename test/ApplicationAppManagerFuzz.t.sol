// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/data/IPauseRules.sol";
import "test/helpers/TestCommon.sol";

contract ApplicationAppManagerFuzzTest is TestCommon {
    bytes32 public constant SUPER_ADMIN_ROLE = ("SUPER_ADMIN_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    uint256 public constant TEST_DATE = 1666706998;
    string tokenName = "FEUD";

    function setUp() public {
        vm.startPrank(superAdmin); //set up as the default admin
        /// Set up the protocol and an applicationAppManager
        setUpProtocolAndAppManager();
        console.log(applicationHandler.owner());

        vm.warp(TEST_DATE); // set block.timestamp
    }

    /**
     * ################### TEST FUNCTIONS SINGULARLY ####################
     */

    /// testing renouncing admin role
    function testRenounceSuperAdmin(uint8 addressIndex) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        applicationAppManager.renounceRole(APP_ADMIN_ROLE, sender);
        if (sender == superAdmin) assertFalse(applicationAppManager.isAppAdministrator(sender));
    }

    ///---------------APP ADMIN--------------------
    // Test the Application Administrators roles(only DEFAULT_ADMIN can add app administrator)
    function testAddAppAdministrator(uint8 addressIndexA, uint8 addressIndexB) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            assertTrue(applicationAppManager.isAppAdministrator(admin));
            assertFalse(applicationAppManager.isAppAdministrator(address(0xBABE)));
        }
    }

    function testAddMultipleAppAdministrator(uint8 addressIndexA) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addMultipleAppAdministrator(ADDRESSES);
        if (sender == superAdmin) {
            assertTrue(applicationAppManager.isAppAdministrator(appAdministrator));
            assertFalse(applicationAppManager.isAppAdministrator(address(0xFF77)));
        }
    }

    /// Test revoke Application Administrators role
    function testRevokeAppAdministrator(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin); //set a app administrator
        if (sender == superAdmin) {
            assertTrue(applicationAppManager.isAppAdministrator(admin));
            assertTrue(applicationAppManager.hasRole(APP_ADMIN_ROLE, admin)); // verify it was added as a app administrator
            vm.stopPrank();
            vm.startPrank(random);
            if (random != superAdmin) vm.expectRevert();
            applicationAppManager.revokeRole(APP_ADMIN_ROLE, admin);
            if (random == superAdmin) assertFalse(applicationAppManager.isAppAdministrator(admin));
        }
    }

    /// Test renounce Application Administrators role
    function testRenounceAppAdministrator(uint8 addressIndexA, uint8 addressIndexB) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            assertTrue(applicationAppManager.isAppAdministrator(admin));
            assertTrue(applicationAppManager.hasRole(APP_ADMIN_ROLE, admin)); // verify it was added as a app administrator
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.renounceAppAdministrator();
            assertFalse(applicationAppManager.isAppAdministrator(admin));
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
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addRiskAdmin(random); //add risk admin
            assertTrue(applicationAppManager.isRiskAdmin(random));
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != superAdmin && random != admin) vm.expectRevert();
            applicationAppManager.addRiskAdmin(random); //add risk admin
        }
    }

    function testAddMultipleRiskAdmins(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addMultipleRiskAdmin(ADDRESSES); //add risk admins
            assertTrue(applicationAppManager.isRiskAdmin(random));
            assertTrue(applicationAppManager.isRiskAdmin(address(0xF00D)));
            assertTrue(applicationAppManager.isRiskAdmin(address(0xBEEF)));
            assertTrue(applicationAppManager.isRiskAdmin(address(0xC0FFEE)));
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));
        }
    }

    /// Test renounce risk Admin role
    function testRenounceRiskAdmin(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addRiskAdmin(random); //add risk admin
            assertTrue(applicationAppManager.isRiskAdmin(random));
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));

            vm.stopPrank(); //stop interacting as the app administrator
            vm.startPrank(random); //interact as the created risk admin
            applicationAppManager.renounceRiskAdmin();
            assertFalse(applicationAppManager.isRiskAdmin(random));
        }
    }

    /// Test revoke risk Admin role
    function testRevokeRiskAdmin(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addRiskAdmin(random); //add risk admin
            assertTrue(applicationAppManager.isRiskAdmin(random));
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != superAdmin && random != admin) vm.expectRevert();
            applicationAppManager.revokeRole(RISK_ADMIN_ROLE, admin);
            if (random == superAdmin || random == admin) assertFalse(applicationAppManager.isRiskAdmin(admin));
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
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addAccessTier(random); //add AccessLevel admin
            assertTrue(applicationAppManager.isAccessTier(random));
            assertFalse(applicationAppManager.isAccessTier(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != superAdmin && random != admin) vm.expectRevert();
            applicationAppManager.addAccessTier(address(0xBABE)); //add AccessLevel
        }
    }

    // Test adding the Access Tier roles for multiple addresses
    function testMultipleAddAccessTier(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addMultipleAccessTier(ADDRESSES); //add AccessLevel admins
            assertTrue(applicationAppManager.isAccessTier(random));
            assertTrue(applicationAppManager.isAccessTier(address(0xF00D)));
            assertTrue(applicationAppManager.isAccessTier(address(0xBEEF)));
            assertTrue(applicationAppManager.isAccessTier(address(0xC0FFEE)));
            assertFalse(applicationAppManager.isAccessTier(address(88)));
        }
    }

    /// Test renounce Access Tier role
    function testRenounceAccessTier(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addAccessTier(random); //add AccessLevel admin
            assertTrue(applicationAppManager.isAccessTier(random));
            assertFalse(applicationAppManager.isAccessTier(address(88)));

            vm.stopPrank(); //stop interacting as the app administrator
            vm.startPrank(random); //interact as the created risk admin
            applicationAppManager.renounceAccessTier();
            assertFalse(applicationAppManager.isAccessTier(random));
        }
    }

    /// Test revoke Access Tier role
    function testRevokeAccessTier(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addAccessTier(random); //add AccessLevel admin
            assertTrue(applicationAppManager.isAccessTier(random));
            assertFalse(applicationAppManager.isAccessTier(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != superAdmin && random != admin) vm.expectRevert();
            applicationAppManager.revokeRole(ACCESS_TIER_ADMIN_ROLE, admin);
            if (random == superAdmin || random == admin) assertFalse(applicationAppManager.isRiskAdmin(admin));
        }
    }

    ///---------------AccessLevel LEVEL MAINTENANCE--------------------
    function testAddAccessLevel(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, uint8 AccessLevel) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAccessTier(admin);
        if (sender == superAdmin) {
            assertTrue(applicationAppManager.isAccessTier(admin));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != admin || (AccessLevel > 4)) vm.expectRevert();
            applicationAppManager.addAccessLevel(address(0xBABE), AccessLevel);
            if (random == admin && (AccessLevel < 4)) {
                assertEq(applicationAppManager.getAccessLevel(address(0xBABE)), AccessLevel);
                /// testing update
                applicationAppManager.addAccessLevel(address(0xBABE), 1);
                assertEq(applicationAppManager.getAccessLevel(address(0xBABE)), 1);
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
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addRiskAdmin(admin);
        if (sender == superAdmin) {
            assertTrue(applicationAppManager.isRiskAdmin(admin));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != admin || riskScore > 100) vm.expectRevert();
            applicationAppManager.addRiskScore(address(0xBABE), riskScore);
            if (random == admin && riskScore <= 100) {
                assertEq(applicationAppManager.getRiskScore(address(0xBABE)), riskScore);
                /// testing update
                applicationAppManager.addRiskScore(address(0xBABE), 1);
                assertEq(applicationAppManager.getRiskScore(address(0xBABE)), 1);
            }
        }
    }

    ///---------------GENERAL TAGS--------------------
    // Test adding the general tags
    function testAddGeneralTag(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, bytes32 Tag1, bytes32 Tag2) public {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag1);
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            if (Tag1 == "") vm.expectRevert();
            applicationAppManager.addGeneralTag(address(0xBABE), Tag1); //add tag
            if (Tag1 != "") assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag1));
            vm.stopPrank();
            vm.startPrank(random);
            if ((random != admin && random != superAdmin) || Tag2 == "") vm.expectRevert();
            applicationAppManager.addGeneralTag(address(0xBABE), Tag2);
            if ((random == admin || random == superAdmin) && Tag2 != "") assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag2));
        }
    }

    function testAddMultipleGenTagsToMulitpleAccounts(uint8 addressIndexA, uint8 addressIndexB, bytes32 Tag1, bytes32 Tag2, bytes32 Tag3, bytes32 Tag4) public {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag3 && Tag3 != Tag4 && Tag4 != Tag1 && Tag4 != Tag2 && Tag3 != Tag1);
        vm.assume(Tag1 != "" && Tag2 != "" && Tag3 != "" && Tag4 != "");
        vm.stopPrank();
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];

        bytes32[] memory genTags = new bytes32[](8);
        genTags[0] = Tag1;
        genTags[1] = Tag1;
        genTags[2] = Tag2;
        genTags[3] = Tag2;
        genTags[4] = Tag3;
        genTags[5] = Tag3;
        genTags[6] = Tag4;
        genTags[7] = Tag4;

        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        ///Test to ensure non admins cannot call function
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addMultipleGeneralTagToMultipleAccounts(ADDRESSES, genTags);
            /// Test to prove addresses in array are tagged by index matched to secon array of tags
            assertTrue(applicationAppManager.hasTag(user, Tag3));
            assertTrue(applicationAppManager.hasTag(address(0xBEEF), Tag3));
            assertTrue(applicationAppManager.hasTag(address(0xC0FFEE), Tag4));
            assertTrue(applicationAppManager.hasTag(address(0xF00D), Tag4));
        }
    }

    function testRemoveGeneralTag(uint8 addressIndexA, bytes32 Tag1, bytes32 Tag2, bytes32 Tag3, bytes32 Tag4) public {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag3 && Tag3 != Tag4 && Tag4 != Tag1 && Tag4 != Tag2 && Tag3 != Tag1);

        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        /// add first tag
        if (Tag1 == "") vm.expectRevert();
        applicationAppManager.addGeneralTag(address(0xBABE), Tag1); //add tag
        if (Tag1 != "") {
            assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag1));
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag2));
        }
        /// add second tag
        if (Tag2 == "") vm.expectRevert();
        applicationAppManager.addGeneralTag(address(0xBABE), Tag2); //add tag
        if (Tag2 != "") {
            assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag2));
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag3));
        }
        /// add a third tag
        if (Tag3 == "") vm.expectRevert();
        applicationAppManager.addGeneralTag(address(0xBABE), Tag3); //add tag
        if (Tag3 != "") {
            assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag3));
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag4));
        }
        /// remove tags
        vm.stopPrank();
        vm.startPrank(sender);
        if ((sender != appAdministrator)) vm.expectRevert();
        applicationAppManager.removeGeneralTag(address(0xBABE), Tag3);
        if ((sender == appAdministrator)) assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag3));
        if ((sender != appAdministrator)) vm.expectRevert();
        applicationAppManager.removeGeneralTag(address(0xBABE), Tag2);
        if ((sender == appAdministrator)) assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag2));
        if ((sender != appAdministrator)) vm.expectRevert();
        applicationAppManager.removeGeneralTag(address(0xBABE), Tag1);
        if ((sender == appAdministrator)) {
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag1));
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
        if (sender != superAdmin) vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            /// we are adding a repeated rule to test the reciliency of the
            /// contract to this scenario
            if (start >= end || start <= block.timestamp) vm.expectRevert();
            applicationAppManager.addPauseRule(start, end);
            if (start >= end || start <= block.timestamp) vm.expectRevert();
            applicationAppManager.addPauseRule(start, end);
            if (start < end && start > block.timestamp) {
                PauseRule[] memory test = applicationAppManager.getPauseRules();
                assertTrue(test.length == 2);

                /// test if not-an-admin can set a rule
                vm.stopPrank();
                vm.startPrank(random);
                /// testing onlyAppAdministrator
                if (random != admin && random != superAdmin) vm.expectRevert();
                applicationAppManager.addPauseRule(1769924800, 1769984800);
                if (random == admin || random == superAdmin) {
                    test = applicationAppManager.getPauseRules();
                    assertTrue(test.length == 3);
                }
                PauseRule[] memory total = applicationAppManager.getPauseRules();
                vm.stopPrank();
                vm.startPrank(admin);
                applicationAppManager.removePauseRule(start, end);
                test = applicationAppManager.getPauseRules();
                assertTrue(test.length == total.length - 2);
            }
        }
    }

    /**
     * ################# TEST DIFFERENT SCENARIOS #####################
     */
    /// Test the checkAction. This tests all application compliance
    function testCheckActionFuzz(uint start, uint end, uint128 forward) public {
        switchToRuleAdmin();
        /// add a pause rule
        if (start >= end || start <= block.timestamp) vm.expectRevert();
        applicationAppManager.addPauseRule(start, end);

        /// go to the future
        vm.warp(forward);

        /// check against the the actual rules. We consult because they might've not been added
        PauseRule[] memory pauseRules = applicationAppManager.getPauseRules();

        /// Now we check for access action depending on these rules.
        /// If we got a pause rule, then we check also against the AccessLevel score
        if (pauseRules.length > 0) {
            if (pauseRules[0].pauseStart <= block.timestamp && pauseRules[0].pauseStop > block.timestamp) vm.expectRevert();
            //applicationAppManager.checkAction(ApplicationHandlerLib.ActionTypes.SELL, user);
            applicationAppManager.checkApplicationRules(ActionTypes.SELL, user, user, 0, 0);
        }
    }
}
