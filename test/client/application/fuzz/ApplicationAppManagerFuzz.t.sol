// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";


contract ApplicationAppManagerFuzzTest is TestCommonFoundry {

    function setUp() public {
        setUpProtocolAndAppManager();
        _addAdminsToAddressArray(); 
        _grantAdminRolesToAdmins();           
        vm.warp(Blocktime); // set block.timestamp
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: The app admin role is renounced. 
     */
    function testApplication_ApplicationAppManagerFuzz_RenounceAppAdmin(uint8 addressIndex) public endWithStopPrank() {
        switchToAppAdministrator();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.stopPrank();
        vm.startPrank(sender);
        applicationAppManager.renounceRole(APP_ADMIN_ROLE, sender);
        assertFalse(applicationAppManager.isAppAdministrator(sender));
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: The app admin role is granted to newAppAdmin only. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddAppAdministrator(uint8 addressIndex) public endWithStopPrank() {
        address newAppAdmin = ADDRESSES[addressIndex % ADDRESSES.length];
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(newAppAdmin);
        assertTrue(applicationAppManager.isAppAdministrator(newAppAdmin));
        assertFalse(applicationAppManager.isAppAdministrator(address(0xBABE)));
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: App Admin Role is granted to 0xBABE address, else reverts. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddAppAdministrator_Negative(uint8 addressIndexA) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
            applicationAppManager.addAppAdministrator(address(0xBABE));
            assertFalse(applicationAppManager.isAppAdministrator(address(0xBABE)));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Add App Admin Role to entire ADDRESSES array. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddMultipleAppAdministrator(uint8 addressIndexA) public endWithStopPrank() {
        address TestAddress = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToSuperAdmin();
        applicationAppManager.addMultipleAppAdministrator(ADDRESSES);
        assertFalse(applicationAppManager.isAppAdministrator(address(0xF00D)));
        assertTrue(applicationAppManager.isAppAdministrator(address(0xFF7)));
        assertTrue(applicationAppManager.isAppAdministrator(address(TestAddress)));
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Add App Admin Role to entire ADDRESSES array, else revert. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddMultipleAppAdministrator_Negative(uint8 addressIndexA) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address[] memory alts = new address[](2);
        alts[0] = address(0xFF77);
        alts[1] = address(0xBABE);
        vm.startPrank(sender);
        if (sender != superAdmin) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
            applicationAppManager.addMultipleAppAdministrator(alts);
            assertFalse(applicationAppManager.isAppAdministrator(address(0xFF77)));
            assertFalse(applicationAppManager.isAppAdministrator(address(0xBABE)));
        } else if (sender == superAdmin) {
            applicationAppManager.addMultipleAppAdministrator(alts);
            assertTrue(applicationAppManager.isAppAdministrator(address(0xFF77)));
            assertTrue(applicationAppManager.isAppAdministrator(address(0xBABE)));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: App Admin role is revoked from admin. 
     */
    function testApplication_ApplicationAppManagerFuzz_RevokeAppAdministrator(uint8 addressIndexA, uint8 addressIndexB) public endWithStopPrank() {
        address admin = ADDRESSES[addressIndexA % ADDRESSES.length];
        address random = ADDRESSES[addressIndexB % ADDRESSES.length];
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(admin); //set a app administrator
        assertTrue(applicationAppManager.isAppAdministrator(admin));
        assertTrue(applicationAppManager.hasRole(APP_ADMIN_ROLE, admin));
        vm.stopPrank();
        vm.startPrank(random);
        if (random != superAdmin) {
        vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(random), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
        applicationAppManager.revokeRole(APP_ADMIN_ROLE, admin);
        assertTrue(applicationAppManager.isAppAdministrator(admin));
        } else if (random == superAdmin) {
            applicationAppManager.revokeRole(APP_ADMIN_ROLE, admin);
            assertFalse(applicationAppManager.isAppAdministrator(admin));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: App Admin role is renounced from admin.
     */ 
    function testApplication_ApplicationAppManagerFuzz_RenounceAppAdministrator(uint8 addressIndexA, uint8 addressIndexB) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
            console.log(address(sender), " AccessControl: account is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689");
            applicationAppManager.addAppAdministrator(admin);
        } else if (sender == superAdmin) {
            applicationAppManager.addAppAdministrator(admin);
            assertTrue(applicationAppManager.isAppAdministrator(admin));
            assertTrue(applicationAppManager.hasRole(APP_ADMIN_ROLE, admin)); // verify it was added as a app administrator
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.renounceAppAdministrator();
            assertFalse(applicationAppManager.isAppAdministrator(admin));
        }
    }

    ///---------------Risk ADMIN--------------------
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Risk Admin role is added to the random address.
     */
    function testApplication_ApplicationAppManagerFuzz_AddRiskAdmin(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != appAdministrator) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.addRiskAdmin(admin);
        }
        if (sender == appAdministrator) {
            applicationAppManager.addRiskAdmin(random); 
            assertTrue(applicationAppManager.isRiskAdmin(random)); 
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Risk Admin role is added to the random address, else revert. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddRiskAdmin_Negative(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != appAdministrator) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.addRiskAdmin(admin);
        }
        if (sender == appAdministrator) {
            applicationAppManager.addRiskAdmin(random); 
            assertTrue(applicationAppManager.isRiskAdmin(random)); 
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != appAdministrator && random != admin) {
                vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(random), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
                applicationAppManager.addRiskAdmin(random); 
            }
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Risk Admin role is added to the ADDRESSES array.
     */
    function testApplication_ApplicationAppManagerFuzz_AddMultipleRiskAdmins(uint8 addressIndexA, uint8 addressIndexB) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address random = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != appAdministrator) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.addMultipleRiskAdmin(ADDRESSES);
        }
        if (sender == appAdministrator) {
            applicationAppManager.addMultipleRiskAdmin(ADDRESSES); //add risk admins
            assertTrue(applicationAppManager.isRiskAdmin(random));
            assertFalse(applicationAppManager.isRiskAdmin(address(0xF00D)));
            assertFalse(applicationAppManager.isRiskAdmin(address(0xBEEF)));
            assertFalse(applicationAppManager.isRiskAdmin(address(0xC0FFEE)));
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));
        }

    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Risk Admin role is added to the ADDRESSES array, else revert. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddMultipleRiskAdmins_Negative(uint8 addressIndexA) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != appAdministrator) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.addMultipleRiskAdmin(ADDRESSES);
            assertFalse(applicationAppManager.isRiskAdmin(address(88)));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Risk Admin role is renounced by the admin address.
     */
    function testApplication_ApplicationAppManagerFuzz_RenounceRiskAdmin(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
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

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Risk Admin role is revoked from the admin address.
     */
    function testApplication_ApplicationAppManagerFuzz_RevokeRiskAdmin(uint8 addressIndexA) public endWithStopPrank() {
        address random = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        applicationAppManager.addRiskAdmin(random);
        assertTrue(applicationAppManager.isRiskAdmin(random));
        assertFalse(applicationAppManager.isRiskAdmin(address(88)));
           
    }

    ///---------------ACCESS LEVEL--------------------
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Add Access Level Admin role to the random address. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddAccessLevel(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addAccessLevelAdmin(random); //add AccessLevel admin
            assertTrue(applicationAppManager.isAccessLevelAdmin(random));
            assertFalse(applicationAppManager.isAccessLevelAdmin(address(88)));
            vm.stopPrank();
            vm.startPrank(random);
            if (random != appAdministrator && random != admin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(random), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.addAccessLevelAdmin(address(0xBABE)); //add AccessLevel
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Add Access Level Admin role to the ADDRESSES array. 
     */
    function testApplication_ApplicationAppManagerFuzz_MultipleAddAccessLevel(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addMultipleAccessLevelAdmins(ADDRESSES); //add AccessLevel admins
            assertTrue(applicationAppManager.isAccessLevelAdmin(random));
            assertFalse(applicationAppManager.isAccessLevelAdmin(address(0xF00D)));
            assertFalse(applicationAppManager.isAccessLevelAdmin(address(0xBEEF)));
            assertFalse(applicationAppManager.isAccessLevelAdmin(address(0xC0FFEE)));
            assertFalse(applicationAppManager.isAccessLevelAdmin(address(88)));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Access Level Admin role renounced by the random address. 
     */
    function testApplication_ApplicationAppManagerFuzz_RenounceAccessLevel(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addAccessLevelAdmin(random); //add AccessLevel admin
            assertTrue(applicationAppManager.isAccessLevelAdmin(random));
            assertFalse(applicationAppManager.isAccessLevelAdmin(address(88)));
            vm.stopPrank(); 
            vm.startPrank(random);
            applicationAppManager.renounceAccessLevelAdmin();
            assertFalse(applicationAppManager.isAccessLevelAdmin(random));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Access Level Admin role revoked from the random address. 
     */
    function testApplication_ApplicationAppManagerFuzz_RevokeAccessLevel(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            applicationAppManager.addAccessLevelAdmin(random); //add AccessLevel admin
            assertTrue(applicationAppManager.isAccessLevelAdmin(random));
            assertFalse(applicationAppManager.isAccessLevelAdmin(address(88)));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Risk Score Admin granted to the random address, else reverts. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddRiskScore_Negative(uint8 addressIndexA, uint8 addressIndexB, uint8 riskScore) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address random = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != appAdministrator) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
        applicationAppManager.addRiskAdmin(random);
        if (sender == appAdministrator) {
            vm.stopPrank();
            vm.startPrank(random);
            if (riskScore > 100) {
                bytes4 selector = bytes4(keccak256("riskScoreOutOfRange(uint8)"));
                vm.expectRevert(abi.encodeWithSelector(selector, riskScore));
                applicationAppManager.addRiskScore(address(0xBABE), riskScore);
            }
        }
    }

    ///---------------TAGS--------------------
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: When the tag is not blank: Tag applied to 0xBABE address. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddTag(uint8 addressIndexA, uint8 addressIndexB, bytes32 Tag1) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            if (Tag1 == "") vm.expectRevert(0xd7be2be3);
            applicationAppManager.addTag(address(0xBABE), Tag1); //add tag
            if (Tag1 != "") assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag1));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: When the tag is not blank: Tag applied to 0xBABE address, else reverts. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddTag_Negative(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, bytes32 Tag1, bytes32 Tag2) public endWithStopPrank() {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag1);
        vm.assume(Tag2 != "");
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        vm.startPrank(sender);
        if (sender != superAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689"));
        applicationAppManager.addAppAdministrator(admin);
        if (sender == superAdmin) {
            vm.stopPrank();
            vm.startPrank(admin);
            if (Tag1 == "") vm.expectRevert(0xd7be2be3);
            applicationAppManager.addTag(address(0xBABE), Tag1); //add tag
            if (admin != appAdministrator && Tag1 != "") assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag2));
            vm.stopPrank();
            vm.startPrank(random);
            if ((random != admin && random != appAdministrator)) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(random), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            /// The expected reversion is dynamic and does not contain the expected error. 
            applicationAppManager.addTag(address(0xBABE), Tag2);
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: When the tag is not blank: Tag applied to tagAddresses array. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddMultipleGenTagsToMulitpleAccounts(bytes32 Tag1, bytes32 Tag2,  bytes32 Tag3) public endWithStopPrank() {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag3&& Tag3 != Tag1);
        vm.assume(Tag1 != "" && Tag2 != "" && Tag3 != "");
        bytes32[] memory genTags = createBytes32Array(Tag1, Tag2, Tag3);
        address[] memory tagAddresses = createAddressArray(address(0xff1), address(0xff2), address(0xff3));

        switchToAppAdministrator(); 
        applicationAppManager.addMultipleTagToMultipleAccounts(tagAddresses, genTags);
        /// Test to prove addresses in array are tagged by index matched to second array of tags
        assertTrue(applicationAppManager.hasTag(address(0xff1), Tag1));
        assertTrue(applicationAppManager.hasTag(address(0xff2), Tag2));
        assertTrue(applicationAppManager.hasTag(address(0xff3), Tag3));
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role:
     */
    function testApplication_ApplicationAppManagerFuzz_AddMultipleGenTagsToMulitpleAccounts_Negative(uint8 addressIndexA, bytes32 Tag1, bytes32 Tag2, bytes32 Tag3) public endWithStopPrank() {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag3&& Tag3 != Tag1);
        vm.assume(Tag1 != "" && Tag2 != "" && Tag3 != "");
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        bytes32[] memory genTags = createBytes32Array(Tag1, Tag2, Tag3);
        address[] memory tagAddresses = createAddressArray(address(0xff1), address(0xff2), address(0xff3));
        vm.startPrank(sender); 
        if (sender != appAdministrator) {
            vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.addMultipleTagToMultipleAccounts(tagAddresses, genTags);
        } 
        if (sender == appAdministrator) {
            applicationAppManager.addMultipleTagToMultipleAccounts(tagAddresses, genTags);
            /// Test to prove addresses in array are tagged by index matched to second array of tags
            assertTrue(applicationAppManager.hasTag(address(0xff1), Tag1));
            assertTrue(applicationAppManager.hasTag(address(0xff2), Tag2));
            assertTrue(applicationAppManager.hasTag(address(0xff3), Tag3));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: When the tag is not blank: Tags are applied to 0xBABE address, else reverts. 
     */
    function testApplication_ApplicationAppManagerFuzz_RemoveTag(uint8 addressIndexA, bytes32 Tag1, bytes32 Tag2, bytes32 Tag3, bytes32 Tag4) public endWithStopPrank() {
        vm.assume(Tag1 != Tag2 && Tag2 != Tag3 && Tag3 != Tag4 && Tag4 != Tag1 && Tag4 != Tag2 && Tag3 != Tag1);

        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        /// add first tag
        if (Tag1 == "") vm.expectRevert(0xd7be2be3);
        applicationAppManager.addTag(address(0xBABE), Tag1); //add tag
        if (Tag1 != "") {
            assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag1));
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag2));
        }
        /// add second tag
        if (Tag2 == "") vm.expectRevert(0xd7be2be3);
        applicationAppManager.addTag(address(0xBABE), Tag2); //add tag
        if (Tag2 != "") {
            assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag2));
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag3));
        }
        /// add a third tag
        if (Tag3 == "") vm.expectRevert(0xd7be2be3);
        applicationAppManager.addTag(address(0xBABE), Tag3); //add tag
        if (Tag3 != "") {
            assertTrue(applicationAppManager.hasTag(address(0xBABE), Tag3));
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag4));
        }
        /// remove tags
        vm.stopPrank();
        vm.startPrank(sender);
        console.log(address(sender));
        if ((sender != appAdministrator)) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
        applicationAppManager.removeTag(address(0xBABE), Tag3);
        if ((sender == appAdministrator)) assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag3));
        if ((sender != appAdministrator)) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
        applicationAppManager.removeTag(address(0xBABE), Tag2);
        if ((sender == appAdministrator)) assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag2));
        if ((sender != appAdministrator)) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
        applicationAppManager.removeTag(address(0xBABE), Tag1);
        if ((sender == appAdministrator)) {
            assertFalse(applicationAppManager.hasTag(address(0xBABE), Tag1));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: When the tag is not blank: Tag is applied to 0xBABE address, else reverts. 
     */
    function testApplication_ApplicationAppManagerFuzz_RemoveTag_Negative(uint8 addressIndexA, bytes32 Tag1) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        switchToAppAdministrator();
        /// add first tag
        if (Tag1 == "") vm.expectRevert(0xd7be2be3);
        applicationAppManager.addTag(address(0xBABE), Tag1); //add tag
        if (Tag1 != "") {
            assertFalse(!applicationAppManager.hasTag(address(0xBABE), Tag1));
            /// remove tags
            vm.stopPrank();
            vm.startPrank(sender);
            if ((sender != appAdministrator)) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.removeTag(address(0xBABE), Tag1);
        }
    }

    ///---------------PAUSE RULES----------------
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Sets the Pause Rules  
     */
    function testApplication_ApplicationAppManagerFuzz_AddPauseRuleFuzz(uint8 addressIndexA, uint8 addressIndexB, uint64 start, uint64 end) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        bytes4 selector = bytes4(keccak256("InvalidDateWindow(uint256,uint256)"));
        vm.startPrank(sender);
        if (sender != appAdministrator) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
            applicationAppManager.addRuleAdministrator(admin);
        if (sender == appAdministrator) {
            vm.stopPrank();
            vm.startPrank(admin);
            /// we are adding a repeated rule to test the resiliency of the
            /// contract to this scenario
            if (start >= end || start <= block.timestamp) vm.expectRevert(abi.encodeWithSelector(selector, start, end));
            applicationAppManager.addPauseRule(start, end);
            if (start >= end || start <= block.timestamp) vm.expectRevert(abi.encodeWithSelector(selector, start, end));
            applicationAppManager.addPauseRule(start, end);
            if (start < end && start > block.timestamp) {
                PauseRule[] memory test = applicationAppManager.getPauseRules();
                assertTrue(test.length == 2);
                assertTrue(applicationHandler.isPauseRuleActive() == true);
            }
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, and App Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin, Rule Admin, Risk Admin, and Rule Admins are set during test set up. 
     * Test that only the correct admin role can call the function within the App Manager.  
     * Postconditions: When Sender is correct admin role: Set Pause Rules, else reverts. 
     */
    function testApplication_ApplicationAppManagerFuzz_AddPauseRuleFuzz_Negative(uint8 addressIndexA, uint8 addressIndexB, uint8 addressIndexC, uint64 start, uint64 end) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndexA % ADDRESSES.length];
        address admin = ADDRESSES[addressIndexB % ADDRESSES.length];
        address random = ADDRESSES[addressIndexC % ADDRESSES.length];
        bytes4 selector = bytes4(keccak256("InvalidDateWindow(uint256,uint256)"));
        vm.startPrank(sender);
        if (sender != appAdministrator) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(sender), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
        applicationAppManager.addRuleAdministrator(admin);
        if (sender == appAdministrator) {
            vm.stopPrank();
            vm.startPrank(admin);
            /// we are adding a repeated rule to test the resiliency of the
            /// contract to this scenario
            if (start >= end || start <= block.timestamp) vm.expectRevert(abi.encodeWithSelector(selector, start, end));
            applicationAppManager.addPauseRule(start, end);
            if (start >= end || start <= block.timestamp) vm.expectRevert(abi.encodeWithSelector(selector, start, end));
            applicationAppManager.addPauseRule(start, end);
            if (start < end && start > block.timestamp) {
                PauseRule[] memory test = applicationAppManager.getPauseRules();
                assertFalse(test.length != 2);
                assertFalse(applicationHandler.isPauseRuleActive() != true);
                /// test if non admin can set a rule
                vm.stopPrank();
                vm.startPrank(random);
                /// testing onlyRule
                if (random != admin && random != ruleAdmin) vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(random), " is missing role 0x5ff038c4899bb7fbbc7cf40ef4accece5ebd324c2da5ab7db2c3b81e845e2a7a"));
                /// The expected reversion is dynamic and does not contain the expected error.
                applicationAppManager.addPauseRule(1769924850, 1769984900);
                if (random == admin || random == ruleAdmin) {
                    test = applicationAppManager.getPauseRules();
                    assertFalse(test.length != 3);
                }
                PauseRule[] memory total = applicationAppManager.getPauseRules();
                vm.stopPrank();
                vm.startPrank(admin);
                applicationAppManager.removePauseRule(start, end);
                test = applicationAppManager.getPauseRules();
                assertFalse(test.length != total.length - 2);
            }
        }
    }
}
