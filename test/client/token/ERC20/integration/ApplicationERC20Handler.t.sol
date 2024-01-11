// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

/**
 * @title Application Coin Handler Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests the ApplicationERC20 Handler. This handler is deployed specifically for its implementation
 *      contains all the rule checks for the particular ERC20.
 * @notice It simulates the input from a token contract
 */
contract ApplicationERC20HandlerTest is TestCommonFoundry {


    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(superAdmin);
        setUpProcotolAndCreateERC20AndHandlerSpecialOwner();
        switchToAppAdministrator();

    }

    ///Test Fee Data setting/getting
    function testFeeCreationAndSetting() public {
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address feeCollectorAccount = appAdministrator;
        // create one fee
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        Fees.Fee memory fee = applicationCoinHandlerSpecialOwner.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandlerSpecialOwner.getFeeTotal());
        // test replacing a fee
        tag1 = "cheap";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = -400;
        applicationCoinHandlerSpecialOwner.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        fee = applicationCoinHandlerSpecialOwner.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeCollectorAccount, feeCollectorAccount);
        assertEq(1, applicationCoinHandlerSpecialOwner.getFeeTotal());
        // create a second fee
        tag1 = "expensive";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        applicationCoinHandlerSpecialOwner.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        fee = applicationCoinHandlerSpecialOwner.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeCollectorAccount, feeCollectorAccount);
        assertEq(2, applicationCoinHandlerSpecialOwner.getFeeTotal());
        // remove a fee
        tag1 = "expensive";
        applicationCoinHandlerSpecialOwner.removeFee(tag1);
        fee = applicationCoinHandlerSpecialOwner.getFee(tag1);
        assertFalse(fee.feePercentage > 0);
        assertEq(1, applicationCoinHandlerSpecialOwner.getFeeTotal());

        // test the validations
        tag1 = "error";
        maxBalance = 10 * 10 ** 18;
        minBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        vm.expectRevert(0xeeb9d4f7);
        applicationCoinHandlerSpecialOwner.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        tag1 = "error";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 10001;
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        applicationCoinHandlerSpecialOwner.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
    }

    ///Test getting the fees and discounts that apply and how they apply
    function testGetApplicableFees() public {
        switchToRuleAdmin();
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address targetAccount = appAdministrator;
        // create one fee
        applicationCoinHandlerSpecialOwner.addFee(tag1, minBalance, maxBalance, feePercentage, targetAccount);
        Fees.Fee memory fee = applicationCoinHandlerSpecialOwner.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandlerSpecialOwner.getFeeTotal());
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addGeneralTag(user1, "cheap"); ///add tag
        address[] memory targetAccounts;
        int24[] memory feePercentages;
        (targetAccounts, feePercentages) = applicationCoinHandlerSpecialOwner.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 300);
        // add another to see if it comes back as well
        applicationAppManager.addGeneralTag(user1, "not as cheap"); ///add tag
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.addFee("not as cheap", minBalance, maxBalance, 500, appAdministrator);
        switchToAppAdministrator();
        (targetAccounts, feePercentages) = applicationCoinHandlerSpecialOwner.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 300);
        assertEq(targetAccounts[1], appAdministrator);
        assertEq(feePercentages[1], 500);

        // do discounts(they should get evenly distributed across all fees)
        applicationAppManager.addGeneralTag(user1, "discount"); ///add tag
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.addFee("discount", minBalance, maxBalance, -100, address(0));
        switchToAppAdministrator();
        (targetAccounts, feePercentages) = applicationCoinHandlerSpecialOwner.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 250);
        assertEq(targetAccounts[1], appAdministrator);
        assertEq(feePercentages[1], 450);
        assertEq(targetAccounts[2], address(0));
        assertEq(feePercentages[2], 0);

        // do discount only(This should return nothing as there is no such thing as a positive discount)
        applicationAppManager.removeGeneralTag(user1, "cheap"); ///remove the previous tag
        applicationAppManager.removeGeneralTag(user1, "not as cheap"); ///remove the previous tag
        (targetAccounts, feePercentages) = applicationCoinHandlerSpecialOwner.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
        // check when the balance negates the fee
        applicationAppManager.addGeneralTag(user1, "cheap2"); ///add tag
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.addFee("cheap2", 300 * 10 ** 18, maxBalance, 200, targetAccount);
        (targetAccounts, feePercentages) = applicationCoinHandlerSpecialOwner.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
    }

    ///Test risk score max size of 99 when adding risk rules
    function testRiskScoreRiskLevelMaxSize() public {
        uint48[] memory _maxSize = createUint48Array(1000000, 10000, 10); 
        uint8[] memory _riskLevel = createUint8Array(25, 50, 75);
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addTransactionLimitByRiskScore(address(applicationAppManager), _riskLevel, _maxSize);
        ///Activate rule
        applicationHandler.setTransactionLimitByRiskRuleId(ruleId);
        ///add txnLimit failing (risk level 100)
        uint48[] memory maxSize = createUint48Array(1000000, 10000, 10);
        uint8[] memory riskLevel = createUint8Array(25, 75, 100);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addTransactionLimitByRiskScore(address(applicationAppManager), riskLevel, maxSize);

        ///add balanceLimit passing (less than 100)
        uint8[] memory _riskScores = createUint8Array(25, 50, 75);
        uint48[] memory _balanceLimits = createUint48Array(1000000, 10000, 10);
        AppRuleDataFacet(address(ruleProcessor)).addAccountBalanceByRiskScore(address(applicationAppManager), _riskScores, _balanceLimits);

        ///add balanceLimit failing (risk level 100)
        uint8[] memory riskScores = createUint8Array(25, 50, 100);
        uint48[] memory balanceLimits = createUint48Array(1000000, 10000, 10);
        vm.expectRevert();
        AppRuleDataFacet(address(ruleProcessor)).addAccountBalanceByRiskScore(address(applicationAppManager), riskScores, balanceLimits);
    }

    /// now disable since it won't work unless an ERC20 is using it
    function testTaggedCheckForMinMaxBalancePasses() public {
        bytes32[] memory _accountTypes = createBytes32Array("BALLER");
        uint256[] memory _minimum = createUint256Array(10);
        uint256[] memory _maximum = createUint256Array(1000);

        /// Set the min/max rule data
        applicationAppManager.addGeneralTag(user1, "BALLER");
        applicationAppManager.addGeneralTag(user2, "BALLER");
        // add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), _accountTypes, _minimum, _maximum);
        /// connect the rule to this handler
        applicationCoinHandlerSpecialOwner.setMinMaxBalanceRuleId(ruleId);
        switchToAppAdministrator();
        /// execute a passing check for the minimum
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, user2, msg.sender, 10);
        /// execute a passing check for the maximum
        applicationCoinHandlerSpecialOwner.checkAllRules(1000, 0, user1, user2, msg.sender, 500);
        // execute a failing check for the minimum
        vm.expectRevert(0xf1737570);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 1000, user1, user2, msg.sender, 15);
        // execute a passing check for the maximum
        vm.expectRevert(0x24691f6b);
        applicationCoinHandlerSpecialOwner.checkAllRules(1000, 800, user1, user2, msg.sender, 500);
    }

    /// now disable since it won't work unless an ERC20 is using it
    function testOracleERC20Handler() public {
        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        switchToAppAdministrator();
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        // add a blocked address
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.setOracleRuleId(_index);
        switchToAppAdministrator();
        // test that the oracle works
        // This one should pass
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, user2, msg.sender, 10);
        // This one should fail
        vm.expectRevert(0x2767bda4);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(69), msg.sender, 10);

        // check the allowed list type
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandlerSpecialOwner.setOracleRuleId(_index);
        switchToAppAdministrator();
        // add an allowed address
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        // This one should pass
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(59), msg.sender, 10);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(88), msg.sender, 10);

        // Finally, check the invalid type
        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 2, address(oracleAllowed));
    }

    /// now disable since it won't work unless an ERC20 is using it
    function testTurningOnOffRules() public {
        bytes32[] memory _accountTypes = createBytes32Array("BALLER");
        uint256[] memory _minimum = createUint256Array(10);
        uint256[] memory _maximum = createUint256Array(1000);

        /// Set the min/max rule data
        applicationAppManager.addGeneralTag(user1, "BALLER");
        applicationAppManager.addGeneralTag(user2, "BALLER");
        // add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), _accountTypes, _minimum, _maximum);
        /// connect the rule to this handler
        applicationCoinHandlerSpecialOwner.setMinMaxBalanceRuleId(ruleId);
        switchToAppAdministrator();
        /// execute a passing check for the minimum
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, user2, msg.sender, 10);
        /// execute a passing check for the maximum
        applicationCoinHandlerSpecialOwner.checkAllRules(1000, 0, user1, user2, msg.sender, 500);
        // execute a failing check for the minimum
        vm.expectRevert(0xf1737570);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 1000, user1, user2, msg.sender, 15);
        // execute a failing check for the maximum
        vm.expectRevert(0x24691f6b);
        applicationCoinHandlerSpecialOwner.checkAllRules(1000, 800, user1, user2, msg.sender, 500);
        /// turning rules off
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.activateMinMaxBalanceRule(false);
        switchToAppAdministrator();
        /// now we can "break" the rules
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 1000, user1, user2, msg.sender, 15);
        applicationCoinHandlerSpecialOwner.checkAllRules(1000, 800, user1, user2, msg.sender, 500);
        /// turning rules back on
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.activateMinMaxBalanceRule(true);
        switchToAppAdministrator();
        /// now we cannot break the rules again
        vm.expectRevert(0xf1737570);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 1000, user1, user2, msg.sender, 15);
        vm.expectRevert(0x24691f6b);
        applicationCoinHandlerSpecialOwner.checkAllRules(1000, 800, user1, user2, msg.sender, 500);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        // add a blocked address
        switchToAppAdministrator();
        badBoys.push(address(68));
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.setOracleRuleId(_index);
        switchToAppAdministrator();
        // test that the oracle works
        // This one should pass
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, user2, msg.sender, 10);
        // This one should fail
        vm.expectRevert(0x2767bda4);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(68), msg.sender, 10);


        // check the allowed list type
        switchToRuleAdmin();
        uint32 _indexTwo = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandlerSpecialOwner.setOracleRuleId(_indexTwo);

        NonTaggedRules.OracleRule memory ruleCheck = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(ruleCheck.oracleType, 0);
        assertEq(ruleCheck.oracleAddress, address(oracleDenied));

        NonTaggedRules.OracleRule memory ruleCheckTwo = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_indexTwo);
        assertEq(ruleCheckTwo.oracleType, 1);
        assertEq(ruleCheckTwo.oracleAddress, address(oracleAllowed));

        switchToAppAdministrator();
        // add an allowed address
        goodBoys.push(address(59));
        goodBoys.push(address(68));
        oracleAllowed.addToAllowList(goodBoys);
        // This one should pass
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(59), msg.sender, 10);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(88), msg.sender, 10);

        // let's turn the allowed list rule off
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.activateOracleRule(false, _indexTwo);
        switchToAppAdministrator();
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(88), msg.sender, 10);

        // let's verify that the denied list rule is still active
        vm.expectRevert(0x2767bda4);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(68), msg.sender, 10);

        // let's turn it back on
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.activateOracleRule(true, _indexTwo);
        switchToAppAdministrator();
        vm.expectRevert(0x7304e213);
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(88), msg.sender, 10);

        // Remove the denied list rule and verify it no longer fails.
        switchToRuleAdmin();
        applicationCoinHandlerSpecialOwner.removeOracleRule(_index);
        switchToAppAdministrator();
        applicationCoinHandlerSpecialOwner.checkAllRules(20, 0, user1, address(68), msg.sender, 10);
    }

    ///---------------UPGRADEABILITY---------------
    /**
     * @dev This function ensures that a coin rule handler can be upgraded without losing its data
     */
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
        applicationCoinHandlerSpecialOwner.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        Fees.Fee memory fee = applicationCoinHandlerSpecialOwner.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandlerSpecialOwner.getFeeTotal());
        switchToAppAdministrator();
        /// create new handler
        ApplicationERC20Handler applicationCoinHandlerSpecialOwnerNew = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(this), false);
        /// connect the old data contract to the new handler
        applicationCoinHandlerSpecialOwner.proposeDataContractMigration(address(applicationCoinHandlerSpecialOwnerNew));
        applicationCoinHandlerSpecialOwnerNew.confirmDataContractMigration(address(applicationCoinHandlerSpecialOwner));

        /// test that the data is accessible only from the new handler
        fee = applicationCoinHandlerSpecialOwnerNew.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandlerSpecialOwnerNew.getFeeTotal());

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xba80c9e5);
        applicationCoinHandlerSpecialOwnerNew.proposeDataContractMigration(address(applicationCoinHandlerSpecialOwner));

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationCoinHandlerSpecialOwnerNew.proposeDataContractMigration(address(applicationCoinHandlerSpecialOwner));
    }

    function testZeroAddressErrors() public {
        /// test both address checks in constructor
        vm.expectRevert();
        new ApplicationERC20Handler(address(0x0), address(applicationAppManager), appAdministrator, false);
        vm.expectRevert();
        new ApplicationERC20Handler(address(ruleProcessor), address(0x0), appAdministrator, false);

    }
}
