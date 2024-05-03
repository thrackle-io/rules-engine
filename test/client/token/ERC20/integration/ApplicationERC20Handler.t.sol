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
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address[] targetAccounts;
    int24[] feePercentages;

    function setUp() public {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndHandlerSpecialOwner();
    }

    function testERC20_ApplicationERC20Handler_FeeCreationAndSetting_ReplaceFee() public endWithStopPrank {
        _feeCreationAndSettingSetup();
        switchToRuleAdmin();
        // test replacing a fee
        bytes32 tag1 = "cheap";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = -400;
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeSink);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeSink, feeSink);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
    }

    function testERC20_ApplicationERC20Handler_FeeCreationAndSetting_AdditionalFee() public endWithStopPrank {
        _feeCreationAndSettingSetup();
        switchToRuleAdmin();
        // create a second fee
        bytes32 tag1 = "expensive";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeSink);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeSink, feeSink);
        assertEq(2, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
    }

    function testERC20_ApplicationERC20Handler_FeeCreationAndSetting_RemoveFee() public endWithStopPrank {
        _feeCreationAndSettingSetup();
        switchToRuleAdmin();
        // remove a fee
        bytes32 tag1 = "expensive";
        Fees(address(applicationCoinHandlerSpecialOwner)).removeFee(tag1);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertFalse(fee.feePercentage > 0);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
    }

    function testERC20_ApplicationERC20Handler_FeeCreationAndSetting_Validations() public endWithStopPrank {
        _feeCreationAndSettingSetup();
        switchToRuleAdmin();
        // test the validations
        bytes32 tag1 = "error";
        maxBalance = 10 * 10 ** 18;
        minBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        vm.expectRevert(0xeeb9d4f7);
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeSink);
        tag1 = "error";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 10001;
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeSink);
    }

    function testERC20_ApplicationERC20Handler_GetApplicableFees_AdditionalFee() public endWithStopPrank {
        _getApplicableFeesSetup();
        switchToAppAdministrator();
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
    }

    function testERC20_ApplicationERC20Handler_GetApplicableFees_Discount() public endWithStopPrank {
        _getApplicableFeesSetup();
        switchToAppAdministrator();
        // do discounts(they should get evenly distributed across all fees)
        applicationAppManager.addTag(user1, "discount"); ///add tag
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee("discount", minBalance, maxBalance, -100, address(0));
        switchToAppAdministrator();
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 200);
        assertEq(targetAccounts[1], address(0));
        assertEq(feePercentages[1], 0);
    }

    function testERC20_ApplicationERC20Handler_GetApplicableFees_PositiveDiscount() public endWithStopPrank {
        _getApplicableFeesSetup();
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "discount"); ///add tag
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee("discount", minBalance, maxBalance, -100, address(0));
        // do discount only(This should return nothing as there is no such thing as a positive discount)
        switchToAppAdministrator();
        applicationAppManager.removeTag(user1, "cheap"); ///remove the previous tag
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
        // check when the balance negates the fee
        applicationAppManager.addTag(user1, "cheap2"); ///add tag
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee("cheap2", 300 * 10 ** 18, maxBalance, 200, appAdministrator);
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
    }

    /// Test risk score max size of 99 when adding risk rules
    function testERC20_ApplicationERC20Handler_AccountMaxTransactionValueByRiskScore() public endWithStopPrank {
        switchToRuleAdmin();
        ///Activate rule
        uint32 ruleId = createAccountMaxTxValueByRiskRule(createUint8Array(25, 50, 75), createUint48Array(1000000, 10000, 10));
        setAccountMaxTxValueByRiskRule(ruleId);
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(0);
        assertEq(rule.maxValue[0], 1000000);
    }

    /// Test risk score max size of 100 when adding risk rules
    function testERC20_ApplicationERC20Handler_AccountMaxTransactionValueByRiskScore_Negative() public endWithStopPrank {
        switchToRuleAdmin();
        ///add txnLimit failing (risk score 100)
        uint48[] memory maxValue = createUint48Array(1000000, 10000, 10);
        uint8[] memory riskScore = createUint8Array(25, 75, 100);
        vm.expectRevert(0xfe5d1090);
        AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), maxValue, riskScore, 0, uint64(block.timestamp));
    }

    function testERC20_ApplicationERC20Handler_AccountMinMaxTokenBalanceTaggedCheckPasses() public endWithStopPrank {
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "BALLER");
        applicationAppManager.addTag(user2, "BALLER");
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
        // execute a passing check for the maximum
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(1000, 800, user1, user2, user1, 500);
    }

    /// Test Account Approve Deny Oracle Rule
    function testERC20_ApplicationERC20Handler_AccountDenyOracleERC20Handler_Positive() public endWithStopPrank {
        _accountDenyOracleERC20HandlerSetup();
        // test that the oracle works
        // This one should pass
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, user2, user1, 10);
    }

    function testERC20_ApplicationERC20Handler_AccountDenyOracleERC20Handler_Negative() public endWithStopPrank {
        _accountDenyOracleERC20HandlerSetup();
        vm.startPrank(address(applicationCoin));
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(69), user1, 10);
    }

    function testERC20_ApplicationERC20Handler_AccountApproveOracleERC20Handler_Positive() public endWithStopPrank {
        _accountApproveOracleERC20HandlerSetup();
        vm.startPrank(address(applicationCoin));
        // This one should pass
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(59), user1, 10);
    }

    function testERC20_ApplicationERC20Handler_AccountApproveOracleERC20Handler_Negative() public endWithStopPrank {
        _accountApproveOracleERC20HandlerSetup();
        vm.startPrank(address(applicationCoin));
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).checkAllRules(20, 0, user1, address(88), user1, 10);
    }

    function testERC20_ApplicationERC20Handler_AccountApproveDenyOracleERC20Handler_Invalid() public endWithStopPrank {
        // Finally, check the invalid type
        switchToRuleAdmin();
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    function testERC20_ApplicationERC20Handler_UpgradeApplicationERC20Handler() public endWithStopPrank {
        /// put data in the old rule handler
        /// Fees
        bytes32 tag1 = "cheap";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 300;
        feeSink = appAdministrator;
        // create one fee
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeSink);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
    }

    function testERC20_ApplicationERC20Handler_ZeroAddressErrors() public {
        /// test both address checks in constructor
        HandlerDiamond handler = _createERC20HandlerDiamond();
        vm.expectRevert(0xd92e233d);
        ERC20HandlerMainFacet(address(handler)).initialize(address(0x0), address(applicationAppManager), appAdministrator);
        vm.expectRevert(0xd92e233d);
        ERC20HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(0x0), appAdministrator);
        vm.expectRevert(0xd92e233d);
        ERC20HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(applicationAppManager), address(0x0));
    }

    /// Utility Helper Functions
    function _feeCreationAndSettingSetup() public endWithStopPrank {
        bytes32 tag1 = "cheap";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 300;
        feeSink = appAdministrator;
        // create one fee
        switchToRuleAdmin();
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, feeSink);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
    }

    function _getApplicableFeesSetup() public endWithStopPrank {
        switchToRuleAdmin();
        bytes32 tag1 = "cheap";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 300;
        // create one fee
        Fees(address(applicationCoinHandlerSpecialOwner)).addFee(tag1, minBalance, maxBalance, feePercentage, appAdministrator);
        Fee memory fee = Fees(address(applicationCoinHandlerSpecialOwner)).getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, Fees(address(applicationCoinHandlerSpecialOwner)).getFeeTotal());
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user1, "cheap"); ///add tag
        targetAccounts;
        feePercentages;
        (targetAccounts, feePercentages) = Fees(address(applicationCoinHandlerSpecialOwner)).getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 300);
    }

    function _accountDenyOracleERC20HandlerSetup() public endWithStopPrank {
        switchToAppAdministrator();
        // add a denied address
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerSpecialOwner), ruleId);
    }

    function _accountApproveOracleERC20HandlerSetup() public endWithStopPrank {
        switchToAppAdministrator();
        // add an approved address
        goodBoys.push(address(59));
        oracleApproved.addToApprovedList(goodBoys);
        // check the approved list type
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerSpecialOwner), ruleId);
    }
}
