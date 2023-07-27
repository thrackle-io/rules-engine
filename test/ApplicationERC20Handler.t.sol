// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./DiamondTestUtil.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/example/application/ApplicationHandler.sol";
import "../src/application/AppManager.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/ApplicationERC20Handler.sol";

import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "../src/economic/ruleStorage/RuleDataInterfaces.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {RuleDataFacet as Facet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";
import "../src/token/data/Fees.sol";

/**
 * @title Application Coin Handler Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests the ApplicationERC20 Handler. This handler is deployed specifically for its implementation
 *      contains all the rule checks for the particular ERC20.
 * @notice It simulates the input from a token contract
 */
contract ApplicationERC20HandlerTest is Test, DiamondTestUtil, RuleProcessorDiamondTestUtil {
    /// Store the FacetCut struct for each facet that is being deployed.
    /// NOTE: using storage array to easily "push" new FacetCut as we
    /// process the facets.
    AppManager public appManager;
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(1);
    address user2 = address(2);
    address accessTier = address(3);
    address ac;
    address[] badBoys;
    address[] goodBoys;
    uint256 Blocktime = 1675723152;
    RuleProcessorDiamond ruleProcessor;
    ApplicationHandler public applicationHandler;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC20Handler applicationCoinHandler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the rule processor diamonds
        ruleProcessor = getRuleProcessorDiamond();

        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));
        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));

        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        /// add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        /// add the accessTier Admin
        appManager.addAccessTier(accessTier);
        ac = address(appManager);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), ac, false);

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
        /// set the erc20 pricer
        erc20Pricer = new ApplicationERC20Pricing();
        /// connect ERC20 pricer to applicationCoinHandler
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        vm.warp(Blocktime);
    }

    ///Test Fee Data setting/getting
    function testFeeCreationAndSetting() public {
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address feeCollectorAccount = appAdministrator;
        // create one fee
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        Fees.Fee memory fee = applicationCoinHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());
        // test replacing a fee
        tag1 = "cheap";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = -400;
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        fee = applicationCoinHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeCollectorAccount, feeCollectorAccount);
        assertEq(1, applicationCoinHandler.getFeeTotal());
        // create a second fee
        tag1 = "expensive";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        fee = applicationCoinHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(fee.feeCollectorAccount, feeCollectorAccount);
        assertEq(2, applicationCoinHandler.getFeeTotal());
        // remove a fee
        tag1 = "expensive";
        applicationCoinHandler.removeFee(tag1);
        fee = applicationCoinHandler.getFee(tag1);
        assertFalse(fee.isValue);
        assertEq(1, applicationCoinHandler.getFeeTotal());

        // test the validations
        tag1 = "error";
        maxBalance = 10 * 10 ** 18;
        minBalance = 1000 * 10 ** 18;
        feePercentage = 9000;
        vm.expectRevert(0xeeb9d4f7);
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        tag1 = "error";
        minBalance = 10 * 10 ** 18;
        maxBalance = 1000 * 10 ** 18;
        feePercentage = 10001;
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
    }

    ///Test getting the fees and discounts that apply and how they apply
    function testGetApplicableFees() public {
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address targetAccount = appAdministrator;
        // create one fee
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, targetAccount);
        Fees.Fee memory fee = applicationCoinHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());
        // now test the fee assessment
        appManager.addGeneralTag(user1, "cheap"); ///add tag
        address[] memory targetAccounts;
        int24[] memory feePercentages;
        (targetAccounts, feePercentages) = applicationCoinHandler.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 300);
        // add another to see if it comes back as well
        appManager.addGeneralTag(user1, "not as cheap"); ///add tag
        applicationCoinHandler.addFee("not as cheap", minBalance, maxBalance, 500, defaultAdmin);
        (targetAccounts, feePercentages) = applicationCoinHandler.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 300);
        assertEq(targetAccounts[1], defaultAdmin);
        assertEq(feePercentages[1], 500);

        // do discounts(they should get evenly distributed across all fees)
        appManager.addGeneralTag(user1, "discount"); ///add tag
        applicationCoinHandler.addFee("discount", minBalance, maxBalance, -100, address(0));
        (targetAccounts, feePercentages) = applicationCoinHandler.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], appAdministrator);
        assertEq(feePercentages[0], 250);
        assertEq(targetAccounts[1], defaultAdmin);
        assertEq(feePercentages[1], 450);
        assertEq(targetAccounts[2], address(0));
        assertEq(feePercentages[2], 0);

        // do discount only(This should return nothing as there is no such thing as a positive discount)
        appManager.removeGeneralTag(user1, "cheap"); ///remove the previous tag
        appManager.removeGeneralTag(user1, "not as cheap"); ///remove the previous tag
        (targetAccounts, feePercentages) = applicationCoinHandler.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
        // check when the balance negates the fee
        appManager.addGeneralTag(user1, "cheap2"); ///add tag
        applicationCoinHandler.addFee("cheap2", 300 * 10 ** 18, maxBalance, 200, targetAccount);
        (targetAccounts, feePercentages) = applicationCoinHandler.getApplicableFees(user1, 100 * 10 ** 18);
        assertEq(targetAccounts[0], address(0));
        assertEq(feePercentages[0], 0);
    }

    ///Test risk score max size of 99 when adding risk rules
    function testRiskScoreRiskLevelMaxSize() public {
        ///add txnLimit passing (less than 100)
        uint48[] memory _maxSize = new uint48[](4);
        uint8[] memory _riskLevel = new uint8[](3);

        _maxSize[0] = 100000000;
        _maxSize[1] = 1000000;
        _maxSize[2] = 10000;
        _maxSize[3] = 10;
        _riskLevel[0] = 25;
        _riskLevel[1] = 50;
        _riskLevel[2] = 75;

        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(appManager), _riskLevel, _maxSize);
        ///Activate rule
        applicationCoinHandler.setTransactionLimitByRiskRuleId(ruleId);

        ///add txnLimit failing (risk level 100)
        uint48[] memory maxSize = new uint48[](4);
        uint8[] memory riskLevel = new uint8[](3);

        maxSize[0] = 100000000;
        maxSize[1] = 1000000;
        maxSize[2] = 10000;
        maxSize[3] = 10;
        riskLevel[0] = 25;
        riskLevel[1] = 75;
        riskLevel[2] = 100;

        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(appManager), riskLevel, maxSize);

        ///add balanceLimit passing (less than 100)
        uint8[] memory _riskScores = new uint8[](5);
        uint48[] memory _balanceLimits = new uint48[](6);
        _riskScores[0] = 0;
        _riskScores[1] = 10;
        _riskScores[2] = 40;
        _riskScores[3] = 80;
        _riskScores[4] = 99;
        _balanceLimits[0] = 1000000;
        _balanceLimits[1] = 100000;
        _balanceLimits[2] = 10000;
        _balanceLimits[3] = 1000;
        _balanceLimits[4] = 100;
        _balanceLimits[5] = 1;

        AppRuleDataFacet(address(ruleStorageDiamond)).addAccountBalanceByRiskScore(address(appManager), _riskScores, _balanceLimits);

        ///add balanceLimit failing (risk level 100)
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory balanceLimits = new uint48[](6);
        riskScores[0] = 0;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 100;
        balanceLimits[0] = 1000000;
        balanceLimits[1] = 100000;
        balanceLimits[2] = 10000;
        balanceLimits[3] = 1000;
        balanceLimits[4] = 100;
        balanceLimits[5] = 1;

        vm.expectRevert();
        AppRuleDataFacet(address(ruleStorageDiamond)).addAccountBalanceByRiskScore(address(appManager), riskScores, balanceLimits);
    }

    /// now disable since it won't work unless an ERC20 is using it
    function testTaggedCheckForMinMaxBalancePasses() public {
        bytes32[] memory _accountTypes = new bytes32[](1);
        uint256[] memory _minimum = new uint256[](1);
        uint256[] memory _maximum = new uint256[](1);

        /// Set the min/max rule data
        appManager.addGeneralTag(user1, "BALLER");
        appManager.addGeneralTag(user2, "BALLER");
        _accountTypes[0] = "BALLER";
        _minimum[0] = 10;
        _maximum[0] = 1000;
        // add the rule.
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, _accountTypes, _minimum, _maximum);
        /// connect the rule to this handler
        applicationCoinHandler.setMinMaxBalanceRuleId(ruleId);
        /// execute a passing check for the minimum
        applicationCoinHandler.checkAllRules(20, 0, user1, user2, 10, ActionTypes.TRADE);
        /// execute a passing check for the maximum
        applicationCoinHandler.checkAllRules(1000, 0, user1, user2, 500, ActionTypes.TRADE);
        // execute a failing check for the minimum
        vm.expectRevert(0xf1737570);
        applicationCoinHandler.checkAllRules(20, 1000, user1, user2, 15, ActionTypes.TRADE);
        // execute a passing check for the maximum
        vm.expectRevert(0x24691f6b);
        applicationCoinHandler.checkAllRules(1000, 800, user1, user2, 500, ActionTypes.TRADE);
    }

    /// now disable since it won't work unless an ERC20 is using it
    function testOracle() public {
        // add the rule.
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blocked address
        badBoys.push(address(69));
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // test that the oracle works
        // This one should pass
        applicationCoinHandler.checkAllRules(20, 0, user1, user2, 10, ActionTypes.TRADE);
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        applicationCoinHandler.checkAllRules(20, 0, user1, address(69), 10, ActionTypes.TRADE);

        // check the allowed list type
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // add an allowed address
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        // This one should pass
        applicationCoinHandler.checkAllRules(20, 0, user1, address(59), 10, ActionTypes.TRADE);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationCoinHandler.checkAllRules(20, 0, user1, address(88), 10, ActionTypes.TRADE);

        // Finally, check the invalid type
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 2, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
    }

    /// now disable since it won't work unless an ERC20 is using it
    function testTurningOnOffRules() public {
        bytes32[] memory _accountTypes = new bytes32[](1);
        uint256[] memory _minimum = new uint256[](1);
        uint256[] memory _maximum = new uint256[](1);

        /// Set the min/max rule data
        appManager.addGeneralTag(user1, "BALLER");
        appManager.addGeneralTag(user2, "BALLER");
        _accountTypes[0] = "BALLER";
        _minimum[0] = 10;
        _maximum[0] = 1000;
        // add the rule.
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, _accountTypes, _minimum, _maximum);
        /// connect the rule to this handler
        applicationCoinHandler.setMinMaxBalanceRuleId(ruleId);
        /// execute a passing check for the minimum
        applicationCoinHandler.checkAllRules(20, 0, user1, user2, 10, ActionTypes.TRADE);
        /// execute a passing check for the maximum
        applicationCoinHandler.checkAllRules(1000, 0, user1, user2, 500, ActionTypes.TRADE);
        // execute a failing check for the minimum
        vm.expectRevert(0xf1737570);
        applicationCoinHandler.checkAllRules(20, 1000, user1, user2, 15, ActionTypes.TRADE);
        // execute a failing check for the maximum
        vm.expectRevert(0x24691f6b);
        applicationCoinHandler.checkAllRules(1000, 800, user1, user2, 500, ActionTypes.TRADE);
        /// turning rules off
        applicationCoinHandler.activateMinMaxBalanceRule(false);
        /// now we can "break" the rules
        applicationCoinHandler.checkAllRules(20, 1000, user1, user2, 15, ActionTypes.TRADE);
        applicationCoinHandler.checkAllRules(1000, 800, user1, user2, 500, ActionTypes.TRADE);
        /// turning rules back on
        applicationCoinHandler.activateMinMaxBalanceRule(true);
        /// now we cannot break the rules again
        vm.expectRevert(0xf1737570);
        applicationCoinHandler.checkAllRules(20, 1000, user1, user2, 15, ActionTypes.TRADE);
        vm.expectRevert(0x24691f6b);
        applicationCoinHandler.checkAllRules(1000, 800, user1, user2, 500, ActionTypes.TRADE);

        // add the rule.
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blocked address
        badBoys.push(address(69));
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // test that the oracle works
        // This one should pass
        applicationCoinHandler.checkAllRules(20, 0, user1, user2, 10, ActionTypes.TRADE);
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        applicationCoinHandler.checkAllRules(20, 0, user1, address(69), 10, ActionTypes.TRADE);

        // check the allowed list type
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // add an allowed address
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        // This one should pass
        applicationCoinHandler.checkAllRules(20, 0, user1, address(59), 10, ActionTypes.TRADE);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationCoinHandler.checkAllRules(20, 0, user1, address(88), 10, ActionTypes.TRADE);

        // Finally, check the invalid type
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 2, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        vm.expectRevert(0x2a15491e);
        applicationCoinHandler.checkAllRules(20, 0, user1, address(69), 10, ActionTypes.TRADE);

        /// let's turn the rule off
        applicationCoinHandler.activateOracleRule(false);
        applicationCoinHandler.checkAllRules(20, 0, user1, address(69), 10, ActionTypes.TRADE);

        /// let's turn it back on
        applicationCoinHandler.activateOracleRule(true);
        vm.expectRevert(0x2a15491e);
        applicationCoinHandler.checkAllRules(20, 0, user1, address(69), 10, ActionTypes.TRADE);
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
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        Fees.Fee memory fee = applicationCoinHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());

        /// create new handler
        ApplicationERC20Handler applicationCoinHandlerNew = new ApplicationERC20Handler(address(ruleProcessor), ac, false);
        /// connect the old data contract to the new handler
        applicationCoinHandler.proposeDataContractMigration(address(applicationCoinHandlerNew));
        applicationCoinHandlerNew.confirmDataContractMigration(address(applicationCoinHandler));

        /// test that the data is accessible only from the new handler
        fee = applicationCoinHandlerNew.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandlerNew.getFeeTotal());

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xba80c9e5);
        applicationCoinHandlerNew.proposeDataContractMigration(address(applicationCoinHandler));

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationCoinHandlerNew.proposeDataContractMigration(address(applicationCoinHandler));
    }
}
