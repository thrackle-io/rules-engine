// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";

/**
 * @title Application Token Handler Complex Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract contains a multi-step test for the ApplicationERC20Handler rule interactions
 * @notice It simulates the input from a token contract
 */
contract ApplicationERC20HandlerComplexTest is TestCommonFoundry, ERC20Util {

    function setUp() public {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndHandlerSpecialOwner();
    }

    function testERC20_ApplicationERC20Handler_TurningOnOffRules() public endWithStopPrank {
        switchToAppAdministrator();
        /// Set the min/max rule data
        applicationAppManager.addTag(user1, "BALLER");
        applicationAppManager.addTag(user2, "BALLER");
        // add the rule.
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("BALLER"), createUint256Array(10), createUint256Array(1000));
        switchToRuleAdmin();
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandlerSpecialOwner), ruleId);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        /// execute a passing check for the minimum
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, user2, user1, 10);
        /// execute a passing check for the maximum
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 0, user1, user2, user1, 500);
        // execute a failing check for the minimum
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 1000, user1, user2, user1, 15);
        // execute a failing check for the maximum
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 800, user1, user2, user1, 500);
        /// turning rules off
        switchToRuleAdmin();
        ERC20TaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).activateAccountMinMaxTokenBalance(_createActionsArray(), false);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        /// now we can "break" the rules
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 1000, user1, user2, user1, 15);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 800, user1, user2, user1, 500);
        /// turning rules back on
        switchToRuleAdmin();
        ERC20TaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).activateAccountMinMaxTokenBalance(_createActionsArray(), true);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        /// now we cannot break the rules again
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 1000, user1, user2, user1, 15);
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 800, user1, user2, user1, 500);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerSpecialOwner), _index);
        assertEq(_index, 0);
        NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        // add a blocked address
        switchToAppAdministrator();
        badBoys.push(address(68));
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        // test that the oracle works
        // This one should pass
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, user2, user1, 10);
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(68), user1, 10);

        // check the allowed list type
        switchToRuleAdmin();
        uint32 _indexTwo = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerSpecialOwner), _indexTwo);
        NonTaggedRules.AccountApproveDenyOracle memory ruleCheck = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
        assertEq(ruleCheck.oracleType, 0);
        assertEq(ruleCheck.oracleAddress, address(oracleDenied));

        NonTaggedRules.AccountApproveDenyOracle memory ruleCheckTwo = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_indexTwo);
        assertEq(ruleCheckTwo.oracleType, 1);
        assertEq(ruleCheckTwo.oracleAddress, address(oracleApproved));

        switchToAppAdministrator();
        // add an allowed address
        goodBoys.push(address(59));
        goodBoys.push(address(68));
        oracleApproved.addToApprovedList(goodBoys);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        // This one should pass
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(59), user1, 10);
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);

        // let's turn the allowed list rule off
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).activateAccountApproveDenyOracle(_createActionsArray(), false, _indexTwo);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);

        // let's verify that the denied list rule is still active
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(68), user1, 10);

        // let's turn it back on
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).activateAccountApproveDenyOracle(_createActionsArray(), true, _indexTwo);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);

        // Remove the denied list rule and verify it no longer fails.
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).removeAccountApproveDenyOracle(_createActionsArray(), _index);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(68), user1, 10);
    }
}