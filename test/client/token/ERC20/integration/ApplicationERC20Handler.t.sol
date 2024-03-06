// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";

/**
 * @title Application Token Handler Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests the ApplicationERC20 Handler. This handler is deployed specifically for its implementation
 *      contains all the rule checks for the particular ERC20.
 * @notice It simulates the input from a token contract
 */
contract ApplicationERC20HandlerTest is TestCommonFoundry, ERC20Util {


    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(superAdmin);
        setUpProcotolAndCreateERC20AndHandlerSpecialOwner();
        switchToAppAdministrator();

    }

    function testFeeCreationAndSetting() public {
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address feeCollectorAccount = appAdministrator;
        // create one fee
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
        // test replacing a fee
        tag1 = "cheap";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = -400;
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeCollectorAccount, feeCollectorAccount);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
        // create a second fee
        tag1 = "expensive";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeCollectorAccount, feeCollectorAccount);
        assertEq(2, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
        // remove a fee
        tag1 = "expensive";
        Fees(address(applicationCoinHandlerSpecialOwner)).removeFee(tag1);
        fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertFalse(fee.feePercentage > 0);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());

        // test the validations
        tag1 = "error";
        maxBalance = 10 * 10 ** 18;
        minBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        vm.expectRevert(0xeeb9d4f7);
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        tag1 = "error";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 10001;
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
    }

    function testGetApplicableFees() public {
        switchToRuleAdmin();
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address targetAccount = appAdministrator;
        // create one fee
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, targetAccount);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user1, "cheap"); ///add tag
        address[] memory targetAccounts;
        int24[] memory feePercentages;
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 300);
        // add another to see if it comes back as well
        applicationAppManager.addTag(user1, "not as cheap"); ///add tag
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee("not as cheap", minBalance, maxBalance, 500, appAdministrator);
        switchToAppAdministrator();
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 300);
        assertEq(targetAccounts[1], appAdministrator);
        assertEq(feePercentages[1], 500);

        // do discounts(they should get evenly distributed across all fees)
        applicationAppManager.addTag(user1, "discount"); ///add tag
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee("discount", minBalance, maxBalance, -100, address(0));
        switchToAppAdministrator();
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 250);
        assertEq(targetAccounts[1], appAdministrator);
        assertEq(feePercentages[1], 450);
        assertEq(targetAccounts[2], address(0));
        assertEq(feePercentages[2], 0);

        // do discount only(This should return nothing as there is no such thing as a positive discount)
        applicationAppManager.removeTag(user1, "cheap"); ///remove the previous tag
        applicationAppManager.removeTag(user1, "not as cheap"); ///remove the previous tag
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
        // check when the balance negates the fee
        applicationAppManager.addTag(user1, "cheap2"); ///add tag
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee("cheap2", 300 * 10 ** 18, maxBalance, 200, targetAccount);
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
    }

    /// Test risk score max size of 99 when adding risk rules
    function testAccountMaxTransactionValueByRiskScore() public { 
        switchToRuleAdmin();
        ///Activate rule
        uint32 ruleId = createAccountMaxTxValueByRiskRule(createUint8Array(25, 50, 75), createUint48Array(1000000, 10000, 10));
        setAccountMaxTxValueByRiskRule(ruleId); 
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(0); 
        assertEq(rule.maxValue[0], 1000000);
    }

    /// Test risk score max size of 100 when adding risk rules
    function testAccountMaxTransactionValueByRiskScoreNegative() public { 
        switchToRuleAdmin();
        ///add txnLimit failing (risk score 100)
        uint48[] memory maxValue = createUint48Array(1000000, 10000, 10);
        uint8[] memory riskScore = createUint8Array(25, 75, 100);
        vm.expectRevert();
        AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), maxValue, riskScore, 0, uint64(block.timestamp));
    }

    function testAccountMinMaxTokenBalanceTaggedCheckPasses() public {
        applicationAppManager.addTag(user1, "BALLER");
        applicationAppManager.addTag(user2, "BALLER");
        switchToRuleAdmin();
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("BALLER"), createUint256Array(10), createUint256Array(1000));
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandlerSpecialOwner), ruleId);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        /// execute a passing check for the minimum
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, user2, user1, 10);
        /// execute a passing check for the maximum
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 0, user1, user2, user1, 500);
        // execute a failing check for the minimum
        vm.expectRevert(0x3e237976);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 1000, user1, user2, user1, 15);
        // execute a passing check for the maximum
        vm.expectRevert(0x1da56a44);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 800, user1, user2, user1, 500);
    }

    /// Test Account Approve Deny Oracle Rule 
    function testAccountApproveDenyOracleERC20Handler() public {
        switchToAppAdministrator();
        // add a denied address
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerSpecialOwner), ruleId);

        switchToAppAdministrator();
        // test that the oracle works
        // This one should pass
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, user2, user1, 10);
        // This one should fail
        vm.expectRevert(0x2767bda4);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(69), user1, 10);

        // check the approved list type
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerSpecialOwner), ruleId);
        switchToAppAdministrator();
        // add an approved address
        goodBoys.push(address(59));
        oracleApproved.addToApprovedList(goodBoys);

        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        // This one should pass
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(59), user1, 10);
        // This one should fail
        vm.expectRevert(0xcafd3316);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);

        // Finally, check the invalid type
        switchToRuleAdmin();
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    function testTurningOnOffRules() public {
        /// Set the min/max rule data
        applicationAppManager.addTag(user1, "BALLER");
        applicationAppManager.addTag(user2, "BALLER");
        // add the rule.
        switchToRuleAdmin();
       uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("BALLER"), createUint256Array(10), createUint256Array(1000));
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandlerSpecialOwner), ruleId);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        /// execute a passing check for the minimum
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, user2, user1, 10);
        /// execute a passing check for the maximum
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 0, user1, user2, user1, 500);
        // execute a failing check for the minimum
        vm.expectRevert(0x3e237976);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 1000, user1, user2, user1, 15);
        // execute a failing check for the maximum
        vm.expectRevert(0x1da56a44);
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
        vm.expectRevert(0x3e237976);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 1000, user1, user2, user1, 15);
        vm.expectRevert(0x1da56a44);
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
        vm.expectRevert(0x2767bda4);
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
        vm.expectRevert(0xcafd3316);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);

        // let's turn the allowed list rule off
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).activateAccountApproveDenyOracle(_createActionsArray(), false, _indexTwo);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);

        // let's verify that the denied list rule is still active
        vm.expectRevert(0x2767bda4);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(68), user1, 10);

        // let's turn it back on
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).activateAccountApproveDenyOracle(_createActionsArray(), true, _indexTwo);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        vm.expectRevert(0xcafd3316);
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);

        // Remove the denied list rule and verify it no longer fails.
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandlerSpecialOwner)).removeAccountApproveDenyOracle(_createActionsArray(), _index);
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(68), user1, 10);
    }

    function testUpgradeApplicationERC20Handler() public {
        /// put data in the old rule handler
        /// Fees
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address feeCollectorAccount = appAdministrator;
        // create one fee
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
        switchToAppAdministrator();
       }

    function testZeroAddressErrors() public {
        /// test both address checks in constructor
        HandlerDiamond handler = _createERC20HandlerDiamond();
        vm.expectRevert();
        ERC20HandlerMainFacet(address(handler)).initialize(address(0x0), address(applicationAppManager), appAdministrator);
        vm.expectRevert();
        ERC20HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(0x0), appAdministrator);
        vm.expectRevert();
        ERC20HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(applicationAppManager), address(0x0));
    }

}
