// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/example/application/ApplicationHandler.sol";
import "../src/application/AppManager.sol";
import "./DiamondTestUtil.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/economic/TokenRuleRouter.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import {TaggedRuleProcessorDiamondTestUtil} from "./TaggedRuleProcessorDiamondTestUtil.sol";

contract ApplicationHandlerTest is TaggedRuleProcessorDiamondTestUtil, DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationHandler public applicationHandler;
    AppManager appManager;
    TokenRuleRouter tokenRuleRouter;
    TokenRuleRouterProxy ruleRouterProxy;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    RuleProcessorDiamond tokenRuleProcessorsDiamond;
    RuleStorageDiamond ruleStorageDiamond;

    string tokenId = "FEUD";

    function setUp() public {
        vm.startPrank(defaultAdmin);
        ruleProcessorDiamond = getApplicationProcessorDiamond();
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the token rule processor diamond
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        // Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // Deploy the token rule processor diamond
        taggedRuleProcessorDiamond = getTaggedRuleProcessorDiamond();
        //connect data diamond with Tagged Rule Processor diamond
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        tokenRuleRouter = new TokenRuleRouter();
        /// connect the TokenRuleRouter to its child Diamond
        ruleRouterProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        TokenRuleRouter(address(ruleRouterProxy)).initialize(payable(address(tokenRuleProcessorsDiamond)), payable(address(taggedRuleProcessorDiamond)));

        appManager = new AppManager(defaultAdmin, "Castlevania", address(ruleRouterProxy), false);

        // for simplicity, set up default as all admins. This is fine because this role logic is
        // test thoroughly in AppManager.t.sol
        appManager.addAppAdministrator(defaultAdmin);
        appManager.addAccessTier(defaultAdmin);
        appManager.addRiskAdmin(defaultAdmin);
        applicationHandler = ApplicationHandler(appManager.getApplicationHandlerAddress());
    }

    /// Test the checkAction. This tests all application compliance
    function testCheckActionApplicationHandler() public {
        // check if standard user can inquire
        //assertTrue(applicationHandler.checkAction(RuleProcessorDiamondLib.ActionTypes.INQUIRE, address(appManager), user));
        //appManager.checkApplicationRules(_action, _from, _to, balanceValuation, transferValuation);
        appManager.checkApplicationRules(RuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);
    }

    ///-----------------------PAUSE ACTIONS-----------------------------///
    /// Test the checkAction. This tests all AccessLevel application compliance
    function testCheckActionForPause() public {
        // check if users can use system when not paused
        appManager.checkApplicationRules(RuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can not use system when paused
        appManager.addPauseRule(1769924800, 1769984800);
        vm.warp(1769924800); // set block.timestamp
        vm.expectRevert();
        appManager.checkApplicationRules(RuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system after the pause rule expires
        vm.warp(1769984801); // set block.timestamp
        appManager.checkApplicationRules(RuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);

        // check if users can use system when in pause block but the pause has been deleted
        appManager.removePauseRule(1769924800, 1769984800);
        PauseRule[] memory removeTest = appManager.getPauseRules();
        assertTrue(removeTest.length == 0);
        vm.warp(1769924800); // set block.timestamp
        appManager.checkApplicationRules(RuleProcessorDiamondLib.ActionTypes.INQUIRE, user, user, 0, 0);
    }
}
