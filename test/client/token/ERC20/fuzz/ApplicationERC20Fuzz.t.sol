// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";

contract ApplicationERC20FuzzTest is TestCommonFoundry, ERC20Util {
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

    // Test balance
    function testERC20_ApplicationERC20Fuzz_BalanceERC20_Positive(uint256 _supply) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, _supply);
        assertEq(applicationCoin.balanceOf(appAdministrator), _supply);
    }
    function testERC20_ApplicationERC20Fuzz_BalanceERC20_MaxSupply_Positive(uint256 _supply, uint256 _mintAmount) public endWithStopPrank {
        _mintAmount = bound(_mintAmount, 1, type(uint256).max);
        switchToAppAdministrator();
        applicationCoin.setMaxSupply(_supply);
        if (_supply >= applicationCoin.getMaxSupply() || _supply == 0){
            applicationCoin.mint(appAdministrator, _mintAmount);
            assertEq(applicationCoin.balanceOf(appAdministrator), _mintAmount);
        } else{
            assertEq(applicationCoin.balanceOf(appAdministrator), 0);
        }
    }
    function testERC20_ApplicationERC20Fuzz_BalanceERC20_MaxSupply_Negative(uint256 _supply, uint256 _mintAmount) public endWithStopPrank {
        _mintAmount = bound(_mintAmount, 1, type(uint256).max);
        switchToAppAdministrator();
        applicationCoin.setMaxSupply(_supply);
        if (_supply < applicationCoin.getMaxSupply() && _supply != 0){
            vm.expectRevert(abi.encodeWithSignature("ExceedingMaxSupply()"));
            applicationCoin.mint(appAdministrator, _mintAmount);
            assertEq(applicationCoin.balanceOf(appAdministrator), 0);
        } 
    }
    function testERC20_ApplicationERC20Fuzz_setMaxSupply_Positive(uint256 _supply) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.setMaxSupply(_supply);
        assertEq(applicationCoin.getMaxSupply(),_supply);
    }

    function testERC20_ApplicationERC20Fuzz_setMaxSupply_NotAppAdmin(uint256 _supply) public endWithStopPrank {
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        applicationCoin.setMaxSupply(_supply);
        assertEq(applicationCoin.getMaxSupply(),0);
    }

    function testERC20_ApplicationERC20Fuzz_Transfer_Positive(uint8 _addressIndex, uint256 _amount) public endWithStopPrank {
        switchToAppAdministrator();
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        address _user1 = addressList[0];
        applicationCoin.mint(appAdministrator, _amount);
        applicationCoin.transfer(_user1, _amount);
        assertEq(applicationCoin.balanceOf(_user1), _amount);
        assertEq(applicationCoin.balanceOf(appAdministrator), 0);
    }

    function testERC20_ApplicationERC20Fuzz_Transfer_ToAddressZeroAddress(uint256 _amount) public endWithStopPrank {
        switchToAppAdministrator();
        address _user1 = address(0);
        applicationCoin.mint(appAdministrator, _amount);
        vm.expectRevert("ERC20: transfer to the zero address");
        applicationCoin.transfer(_user1, _amount);
        assertEq(applicationCoin.balanceOf(appAdministrator), _amount);
    }

    function testERC20_ApplicationERC20Fuzz_Transfer_NotOwned(uint8 _addressIndex, uint256 _amount) public endWithStopPrank {
        _amount = bound(_amount, 1, type(uint256).max);
        switchToAppAdministrator();
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        address _user1 = addressList[0];
        applicationCoin.mint(appAdministrator, _amount);
        switchToUser();
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        applicationCoin.transfer(_user1, _amount);
        assertEq(applicationCoin.balanceOf(_user1), 0);
    }

    function testERC20_ApplicationERC20Fuzz_TokenMinTransactionSize_Positive(uint8 _addressIndex, uint128 _transferAmount) public endWithStopPrank {
        // if the transferAmount is the max, adust so the internal arithmetic works
        _transferAmount = uint128(bound(uint256(_transferAmount), 1, type(uint128).max-1));
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        address _user1 = addressList[0];
        // Then we add the rule.
        uint32 ruleId;
        switchToRuleAdmin();
        ruleId = createTokenMinimumTransactionRule(_transferAmount);
        setTokenMinimumTransactionRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        /// now we perform the transfer
        // emit Log("transferAmount", _transferAmount);
        applicationCoin.transfer(_user1, _transferAmount + 1);
        assertEq(applicationCoin.balanceOf(_user1), _transferAmount + 1);
    }

    function testERC20_ApplicationERC20Fuzz_TokenMinTransactionSize_Negative(uint8 _addressIndex, uint128 _transferAmount) public endWithStopPrank {
        // if the transferAmount is the max, adust so the internal arithmetic works
        _transferAmount = uint128(bound(uint256(_transferAmount), 1, type(uint128).max-1));
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        // Then we add the rule.
        uint32 ruleId;
        switchToRuleAdmin();
        ruleId = createTokenMinimumTransactionRule(_transferAmount);
        setTokenMinimumTransactionRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();        
        vm.stopPrank();
        vm.startPrank(_user1);
        // now we check for proper failure
        vm.expectRevert(0x7a78c901);
        applicationCoin.transfer(_user2, _transferAmount - 1);
    }

    // NOTE: this function had to be delineated with braces to prevent "stack too deep" errors
    function testERC20_ApplicationERC20Fuzz_AccountMinMaxTokenBalance_Positive(bytes32 _tag, uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        _amountSeed = uint24(bound(uint256(_amountSeed), 1, 167770));
        switchToAppAdministrator();
        if (_tag == "") _tag = bytes32("TEST");
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _richUser;
        address _user1;
        address _user2;
        address _user3;
        // set up amounts
        uint256 maxAmount;
        uint256 minAmount;
        {
            applicationCoin.mint(appAdministrator, type(uint256).max);
            _richUser = addressList[0];
            _user1 = addressList[1];
            _user2 = addressList[2];
            _user3 = addressList[3];
            maxAmount = _amountSeed * 100;
            minAmount = _amountSeed;
        }
        {
            /// set up a non admin user with tokens
            applicationCoin.transfer(_richUser, maxAmount);
            applicationCoin.transfer(_user1, maxAmount);
            uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(_tag), createUint256Array(minAmount), createUint256Array(maxAmount));
            setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
            switchToAppAdministrator();
        }
        {
            ///Add Tag to account
            applicationAppManager.addTag(_user1, _tag); ///add tag
            assertTrue(applicationAppManager.hasTag(_user1, _tag));
            applicationAppManager.addTag(_user2, _tag); ///add tag
            assertTrue(applicationAppManager.hasTag(_user2, _tag));
            applicationAppManager.addTag(_user3, _tag); ///add tag
            assertTrue(applicationAppManager.hasTag(_user3, _tag));
        }
        {
            ///perform transfer that checks rule
            vm.stopPrank();
            vm.startPrank(_user1);
            applicationCoin.transfer(_user2, minAmount);
            assertEq(applicationCoin.balanceOf(_user2), minAmount);
            assertEq(applicationCoin.balanceOf(_user1), maxAmount - minAmount);
        }
    }

    // NOTE: this function had to be delineated with braces to prevent "stack too deep" errors
    function testERC20_ApplicationERC20Fuzz_AccountMinMaxTokenBalance_UnderMinBalance(bytes32 _tag, uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        _amountSeed = uint24(bound(uint256(_amountSeed), 2, 167770));
        switchToAppAdministrator();
        if (_tag != "") {
            address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
            address _user1;
            address _user2;
            // set up amounts
            uint256 maxAmount;
            uint256 minAmount;
            {
                applicationCoin.mint(appAdministrator, type(uint256).max);
                _user1 = addressList[1];
                _user2 = addressList[2];
                maxAmount = _amountSeed * 100;
                minAmount = _amountSeed;
            }
            {
                /// set up a non admin user with tokens
                applicationCoin.transfer(_user1, maxAmount);
                uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(_tag), createUint256Array(minAmount), createUint256Array(maxAmount));
                setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
                switchToAppAdministrator();
            }
            {
                ///Add Tag to account
                applicationAppManager.addTag(_user1, _tag); ///add tag
                applicationAppManager.addTag(_user2, _tag); ///add tag
                ///perform transfer that checks rule
                vm.startPrank(_user1);
                // make sure the minimum rules fail results in revert
                vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
                applicationCoin.transfer(_user2, maxAmount);
            }
        }
    }

    // NOTE: this function had to be delineated with braces to prevent "stack too deep" errors
    function testERC20_ApplicationERC20Fuzz_AccountMinMaxTokenBalance_OverMaxBalance(bytes32 _tag, uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        if (_tag != "") {
            address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
            address _richUser;
            address _user1;
            address _user2;
            address _user3;
            // set up amounts
            uint256 maxAmount;
            uint256 minAmount;
            {
                applicationCoin.mint(appAdministrator, type(uint256).max);
                _richUser = addressList[0];
                _user1 = addressList[1];
                _user2 = addressList[2];
                _user3 = addressList[3];
                // set up amounts(accounting for too big and too small numbers)
                if (_amountSeed == 0) {
                    _amountSeed = 1;
                }
                if (_amountSeed > 167770) {
                    _amountSeed = 167770;
                }
                maxAmount = _amountSeed * 100;
                minAmount = maxAmount / 100;
            }
            {
                /// set up a non admin user with tokens
                applicationCoin.transfer(_richUser, maxAmount);
                assertEq(applicationCoin.balanceOf(_richUser), maxAmount);
                applicationCoin.transfer(_user1, maxAmount);
                assertEq(applicationCoin.balanceOf(_user1), maxAmount);
                uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(_tag), createUint256Array(minAmount), createUint256Array(maxAmount));
                setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
                switchToAppAdministrator();
            }
            {
                ///Add Tag to account
                applicationAppManager.addTag(_user1, _tag); ///add tag
                applicationAppManager.addTag(_user2, _tag); ///add tag
                applicationAppManager.addTag(_user3, _tag); ///add tag
            }
            {
                /// make sure the maximum rule fail results in revert
                vm.startPrank(_richUser);
                vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
                applicationCoin.transfer(_user2, maxAmount+1);
            }
        }
    }


    function testERC20_ApplicationERC20Fuzz_AccountApproveDenyOracle_Positive(uint8 _addressIndex) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
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
    }

    function testERC20_ApplicationERC20Fuzz_AccountApproveDenyOracle_Denied(uint8 _addressIndex) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address _user1 = addressList[0];
        address _user3 = addressList[2];
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
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        applicationCoin.transfer(_user3, 10);
        assertEq(applicationCoin.balanceOf(_user3), 0);
    }

    function testERC20_ApplicationERC20Fuzz_AccountApproveDenyOracle_NotApproved(uint8 _addressIndex) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address _user1 = addressList[0];
        address _user3 = addressList[2];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, 100000);
        assertEq(applicationCoin.balanceOf(_user1), 100000);

        // add the rule.
        switchToRuleAdmin();
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        applicationCoin.transfer(_user3, 10);
        assertEq(applicationCoin.balanceOf(_user3), 0);
    }


    function testERC20_ApplicationERC20Fuzz_MaxTxSizePerPeriodByRiskRuleERC20_NextPeriod_Negative(uint8 _risk, uint8 _period) public endWithStopPrank {
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
        /// we jump to the next period and make sure it still works.
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 1 * (10 ** 18));

        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (9 * (uint256(period) * 1 hours)) / 2);

        /// TEST RULE ON SENDER
        /// first we send only 1 token which shouldn't trigger any risk check
        applicationCoin.transfer(user2, 1);
        console.log(risk);
        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        /// now, if the user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskScore[2]) vm.expectRevert();
        applicationCoin.transfer(user2, 1 * (10 ** 18));
        /// 2
        /// if the user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskScore[1]) vm.expectRevert();
        applicationCoin.transfer(user2, 10_000 * (10 ** 18) - 1);
        /// 10_001
        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskScore[0]) vm.expectRevert();
        applicationCoin.transfer(user2, 100_000_000 * (10 ** 18) - 10_000 * (10 ** 18));
        /// 100_000_000 - 10_000 + 10_001 = 100_000_000 + 1 = 100_000_001
        if (risk >= _riskScore[0]) vm.expectRevert();
        applicationCoin.transfer(user2, 1_000_000_000_000 * (10 ** 18) - 100_000_000 * (10 ** 18));
    }

    function testERC20_ApplicationERC20Fuzz_MaxTxSizePerPeriodByRiskRuleERC20_Simple_Positive(uint8 _risk, uint8 _period) public endWithStopPrank {
        vm.warp(Blocktime);
        /// we create the rule parameters
        uint8[] memory _riskScore = createUint8Array(25, 50, 75);
        uint8 period = _period > 6 ? _period / 6 + 1 : 1;
        uint8 risk = uint8((uint16(_risk) * 100) / 256);
        /// we give some trillions to user1 to spend
        applicationCoin.mint(user1, 10_000_000_000_000 * (10 ** 18));

        /// we create and register the rule in the protocol
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
    }

    function testERC20_ApplicationERC20Fuzz_MaxTxSizePerPeriodByRiskRuleERC20_Simple_Negative(uint8 _risk, uint8 _period) public endWithStopPrank {
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

    }

    function testERC20_ApplicationERC20Fuzz_TransactionLimitByRiskScore_Positive(uint8 _risk) public endWithStopPrank {
        uint8 risk = uint8((uint16(_risk) * 100) / 256);
        uint8[] memory riskScores = createUint8Array(25, 50, 75);
        // make sure it at least always falls into the range
        risk = uint8(bound(uint256(risk), 0, 75));
        ///Give tokens to user1 and user2
        applicationCoin.mint(user1, 100000000 * (10 ** 18));

        ///Activate rule
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(100_000_000, 10_000, 1));
        setAccountMaxTxValueByRiskRule(ruleId);
        /// we set a risk score for user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, risk);

        ///Execute transfers
        vm.stopPrank();
        vm.startPrank(user1);

        applicationCoin.transfer(user2, 1);
    }

    function testERC20_ApplicationERC20Fuzz_TransactionLimitByRiskScore_Negative(uint8 _risk) public endWithStopPrank {
        uint8 risk = uint8((uint16(_risk) * 100) / 256);
        uint8[] memory riskScores = createUint8Array(25, 50, 75);
        // make sure it at least always falls into the range
        risk = uint8(bound(uint256(risk), 0, 75));
        ///Give tokens to user1 and user2
        applicationCoin.mint(user1, 100000000 * (10 ** 18));

        ///Activate rule
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(100_000_000, 10_000, 1));
        setAccountMaxTxValueByRiskRule(ruleId);
        /// we set a risk score for user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, risk);

        ///Execute transfers
        vm.stopPrank();
        vm.startPrank(user1);

        if (risk >= riskScores[2]) vm.expectRevert();
        applicationCoin.transfer(user2, 11 * (10 ** 18));

        if (risk >= riskScores[1]) vm.expectRevert();
        applicationCoin.transfer(user2, 10001 * (10 ** 18));
    }

    function testERC20_ApplicationERC20Fuzz_AccountMaxValueByRiskScore_Positive(uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        // set up amounts(accounting for too big and too small numbers)
        if (_amountSeed == 0) {
            _amountSeed = 1;
        }
        if (_amountSeed > 167770) {
            _amountSeed = 167770;
        }
        uint48 riskBalance1 = _amountSeed + 1000;
        uint48 riskBalance2 = _amountSeed + 500;
        uint48 riskBalance3 = _amountSeed + 100;
        // add the rule.
        uint8[] memory _riskScore = createUint8Array(25, 50, 75, 90);
        uint32 ruleId = createAccountMaxValueByRiskRule(_riskScore, createUint48Array(riskBalance1, riskBalance2, riskBalance3, 1));
        setAccountMaxValueByRiskRule(ruleId);
        /// we set a risk score for user2, user3 and user4
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(_user2, _riskScore[3]);
        applicationAppManager.addRiskScore(_user3, _riskScore[2]);
        applicationAppManager.addRiskScore(_user4, _riskScore[1]);

        ///Execute transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        ///Max riskScore allows for single token balance
        applicationCoin.transfer(_user2, 1 * (10 ** 18));
    }

    function testERC20_ApplicationERC20Fuzz_AccountMaxValueByRiskScore_Negative(uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        // set up amounts(accounting for too big and too small numbers)
        if (_amountSeed == 0) {
            _amountSeed = 1;
        }
        if (_amountSeed > 167770) {
            _amountSeed = 167770;
        }
        uint48 riskBalance1 = _amountSeed + 1000;
        uint48 riskBalance2 = _amountSeed + 500;
        uint48 riskBalance3 = _amountSeed + 100;
        uint48 riskBalance4 = _amountSeed;
        // add the rule.
        uint8[] memory _riskScore = createUint8Array(25, 50, 75, 90);
        uint32 ruleId = createAccountMaxValueByRiskRule(_riskScore, createUint48Array(riskBalance1, riskBalance2, riskBalance3, 1));
        setAccountMaxValueByRiskRule(ruleId);
        /// we set a risk score for user2, user3 and user4
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(_user2, _riskScore[3]);
        applicationAppManager.addRiskScore(_user3, _riskScore[2]);
        applicationAppManager.addRiskScore(_user4, _riskScore[1]);

        ///Execute transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        ///Transfer more than Risk Score allows
        vm.expectRevert();
        applicationCoin.transfer(_user2, riskBalance4 * (10 ** 18) + 1);
        vm.expectRevert();
        applicationCoin.transfer(_user3, riskBalance3 * (10 ** 18) + 1);
        ///Transfer more than Risk Score allows
        vm.expectRevert();
        applicationCoin.transfer(_user4, riskBalance1 * (10 ** 18) + 1);
    }

    function testERC20_ApplicationERC20Fuzz_AccountMaxValueByAccessLevel_Positive(uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user3 = addressList[2];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        // set up amounts(accounting for too big and too small numbers)
        if (_amountSeed == 0) {
            _amountSeed = 1;
        }
        if (_amountSeed > 167770) {
            _amountSeed = 167770;
        }
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = _amountSeed + 100;
        uint48 accessBalance3 = _amountSeed + 500;
        uint48 accessBalance4 = _amountSeed + 1000;
        // add the rule.
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, accessBalance1, accessBalance2, accessBalance3, accessBalance4);
        setAccountMaxValueByAccessLevelRule(ruleId);

        /// Add access level to _user3
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user3, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.stopPrank();
        vm.startPrank(_user1);
        /// this one is within the limit and should pass
        applicationCoin.transfer(_user3, uint256(accessBalance4) * (10 ** 18));
        assertEq(applicationCoin.balanceOf(_user3), uint256(accessBalance4) * (10 ** 18));
    }

    function testERC20_ApplicationERC20Fuzz_AccountMaxValueByAccessLevel_NoAccessLevel(uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        // set up amounts(accounting for too big and too small numbers)
        if (_amountSeed == 0) {
            _amountSeed = 1;
        }
        if (_amountSeed > 167770) {
            _amountSeed = 167770;
        }
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = _amountSeed + 100;
        uint48 accessBalance3 = _amountSeed + 500;
        uint48 accessBalance4 = _amountSeed + 1000;
        // add the rule.
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, accessBalance1, accessBalance2, accessBalance3, accessBalance4);
        setAccountMaxValueByAccessLevelRule(ruleId);
        ///perform transfer that checks rule when account does not have AccessLevel(should fail)
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert(0xaee8b993);
        applicationCoin.transfer(_user2, 1);
        assertEq(applicationCoin.balanceOf(_user2), 0);
    }

    function testERC20_ApplicationERC20Fuzz_AccountMaxValueByAccessLevel_NoBalancesNegative(uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user3 = addressList[2];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        // set up amounts(accounting for too big and too small numbers)
        if (_amountSeed == 0) {
            _amountSeed = 1;
        }
        if (_amountSeed > 167770) {
            _amountSeed = 167770;
        }
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = _amountSeed + 100;
        uint48 accessBalance3 = _amountSeed + 500;
        uint48 accessBalance4 = _amountSeed + 1000;
        // add the rule.
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, accessBalance1, accessBalance2, accessBalance3, accessBalance4);
        setAccountMaxValueByAccessLevelRule(ruleId);

        /// Add access level to _user3
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user3, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.stopPrank();
        vm.startPrank(_user1);
        /// this one is over the limit and should fail
        vm.expectRevert(0xaee8b993);
        applicationCoin.transfer(_user3, uint256(accessBalance4) * (10 ** 18) + 1);
    }

    function testERC20_ApplicationERC20Fuzz_AccountMaxValueByAccessLevel_BalancesNegative(uint8 _addressIndex, uint24 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user4 = addressList[3];
        /// set up a non admin user with tokens
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        // set up amounts(accounting for too big and too small numbers)
        if (_amountSeed == 0) {
            _amountSeed = 1;
        }
        if (_amountSeed > 167770) {
            _amountSeed = 167770;
        }
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = _amountSeed + 100;
        uint48 accessBalance3 = _amountSeed + 500;
        uint48 accessBalance4 = _amountSeed + 1000;
        // add the rule.
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, accessBalance1, accessBalance2, accessBalance3, accessBalance4);
        setAccountMaxValueByAccessLevelRule(ruleId);

        switchToRuleBypassAccount();
        draculaCoin.mint(ruleBypassAccount, type(uint256).max);

        draculaCoin.transfer(_user1, type(uint256).max);
        assertEq(draculaCoin.balanceOf(_user1), type(uint256).max);
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(draculaCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(draculaCoin)), 1 * (10 ** 18));
        // set the access level for the user4
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user4, 3);

        vm.stopPrank();
        vm.startPrank(_user1);
        draculaCoin.transfer(_user4, uint256(accessBalance3) * (10 ** 18) - 1 * (10 ** 18));
        uint256 beginningBalance = applicationCoin.balanceOf(_user1);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail because of other balance)
        vm.expectRevert(0xaee8b993);
        applicationCoin.transfer(_user4, 2 * (10 ** 18));
        //Make sure balance didn't change.
        assertEq(applicationCoin.balanceOf(_user1), beginningBalance);
    }

    function testERC20_ApplicationERC20Fuzz_AdminMinTokenBalance_CannotDeactivateIfActive() public endWithStopPrank {
        /// we load the admin with tokens
        applicationCoin.mint(ruleBypassAccount, type(uint256).max);
        switchToRuleAdmin();
        /// we create a rule that sets the minimum amount to 1 million tokens to be released in 1 year
        uint32 ruleId = createAdminMinTokenBalanceRule(1_000_000 * (10 ** 18), uint64(block.timestamp + 365 days));
        setAdminMinTokenBalanceRule(address(applicationCoinHandler), ruleId);
        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        ERC20HandlerMainFacet(address(applicationCoinHandler)).activateAdminMinTokenBalance(createActionTypeArray(ActionTypes.P2P_TRANSFER), false);
    }

    function testERC20_ApplicationERC20Fuzz_AdminMinTokenBalance_Set_Positive(uint256 amount, uint32 secondsForward) public endWithStopPrank {
        /// we load the admin with tokens
        applicationCoin.mint(ruleBypassAccount, type(uint256).max);
        /// we create a rule that sets the minimum amount to 1 million tokens to be released in 1 year
        uint32 ruleId = createAdminMinTokenBalanceRule(1_000_000 * (10 ** 18), uint64(block.timestamp + 365 days));
        setAdminMinTokenBalanceRule(address(applicationCoinHandler), ruleId);
        vm.warp(block.timestamp + secondsForward);
        switchToRuleBypassAccount();

        if (secondsForward < 365 days && type(uint256).max - amount < 1_000_000 * (10 ** 18)) vm.expectRevert();

        applicationCoin.transfer(user1, amount);
        switchToRuleAdmin();
        /// if last rule is expired, we should be able to turn off and update the rule
        if (secondsForward >= 365 days) {
            ERC20HandlerMainFacet(address(applicationCoinHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
            ERC20HandlerMainFacet(address(applicationCoinHandler)).setAdminMinTokenBalanceId(_createActionsArray(), ruleId);
            assertFalse(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActiveAndApplicable());
        }
    }


    function testERC20_ApplicationERC20Fuzz_AccountMinMaxTokenBalance_Positive2(uint8 _addressIndex, uint256 _amountSeed, bytes32 tag1, bytes32 tag2, bytes32 tag3) public endWithStopPrank {
        switchToAppAdministrator();
        _amountSeed = bound(_amountSeed, 1, 1000);
        if(tag1 == "") tag1  = "TAG1";
        if(tag2 =="") tag2  = "TAG2";
        if(tag3 == "") tag3  = "TAG3";
        if(tag1 == tag2 || tag1 == tag3){
            tag1  = "TAG1";
            tag2  = "TAG2";
            tag3  = "TAG3";
        }
        applicationCoin.mint(appAdministrator, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        rich_user = addressList[0];
        user1 = addressList[1];
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array(tag1, tag2, tag3);
        uint256[] memory minAmounts = createUint256Array((_amountSeed * (10 ** 18)), (_amountSeed + 1000) * (10 ** 18), (_amountSeed + 2000) * (10 ** 18));
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        /// 720 = 1 month, 4380 = 6 months, 17520 = 2 years
        uint16[] memory periods = createUint16Array(720, 4380, 17520);

        switchToAppAdministrator();
        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, (_amountSeed * 10) * (10 ** 18));

        uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        /// tag the user
        applicationAppManager.addTag(rich_user, tag1); ///add tag
        applicationAppManager.addTag(user1, tag1); ///add tag
        /// switch to the user
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// make sure a transfer that is acceptable will still pass within the freeze window.
        uint256 transferAmount = (applicationCoin.balanceOf(rich_user) - (minAmounts[0] - 1))-1;
        applicationCoin.transfer(user1, transferAmount);
        assertEq(transferAmount, applicationCoin.balanceOf(user1));
    }

    function testERC20_ApplicationERC20Fuzz_TransactionFeeTable_StandardFee_Positive(uint8 _addressIndex, uint24 _amountSeed, int24 _feeSeed) public endWithStopPrank {
        _amountSeed = uint24(bound(_amountSeed, 1, type(uint24).max / 10000));
        if (_feeSeed > 10000) _feeSeed = 10000;
        if (_feeSeed <= 0) _feeSeed = 1;
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address fromUser = addressList[0];
        address treasury = addressList[1];
        address toUser = addressList[2];
        uint256 fromUserBalance = type(uint256).max - 1;
        applicationCoin.mint(fromUser, fromUserBalance);
        uint256 maxBalance = type(uint256).max;
        address targetAccount = treasury;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("fee", 0, maxBalance, _feeSeed, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("fee");
        assertEq(fee.feePercentage, _feeSeed);
        assertEq(fee.minBalance, 0);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());

        // now test the fee assessment
        applicationAppManager.addTag(fromUser, "fee"); ///add tag
        vm.stopPrank();
        vm.startPrank(fromUser);
        // make sure standard fee works
        console.logUint(_amountSeed);
        applicationCoin.transfer(toUser, _amountSeed);
        assertEq(applicationCoin.balanceOf(fromUser), fromUserBalance - _amountSeed);
    }

    function testERC20_ApplicationERC20Fuzz_TransactionFeeTable_Discount_Positive(uint8 _addressIndex, uint24 _amountSeed, int24 _feeSeed, int24 _discountSeed) public endWithStopPrank {
        _amountSeed = uint24(bound(_amountSeed, 1, type(uint24).max / 10000));
        if (_feeSeed > 10000) _feeSeed = 10000;
        if (_feeSeed <= 0) _feeSeed = 1;
        if (_discountSeed >= 0) _discountSeed = -1;
        if (_discountSeed < -10000) _discountSeed = -10000;

        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address fromUser = addressList[0];
        address treasury = addressList[1];
        address toUser = addressList[2];
        uint256 fromUserBalance = type(uint256).max - 1;
        applicationCoin.mint(fromUser, fromUserBalance);
        uint256 maxBalance = type(uint256).max;
        address targetAccount = treasury;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("fee", 0, maxBalance, _feeSeed, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("fee");

        // now test the fee assessment
        applicationAppManager.addTag(fromUser, "fee"); ///add tag
        applicationAppManager.addTag(fromUser, "discount"); ///add tag
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("discount", 0, maxBalance, _discountSeed, address(0));
        switchToAppAdministrator();
        fee = FeesFacet(address(applicationCoinHandler)).getFee("discount");
        vm.stopPrank();
        vm.startPrank(fromUser);
        // make sure standard fee works
        console.logUint(_amountSeed);
        applicationCoin.transfer(toUser, _amountSeed);
        assertEq(applicationCoin.balanceOf(fromUser), fromUserBalance - _amountSeed);
        uint feeCalculus;
        // discount is set, calculate for it
        // fees calculate to 0
        if (_feeSeed + _discountSeed < 0) {
            feeCalculus = 0;
        } else {
            feeCalculus = uint24(_feeSeed + _discountSeed); // note: discount is negative
        }
        assertEq(applicationCoin.balanceOf(toUser), _amountSeed - (_amountSeed * feeCalculus) / 10000);
        assertEq(applicationCoin.balanceOf(targetAccount), (_amountSeed * feeCalculus) / 10000);
    }
    
    function testERC20_ApplicationERC20Fuzz_TransactionFeeTable_StandardFee_TransferFrom_Positive(uint8 _addressIndex, uint24 _amountSeed, int24 _feeSeed) public endWithStopPrank {
        _amountSeed = uint24(bound(_amountSeed, 1, type(uint24).max / 10000));
        if (_feeSeed > 10000) _feeSeed = 10000;
        if (_feeSeed <= 0) _feeSeed = 1;
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address fromUser = addressList[0];
        address treasury = addressList[1];
        address toUser = addressList[2];
        uint256 fromUserBalance = type(uint256).max - 1;
        applicationCoin.mint(fromUser, fromUserBalance);
        uint256 maxBalance = type(uint256).max;
        address targetAccount = treasury;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("fee", 0, maxBalance, _feeSeed, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("fee");
        assertEq(fee.feePercentage, _feeSeed);
        assertEq(fee.minBalance, 0);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());

        // now test the fee assessment
        applicationAppManager.addTag(fromUser, "fee"); ///add tag
        vm.stopPrank();
        vm.startPrank(fromUser);
        applicationCoin.approve(fromUser, _amountSeed);
        // make sure standard fee works
        console.logUint(_amountSeed);
        applicationCoin.transferFrom(fromUser, toUser, _amountSeed);
        assertEq(applicationCoin.balanceOf(fromUser), fromUserBalance - _amountSeed);
    }

    function testERC20_ApplicationERC20Fuzz_TransactionFeeTable_Discount_TransferFrom_Positive(uint8 _addressIndex, uint24 _amountSeed, int24 _feeSeed, int24 _discountSeed) public endWithStopPrank {
        _amountSeed = uint24(bound(_amountSeed, 1, type(uint24).max / 10000));
        if (_feeSeed > 10000) _feeSeed = 10000;
        if (_feeSeed <= 0) _feeSeed = 1;
        if (_discountSeed >= 0) _discountSeed = -1;
        if (_discountSeed < -10000) _discountSeed = -10000;

        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address fromUser = addressList[0];
        address treasury = addressList[1];
        address toUser = addressList[2];
        uint256 fromUserBalance = type(uint256).max - 1;
        applicationCoin.mint(fromUser, fromUserBalance);
        uint256 maxBalance = type(uint256).max;
        address targetAccount = treasury;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("fee", 0, maxBalance, _feeSeed, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("fee");

        // now test the fee assessment
        applicationAppManager.addTag(fromUser, "fee"); ///add tag
        applicationAppManager.addTag(fromUser, "discount"); ///add tag
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("discount", 0, maxBalance, _discountSeed, address(0));
        switchToAppAdministrator();
        fee = FeesFacet(address(applicationCoinHandler)).getFee("discount");
        vm.stopPrank();
        vm.startPrank(fromUser);
        // make sure standard fee works
        console.logUint(_amountSeed);
        applicationCoin.approve(fromUser, _amountSeed);
        applicationCoin.transferFrom(fromUser, toUser, _amountSeed);
        assertEq(applicationCoin.balanceOf(fromUser), fromUserBalance - _amountSeed);
        uint feeCalculus;
        // discount is set, calculate for it
        // fees calculate to 0
        if (_feeSeed + _discountSeed < 0) {
            feeCalculus = 0;
        } else {
            feeCalculus = uint24(_feeSeed + _discountSeed); // note: discount is negative
        }
        assertEq(applicationCoin.balanceOf(toUser), _amountSeed - (_amountSeed * feeCalculus) / 10000);
        assertEq(applicationCoin.balanceOf(targetAccount), (_amountSeed * feeCalculus) / 10000);
    }

    function testERC20_ApplicationERC20Fuzz_TokenMaxTradingVolume_Positive(uint8 _addressIndex, uint8 _period, uint24 _maxPercent) public endWithStopPrank {
        _period = uint8(bound(_period,1,type(uint8).max));
        _maxPercent = uint24(bound(_maxPercent,1,99999));
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        rich_user = addressList[0];

        switchToAppAdministrator();
        /// load non admin users with game coin
        applicationCoin.mint(rich_user, 1000000);
        /// apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(_maxPercent, _period, Blocktime, 100_000);
        setTokenMaxTradingVolumeRule(address(applicationCoinHandler), ruleId);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// determine the maximum transfer amount
        uint256 maxSize = uint256(_maxPercent) * 10;
        /// make sure that transfer under the threshold works
        applicationCoin.transfer(user1, maxSize - 1);
        assertEq(applicationCoin.balanceOf(user1), maxSize - 1);
    }

    function testERC20_ApplicationERC20Fuzz_TokenMaxTradingVolume_Negative(uint8 _addressIndex, uint8 _period, uint24 _maxPercent) public endWithStopPrank {
        _period = uint8(bound(_period,1,type(uint8).max));
        _maxPercent = uint24(bound(_maxPercent,1,99999));
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        rich_user = addressList[0];

        switchToAppAdministrator();
        /// load non admin users with game coin
        applicationCoin.mint(rich_user, 1000000);
        /// apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(_maxPercent, _period, Blocktime, 100_000);
        setTokenMaxTradingVolumeRule(address(applicationCoinHandler), ruleId);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// determine the maximum transfer amount
        uint256 maxSize = uint256(_maxPercent) * 10;
        /// now violate the rule and ensure revert
        vm.expectRevert(0x009da0ce);
        applicationCoin.transfer(user1, maxSize);
        assertEq(applicationCoin.balanceOf(user1), 0);
        /// now move 1 block into the future and make sure it works
        vm.warp(block.timestamp + (uint256(_period) * 1 hours) + 1 minutes);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        applicationCoin.transfer(user2, maxSize);
        assertEq(applicationCoin.balanceOf(user2), 0);
    }



    function testERC20_ApplicationERC20Fuzz_TokenMaxSupplyVolatility_Mint_Negative(uint8 _addressIndex, uint256 amount, uint16 volLimit) public endWithStopPrank {
        switchToAppAdministrator();
        vm.warp(Blocktime);
        /// test params
        volLimit = uint16(bound(volLimit, 100, 9999));
        uint256 initialSupply = 100_000 * (10 ** 18);
        uint256 volume = uint256(volLimit) * 10;
        amount = bound(amount, (initialSupply - volume), initialSupply);
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        user1 = addressList[0];
        /// mint initial supply
        applicationCoin.mint(ruleBypassAccount, initialSupply);
        switchToRuleBypassAccount();
        /// create and activate rule
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(volLimit, rulePeriod, startTime, tokenSupply);
        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
        /// test mint
        vm.stopPrank();
        vm.startPrank(user1);
        console.log(initialSupply);
        console.log(volume);
        console.log(amount);
        vm.expectRevert(abi.encodeWithSignature("OverMaxSupplyVolatility()"));
        applicationCoin.mint(user1, amount);
        assertEq(applicationCoin.balanceOf(user1),0);
           
    }

    function testERC20_ApplicationERC20Fuzz_TokenMaxSupplyVolatility_Mint_Positive(uint8 _addressIndex, uint256 amount, uint16 volLimit) public endWithStopPrank {
        switchToAppAdministrator();
        vm.warp(Blocktime);
        /// test params
        volLimit = uint16(bound(volLimit, 100, 9999));
        uint256 initialSupply = 100_000 * (10 ** 18);
        uint256 volume = uint256(volLimit) * 10;
        amount = bound(amount, 1, (initialSupply / volume));
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        user1 = addressList[0];
        /// mint initial supply
        applicationCoin.mint(ruleBypassAccount, initialSupply);
        switchToRuleBypassAccount();
        /// create and activate rule
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(volLimit, rulePeriod, startTime, tokenSupply);
        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
        /// test mint
        vm.stopPrank();
        vm.startPrank(user1);
        console.log(initialSupply);
        console.log(volume);
        console.log(amount);
        applicationCoin.mint(user1, amount);
           
    }

    function testERC20_ApplicationERC20Fuzz_TokenMaxSupplyVolatility_Burn_Positive(uint8 _addressIndex, uint256 amount, uint16 volLimit) public endWithStopPrank {
        switchToAppAdministrator();
        vm.warp(Blocktime);
        /// test params
        volLimit = uint16(bound(volLimit, 100, 9999));
        uint256 initialSupply = 100_000 * (10 ** 18);
        uint256 volume = uint256(volLimit) * 10;
        amount = bound(amount, 1, (initialSupply / volume));
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        user1 = addressList[0];
        /// mint initial supply
        applicationCoin.mint(ruleBypassAccount, initialSupply);
        switchToRuleBypassAccount();
        /// create and activate rule
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(volLimit, rulePeriod, startTime, tokenSupply);
        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
        /// test mint
        vm.stopPrank();
        vm.startPrank(user1);
        console.log(initialSupply);
        console.log(volume);
        console.log(amount);
        applicationCoin.mint(user1, amount);
           
    }

    function testERC20_ApplicationERC20Fuzz_TokenMaxSupplyVolatility_Burn_Negative(uint8 _addressIndex, uint256 amount, uint16 volLimit) public endWithStopPrank {
        switchToAppAdministrator();
        vm.warp(Blocktime);
        /// test params
        volLimit = uint16(bound(volLimit, 100, 9999));
        uint256 initialSupply = 100_000 * (10 ** 18);
        uint256 volume = uint256(volLimit) * 10;
        amount = bound(amount, (initialSupply - volume), initialSupply);
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        user1 = addressList[0];
        /// mint initial supply
        applicationCoin.mint(ruleBypassAccount, initialSupply);
        switchToRuleBypassAccount();
        /// create and activate rule
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(volLimit, rulePeriod, startTime, tokenSupply);
        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
        /// test mint
        vm.stopPrank();
        vm.startPrank(user1);
        console.log(initialSupply);
        console.log(volume);
        console.log(amount);
        vm.expectRevert(abi.encodeWithSignature("OverMaxSupplyVolatility()"));
        applicationCoin.mint(user1, amount);
           
    }

}
