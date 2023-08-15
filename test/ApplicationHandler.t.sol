// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/example/application/ApplicationHandler.sol";
import "../src/application/AppManager.sol";
import "./DiamondTestUtil.sol";
import "test/helpers/TestCommon.sol";

contract ApplicationHandlerTest is TestCommon {
    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler));
    }

    /// Test the checkAction. This tests all application compliance
    function testCheckActionApplicationHandler() public {
        // check if standard user can inquire
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);
    }

    ///-----------------------PAUSE ACTIONS-----------------------------///
    /// Test the checkAction. This tests all AccessLevel application compliance
    function testCheckActionForPause() public {
        // check if users can use system when not paused
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can not use system when paused
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(1769924800, 1769984800);
        vm.warp(1769924800); // set block.timestamp
        vm.expectRevert();
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system after the pause rule expires
        vm.warp(1769984801); // set block.timestamp
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system when in pause block but the pause has been deleted
        applicationAppManager.removePauseRule(1769924800, 1769984800);
        PauseRule[] memory removeTest = applicationAppManager.getPauseRules();
        assertTrue(removeTest.length == 0);
        vm.warp(1769924800); // set block.timestamp
        applicationAppManager.checkApplicationRules(ActionTypes.INQUIRE, user, user, 0, 0);
    }
}
