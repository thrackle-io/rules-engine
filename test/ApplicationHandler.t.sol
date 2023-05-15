// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/application/ApplicationHandler.sol";
import "../src/application/AppManager.sol";
import "./DiamondTestUtil.sol";

contract ApplicationHandlerTest is Test, DiamondTestUtil {
    ApplicationHandler public applicationHandler;
    AppManager appManager;

    string tokenId = "FEUD";

    function setUp() public {
        vm.startPrank(defaultAdmin);
        appManager = new AppManager(defaultAdmin, "Castlevania", false);
        applicationRuleProcessorDiamond = getApplicationProcessorDiamond();
        applicationHandler = appManager.applicationHandler();
        applicationHandler.setApplicationRuleProcessorDiamondAddress(address(applicationRuleProcessorDiamond));
        // for simplicity, set up default as all admins. This is fine because this role logic is
        // test thoroughly in AppManager.t.sol
        appManager.addAppAdministrator(defaultAdmin);
        appManager.addAccessTier(defaultAdmin);
        appManager.addRiskAdmin(defaultAdmin);
    }

    // Test setting the access diamond address
    function testSetapplicationRuleProcessorDiamondAddress() public {
        applicationHandler.setApplicationRuleProcessorDiamondAddress(address(99));
        assertEq(applicationHandler.getApplicationRuleProcessorDiamondAddress(), address(99));
    }

    // Test failed setting the access diamond address
    function testFailSetapplicationRuleProcessorDiamondAddress() public {
        vm.stopPrank();
        vm.startPrank(address(88)); //set up as the default admin
        applicationHandler.setApplicationRuleProcessorDiamondAddress(address(99));
        assertEq(applicationHandler.getApplicationRuleProcessorDiamondAddress(), address(99));
    }

    /// Test the checkAction. This tests all application compliance
    function testCheckActionApplicationHandler() public {
        applicationHandler.setApplicationRuleProcessorDiamondAddress(address(applicationRuleProcessorDiamond));
        // check if standard user can inquire
        //assertTrue(applicationHandler.checkAction(ApplicationRuleProcessorDiamondLib.ActionTypes.INQUIRE, address(appManager), user));
        //appManager.checkApplicationRules(_action, _from, _to, balanceValuation, transferValuation);
        appManager.checkApplicationRules(ApplicationRuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);
    }

    ///-----------------------PAUSE ACTIONS-----------------------------///
    /// Test the checkAction. This tests all AccessLevel application compliance
    function testCheckActionForPause() public {
        applicationHandler.setApplicationRuleProcessorDiamondAddress(address(applicationRuleProcessorDiamond));
        // check if users can use system when not paused
        appManager.checkApplicationRules(ApplicationRuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can not use system when paused
        appManager.addPauseRule(1769924800, 1769984800);
        vm.warp(1769924800); // set block.timestamp
        vm.expectRevert();
        appManager.checkApplicationRules(ApplicationRuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system after the pause rule expires
        vm.warp(1769984801); // set block.timestamp
        appManager.checkApplicationRules(ApplicationRuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system when in pause block but the pause has been deleted
        appManager.removePauseRule(1769924800, 1769984800);
        PauseRule[] memory removeTest = appManager.getPauseRules();
        assertTrue(removeTest.length == 0);
        vm.warp(1769924800); // set block.timestamp
        appManager.checkApplicationRules(ApplicationRuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);
    }
}
