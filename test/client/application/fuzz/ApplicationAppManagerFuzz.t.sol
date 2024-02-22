// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

contract ApplicationAppManagerFuzzTest is TestCommonFoundry {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();            
        vm.warp(Blocktime); // set block.timestamp
        vm.stopPrank();
    }

    function testRenounceAppAdmin(uint8 addressIndex) public {
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(sender);
        assertTrue(applicationAppManager.isAppAdministrator(sender));
        vm.startPrank(sender);
        applicationAppManager.renounceRole(APP_ADMIN_ROLE, sender);
        assertFalse(applicationAppManager.isAppAdministrator(sender));
    }


    function testAddAppAdministrator(uint8 addressIndexA) public {
        address admin = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(admin);        
        assertTrue(applicationAppManager.isAppAdministrator(admin));
        assertFalse(applicationAppManager.isAppAdministrator(address(0xBABE)));
    }

    function testAddMultipleAppAdministrator(uint8 addressIndexA) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, uint8(addressIndexA % ADDRESSES.length));
        switchToSuperAdmin();
        applicationAppManager.addMultipleAppAdministrator(addressList); 
        for (uint i = 0; i < addressList.length; i++) {
            assertTrue(applicationAppManager.isAppAdministrator(addressList[i]));
        }
        assertFalse(applicationAppManager.isAppAdministrator(address(0xBABE)));
    }

    function testRevokeAppAdministrator(uint8 addressIndexA) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 2);
        address admin = addressList[0];
        address random = addressList[1];
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(admin); //set a app administrator
        assertTrue(applicationAppManager.isAppAdministrator(admin));
        assertTrue(applicationAppManager.hasRole(APP_ADMIN_ROLE, admin)); // verify it was added as a app administrator
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, admin);
        vm.startPrank(random);
        vm.expectRevert();
        applicationAppManager.addAppAdministrator(admin); //set a app administrator
        assertFalse(applicationAppManager.isAppAdministrator(admin));
    }


    ///---------------Risk ADMIN--------------------
    function testAddRiskAdmin(uint8 addressIndexA) public {
        address admin = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        applicationAppManager.addRiskAdmin(admin);        
        assertTrue(applicationAppManager.isRiskAdmin(admin));
        assertFalse(applicationAppManager.isRiskAdmin(address(0xBABE)));
    }

    function testAddMultipleRiskAdmins(uint8 addressIndexA) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 3);
        switchToAppAdministrator();
        applicationAppManager.addMultipleRiskAdmin(addressList); 
        for (uint i = 0; i < addressList.length; i++) {
            assertTrue(applicationAppManager.isRiskAdmin(addressList[i]));
        }
        assertFalse(applicationAppManager.isRiskAdmin(address(0xBABE)));
    }

    function testRenounceRiskAdmin(uint8 addressIndexA) public {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        applicationAppManager.addRiskAdmin(sender);
        assertTrue(applicationAppManager.isRiskAdmin(sender));
        vm.startPrank(sender);
        applicationAppManager.renounceRole(RISK_ADMIN_ROLE, sender);
        assertFalse(applicationAppManager.isRiskAdmin(sender));
    }

    function testRevokeRiskAdmin(uint8 addressIndexA) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 2);
        address admin = addressList[0];
        address random = addressList[1];
        switchToAppAdministrator();
        applicationAppManager.addRiskAdmin(admin); //set a app administrator
        assertTrue(applicationAppManager.isRiskAdmin(admin));
        assertTrue(applicationAppManager.hasRole(RISK_ADMIN_ROLE, admin)); // verify it was added as a app administrator
        applicationAppManager.revokeRole(RISK_ADMIN_ROLE, admin);
        vm.startPrank(random);
        vm.expectRevert();
        applicationAppManager.addRiskAdmin(admin); //set a app administrator
        assertFalse(applicationAppManager.isRiskAdmin(admin));
    }

    ///---------------ACCESS LEVEL--------------------
    function testAddAccessLevel(uint8 addressIndexA) public {
        address admin = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        applicationAppManager.addAccessLevelAdmin(admin);        
        assertTrue(applicationAppManager.isAccessLevelAdmin(admin));
        assertFalse(applicationAppManager.isAccessLevelAdmin(address(0xBABE)));
    }

    function testMultipleAddAccessLevel(uint8 addressIndexA) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 4);
        switchToAppAdministrator();
        applicationAppManager.addMultipleAccessLevelAdmins(addressList); 
        for (uint i = 0; i < addressList.length; i++) {
            assertTrue(applicationAppManager.isAccessLevelAdmin(addressList[i]));
        }
        assertFalse(applicationAppManager.isAccessLevelAdmin(address(0xBABE)));
    }

    function testRenounceAccessLevel(uint8 addressIndexA) public {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        applicationAppManager.addAccessLevelAdmin(sender);
        assertTrue(applicationAppManager.isAccessLevelAdmin(sender));
        vm.startPrank(sender);
        applicationAppManager.renounceRole(ACCESS_LEVEL_ADMIN_ROLE, sender);
        assertFalse(applicationAppManager.isAccessLevelAdmin(sender));
    }

    function testRevokeAccessLevel(uint8 addressIndexA) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 2);
        address admin = addressList[0];
        address random = addressList[1];
        switchToAppAdministrator();
        applicationAppManager.addAccessLevelAdmin(admin); //set a app administrator
        assertTrue(applicationAppManager.isAccessLevelAdmin(admin));
        assertTrue(applicationAppManager.hasRole(ACCESS_LEVEL_ADMIN_ROLE, admin)); // verify it was added as a app administrator
        applicationAppManager.revokeRole(ACCESS_LEVEL_ADMIN_ROLE, admin);
        vm.startPrank(random);
        vm.expectRevert();
        applicationAppManager.addAccessLevelAdmin(admin); //set a app administrator
        assertFalse(applicationAppManager.isAccessLevelAdmin(admin));
    }

    ///---------------AccessLevel MAINTENANCE--------------------
    function testAddAccessLevel(uint8 addressIndexA, uint8 level) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 1);
        address random = addressList[0];
        switchToAccessLevelAdmin();
            if ((level <= 4)) {
                applicationAppManager.addAccessLevel(random, level);
                assertEq(applicationAppManager.getAccessLevel(random), level);
                /// testing update
                applicationAppManager.addAccessLevel(random, 1);
                assertEq(applicationAppManager.getAccessLevel(random), 1);
            } else {
                vm.expectRevert();
                applicationAppManager.addAccessLevel(random, level);
                assertEq(applicationAppManager.getAccessLevel(random), 0);
            }
    }

    ///---------------RISK SCORE MAINTENANCE--------------------
    function testAddRiskScore(uint8 addressIndexA, uint8 riskScore) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 1);
        address random = addressList[0];
        switchToRiskAdmin();
            if ((riskScore <= 100)) {
                applicationAppManager.addRiskScore(random, riskScore);
                assertEq(applicationAppManager.getRiskScore(random), riskScore);
                /// testing update
                applicationAppManager.addRiskScore(random, 1);
                assertEq(applicationAppManager.getRiskScore(random), 1);
            } else {
                vm.expectRevert();
                applicationAppManager.addRiskScore(random, riskScore);
                assertEq(applicationAppManager.getRiskScore(random), 0);
            }
    }

    ///---------------TAGS--------------------
    function testAddTag(uint8 addressIndexA, bytes32 Tag1, bytes32 Tag2) public {
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 1);
        address random = addressList[0];
        switchToAppAdministrator();
        applicationAppManager.addTag(random, Tag1);
        assertTrue(applicationAppManager.hasTag(random, Tag1));
        assertFalse(applicationAppManager.hasTag(random, Tag2));
    }

    function testAddMultipleGenTagsToMulitpleAccounts(uint8 addressIndexA, bytes32 Tag1, bytes32 Tag2, bytes32 Tag3) public {
        vm.assume(Tag1 != Tag2 && Tag1 != Tag3 && Tag2 != Tag3);
        vm.assume(Tag1 != "");
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 3);
        address user1 = addressList[0];
        address user2 = addressList[1];
        address user3 = addressList[2];
        bytes32[] memory genTags = createBytes32Array(Tag1, Tag2, Tag3);
        switchToAppAdministrator();
        applicationAppManager.addMultipleTagToMultipleAccounts(addressList, genTags);
        /// Test to prove addresses in array are tagged by index matched to second array of tags
        assertTrue(applicationAppManager.hasTag(user1, Tag1));
        assertTrue(applicationAppManager.hasTag(user2, Tag2));
        assertTrue(applicationAppManager.hasTag(user3, Tag3));
        assertFalse(applicationAppManager.hasTag(address(0xBEEF), Tag1));
        assertFalse(applicationAppManager.hasTag(address(0xBEEF), Tag2));
        assertFalse(applicationAppManager.hasTag(address(0xBEEF), Tag3));
    }

    function testRemoveTag(uint8 addressIndexA, bytes32 Tag1, bytes32 Tag2) public {
        vm.assume(Tag1 != Tag2);
        vm.assume(Tag1 != "");
        address[] memory addressList = getUniqueAddresses(addressIndexA % ADDRESSES.length, 1);
        address user1 = addressList[0];
        switchToAppAdministrator();
        /// add first tag
        applicationAppManager.addTag(user1, Tag1); //add tag
        assertTrue(applicationAppManager.hasTag(user1, Tag1));
        assertFalse(applicationAppManager.hasTag(user1, Tag2));
        /// add second tag
        applicationAppManager.addTag(user1, Tag2); //add tag
        assertTrue(applicationAppManager.hasTag(user1, Tag1));
        assertTrue(applicationAppManager.hasTag(user1, Tag2));
        /// remove tags
        applicationAppManager.removeTag(user1, Tag1);
        assertFalse(applicationAppManager.hasTag(user1, Tag1));
        applicationAppManager.removeTag(user1, Tag2);
        assertFalse(applicationAppManager.hasTag(user1, Tag2));
    }

    ///---------------PAUSE RULES----------------
    function testAddPauseRuleFuzz(uint64 start, uint64 end) public {
        switchToRuleAdmin();
        /// we are adding a repeated rule to test the resiliency of the
        /// contract to this scenario
        if (start >= end || start <= block.timestamp) vm.expectRevert();
        applicationAppManager.addPauseRule(start, end);
        if (start >= end || start <= block.timestamp) vm.expectRevert();
        applicationAppManager.addPauseRule(start, end);
        if (start < end && start > block.timestamp) {
            PauseRule[] memory test = applicationAppManager.getPauseRules();
            assertTrue(test.length == 2);
            assertTrue(applicationHandler.isPauseRuleActive() == true);

            /// test if not-an-admin can set a rule
            PauseRule[] memory total = applicationAppManager.getPauseRules();
            applicationAppManager.removePauseRule(start, end);
            test = applicationAppManager.getPauseRules();
            assertTrue(test.length == total.length - 2);
        }
    }
}
