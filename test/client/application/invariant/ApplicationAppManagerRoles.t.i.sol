// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

/**
 * @title ApplicationAppManagerRolesTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for AppManager Role functionality.
 */
contract ApplicationAppManagerRolesTest is TestCommonFoundry {
    uint8 _seed;
    function setUp() public {
        setUpProtocolAndAppManager();
    }

    // There will always be a SuperAdmin
    function invariant_AlwaysASuperAdmin() public view {
        assertTrue(applicationAppManager.isSuperAdmin(superAdmin));
    }

    // When grantRole TREASURY_ACCOUNT is called directly on the AppManager contract the transaction will be reverted.
    function invariant_GrantRoleDirectCallRevertsTreasury() public {
        vm.expectRevert(bytes("Function disabled"));
        applicationAppManager.grantRole(TREASURY_ACCOUNT, user);
        assertFalse(applicationAppManager.isTreasuryAccount(user));
    }
    // When grantRole is SUPER_ADMIN_ROLE called directly on the AppManager contract the transaction will be reverted.
    function invariant_GrantRoleDirectCallRevertsSuperAdmin() public {
        vm.expectRevert(bytes("Function disabled"));
        applicationAppManager.grantRole(SUPER_ADMIN_ROLE, user);
        assertFalse(applicationAppManager.isSuperAdmin(user));
    }
    // When grantRole is APP_ADMIN_ROLE called directly on the AppManager contract the transaction will be reverted.
    function invariant_GrantRoleDirectCallRevertsAppAdmin() public {
        vm.expectRevert(bytes("Function disabled"));
        applicationAppManager.grantRole(APP_ADMIN_ROLE, user);
        assertFalse(applicationAppManager.isAppAdministrator(user));
    }
    // When grantRole is ACCESS_LEVEL_ADMIN_ROLE called directly on the AppManager contract the transaction will be reverted.
    function invariant_GrantRoleDirectCallRevertsAccessLevelAdmin() public {
        vm.expectRevert(bytes("Function disabled"));
        applicationAppManager.grantRole(ACCESS_LEVEL_ADMIN_ROLE, user);
        assertFalse(applicationAppManager.isAccessLevelAdmin(user));
    }
    // When grantRole is RISK_ADMIN_ROLE called directly on the AppManager contract the transaction will be reverted.
    function invariant_GrantRoleDirectCallRevertsRiskAdmin() public {
        vm.expectRevert(bytes("Function disabled"));
        applicationAppManager.grantRole(RISK_ADMIN_ROLE, user);
        assertFalse(applicationAppManager.isRiskAdmin(user));
    }
    // When renounceRole is called by the Super Admin the transaction will be reverted.
    function invariant_SuperAdminRenounceReverts() public {
        switchToSuperAdmin();
        vm.expectRevert(0x7f8e121f);
        applicationAppManager.renounceRole(SUPER_ADMIN_ROLE,superAdmin);
        assertTrue(applicationAppManager.isSuperAdmin(superAdmin));
    }
    // When addAppAdministrator is called by an account other than the Super Admin the transaction will be reverted.
    function invariant_OnlySuperAdminCanAddRemoveAppAdmin() public {
        if (_seed%2==0){
            switchToSuperAdmin();
            applicationAppManager.addAppAdministrator(user);
            assertTrue(applicationAppManager.isAppAdministrator(user));
        } else{
            vm.expectRevert();
            applicationAppManager.addAppAdministrator(user);
            assertFalse(applicationAppManager.isAppAdministrator(user));
        }
        _seed++;
    }
    // When addAppAdministrator is called with an address of 0 the transaction will be reverted.
    function invariant_AddAppAdministratorNoZeroAddress() public {
        switchToSuperAdmin();
        vm.expectRevert();
        applicationAppManager.addAppAdministrator(address(0));
        assertFalse(applicationAppManager.isAppAdministrator(address(0)));
    }
    // If addAppAdministrator is not reverted the AppAdministrator event will be emitted.
    function invariant_AddAppAdministratorEmitsEvent() public {
        switchToSuperAdmin();
        vm.expectEmit();
        emit RoleGranted(APP_ADMIN_ROLE, user, superAdmin);
        applicationAppManager.addAppAdministrator(user);
    }
    // When renounceRole is called with argument APP_ADMIN_ROLE the AccessControl.RoleRevoked event will be emitted.
    function invariant_RenounceAppAdministratorEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit RoleRevoked(APP_ADMIN_ROLE, appAdministrator, appAdministrator);
        applicationAppManager.renounceRole(APP_ADMIN_ROLE, appAdministrator);
    }

    /** RULE ADMIN */
    // When addRuleAdministrator is called by an account other than the App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddRemoveRuleAdmin() public {
        if (_seed%2==0){
            switchToAppAdministrator();
            applicationAppManager.addRuleAdministrator(user);
            assertTrue(applicationAppManager.isRuleAdministrator(user));
        } else{
            vm.expectRevert();
            applicationAppManager.addRuleAdministrator(user);
            assertFalse(applicationAppManager.isRuleAdministrator(user));
        }
        _seed++;
    }
    // When addRuleAdministrator is called with an address of 0 the transaction will be reverted.
    function invariant_AddRuleAdministratorNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.addRuleAdministrator(address(0));
        assertFalse(applicationAppManager.isRuleAdministrator(address(0)));
    }
    // If addRuleAdministrator is not reverted the RuleAdministrator event will be emitted.
    function invariant_AddRuleAdministratorEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit RoleGranted(RULE_ADMIN_ROLE, user, appAdministrator);
        applicationAppManager.addRuleAdministrator(user);
    }
    // When renounceRole is called with argument RULE_ADMIN_ROLE the AccessControl.RoleRevoked event will be emitted.
    function invariant_RenounceRuleAdministratorEmitsEvent() public {
        switchToRuleAdmin();
        vm.expectEmit();
        emit RoleRevoked(RULE_ADMIN_ROLE, ruleAdmin, ruleAdmin);
        applicationAppManager.renounceRole(RULE_ADMIN_ROLE, ruleAdmin);
    }

    /** RISK ADMIN */
    // When addRiskAdmin is called by an account other than the App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddRemoveRiskAdmin() public {
        if (_seed%2==0){
            switchToAppAdministrator();
            applicationAppManager.addRiskAdmin(user);
            assertTrue(applicationAppManager.isRiskAdmin(user));
        } else{
            vm.expectRevert();
            applicationAppManager.addRiskAdmin(user);
            assertFalse(applicationAppManager.isRiskAdmin(user));
        }
        _seed++;
    }
    // When addRiskAdmin is called with an address of 0 the transaction will be reverted.
    function invariant_AddRiskAdminrNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.addRuleAdministrator(address(0));
        assertFalse(applicationAppManager.isRuleAdministrator(address(0)));
    }
    // If addRiskAdmin is not reverted the RiskAdmin event will be emitted.
    function invariant_AddRiskAdminEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit RoleGranted(RISK_ADMIN_ROLE, user, appAdministrator);
        applicationAppManager.addRiskAdmin(user);
    }
    // When renounceRole is called with argument RISK_ADMIN_ROLE the AccessControl.RoleRevoked event will be emitted.
    function invariant_RenounceRiskAdminEmitsEvent() public {
        switchToRiskAdmin();
        vm.expectEmit();
        emit RoleRevoked(RISK_ADMIN_ROLE, riskAdmin, riskAdmin);
        applicationAppManager.renounceRole(RISK_ADMIN_ROLE, riskAdmin);
    }

    /** ACCESS LEVEL ADMIN */
    // When addAccessLevelAdmin is called by an account other than the App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddRemoveAccessLevelAdmin() public {
        if (_seed%2==0){
            switchToAppAdministrator();
            applicationAppManager.addAccessLevelAdmin(user);
            assertTrue(applicationAppManager.isAccessLevelAdmin(user));
        } else{
            vm.expectRevert();
            applicationAppManager.addAccessLevelAdmin(user);
            assertFalse(applicationAppManager.isAccessLevelAdmin(user));
        }
        _seed++;
    }
    // When addAccessLevelAdmin is called with an address of 0 the transaction will be reverted.
    function invariant_AddAccessLevelAdminrNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.addRuleAdministrator(address(0));
        assertFalse(applicationAppManager.isRuleAdministrator(address(0)));
    }
    // If addAccessLevelAdmin is not reverted the AccessLevelAdmin event will be emitted.
    function invariant_AddAccessLevelAdminEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit RoleGranted(ACCESS_LEVEL_ADMIN_ROLE, user, appAdministrator);
        applicationAppManager.addAccessLevelAdmin(user);
    }
    // When renounceRole is called with argument ACCESS_LEVEL_ADMIN_ROLE the AccessControl.RoleRevoked event will be emitted.
    function invariant_RenounceAccessLevelAdminEmitsEvent() public {
        switchToAccessLevelAdmin();
        vm.expectEmit();
        emit RoleRevoked(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin, accessLevelAdmin);
        applicationAppManager.renounceRole(ACCESS_LEVEL_ADMIN_ROLE, accessLevelAdmin);
    }

    /** TREASURY ACCOUNT   */
    // When addTreasuryAccount is called by an account other than the App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddRemoveTreasuryAccount() public {
        if (_seed%2==0){
            switchToAppAdministrator();
            applicationAppManager.addTreasuryAccount(user);
            assertTrue(applicationAppManager.isTreasuryAccount(user));
        } else{
            vm.expectRevert();
            applicationAppManager.addTreasuryAccount(user);
            assertFalse(applicationAppManager.isTreasuryAccount(user));
        }
        _seed++;
    }
    // When addTreasuryAccount is called with an address of 0 the transaction will be reverted.
    function invariant_AddTreasuryAccountrNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.addRuleAdministrator(address(0));
        assertFalse(applicationAppManager.isRuleAdministrator(address(0)));
    }
    // If addTreasuryAccount is not reverted the TreasuryAccount event will be emitted.
    function invariant_AddTreasuryAccountEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit RoleGranted(TREASURY_ACCOUNT, user, appAdministrator);
        applicationAppManager.addTreasuryAccount(user);
    }
    // When renounceRole is called with argument TREASURY_ACCOUNT the AccessControl.RoleRevoked event will be emitted.
    function invariant_RenounceTreasuryAccountEmitsEvent() public {
        switchToTreasuryAccount();
        vm.expectEmit();
        emit RoleRevoked(TREASURY_ACCOUNT, treasuryAccount, treasuryAccount);
        applicationAppManager.renounceRole(TREASURY_ACCOUNT, treasuryAccount);
    }

}
