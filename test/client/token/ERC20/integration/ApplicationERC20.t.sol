// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";
import "test/client/token/ERC20/integration/ERC20CommonTests.t.sol";

contract ApplicationERC20Test is ERC20CommonTests {
    address targetAccount;
    address targetAccount2;
    uint256 minBalance;
    uint256 maxBalance;

    function setUp() public endWithStopPrank {
        setUpProcotolAndCreateERC20AndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * ATTO);
        testCaseToken = applicationCoin;
        vm.warp(Blocktime);
    }

    function testERC20_ApplicationERC20_TokenMaxSupplyVolatility_Negative() public endWithStopPrank {
        _tokenMaxSupplyVolatilitySetup();
        vm.startPrank(user1);
        /// fail transactions (mint and burn with passing transfers)
        vm.expectRevert(0xc406d470);
        applicationCoin.mint(user1, 6500 * ATTO);
    }

    function testERC20_ApplicationERC20_TokenMaxSupplyVolatility_Period() public endWithStopPrank {
        _tokenMaxSupplyVolatilitySetup();
        vm.startPrank(user1);
        /// move out of rule period
        vm.warp(Blocktime + 40 hours);
        applicationCoin.mint(user1, 2550 * ATTO);

        /// burn tokens
        /// move into fresh period
        vm.warp(Blocktime + 95 hours);
        applicationCoin.burn(1000 * ATTO);
        applicationCoin.burn(1000 * ATTO);
        applicationCoin.burn(8000 * ATTO);

        vm.expectRevert(0xc406d470);
        applicationCoin.burn(2550 * ATTO);

        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_AppAdminExclusion() public endWithStopPrank {
        _transactionFeeTableCoinSetup();
        switchToAppAdministrator();
        // make sure fees don't affect Application Administrators(even if tagged)
        applicationAppManager.addTag(superAdmin, "cheap"); ///add tag
        applicationCoin.transfer(user2, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user2), 100 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_FeeAssessment() public endWithStopPrank {
        _transactionFeeTableCoinSetup();
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user4, "cheap"); ///add tag
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_Exclusion() public endWithStopPrank {
        // make sure when fees are active, that non qualifying users are not affected
        _transactionFeeTableCoinSetup();
        switchToAppAdministrator();
        applicationCoin.transfer(user5, 100 * ATTO);
        vm.startPrank(user5);
        applicationCoin.transfer(user6, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user6), 100 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 0); // Nothing added
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_MultipleFee() public endWithStopPrank {
        // make sure multiple fees work by adding additional rule and applying to user4
        _transactionFeeTableCoinSetup();
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "cheap"); ///add tag
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.startPrank(user4);
        applicationCoin.transfer(user7, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * ATTO); // treasury gets fees
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_Discount() public endWithStopPrank {
        // make sure discounts work by adding a discount to user4
        _transactionFeeTableCoinSetup();
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "cheap"); ///add tag
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        FeesFacet(address(applicationCoinHandler)).addFee("discount", minBalance, maxBalance, -200, address(0));
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "discount"); ///add tag
        vm.startPrank(user4);
        applicationCoin.transfer(user8, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user8), 93 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 2 * ATTO); // treasury gets fees
        assertEq(applicationCoin.balanceOf(targetAccount2), 5 * ATTO); // treasury gets fees(added from previous...6 + 5)
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_Deactivation() public endWithStopPrank {
        // make sure deactivation works
        _transactionFeeTableCoinSetup();
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).setFeeActivation(false);
        vm.startPrank(user4);
        applicationCoin.transfer(user9, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user9), 100 * ATTO); // to account gets amount while ignoring fees
        assertEq(applicationCoin.balanceOf(targetAccount), 0); // Nothing added
        assertEq(applicationCoin.balanceOf(targetAccount2), 0); // Nothing added
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_BlankTag_StandardFee() public endWithStopPrank {
        _transactionFeeTableCoinBlankTagSetup();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin_BlankTag_AdditionalFee() public endWithStopPrank {
        _transactionFeeTableCoinBlankTagSetup();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * ATTO);
        /// Now add another fee and make sure it accumulates.
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.startPrank(user4);
        applicationCoin.transfer(user7, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99800 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * ATTO); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * ATTO); // treasury gets fees
    }

    function testERC20_ApplicationERC20_TransactionFeeTableDiscountsCoin() public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        minBalance = 10 * ATTO;
        maxBalance = 10000000 * ATTO;
        int24 feePercentage = 100;
        targetAccount = rich_user;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("fee1", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("fee1");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        // create a discount
        switchToRuleAdmin();
        feePercentage = -9000;
        FeesFacet(address(applicationCoinHandler)).addFee("discount1", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        fee = FeesFacet(address(applicationCoinHandler)).getFee("discount1");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        // create another discount that makes it more than the fee
        switchToRuleAdmin();
        feePercentage = -2000;
        FeesFacet(address(applicationCoinHandler)).addFee("discount2", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        fee = FeesFacet(address(applicationCoinHandler)).getFee("discount2");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);

        // now test the fee assessment
        applicationAppManager.addTag(user4, "discount1"); ///add tag
        applicationAppManager.addTag(user4, "discount2"); ///add tag
        applicationAppManager.addTag(user4, "fee1"); ///add tag
        vm.startPrank(user4);
        // discounts are greater than fees so it should put fees to 0
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 100 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 0 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableTransferFrom_AppAdminExclusion() public endWithStopPrank {
        _transactionFeeTableTransferFromSetup();
        switchToAppAdministrator();
        // make sure fees don't affect Application Administrators(even if tagged)
        applicationAppManager.addTag(appAdministrator, "cheap"); ///add tag
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(appAdministrator, user2, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user2), 100 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableTransferFrom_FeeAssessment() public endWithStopPrank {
        _transactionFeeTableTransferFromSetup();
        vm.startPrank(user4);
        // test the fee assessment
        // make sure standard fee works
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableTransferFrom_Exclusion() public endWithStopPrank {
        _transactionFeeTableTransferFromSetup();
        // make sure when fees are active, that non qualifying users are not affected
        switchToAppAdministrator();
        applicationCoin.transfer(user5, 100 * ATTO);
        vm.startPrank(user5);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user5, user6, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user6), 100 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 0); // Nothing added
    }

    function testERC20_ApplicationERC20_TransactionFeeTableTransferFrom_MultipleFee() public endWithStopPrank {
        _transactionFeeTableTransferFromSetup();
        // make sure multiple fees work by adding additional rule and applying to user4
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user7, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO); // treasury gets fees
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * ATTO); // treasury gets fees
    }

    function testERC20_ApplicationERC20_TransactionFeeTableTransferFrom_Discount() public endWithStopPrank {
        _transactionFeeTableTransferFromSetup();
        // make sure discounts work by adding a discount to user4
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        FeesFacet(address(applicationCoinHandler)).addFee("discount", minBalance, maxBalance, -200, address(0));
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        applicationAppManager.addTag(user4, "discount"); ///add tag
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user8, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user8), 93 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 2 * ATTO); // treasury gets fees
        assertEq(applicationCoin.balanceOf(targetAccount2), 5 * ATTO); // treasury gets fees
    }

    function testERC20_ApplicationERC20_TransactionFeeTableTransferFrom_Deactivation() public endWithStopPrank {
        _transactionFeeTableTransferFromSetup();
        // make sure deactivation works
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).setFeeActivation(false);
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user9, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user9), 100 * ATTO); // to account gets amount while ignoring fees
        assertEq(applicationCoin.balanceOf(targetAccount), 0); // treasury doesn't receive anything
        assertEq(applicationCoin.balanceOf(targetAccount2), 0); // treasury doesn't receive anything
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoinGt100_FeeAssessment() public endWithStopPrank {
        _transactionFeeTableCoinGt100Setup();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoinGt100_100Percent() public endWithStopPrank {
        _transactionFeeTableCoinGt100Setup();
        // add a fee to bring it to 100 percent
        switchToRuleAdmin();
        int24 feePercentage = 9700;
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, feePercentage, targetAccount2);
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.startPrank(user4);
        // make sure standard fee works(other fee will also be assessed)
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 0);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount2), 97 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoinGt100_Above100Percent() public endWithStopPrank {
        _transactionFeeTableCoinGt100Setup();
        // add a fee to bring it over 100 percent
        switchToRuleAdmin();
        int24 feePercentage = 10;
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 9700, targetAccount2);
        FeesFacet(address(applicationCoinHandler)).addFee("super cheap", minBalance, maxBalance, feePercentage, targetAccount2);
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        applicationAppManager.addTag(user4, "super cheap"); ///add tag
        vm.startPrank(user4);
        // make sure standard fee works(other fee will also be assessed)
        bytes4 selector = bytes4(keccak256("FeesAreGreaterThanTransactionAmount(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, user4));
        applicationCoin.transfer(user3, 200 * ATTO);
        // make sure nothing changed
        assertEq(applicationCoin.balanceOf(user4), 100000 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 0);
        assertEq(applicationCoin.balanceOf(targetAccount), 0);
        assertEq(applicationCoin.balanceOf(targetAccount2), 0); // current 7
    }

    /// INTERNAL HELPER FUNCTIONS
    function _tokenMaxSupplyVolatilitySetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// burn tokens to specific supply
        applicationCoin.burn(10_000_000_000_000_000_000_000 * ATTO);
        applicationCoin.mint(appAdministrator, 100_000 * ATTO);
        applicationCoin.transfer(user1, 5000 * ATTO);

        /// create rule
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(1000, 24, Blocktime, 0);
        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        /// move within period
        vm.warp(Blocktime + 13 hours);
        console.log(applicationCoin.totalSupply());
        vm.startPrank(user1);
        /// mint tokens to the cap
        applicationCoin.mint(user1, 1);
        applicationCoin.mint(user1, 1000 * ATTO);
        applicationCoin.mint(user1, 8000 * ATTO);
    }

    function _transactionFeeTableCoinSetup() public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);

        int24 feePercentage = 300;
        targetAccount = rich_user;
        targetAccount2 = user10;
        minBalance = 10 * ATTO;
        maxBalance = 10000000 * ATTO;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());
    }

    function _transactionFeeTableCoinBlankTagSetup() public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        minBalance = 10 * ATTO;
        maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        targetAccount = rich_user;
        targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "discount"); ///add tag
    }

    function _transactionFeeTableTransferFromSetup() public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        minBalance = 10 * ATTO;
        maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        targetAccount = rich_user;
        targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());

        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "cheap"); ///add tag
    }

    function _transactionFeeTableCoinGt100Setup() public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        minBalance = 10 * ATTO;
        maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        targetAccount = rich_user;
        targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());

        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user4, "cheap"); ///add tag
    }
}
