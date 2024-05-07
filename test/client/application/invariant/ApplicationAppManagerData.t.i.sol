// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

/**
 * @title ApplicationAppManagerDataTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for AppManager data functionality.
 */
contract ApplicationAppManagerDataInvariantTest is TestCommonFoundry {
    address msgSender;
    function setUp() public {
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin);
        applicationAppManager.addRiskAdmin(riskAdmin);
        applicationAppManager.addRuleAdministrator(ruleAdmin);
        applicationAppManager.addTreasuryAccount(treasuryAccount);
        applicationAppManager.addTag(bob,bytes32("TAG"));
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(bob, 4);
        vm.stopPrank();
        targetSender(accessLevelAdmin);
        targetSender(riskAdmin);
        targetSender(ruleAdmin);
        targetSender(treasuryAccount);
    }

    /** ACCESS LEVELS **********/

    // If addAccessLevel is called by an account that is not an Access Level Admin the transaction will be reverted.
    function invariant_OnlyAccessLevelAdminCanAddAccessLevel() public {
        (, msgSender, ) = vm.readCallers();
        
        if (msgSender == accessLevelAdmin){
            applicationAppManager.addAccessLevel(user, 1);
            assertEq(applicationAppManager.getAccessLevel(user), 1);
        } else{
            vm.expectRevert();
            applicationAppManager.addAccessLevel(user, 1);
        }   
    }

    // If addAccessLevelToMultipleAccounts is called by an account that is not an Access Level Admin the transaction will be reverted.
    function invariant_OnlyAccessLevelAdminCanAddMultiAccessLevel() public {
        (, msgSender, ) = vm.readCallers();
        address[] memory users = new address[](1);
        users[0] = user;
        if (msgSender == accessLevelAdmin){
            applicationAppManager.addAccessLevelToMultipleAccounts(users, 1);
            assertEq(applicationAppManager.getAccessLevel(user), 1);
        } else {
            vm.expectRevert();
            applicationAppManager.addAccessLevelToMultipleAccounts(users, 1);
        }
    }

    // If addMultipleAccessLevels is called by an account that is not an Access Level Admin the transaction will be reverted.
    function invariant_OnlyAccessLevelAdminCanAddMultipleAccessLevels() public {
        (, msgSender, ) = vm.readCallers();
        address[] memory users = new address[](1);
        users[0] = user;
        uint8[] memory levels = new uint8[](1);
        levels[0] = 2;
        if (msgSender == accessLevelAdmin){
            applicationAppManager.addMultipleAccessLevels(users, levels);
            assertEq(applicationAppManager.getAccessLevel(user), 2);
        } else {
            vm.expectRevert();
            applicationAppManager.addMultipleAccessLevels(users, levels);
        }
    }

    // If removeAccessLevel is called by an account that is not an Access Level Admin the transaction will be reverted.
    function invariant_OnlyAccessLevelAdminCanRemoveAccessLevels() public {
        (, msgSender, ) = vm.readCallers();
        if (msgSender == accessLevelAdmin){
            applicationAppManager.removeAccessLevel(bob);
            assertEq(applicationAppManager.getAccessLevel(bob), 0);
        } else{
            vm.expectRevert();
            applicationAppManager.removeAccessLevel(bob);
        }   
    }


/** RISK SCORES **********/

    // If addRiskScore is called by an account that is not a Risk Admin the transaction will be reverted.
    function invariant_OnlyRiskScoreAdminCanAddRiskScore() public {
        (, msgSender, ) = vm.readCallers();
        
        if (msgSender == riskAdmin){
            applicationAppManager.addRiskScore(user, 1);
            assertEq(applicationAppManager.getRiskScore(user), 1);
        } else{
            vm.expectRevert();
            applicationAppManager.addRiskScore(user, 1);
        }   
    }

    // If addRiskScoreToMultipleAccounts is called by an account that is not a Risk Admin the transaction will be reverted.
    function invariant_OnlyRiskScoreAdminCanAddMultiRiskScore() public {
        (, msgSender, ) = vm.readCallers();
        address[] memory users = new address[](1);
        users[0] = user;
        if (msgSender == riskAdmin){
            applicationAppManager.addRiskScoreToMultipleAccounts(users, 1);
            assertEq(applicationAppManager.getRiskScore(user), 1);
        } else {
            vm.expectRevert();
            applicationAppManager.addRiskScoreToMultipleAccounts(users, 1);
        }
    }

    // If addMultipleRiskScores is called by an account that is not a Risk Admin the transaction will be reverted.
    function invariant_OnlyRiskScoreAdminCanAddMultipleRiskScores() public {
        (, msgSender, ) = vm.readCallers();
        address[] memory users = new address[](1);
        users[0] = user;
        uint8[] memory levels = new uint8[](1);
        levels[0] = 2;
        if (msgSender == riskAdmin){
            applicationAppManager.addMultipleRiskScores(users, levels);
            assertEq(applicationAppManager.getRiskScore(user), 2);
        } else {
            vm.expectRevert();
            applicationAppManager.addMultipleRiskScores(users, levels);
        }
    }

    // If removeRiskScore is called by an account that is not a Risk Admin the transaction will be reverted.
    function invariant_OnlyRiskScoreAdminCanRemoveRiskScores() public {
        (, msgSender, ) = vm.readCallers();
        if (msgSender == riskAdmin){
            applicationAppManager.removeRiskScore(bob);
            assertEq(applicationAppManager.getRiskScore(bob), 0);
        } else{
            vm.expectRevert();
            applicationAppManager.removeRiskScore(bob);
        }   
    }

/** PAUSE RULES **********/

    // If addPauseRule is called by an account that is not an Rule Admin the transaction will be reverted.
    function invariant_OnlyRuleAdminCanAddPauseRule() public {
        (, msgSender, ) = vm.readCallers();
        
        if (msgSender == ruleAdmin){
            applicationAppManager.addPauseRule(Blocktime, Blocktime + 10000);
            assertEq(applicationAppManager.getPauseRules().length,1);
        } else{
            vm.expectRevert();
            applicationAppManager.addPauseRule(Blocktime, Blocktime + 10000);
        }   
    }


    // If removePauseRule is called by an account that is not an Rule Admin the transaction will be reverted.
    function invariant_OnlyRuleAdminCanRemovePauseRules() public {
        (, msgSender, ) = vm.readCallers();
        if (msgSender == ruleAdmin){
            applicationAppManager.addPauseRule(Blocktime, Blocktime + 10000);
            applicationAppManager.removePauseRule(Blocktime, Blocktime + 10000);
            assertEq(applicationAppManager.getPauseRules().length,0);
        } else{
            vm.expectRevert();
            applicationAppManager.removePauseRule(Blocktime, Blocktime + 10000);
        }   
    }

    // If activatePauseRuleCheck is called by an account that is not a Rule Admin the transaction will be reverted.
    function invariant_OnlyRuleAdminCanActivatePauseRuleCheck() public {
        (, msgSender, ) = vm.readCallers();
        if (msgSender == ruleAdmin){
            applicationAppManager.activatePauseRuleCheck(true);
        } else{
            vm.expectRevert();
            applicationAppManager.activatePauseRuleCheck(true);
        }   
    }

/** TAGS **********/

    // If addTag is called by an account that is not a App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddTag() public {
        (, msgSender, ) = vm.readCallers();
        
        if (msgSender == appAdministrator){
            applicationAppManager.addTag(user, bytes32("TAG"));
            assertTrue(applicationAppManager.hasTag(user,bytes32("TAG")));
        } else{
            vm.expectRevert();
            applicationAppManager.addTag(user, bytes32("TAG"));
            assertFalse(applicationAppManager.hasTag(user,bytes32("TAG")));
        }   
    }

    // If addTagToMultipleAccounts is called by an account that is not a App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddMultiTag() public {
        (, msgSender, ) = vm.readCallers();
        address[] memory users = new address[](1);
        users[0] = user;
        if (msgSender == appAdministrator){
            applicationAppManager.addTagToMultipleAccounts(users, bytes32("TAG"));
            assertTrue(applicationAppManager.hasTag(user,bytes32("TAG")));
        } else {
            vm.expectRevert();
            applicationAppManager.addTagToMultipleAccounts(users, bytes32("TAG"));
        }
    }

    // If addMultipleTags is called by an account that is not a App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanAddMultipleTags() public {
        (, msgSender, ) = vm.readCallers();
        address[] memory users = new address[](1);
        users[0] = user;
        bytes32[] memory tags = new bytes32[](1);
        tags[0] = bytes32("TAG");
        if (msgSender == appAdministrator){
            applicationAppManager.addMultipleTagToMultipleAccounts(users, tags);
            assertTrue(applicationAppManager.hasTag(user,bytes32("TAG")));
        } else {
            vm.expectRevert();
            applicationAppManager.addMultipleTagToMultipleAccounts(users, tags);
        }
    }

    // If removeTag is called by an account that is not a App Admin the transaction will be reverted.
    function invariant_OnlyAppAdminCanRemoveTags() public {
        (, msgSender, ) = vm.readCallers();
        if (msgSender == appAdministrator){
            applicationAppManager.removeTag(bob, bytes32("TAG"));
            assertFalse(applicationAppManager.hasTag(user,bytes32("TAG")));
        } else{
            vm.expectRevert();
            applicationAppManager.removeTag(bob, bytes32("TAG"));
        }   
    }

/** PROVIDERS **********/
    // If proposeRiskScoresProvider is called with an address of 0 the transaction will be reverted.
    function invariant_ProposeRiskScoresProviderNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.proposeRiskScoresProvider(address(0));
    }
    // If proposeRiskScoresProvider is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_ProposeRiskScoresProviderNotAppAdmin() public {
        vm.expectRevert();
        applicationAppManager.proposeRiskScoresProvider(user);
    }
    // If proposeTagsProvider is called with an address of 0 the transaction will be reverted.
    function invariant_ProposeTagsProviderNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.proposeTagsProvider(address(0));
    }
    // If proposeTagsProvider is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_ProposeTagsProviderNotAppAdmin() public {
        vm.expectRevert();
        applicationAppManager.proposeTagsProvider(user);
    }
    // If proposePauseRulesProvider is called with an address of 0 the transaction will be reverted.
    function invariant_ProposePauseRulesProviderNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.proposePauseRulesProvider(address(0));
    }
    // If proposePauseRulesProvider is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_ProposePauseRulesProviderNotAppAdmin() public {
        vm.expectRevert();
        applicationAppManager.proposePauseRulesProvider(user);
    }
    // If proposeAccessLevelProvider is called with an address of 0 the transaction will be reverted.
    function invariant_ProposeAccessLevelProviderNoZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.proposeAccessLevelsProvider(address(0));
    }
    // If proposeAccessLevelProvider is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_ProposeAccessLevelProviderNotAppAdmin() public {
        vm.expectRevert();
        applicationAppManager.proposeAccessLevelsProvider(user);
    }
}
