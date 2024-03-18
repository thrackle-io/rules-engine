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

    // When grantRole RULE_BYPASS_ACCOUNT is called directly on the AppManager contract the transaction will be reverted.
    function invariant_GrantRoleDirectCallRevertsRuleBypass() public {
        vm.expectRevert(bytes("Function disabled"));
        applicationAppManager.grantRole(RULE_BYPASS_ACCOUNT, user);
        assertFalse(applicationAppManager.isRuleBypassAccount(user));
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
        emit AD1467_AppAdministrator(user, true);
        applicationAppManager.addAppAdministrator(user);
    }
    // When renounceAppAdministrator is called the AppAdministrator event will be emitted.
    function invariant_RenounceAppAdministratorEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit AD1467_AppAdministrator(appAdministrator, false);
        applicationAppManager.renounceAppAdministrator();
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
        emit AD1467_RuleAdmin(user, true);
        applicationAppManager.addRuleAdministrator(user);
    }
    // When renounceRuleAdministrator is called the RuleAdministrator event will be emitted.
    function invariant_RenounceRuleAdministratorEmitsEvent() public {
        switchToRuleAdmin();
        vm.expectEmit();
        emit AD1467_RuleAdmin(ruleAdmin, false);
        applicationAppManager.renounceRuleAdministrator();
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
        emit AD1467_RiskAdmin(user, true);
        applicationAppManager.addRiskAdmin(user);
    }
    // When renounceRiskAdmin is called the RiskAdmin event will be emitted.
    function invariant_RenounceRiskAdminEmitsEvent() public {
        switchToRiskAdmin();
        vm.expectEmit();
        emit AD1467_RiskAdmin(riskAdmin, false);
        applicationAppManager.renounceRiskAdmin();
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
        emit AD1467_AccessLevelAdmin(user, true);
        applicationAppManager.addAccessLevelAdmin(user);
    }
    // When renounceAccessLevelAdmin is called the AccessLevelAdmin event will be emitted.
    function invariant_RenounceAccessLevelAdminEmitsEvent() public {
        switchToAccessLevelAdmin();
        vm.expectEmit();
        emit AD1467_AccessLevelAdmin(accessLevelAdmin, false);
        applicationAppManager.renounceAccessLevelAdmin();
    }

    /** RULE BYPASS  */
    // When addRuleBypassAccount is called by an account other than the App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddRemoveRuleBypassAccount() public {
        if (_seed%2==0){
            switchToAppAdministrator();
            applicationAppManager.addRuleBypassAccount(user);
            assertTrue(applicationAppManager.isRuleBypassAccount(user));
        } else{
            vm.expectRevert();
            applicationAppManager.addRuleBypassAccount(user);
            assertFalse(applicationAppManager.isRuleBypassAccount(user));
        }
        _seed++;
    }
    // When addRuleBypassAccount is called with an address of 0 the transaction will be reverted.
    function invariant_AddRuleBypassAccountrNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.addRuleAdministrator(address(0));
        assertFalse(applicationAppManager.isRuleAdministrator(address(0)));
    }
    // If addRuleBypassAccount is not reverted the RuleBypassAccount event will be emitted.
    function invariant_AddRuleBypassAccountEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit AD1467_RuleBypassAccount(user, true);
        applicationAppManager.addRuleBypassAccount(user);
    }
    // When renounceRuleBypassAccount is called the RuleBypassAccount event will be emitted.
    function invariant_RenounceRuleBypassAccountEmitsEvent() public {
        switchToRuleBypassAccount();
        vm.expectEmit();
        emit AD1467_RuleBypassAccount(ruleBypassAccount, false);
        applicationAppManager.renounceRuleBypassAccount();
    }

}
