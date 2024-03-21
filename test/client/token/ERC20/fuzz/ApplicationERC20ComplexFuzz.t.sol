// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";

contract ApplicationERC20ComplexFuzzTest is TestCommonFoundry, ERC20Util {
    // event Log(string eventString, uint256 number);
    ApplicationERC20 draculaCoin;

    function setUp() public {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        switchToAppAdministrator();
        draculaCoin = new ApplicationERC20("application2", "DRAC", address(applicationAppManager));
        applicationCoinHandler2 = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(draculaCoin));
        draculaCoin.connectHandlerToToken(address(applicationCoinHandler2));
        /// register the token
        applicationAppManager.registerToken("DRAC", address(draculaCoin));
        vm.stopPrank();
    }

   function testERC20_ApplicationERC20Fuzz_AccountApproveDenyOracle_Complex(uint8 _addressIndex) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];
        address _user5 = addressList[4];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, 100000);
        assertEq(applicationCoin.balanceOf(_user1), 100000);

        // add the rule.
        switchToRuleAdmin();
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        // add a blocked address
        badBoys.push(_user3);
        oracleDenied.addToDeniedList(badBoys);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationCoin.transfer(_user2, 10);
        assertEq(applicationCoin.balanceOf(_user2), 10);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        applicationCoin.transfer(_user3, 10);
        assertEq(applicationCoin.balanceOf(_user3), 0);
        // check the approved list type
        switchToRuleAdmin();
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        // add an approved address
        goodBoys.push(_user4);
        oracleApproved.addToApprovedList(goodBoys);
        vm.stopPrank();
        vm.startPrank(_user1);
        // This one should pass
        applicationCoin.transfer(_user4, 10);
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        applicationCoin.transfer(_user5, 10);
    }
	
	function testERC20_ApplicationERC20Fuzz_MaxTxSizePerPeriodByRiskRuleERC20_Complex(uint8 _risk, uint8 _period) public endWithStopPrank {
	        vm.warp(Blocktime);
	        /// we create the rule
	        uint8[] memory _riskScore = createUint8Array(25, 50, 75);
	        uint8 period = _period > 6 ? _period / 6 + 1 : 1;
	        uint8 risk = uint8((uint16(_risk) * 100) / 256);
	        /// we give some trillions to user1 to spend
	        applicationCoin.mint(user1, 10_000_000_000_000 * (10 ** 18));

	        /// we register the rule in the protocol
	        uint32 ruleId = createAccountMaxTxValueByRiskRule(_riskScore, createUint48Array(100_000_000, 10_000, 1), period);
	        setAccountMaxTxValueByRiskRule(ruleId);
	        /// we set a risk score for user1
	        switchToRiskAdmin();
	        applicationAppManager.addRiskScore(user1, risk);

	        /// we start the prank exactly at the time when the rule starts taking effect + 1 full period + 1 minute
	        uint256 startTestAt = (block.timestamp + (uint256(period) * (1 hours)) + 1 minutes);
	        vm.warp(startTestAt);

	        /// TEST RULE ON SENDER
	        /// we start making transfers
	        vm.stopPrank();
	        vm.startPrank(user1);
	        /// first we send only 1 token which shouldn't trigger any risk check
	        applicationCoin.transfer(user2, 1);

	        /// let's go to the future in the middle of the period
	        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
	        /// now, if the user's risk profile is in the highest range, this transfer should revert
	        if (risk >= _riskScore[2]) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user2, 1 * (10 ** 18));
	        /// 2
	        /// if the user's risk profile is in the second to the highest range, this transfer should revert
	        if (risk >= _riskScore[1]) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user2, 10_000 * (10 ** 18) - 1);
	        /// 10_001
	        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
	        if (risk >= _riskScore[0]) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user2, 100_000_000 * (10 ** 18) - 10_000 * (10 ** 18));
	        /// 100_000_000 - 10_000 + 10_001 = 100_000_000 + 1 = 100_000_001
	        if (risk >= _riskScore[0]) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user2, 1_000_000_000_000 * (10 ** 18) - 100_000_000 * (10 ** 18));
	        /// if passed: 1_000_000_000_000 - 100_000_000 + 100_000_001 = 1_000_000_000_000 + 1 = 1_000_000_000_001

	        /// we jump to the next period and make sure it still works.
	        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
	        applicationCoin.transfer(user2, 1 * (10 ** 18));

	        /// let's go to the future in the middle of the period
	        vm.warp(block.timestamp + (9 * (uint256(period) * 1 hours)) / 2);

	        switchToRuleAdmin();
	        /// let's deactivate the rule before minting to avoid triggering the rule
	        applicationHandler.activateAccountMaxTxValueByRiskScore(false);
	        switchToAppAdministrator();
	        /// let get some trillions to user2 to spend
	        applicationCoin.mint(user2, 90_000_000_000_000 * (10 ** 18));

	        /// we register the rule in the protocol
	        ruleId = createAccountMaxTxValueByRiskRule(createUint8Array(10, 40, 90), createUint48Array(900_000_000, 90_000, 1), period);
	        setAccountMaxTxValueByRiskRule(ruleId);
	        /// we start making transfers
	        vm.stopPrank();
	        vm.startPrank(user2);

	        /// first we send only 1 token which shouldn't trigger any risk check
	        applicationCoin.transfer(user1, 1 * (10 ** 18));
	        /// 1
	        /// now, if the user's risk profile is in the highest range, this transfer should revert
	        if (risk >= 90) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user1, 1 * (10 ** 18));
	        /// 2
	        /// if the user's risk profile is in the second to the highest range, this transfer should revert
	        if (risk >= 40) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user1, 90_000 * (10 ** 18) - 1);
	        /// 90_001
	        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
	        if (risk >= 10) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user1, 900_000_000 * (10 ** 18) - 90_000 * (10 ** 18));
	        /// 900_000_000 - 90_000 + 90_001 = 900_000_000 + 1 = 900_000_001
	        if (risk >= 10) vm.expectRevert();
	        console.log(risk);
	        applicationCoin.transfer(user1, 9_000_000_000_000 * (10 ** 18) - 900_000_000 * (10 ** 18));
	        /// if passed: 9_000_000_000_000 - 900_000_000 + 900_000_001  = 9_000_000_000_000 + 1 = 9_000_000_000_001

	        /// we jump to the next period and make sure it still works.
	        vm.warp(block.timestamp + (uint256(period) * 1 hours));
	        applicationCoin.transfer(user1, 1 * (10 ** 18));
	    }
	function testERC20_ApplicationERC20Fuzz_TokenMaxSupplyVolatility_Complex(uint8 _addressIndex, uint256 amount, uint16 volLimit) public endWithStopPrank {
	        switchToAppAdministrator();
	        /// test params
	        vm.assume(volLimit < 9999 && volLimit > 0);
	        if (volLimit < 100) volLimit = 100;
	        vm.assume(amount < 9999 * (10 ** 18));
	        vm.warp(Blocktime);
	        uint8 rulePeriod = 24; /// 24 hours
	        uint64 startTime = Blocktime; /// default timestamp
	        uint256 tokenSupply = 0; /// calls totalSupply() for the token
	        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
	        user1 = addressList[0];
	        /// mint initial supply
	        uint256 initialSupply = 100_000 * (10 ** 18);
	        uint256 volume = uint256(volLimit) * 10;
	        applicationCoin.mint(ruleBypassAccount, initialSupply);
	        switchToRuleBypassAccount();
	        /// create and activate rule
	        uint32 ruleId = createTokenMaxSupplyVolatilityRule(volLimit, rulePeriod, startTime, tokenSupply);
	        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
	        /// test mint
	        vm.stopPrank();
	        vm.startPrank(user1);
	        if (user1 != ruleBypassAccount) {
	            if (amount > initialSupply - volume) {
	                vm.expectRevert(0xc406d470);
	                applicationCoin.mint(user1, amount);
	            }
	        }
	        // /// test burn
	        if (user1 != ruleBypassAccount) {
	            if (amount > uint(applicationCoin.totalSupply()) - volume) {
	                vm.expectRevert(0xc406d470);
	                applicationCoin.burn(amount);
	            }
	        }

	        /// reset the total supply
	        {
	            switchToRuleBypassAccount();
	            applicationCoin.burn(applicationCoin.totalSupply());
	            applicationCoin.mint(ruleBypassAccount, initialSupply);
	            vm.warp(Blocktime + 36 hours);

	            vm.stopPrank();
	            vm.startPrank(user1);
	            uint256 transferAmount = uint256(volLimit) * (10 * (10 ** 18));
	            applicationCoin.mint(user1, (transferAmount - (1 * (10 ** 18))));
	            vm.expectRevert();
	            applicationCoin.mint(user1, transferAmount);

	            applicationCoin.transfer(ruleBypassAccount, applicationCoin.balanceOf(user1));
	        }
	        /// test minimum volatility limits
	        switchToRuleBypassAccount();
	        applicationCoin.burn(applicationCoin.balanceOf(ruleBypassAccount));
	        applicationCoin.mint(ruleBypassAccount, initialSupply);
	        console.logUint(applicationCoin.totalSupply());
	        vm.warp(Blocktime + 96 hours);
	        uint16 volatilityLimit = 1; /// 0.01%
	        ruleId = createTokenMaxSupplyVolatilityRule(volatilityLimit, rulePeriod, startTime, tokenSupply);
	        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
	        vm.stopPrank();
	        vm.startPrank(user1);
	        applicationCoin.mint(user1, 5 * (10 ** 18));
	        applicationCoin.mint(user1, 4 * (10 ** 18));
	        applicationCoin.mint(user1, 1 * (10 ** 18));
	        vm.expectRevert();
	        applicationCoin.mint(user1, 1_000_000_000_000_000); /// 0.0001 tokens

	        /// test above 100% volatility limits
	        applicationCoin.transfer(ruleBypassAccount, applicationCoin.balanceOf(user1));
	        switchToRuleBypassAccount();
	        applicationCoin.burn(applicationCoin.balanceOf(ruleBypassAccount));
	        applicationCoin.mint(ruleBypassAccount, initialSupply);
	        console.logUint(applicationCoin.totalSupply());
	        vm.warp(Blocktime + 120 hours);
	        uint16 newVolatilityLimit = 50000; /// 500%
	        ruleId = createTokenMaxSupplyVolatilityRule(newVolatilityLimit, rulePeriod, startTime, tokenSupply);
	        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
	        vm.stopPrank();
	        vm.startPrank(user1);
	        applicationCoin.mint(user1, 450000 * (10 ** 18));
	        applicationCoin.mint(user1, 50000 * (10 ** 18));
	        applicationCoin.burn(50000 * (10 ** 18));
	        applicationCoin.mint(user1, 50000 * (10 ** 18));
	        applicationCoin.burn(50000 * (10 ** 18));
	        applicationCoin.mint(user1, 50000 * (10 ** 18));
	        applicationCoin.burn(50000 * (10 ** 18));
	    }
	
}
