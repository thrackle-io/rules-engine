// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";


/**
 * @title ApplicationAppManagerTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for AppManager general functionality.
 */
contract ApplicationAppManagerTest is TestCommonFoundry {
    address msgSender;
    ApplicationAppManager applicationAppManagerMigration;
    AppManager appManagerData;
    
    function setUp() public {
        setUpProtocolAndAppManagerAndTokensWithERC721HandlerDiamond();
        switchToAppAdministrator();
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin);
        applicationAppManager.addRiskAdmin(riskAdmin);
        applicationAppManager.addRuleAdministrator(ruleAdmin);
        applicationAppManager.addTreasuryAccount(treasuryAccount);
        applicationAppManager.approveAddressToTradingRuleAllowlist(tradingRuleAddress, true);
        switchToSuperAdmin();
        appManagerData = new AppManager(superAdmin, "Data", false);        
        applicationAppManagerMigration = new ApplicationAppManager(superAdmin, "Castlevania", false);
        applicationAppManagerMigration.addAppAdministrator(appAdministrator);
        appManagerData.addAppAdministrator(appAdministrator);
        switchToAppAdministrator();
        applicationAppManager.proposeDataContractMigration(address(appManagerData));
        applicationNFT.proposeAppManagerAddress(address(applicationAppManagerMigration));
        vm.stopPrank();
        targetSender(accessLevelAdmin);
        targetSender(appAdministrator);
        targetSender(riskAdmin);
        targetSender(ruleAdmin);
        targetSender(treasuryAccount);
        targetContract(address(applicationAppManager));
    }

/** REGISTRATION **********/

    // If isRegisteredHandler returns false for an address, calling checkApplicationRules from the address will result in the transaction being reverted.
    function invariant_CheckApplicationRulesOnlyRegisteredHandler() public {
        vm.expectRevert(abi.encodeWithSignature("NotRegisteredHandler(address)", address(this)));
        applicationAppManager.checkApplicationRules(msgSender, user, user, 1, 15, 0, ActionTypes.BURN, HandlerTypes.ERC721HANDLER);
    }

    // If registerToken is called with an address of 0 the transaction will be reverted.
    function invariant_RegisterTokenZeroAddressNotAllowed() public {
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("ZeroAddress()"));
        applicationAppManager.registerToken("token", address(0));
    }
    // If registerToken is called by an account that is not an App Admin the transaction will be reverted. 
    function invariant_RegisterTokenOnlyAppAdmin() public {
        (, msgSender, ) = vm.readCallers();
        if (!applicationAppManager.isAppAdministrator(msgSender)){
            vm.expectRevert();
            applicationAppManager.registerToken("token", address(applicationNFT));
        } else {
            applicationAppManager.registerToken("token", address(applicationNFT));
        }
    }
    // If deregisterToken is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_DeRegisterTokenOnlyAppAdmin() public {
        (, msgSender, ) = vm.readCallers();
        string memory appName = applicationNFT.name();
        if (!applicationAppManager.isAppAdministrator(msgSender)){
            vm.expectRevert();
            applicationAppManager.deregisterToken(appName);
        } else{
            applicationAppManager.deregisterToken(appName);
        }
    }

    // If deregisterToken is called with the address of a token that is not registered, the transaction will be reverted. 
    function invariant_DeRegisterTokenPreviouslyRegistered() public {
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("NoAddressToRemove()"));
        applicationAppManager.deregisterToken("TEST");
    }

    // If deregisterToken is not reverted the RemoveFromRegistry event will be emitted.
    function invariant_DeRegisterTokenAlwaysEmitsEvent() public {
        switchToAppAdministrator();
        string memory appName = applicationNFT.name();
        vm.expectEmit();
        emit AD1467_RemoveFromRegistry(applicationNFT.name(), address(applicationNFT));
        applicationAppManager.deregisterToken(appName);
    }

// TRADING RULE ALLOW LIST
    // If approveAddressToTradingRuleAllowlist is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_ApproveAddressToTradingListOnlyAppAdmin() public {
        (, msgSender, ) = vm.readCallers();
        if (!applicationAppManager.isAppAdministrator(msgSender)){
            vm.expectRevert();
            applicationAppManager.approveAddressToTradingRuleAllowlist(address(0xDabbaDabbaD00), true);
        } else{
            applicationAppManager.approveAddressToTradingRuleAllowlist(address(0xDabbaDabbaD00), true);
        }
    }
    // If an address that has not been previously added is passed in along with a false for isApproved the transaction will be reverted.
    function invariant_ApproveAddressToTradingListNotPreviouslyRegistered() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.approveAddressToTradingRuleAllowlist(address(0xDabbaDabbaD00), false);
    }
    // If an address that is already approved is passed in along with a true for isApproved the transaction will be reverted. 
    function invariant_ApproveAddressToTradingListAlreadyApproved() public {
        switchToAppAdministrator();
        vm.expectRevert();
        applicationAppManager.approveAddressToTradingRuleAllowlist(tradingRuleAddress, true);
    }
    // If approveAddressToTradingRuleAllowList is not reverted the TradingRuleAddressAllowList event will be emitted.
    function invariant_ApproveAddressToTradingListEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit AD1467_TradingRuleAddressAllowlist(address(0xDabbaDabbaD00), true);
        applicationAppManager.approveAddressToTradingRuleAllowlist(address(0xDabbaDabbaD00), true);
    }
// APPHANDLER ADDRESS
    // If setNewApplicationHandlerAddress is called with an address of 0 the transaction will be reverted.
    function invariant_NewApplicationHandlerAddressZeroAddressNotAllowed() public {
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("ZeroAddress()"));
        applicationAppManager.setNewApplicationHandlerAddress(address(0));
    }   
    // If setNewApplicationHandlerAddress is called by an account that is not an App Admin the transaction will be reverted. 
    function invariant_NewApplicationHandlerAddressOnlyAppAdmin() public {
        (, msgSender, ) = vm.readCallers();
        address appHandlerAddress = applicationAppManager.getHandlerAddress();
        if (!applicationAppManager.isAppAdministrator(msgSender)){
            vm.expectRevert();
            applicationAppManager.setNewApplicationHandlerAddress(appHandlerAddress);
        } else{
            applicationAppManager.setNewApplicationHandlerAddress(appHandlerAddress);
        }
    }
    // If setNewApplicationHandlerAddress is not reverted the HandlerConnected event will be emitted.
    function invariant_NewApplicationHandlerAddressEmitsEvent() public {
        switchToAppAdministrator();
        address appHandlerAddress = applicationAppManager.getHandlerAddress();
        vm.expectEmit();
        emit AD1467_HandlerConnected(appHandlerAddress, address(applicationAppManager)); 
        applicationAppManager.setNewApplicationHandlerAddress(appHandlerAddress);
    }

    // If setAppName is called by an account that is not an App Admin the transaction will be reverted. 
    function invariant_SetAppNameOnlyAppAdmin() public {
        (, msgSender, ) = vm.readCallers();
        if (!applicationAppManager.isAppAdministrator(msgSender)){
            vm.expectRevert();
            applicationAppManager.setAppName("New App Name");
        } else{
            applicationAppManager.setAppName("New App Name");
        }
    }
    // If proposeDataContractMigration is called by an account that is not an App Admin the transaction will be reverted. 
    function invariant_ProposeDataContractMigrationOnlyAppAdmin() public {
        (, msgSender, ) = vm.readCallers();
        if (!applicationAppManager.isAppAdministrator(msgSender)){
            vm.expectRevert();
            applicationAppManager.proposeDataContractMigration(address(applicationAppManager));
        } else{
            applicationAppManager.proposeDataContractMigration(address(applicationAppManager));
        }
    }
    // If proposeDataContractMigration is not reverted the AppManagerDataUpgradeProposed event is emitted.
    function invariant_ProposeDataContractMigrationEmitsEvent() public {
        switchToAppAdministrator();
        vm.expectEmit();
        emit AD1467_AppManagerDataUpgradeProposed(address(applicationAppManager), address(applicationAppManager)); 
        applicationAppManager.proposeDataContractMigration(address(applicationAppManager));
    }

/// NEW DATA PROVIDER
    // When confirmNewDataProvider is called with a provider type of TAG and is not reverted, the TagProviderSet event will be emitted.
    function invariant_ConfirmNewDataProviderEmitsEventTag() public {
        switchToAppAdministrator();
        Tags data = new Tags(address(applicationAppManager));
        applicationAppManager.proposeTagsProvider(address(data));
        vm.expectEmit(address(applicationAppManager));
        emit AD1467_TagProviderSet(address(data)); 
        data.confirmDataProvider(IDataEnum.ProviderType.TAG);
    }
    // When confirmNewDataProvider is called with a provider type of RISK_SCORE and is not reverted, the RiskProviderSet event will be emitted.
    function invariant_ConfirmNewDataProviderEmitsEventRiskScore() public {
        switchToAppAdministrator();
        RiskScores data = new RiskScores(address(applicationAppManager));
        applicationAppManager.proposeRiskScoresProvider(address(data));
        vm.expectEmit(address(applicationAppManager));
        emit AD1467_RiskProviderSet(address(data)); 
        data.confirmDataProvider(IDataEnum.ProviderType.RISK_SCORE);
    }
    // When confirmNewDataProvider is called with a provider type of ACCESS_LEVEL and is not reverted, the AccessLevelProviderSet event will be emitted.
    function invariant_ConfirmNewDataProviderEmitsEventAccessLevel() public {
        switchToAppAdministrator();
        AccessLevels data = new AccessLevels(address(applicationAppManager));
        applicationAppManager.proposeAccessLevelsProvider(address(data));
        vm.expectEmit(address(applicationAppManager));
        emit AD1467_AccessLevelProviderSet(address(data)); 
        data.confirmDataProvider(IDataEnum.ProviderType.ACCESS_LEVEL);
    }
    // When confirmNewDataProvider is called with a provider type of PAUSE_RULE and is not reverted, the PauseRuleProviderSet event will be emitted.
    function invariant_ConfirmNewDataProviderEmitsEventPauseRule() public {
        switchToAppAdministrator();
        PauseRules data = new PauseRules(address(applicationAppManager));
        applicationAppManager.proposePauseRulesProvider(address(data));
        vm.expectEmit(address(applicationAppManager));
        emit AD1467_PauseRuleProviderSet(address(data)); 
        data.confirmDataProvider(IDataEnum.ProviderType.PAUSE_RULE);
    }

/// DATA MIGRATION
    // If confirmDataContractMigration is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_ConfirmDataContractMigrationAppAdminOnly() public {
        (, msgSender, ) = vm.readCallers();
        if (!applicationAppManager.isAppAdministrator(msgSender)){
            vm.expectRevert();
            applicationAppManagerMigration.confirmDataContractMigration(address(applicationAppManager));
        } else{
            applicationAppManagerMigration.confirmDataContractMigration(address(applicationAppManager));
        }
    }
    // If confirmDataContractMigration is not reverted the DataContractsMigrated event is emitted.
    function invariant_ConfirmDataContractMigrationEmitsEvent() public {
       switchToAppAdministrator(); // create an app admin and make it the sender.
        applicationAppManager.proposeDataContractMigration(address(appManagerData));
        vm.expectEmit(address(appManagerData));
        emit AD1467_DataContractsMigrated(address(appManagerData)); 
        appManagerData.confirmDataContractMigration(address(applicationAppManager));
    }
    
/// APPMANAGER UPGRADE
    // If confirmAppManager is called by an account that is not an App Admin the transaction will be reverted.
    function invariant_ConfirmAppManagerAppAdminOnly() public {
        (, msgSender, ) = vm.readCallers();
        if (!applicationAppManager.isAppAdministrator(msgSender)){            
            vm.expectRevert();
            applicationAppManagerMigration.confirmAppManager(address(applicationNFT));
        } else{
            applicationAppManagerMigration.confirmAppManager(address(applicationNFT));
        }
    }
}
