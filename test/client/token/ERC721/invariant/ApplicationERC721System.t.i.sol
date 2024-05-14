// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ApplicationERC721Common.t.i.sol";

/**
 * @title ApplicationERC721SystemInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC721 Protocol functionality.
 */
contract ApplicationERC721SystemInvariantTest is ApplicationERC721Common {
    function setUp() public {
        prepERC721AndEnvironment();
        excludeContract(address(applicationAppManager));
        excludeContract(address(ruleProcessor));
        excludeContract(address(applicationCoin));
        excludeContract(address(applicationCoinHandler));
        excludeContract(address(applicationNFTv2));
        excludeContract(address(applicationNFTHandlerv2));
        excludeContract(address(erc20Pricer));
        excludeContract(address(erc721Pricer));
        excludeContract(address(oracleApproved));
        excludeContract(address(oracleDenied));

        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = applicationNFT.getHandlerAddress.selector;
        selectors[1] = applicationNFT.connectHandlerToToken.selector;
        selectors[2] = applicationNFT.getAppManagerAddress.selector;
        selectors[3] = applicationNFT.proposeAppManagerAddress.selector;
        selectors[4] = applicationNFT.confirmAppManagerAddress.selector;
        targetSelector(FuzzSelector({addr: address(applicationNFT), selectors: selectors}));
    }

    // Any user can get the contract's version
    function invariant_ERC721_external_VersionCanBeCalledByAnyUser() public {
        vm.startPrank(USER1);
        bytes memory version = bytes(VersionFacet(address(applicationNFTHandler)).version());
        assertEq(version, "1.2.0"); 
    }

    // Only app admins may connect a handler
    function invariant_ERC721_external_ConnectHandlerAppAdminOnly() public {
        ADDRESSES.push(address(appAdministrator)); 
        if (msg.sender == appAdministrator){ 
            applicationNFT.connectHandlerToToken(address(0xAAA));
            assertEq(applicationNFT.getHandlerAddress(), address(0xAAA)); 
        } else {
            vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
            applicationNFT.connectHandlerToToken(address(0xAAA));
            assertEq(applicationNFT.getHandlerAddress(), address(applicationNFTHandler));
        }
    }

    // A non-appAdmin can never connect a handler to the contract
    function invariant_ERC721_external_UserCannotConnectHandler() public {
        vm.startPrank(USER1);
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        applicationNFT.connectHandlerToToken(address(0xAAA));
        assertEq(applicationNFT.getHandlerAddress(), address(applicationNFTHandler)); 
    }

    // Any account can retrieve handler address
    function invariant_ERC721_external_AnyUserCanRetrieveHandler() public {
        vm.startPrank(USER1);
        address user1Handler = applicationNFT.getHandlerAddress();
        vm.startPrank(USER2);
        address user2Handler = applicationNFT.getHandlerAddress();
        assertEq(user1Handler, user2Handler); 
    }

    // Any account can retrieve App Manager address
    function invariant_ERC721_external_AnyUserCanRetrieveAppManager() public {
        vm.startPrank(USER1);
        address user1AppManagerAddress = applicationNFT.getAppManagerAddress();
        assertEq(user1AppManagerAddress, address(applicationAppManager)); 
    }

    // Once the handler address is set to a non zero address, Handler address can never be zero address
    function invariant_ERC721_external_CannotConnectHandlerToZeroAddress() public {
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("ZeroAddress()"));
        applicationNFT.connectHandlerToToken(address(0x0));
        assertEq(applicationNFT.getHandlerAddress(), address(applicationNFTHandler)); 
    }

    // New deployment will always emit NewTokenDeployed event
    function invariant_ERC721_external_DeploymentEventEmission() public {
        vm.expectEmit(true, false, false, false);
        emit AD1467_NewNFTDeployed(address(applicationAppManager));
        new ApplicationERC721("TEST", "TST", address(applicationAppManager), "https://SampleApp.io");
    }

    // Only an App Admin can propose a new AppManager
    function invariant_ERC721_external_ProposeAppManager_OnlyAppAdmin() public {
        address newAppManagerAddress = address(0x7775);
        vm.startPrank(USER1);
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        applicationNFT.proposeAppManagerAddress(newAppManagerAddress); 
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("NoProposalHasBeenMade()"));
        applicationNFT.confirmAppManagerAddress();
    }

    // Proposed AppManagerAddress can not be set to zero address
    function invariant_ERC721_external_ProposeAppManager_ZeroAddress() public {
        address newAppManagerAddress = address(0x0);
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("ZeroAddress()"));
        applicationNFT.proposeAppManagerAddress(newAppManagerAddress); 
    }

    // Any type of address may confirm the proposed AppManager as long as it is the proposed AppManager.
     function invariant_ERC721_external_ProposeAppManager_ConfirmAppManager_AnyContract() public {
        switchToSuperAdmin();
        DummyAcceptor _testAppManager = new DummyAcceptor();
        switchToAppAdministrator();
        applicationNFT.proposeAppManagerAddress(address(_testAppManager)); 
        _testAppManager.acceptAppManagerProposal(address(applicationNFT)); 
    }
    // Only the proposed AppManager may confirm the AppManagerAddress
    function invariant_ERC721_external_ProposeAppManager_ConfirmAppManager_OnlyAppManager() public {
        switchToAppAdministrator();
        ApplicationAppManager newAppManagerAddress = new ApplicationAppManager(superAdmin, "Frankenvania", false);
        applicationNFT.proposeAppManagerAddress(address(newAppManagerAddress)); 
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = newAppManagerAddress.confirmAppManager.selector;
        targetSelector(FuzzSelector({addr: address(newAppManagerAddress), selectors: selectors}));
        vm.stopPrank();
        vm.startPrank(USER2);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", Strings.toHexString(address(USER2)), " is missing role 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60"));
        newAppManagerAddress.confirmAppManager(address(applicationNFT)); 
    }

    // When AppManagerAddress is confirmed, AppManagerAddressSet event is always emitted
    function invariant_ERC721_external_ProposeAppManager_ConfirmAppManager_EventEmission() public {
        switchToSuperAdmin();
        ApplicationAppManager newAppManagerAddress = new ApplicationAppManager(superAdmin, "Frankenvania", false);
        newAppManagerAddress.addAppAdministrator(appAdministrator);
        switchToAppAdministrator();
        applicationNFT.proposeAppManagerAddress(address(newAppManagerAddress)); 
        vm.expectEmit(true, false, false, false);
        emit AD1467_AppManagerAddressSet(address(newAppManagerAddress));
        newAppManagerAddress.confirmAppManager(address(applicationNFT)); 
    }

}