// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC20.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/example/ApplicationERC20Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";

contract ApplicationERC20FuzzTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationERC20 applicationCoin;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationAppManager appManager;
    ApplicationHandler public applicationHandler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address user4 = address(44);
    address accessTier = address(3);
    address rich_user = address(44);
    address[] badBoys;
    address[] goodBoys;
    uint256 Blocktime = 1675723152;
    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];
    event Log(string eventString, uint256 number);

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));
        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        /// add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        /// add the AccessLevelAdmin address as a AccessLevel admin
        appManager.addAccessTier(accessTier);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));

        applicationCoin = new ApplicationERC20("application", "FRANK", address(appManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), false);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        
        /// register the token
        appManager.registerToken("FRANK", address(applicationCoin));
        /// set the token price
        erc20Pricer = new ApplicationERC20Pricing();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        /// connect ERC20 pricer to applicationCoinHandler
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
        /// add Risk Admin
        appManager.addRiskAdmin(riskAdmin);
    }

    // Test balance
    function testBalance(uint256 _supply) public {
        applicationCoin.mint(defaultAdmin, _supply);
        assertEq(applicationCoin.balanceOf(defaultAdmin), _supply);
    }

    /// Test token transfer
    function testTransferFuzz(uint8 _addressIndex, uint256 _amount) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        address _user1 = addressList[0];
        applicationCoin.mint(defaultAdmin, _amount);
        applicationCoin.transfer(_user1, _amount);
        assertEq(applicationCoin.balanceOf(_user1), _amount);
        assertEq(applicationCoin.balanceOf(defaultAdmin), 0);
    }

    /// test updating min transfer rule
    function testPassesMinTransferRuleFuzz(uint8 _addressIndex, uint128 _transferAmount) public {
        // if the transferAmount is the max, adust so the internal arithmetic works
        if (_transferAmount == 340282366920938463463374607431768211455) {
            _transferAmount -= 1;
        }
        applicationCoin.mint(defaultAdmin, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        // Then we add the rule.
        uint32 ruleId;
        if (_transferAmount == 0) {
            // zero amount should revert
            vm.expectRevert(0x454f1bd4);
            ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), _transferAmount);
        } else {
            ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), _transferAmount);
            /// we update the rule id in the token
            applicationCoinHandler.setMinTransferRuleId(ruleId);
            /// now we perform the transfer
            emit Log("transferAmount", _transferAmount);
            applicationCoin.transfer(_user1, _transferAmount + 1);
            assertEq(applicationCoin.balanceOf(_user1), _transferAmount + 1);
            vm.stopPrank();
            vm.startPrank(_user1);
            // now we check for proper failure
            vm.expectRevert(0x70311aa2);
            applicationCoin.transfer(_user2, _transferAmount - 1);
        }
    }

    // NOTE: this function had to be delineated with braces to prevent "stack too deep" errors
    function testPassMinMaxAccountBalanceRuleApplicationERC20Fuzz(bytes32 _tag, uint8 _addressIndex, uint24 _amountSeed) public {
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
                applicationCoin.mint(defaultAdmin, type(uint256).max);
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

                bytes32[] memory accs = new bytes32[](1);
                uint256[] memory min = new uint256[](1);
                uint256[] memory max = new uint256[](1);
                accs[0] = bytes32(_tag);
                min[0] = uint256(minAmount);
                max[0] = uint256(maxAmount);
                // add the actual rule
                uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);

                ///update ruleId in coin rule handler
                applicationCoinHandler.setMinMaxBalanceRuleId(ruleId);
            }
            {
                ///Add GeneralTag to account
                appManager.addGeneralTag(_user1, _tag); ///add tag
                assertTrue(appManager.hasTag(_user1, _tag));
                appManager.addGeneralTag(_user2, _tag); ///add tag
                assertTrue(appManager.hasTag(_user2, _tag));
                appManager.addGeneralTag(_user3, _tag); ///add tag
                assertTrue(appManager.hasTag(_user3, _tag));
            }
            {
                ///perform transfer that checks rule
                vm.stopPrank();
                vm.startPrank(_user1);
                applicationCoin.transfer(_user2, minAmount);
                assertEq(applicationCoin.balanceOf(_user2), minAmount);
                assertEq(applicationCoin.balanceOf(_user1), maxAmount - minAmount);
            }
            {
                // make sure the minimum rules fail results in revert
                // console.log("USER 1 Balance:");
                // console.logUint(applicationCoin.balanceOf(_user1));
                // console.log("USER 2 Balance:");
                // console.logUint(applicationCoin.balanceOf(_user2));
                vm.expectRevert(0xf1737570);
                applicationCoin.transfer(_user2, maxAmount - minAmount);
            }
            {
                /// make sure the maximum rule fail results in revert
                vm.stopPrank();
                vm.startPrank(_richUser);
                vm.expectRevert(0x24691f6b);
                applicationCoin.transfer(_user2, maxAmount);
            }
        }
    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testOracleFuzz(uint8 _addressIndex) public {
        applicationCoin.mint(defaultAdmin, type(uint256).max);
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
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blocked address
        badBoys.push(_user3);
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationCoin.transfer(_user2, 10);
        assertEq(applicationCoin.balanceOf(_user2), 10);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        applicationCoin.transfer(_user3, 10);
        assertEq(applicationCoin.balanceOf(_user3), 0);
        // check the allowed list type
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // add an allowed address
        goodBoys.push(_user4);
        oracleAllowed.addToAllowList(goodBoys);
        vm.stopPrank();
        vm.startPrank(_user1);
        // This one should pass
        applicationCoin.transfer(_user4, 10);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationCoin.transfer(_user5, 10);

        // Finally, check the invalid type
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 2, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert(0x2a15491e);
        applicationCoin.transfer(_user2, 10);
    }

    function testMaxTxSizePerPeriodByRiskRule(uint8 _risk, uint8 _period, uint8 _hourOfDay) public {
        vm.warp(100_000_000);
        /// we create the rule
        uint48[] memory _maxSize = new uint48[](4);
        uint8[] memory _riskLevel = new uint8[](3);
        uint8 period = _period > 6 ? _period / 6 + 1 : 1;
        uint8 hourOfDay = _hourOfDay < 235 ? _hourOfDay / 10 : 2;
        uint8 risk = uint8((uint16(_risk) * 100) / 256);

        _maxSize[0] = 1_000_000_000_000;
        _maxSize[1] = 100_000_000;
        _maxSize[2] = 10_000;
        _maxSize[3] = 1;
        _riskLevel[0] = 25;
        _riskLevel[1] = 50;
        _riskLevel[2] = 75;

        /// we give some trillions to user1 to spend
        applicationCoin.mint(user1, 10_000_000_000_000 * (10 ** 18));

        /// we register the rule in the protocol
        uint32 ruleId = AppRuleDataFacet(address(ruleStorageDiamond)).addMaxTxSizePerPeriodByRiskRule(address(appManager), _maxSize, _riskLevel, period, hourOfDay);
        /// now we set the rule in the applicationHandler for the applicationCoin only
        applicationHandler.setMaxTxSizePerPeriodByRiskRuleId(ruleId);

        /// we set a risk score for user1
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        appManager.addRiskScore(user1, risk);

        /// we start the prank exactly at the time when the rule starts taking effect + 1 full period + 1 second
        uint256 startTestAt = (block.timestamp - (block.timestamp % (1 days))) + ((uint256(hourOfDay) * (1 hours)) + (uint256(period) * (1 hours))) + 1 - 1 days;
        vm.warp(startTestAt);

        /// TEST RULE ON SENDER
        /// we start making transfers
        vm.stopPrank();
        vm.startPrank(user1);
        /// first we send only 1 token which shouldn't trigger any risk check
        applicationCoin.transfer(user2, 1);
        /// 1
        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        /// now, if the user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskLevel[2]) vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user2, 1 * (10 ** 18));
        /// 2
        /// if the user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskLevel[1]) vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user2, 10_000 * (10 ** 18) - 1);
        /// 10_001
        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskLevel[0]) vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user2, 100_000_000 * (10 ** 18) - 10_000 * (10 ** 18));
        /// 100_000_000 - 10_000 + 10_001 = 100_000_000 + 1 = 100_000_001
        /// even if the user's risk profile is 0, this transfer should revert according to how the rule was built
        vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user2, 1_000_000_000_000 * (10 ** 18) - 100_000_000 * (10 ** 18));
        /// if passed: 1_000_000_000_000 - 100_000_000 + 100_000_001 = 1_000_000_000_000 + 1 = 1_000_000_000_001

        /// we jump to the next period and make sure it still works.
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        applicationCoin.transfer(user2, 1 * (10 ** 18));

        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (9 * (uint256(period) * 1 hours)) / 2);

        /// TEST RULE ON RECIPIENT
        _maxSize[0] = 9_000_000_000_000;
        _maxSize[1] = 900_000_000;
        _maxSize[2] = 90_000;
        _maxSize[3] = 1;
        _riskLevel[0] = 1;
        _riskLevel[1] = 40;
        _riskLevel[2] = 90;

        /// we give some trillions to user1 to spend
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        /// let's deactivate the rule before minting to avoid triggering the rule
        applicationHandler.activateMaxTxSizePerPeriodByRiskRule(false);
        /// let get some trillions to user2 to spend
        applicationCoin.mint(user2, 90_000_000_000_000 * (10 ** 18));

        /// we register the rule in the protocol
        ruleId = AppRuleDataFacet(address(ruleStorageDiamond)).addMaxTxSizePerPeriodByRiskRule(address(appManager), _maxSize, _riskLevel, period, hourOfDay);
        assertEq(ruleId, 1);
        /// now we set the rule in the applicationHandler for the applicationCoin only
        applicationHandler.setMaxTxSizePerPeriodByRiskRuleId(ruleId);
        /// we start making transfers
        vm.stopPrank();
        vm.startPrank(user2);

        /// first we send only 1 token which shouldn't trigger any risk check
        applicationCoin.transfer(user1, 1 * (10 ** 18));
        /// 1
        /// now, if the user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskLevel[2]) vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user1, 1 * (10 ** 18));
        /// 2
        /// if the user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskLevel[1]) vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user1, 90_000 * (10 ** 18) - 1);
        /// 90_001
        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskLevel[0]) vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user1, 900_000_000 * (10 ** 18) - 90_000 * (10 ** 18));
        /// 900_000_000 - 90_000 + 90_001 = 900_000_000 + 1 = 900_000_001
        /// even if the user's risk profile is 0, this transfer should revert according to how the rule was built
        vm.expectRevert();
        console.log(risk);
        applicationCoin.transfer(user1, 9_000_000_000_000 * (10 ** 18) - 900_000_000 * (10 ** 18));
        /// if passed: 9_000_000_000_000 - 900_000_000 + 900_000_001  = 9_000_000_000_000 + 1 = 9_000_000_000_001

        /// we jump to the next period and make sure it still works.
        vm.warp(block.timestamp + (uint256(period) * 1 hours));
        applicationCoin.transfer(user1, 1 * (10 ** 18));
    }

    function testTransactionLimitByRiskScore(uint8 _risk) public {
        uint48[] memory _maxSize = new uint48[](4);
        uint8[] memory _riskLevel = new uint8[](3);
        uint8 risk = uint8((uint16(_risk) * 100) / 256);

        _maxSize[0] = 100000000;
        _maxSize[1] = 1000000;
        _maxSize[2] = 10000;
        _maxSize[3] = 10;
        _riskLevel[0] = 25;
        _riskLevel[1] = 50;
        _riskLevel[2] = 75;

        ///Give tokens to user1 and user2
        applicationCoin.mint(user1, 100000000 * (10 ** 18));
        applicationCoin.mint(user2, 100000000 * (10 ** 18));

        ///Register rule with ERC20Handler
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(appManager), _riskLevel, _maxSize);
        ///Activate rule
        applicationCoinHandler.setTransactionLimitByRiskRuleId(ruleId);

        /// we set a risk score for user1 and user 2
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        appManager.addRiskScore(user1, risk);
        appManager.addRiskScore(user2, risk);

        ///Execute transfers
        vm.stopPrank();
        vm.startPrank(user1);

        if (risk > _riskLevel[2]) vm.expectRevert();
        applicationCoin.transfer(user2, 11 * (10 ** 18));

        if (risk > 75) vm.expectRevert();
        applicationCoin.transfer(user2, 11 * (10 ** 18));

        if (risk > 50) vm.expectRevert();
        applicationCoin.transfer(user2, 10001 * (10 ** 18));
    }

    function testBalanceLimitByRiskScoreFuzz(uint8 _addressIndex, uint24 _amountSeed) public {
        applicationCoin.mint(defaultAdmin, type(uint256).max);
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
        // add the rule.
        uint8[] memory _riskLevel = new uint8[](4);
        uint48[] memory balanceAmounts = new uint48[](5);
        _riskLevel[0] = 25;
        _riskLevel[1] = 50;
        _riskLevel[2] = 75;
        _riskLevel[3] = 90;
        uint48 riskBalance1 = _amountSeed + 1000;
        uint48 riskBalance2 = _amountSeed + 500;
        uint48 riskBalance3 = _amountSeed + 100;
        uint48 riskBalance4 = _amountSeed;

        balanceAmounts[0] = riskBalance1;
        balanceAmounts[1] = riskBalance2;
        balanceAmounts[2] = riskBalance3;
        balanceAmounts[3] = riskBalance4;
        balanceAmounts[4] = 1;

        ///Register rule with application handler
        uint32 ruleId = AppRuleDataFacet(address(ruleStorageDiamond)).addAccountBalanceByRiskScore(address(appManager), _riskLevel, balanceAmounts);
        ///Activate rule
        applicationHandler.setAccountBalanceByRiskRuleId(ruleId);

        /// we set a risk score for user2, user3 and user4
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        appManager.addRiskScore(_user2, _riskLevel[3]);
        appManager.addRiskScore(_user3, _riskLevel[2]);
        appManager.addRiskScore(_user4, _riskLevel[1]);

        ///Execute transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        ///Max riskScore allows for single token balance
        applicationCoin.transfer(_user2, 1 * (10 ** 18));
        ///Transfer more than Risk Score allows
        vm.expectRevert();
        applicationCoin.transfer(_user2, riskBalance4 * (10 ** 18) + 1);

        vm.expectRevert();
        applicationCoin.transfer(_user3, riskBalance3 * (10 ** 18) + 1);
        ///Transfer more than Risk Score allows
        vm.expectRevert();
        applicationCoin.transfer(_user4, riskBalance1 * (10 ** 18) + 1);
    }

    /**
     * @dev Test the Balance By AccessLevel rule
     */
    function testCoinBalanceByAccessLevelRulePassesFuzz(uint8 _addressIndex, uint24 _amountSeed) public {
        applicationCoin.mint(defaultAdmin, type(uint256).max);
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
        // add the rule.
        uint48[] memory balanceAmounts = new uint48[](5);
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = _amountSeed + 100;
        uint48 accessBalance3 = _amountSeed + 500;
        uint48 accessBalance4 = _amountSeed + 1000;

        balanceAmounts[0] = 0;
        balanceAmounts[1] = accessBalance1;
        balanceAmounts[2] = accessBalance2;
        balanceAmounts[3] = accessBalance3;
        balanceAmounts[4] = accessBalance4;
        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(appManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);

        ///perform transfer that checks rule when account does not have AccessLevel(should fail)
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(_user2, 1);

        /// Add access levellevel to _user3
        vm.stopPrank();
        vm.startPrank(accessTier);
        appManager.addAccessLevel(_user3, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.stopPrank();
        vm.startPrank(_user1);
        /// this one is over the limit and should fail
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(_user3, uint256(accessBalance4) * (10 ** 18) + 1);
        /// this one is within the limit and should pass
        applicationCoin.transfer(_user3, uint256(accessBalance4) * (10 ** 18));

        /// create secondary token, mint, and transfer to user
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        ApplicationERC20 draculaCoin = new ApplicationERC20("application2", "DRAC", address(appManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), false);
        draculaCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationCoinHandler2.setERC20PricingAddress(address(erc20Pricer));
        /// register the token
        appManager.registerToken("DRAC", address(draculaCoin));
        draculaCoin.mint(defaultAdmin, type(uint256).max);
        draculaCoin.transfer(_user1, type(uint256).max);
        assertEq(draculaCoin.balanceOf(_user1), type(uint256).max);
        erc20Pricer.setSingleTokenPrice(address(draculaCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(draculaCoin)), 1 * (10 ** 18));
        // set the access levellevel for the user4
        vm.stopPrank();
        vm.startPrank(accessTier);
        appManager.addAccessLevel(_user4, 3);

        vm.stopPrank();
        vm.startPrank(_user1);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail regardless of other balance)
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(_user4, uint256(accessBalance3) * (10 ** 18) + 1);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail because of other balance)
        draculaCoin.transfer(_user4, uint256(accessBalance3) * (10 ** 18) - 1 * (10 ** 18));
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(_user4, 2 * (10 ** 18));

        /// perform transfer that checks user with AccessLevel and existing balances(should pass)
        applicationCoin.transfer(_user4, 1 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(_user4), 1 * (10 ** 18));
    }

    function testAdminWithdrawalFuzz(uint256 amount, uint32 secondsForward) public {
        /// we load the admin with tokens
        applicationCoin.mint(defaultAdmin, type(uint256).max);
        /// we create a rule that sets the minimum amount to 1 million tokens to be released in 1 year
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(appManager), 1_000_000 * (10 ** 18), block.timestamp + 365 days);

        applicationCoinHandler.setAdminWithdrawalRuleId(_index);

        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        applicationCoinHandler.activateAdminWithdrawalRule(false);
        vm.expectRevert();
        applicationCoinHandler.setAdminWithdrawalRuleId(1);

        vm.warp(block.timestamp + secondsForward);
        if (secondsForward < 365 days && type(uint256).max - amount < 1_000_000 * (10 ** 18)) vm.expectRevert();
        applicationCoin.transfer(user1, amount);

        /// if last rule is expired, we should be able to turn off and update the rule
        if (secondsForward >= 365 days) {
            applicationCoinHandler.activateAdminWithdrawalRule(false);
            applicationCoinHandler.setAdminWithdrawalRuleId(1);
        }
    }

    /**
     * @dev test Minimum Balance By Date rule
     */
    function testPassesMinBalByDateCoinFuzz(uint8 _addressIndex, uint256 _amountSeed, bytes32 tag1, bytes32 tag2, bytes32 tag3) public {
        vm.assume(_amountSeed > 0);
        vm.assume(_amountSeed < 1000);
        vm.assume(tag1 != "" && tag2 != "" && tag3 != "");
        vm.assume(tag1 != tag2 && tag1 != tag3);
        applicationCoin.mint(defaultAdmin, type(uint256).max);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        rich_user = addressList[0];
        user1 = addressList[1];
        user2 = addressList[2];
        user3 = addressList[3];
        user4 = addressList[4];
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = tag1;
        accs[1] = tag2;
        accs[2] = tag3;
        uint256[] memory holdAmounts = new uint256[](3);
        holdAmounts[0] = _amountSeed * (10 ** 18);
        holdAmounts[1] = (_amountSeed + 1000) * (10 ** 18);
        holdAmounts[2] = (_amountSeed + 2000) * (10 ** 18);
        uint256[] memory holdPeriods = new uint256[](3);
        holdPeriods[0] = uint32(720); // one month
        holdPeriods[1] = uint32(4380); // six months
        holdPeriods[2] = uint32(17520); // two years
        uint256[] memory holdTimestamps = new uint256[](3);
        holdTimestamps[0] = Blocktime;
        holdTimestamps[1] = Blocktime;
        holdTimestamps[2] = Blocktime;
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(address(appManager), accs, holdAmounts, holdPeriods, holdTimestamps);
        emit Log("Rule Hold Amount", TaggedRuleDataFacet(address(ruleStorageDiamond)).getMinBalByDateRule(_index, accs[0]).holdAmount);
        assertEq(_index, 0);
        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, (_amountSeed * 10) * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), (_amountSeed * 10) * (10 ** 18));
        applicationCoin.transfer(user2, (_amountSeed * 10000) * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), (_amountSeed * 10000) * (10 ** 18));
        applicationCoin.transfer(user3, (_amountSeed * 10000000) * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), (_amountSeed * 10000000) * (10 ** 18));
        applicationCoinHandler.setMinBalByDateRuleId(_index);
        /// tag the user
        appManager.addGeneralTag(rich_user, tag1); ///add tag
        assertTrue(appManager.hasTag(rich_user, tag1));
        appManager.addGeneralTag(user2, tag2); ///add tag
        assertTrue(appManager.hasTag(user2, tag2));
        appManager.addGeneralTag(user3, tag3); ///add tag
        assertTrue(appManager.hasTag(user3, tag3));
        /// switch to the user
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// attempt a transfer that violates the rule
        uint256 transferAmount = (applicationCoin.balanceOf(rich_user) - (holdAmounts[0] - 1));
        emit Log("balanceOf", applicationCoin.balanceOf(rich_user));
        emit Log("holdAmounts", holdAmounts[0]);
        emit Log("transferAmount", transferAmount);
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, transferAmount);
        /// make sure a transfer that is acceptable will still pass within the freeze window.
        transferAmount = transferAmount - 1;
        emit Log("balanceOf", applicationCoin.balanceOf(rich_user));
        emit Log("transferAmount", transferAmount);
        emit Log("holdAmounts", holdAmounts[0]);
        applicationCoin.transfer(user1, transferAmount);
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, 1 * (10 ** 18));
        /// add enough time so that it should pass
        vm.warp(Blocktime + (720 * 1 hours));
        applicationCoin.transfer(user1, 1 * (10 ** 18));

        /// try tier 2
        /// switch to the user
        vm.stopPrank();
        vm.startPrank(user2);
        /// attempt a transfer that violates the rule
        transferAmount = (applicationCoin.balanceOf(user2) - (holdAmounts[1] - 1));
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, transferAmount);
    }

    /**
     * @dev this function ensures that unique addresses can be randomly retrieved from the address array.
     */
    function getUniqueAddresses(uint256 _seed, uint8 _number) public view returns (address[] memory _addressList) {
        _addressList = new address[](ADDRESSES.length);
        // first one will simply be the seed
        _addressList[0] = ADDRESSES[_seed];
        uint256 j;
        if (_number > 1) {
            // loop until all unique addresses are returned
            for (uint256 i = 1; i < _number; i++) {
                // find the next unique address
                j = _seed;
                do {
                    j++;
                    // if end of list reached, start from the beginning
                    if (j == ADDRESSES.length) {
                        j = 0;
                    }
                    if (!exists(ADDRESSES[j], _addressList)) {
                        _addressList[i] = ADDRESSES[j];
                        break;
                    }
                } while (0 == 0);
            }
        }
        return _addressList;
    }

    // Check if an address exists in the list
    function exists(address _address, address[] memory _addressList) public pure returns (bool) {
        for (uint256 i = 0; i < _addressList.length; i++) {
            if (_address == _addressList[i]) {
                return true;
            }
        }
        return false;
    }

    //Test transferring coins with fees enabled
    function testTransactionFeeTableFuzz(uint8 _addressIndex, uint24 _amountSeed, int24 _feeSeed, int24 _discountSeed) public {
        // this logic was used because vm.assume was skipping too many values.
        if (_amountSeed == 0) _amountSeed = 1;
        if (_amountSeed > (type(uint24).max / 10000)) _amountSeed = (type(uint24).max / 10000);
        if (_feeSeed > 10000) _feeSeed = 10000;
        if (_feeSeed <= 0) _feeSeed = 1;
        if (_discountSeed > 0) _discountSeed = 0;
        if (_discountSeed < -10000) _discountSeed = -10000;

        // vm.assume(_discountSeed < 0 && _feeSeed > -10000);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address fromUser = addressList[0];
        address treasury = addressList[1];
        address toUser = addressList[2];
        uint256 fromUserBalance = type(uint256).max - 1;
        applicationCoin.mint(fromUser, fromUserBalance);
        uint256 maxBalance = type(uint256).max;
        address targetAccount = treasury;
        // create a fee
        applicationCoinHandler.addFee("fee", 0, maxBalance, _feeSeed, targetAccount);
        Fees.Fee memory fee = applicationCoinHandler.getFee("fee");
        assertEq(fee.feePercentage, _feeSeed);
        assertEq(fee.minBalance, 0);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());

        // now test the fee assessment
        appManager.addGeneralTag(fromUser, "fee"); ///add tag
        // if the discount is set, then set it up too
        if (_discountSeed != 0) {
            appManager.addGeneralTag(fromUser, "discount"); ///add tag
            applicationCoinHandler.addFee("discount", 0, maxBalance, _discountSeed, address(0));
            fee = applicationCoinHandler.getFee("discount");
            assertEq(fee.feePercentage, _discountSeed);
            assertEq(fee.minBalance, 0);
            assertEq(fee.maxBalance, maxBalance);
            assertEq(2, applicationCoinHandler.getFeeTotal());
        }
        vm.stopPrank();
        vm.startPrank(fromUser);
        // make sure standard fee works
        console.logUint(_amountSeed);
        applicationCoin.transfer(toUser, _amountSeed);
        assertEq(applicationCoin.balanceOf(fromUser), fromUserBalance - _amountSeed);
        uint feeCalculus;
        // if the discount is set, calculate for it, otherwise do normal fee
        if (_discountSeed != 0) {
            // fees calculate to 0
            if (_feeSeed + _discountSeed < 0) {
                feeCalculus = 0;
            } else {
                feeCalculus = uint24(_feeSeed + _discountSeed); // note: discount is negative
            }
            assertEq(applicationCoin.balanceOf(toUser), _amountSeed - (_amountSeed * feeCalculus) / 10000);
            assertEq(applicationCoin.balanceOf(targetAccount), (_amountSeed * feeCalculus) / 10000);
        } else {
            assertEq(applicationCoin.balanceOf(toUser), _amountSeed - (_amountSeed * uint24(_feeSeed)) / 10000);
            assertEq(applicationCoin.balanceOf(targetAccount), (_amountSeed * uint24(_feeSeed)) / 10000);
        }
    }

    ///Test transferring coins with fees enabled
    function testTransactionFeeTableTransferFromFuzz(uint8 _addressIndex, uint24 _amountSeed, int24 _feeSeed, int24 _discountSeed) public {
        // this logic was used because vm.assume was skipping too many values.
        if (_amountSeed == 0) _amountSeed = 1;
        if (_amountSeed > (type(uint24).max / 10000)) _amountSeed = (type(uint24).max / 10000);
        if (_feeSeed > 10000) _feeSeed = 10000;
        if (_feeSeed <= 0) _feeSeed = 1;
        if (_discountSeed > 0) _discountSeed = 0;
        if (_discountSeed < -10000) _discountSeed = -10000;

        // vm.assume(_discountSeed < 0 && _feeSeed > -10000);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address fromUser = addressList[0];
        address treasury = addressList[1];
        address toUser = addressList[2];
        address transferFromUser = addressList[3];
        uint256 fromUserBalance = type(uint256).max - 1;
        applicationCoin.mint(fromUser, fromUserBalance);
        address targetAccount = treasury;
        // create a fee
        applicationCoinHandler.addFee("fee", 0, type(uint256).max, _feeSeed, targetAccount);
        Fees.Fee memory fee = applicationCoinHandler.getFee("fee");
        assertEq(fee.feePercentage, _feeSeed);
        assertEq(fee.minBalance, 0);
        assertEq(fee.maxBalance, type(uint256).max);
        assertEq(1, applicationCoinHandler.getFeeTotal());

        // now test the fee assessment
        appManager.addGeneralTag(fromUser, "fee"); ///add tag
        // if the discount is set, then set it up too
        if (_discountSeed != 0) {
            appManager.addGeneralTag(fromUser, "discount"); ///add tag
            applicationCoinHandler.addFee("discount", 0, type(uint256).max, _discountSeed, address(0));
            fee = applicationCoinHandler.getFee("discount");
            assertEq(fee.feePercentage, _discountSeed);
            assertEq(fee.minBalance, 0);
            assertEq(fee.maxBalance, type(uint256).max);
            assertEq(2, applicationCoinHandler.getFeeTotal());
        }
        // make sure standard fee works
        console.logUint(_amountSeed);
        vm.stopPrank();
        vm.startPrank(fromUser);
        applicationCoin.approve(address(transferFromUser), _amountSeed);
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(fromUser, toUser, _amountSeed);
        assertEq(applicationCoin.balanceOf(fromUser), fromUserBalance - _amountSeed);
        uint24 feeCalculus;
        // if the discount is set, calculate for it, otherwise do normal fee
        if (_discountSeed != 0) {
            // fees calculate to 0
            if (_feeSeed + _discountSeed < 0) {
                feeCalculus = 0;
            } else {
                feeCalculus = uint24(_feeSeed + _discountSeed); // note: discount is negative
            }
            assertEq(applicationCoin.balanceOf(toUser), _amountSeed - (_amountSeed * feeCalculus) / 10000);
            assertEq(applicationCoin.balanceOf(targetAccount), (_amountSeed * feeCalculus) / 10000);
        } else {
            assertEq(applicationCoin.balanceOf(toUser), _amountSeed - (_amountSeed * uint24(_feeSeed)) / 10000);
            assertEq(applicationCoin.balanceOf(targetAccount), (_amountSeed * uint24(_feeSeed)) / 10000);
        }
    }

    /// test the token transfer volume rule in erc20
    function testTokenTransferVolumeRuleFuzzCoin(uint8 _addressIndex, uint8 _period, uint16 _maxPercent) public {
        if (_period == 0) _period = 1;
        if (_maxPercent < 100) _maxPercent = 100;
        if (_maxPercent > 9999) _maxPercent = 9999;
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        rich_user = addressList[0];
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addTransferVolumeRule(address(appManager), _maxPercent, _period, 0, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, _maxPercent);
        assertEq(rule.period, _period);
        assertEq(rule.startingTime, 0);
        /// load non admin users with game coin
        applicationCoin.mint(rich_user, 100_000);
        assertEq(applicationCoin.balanceOf(rich_user), 100_000);
        /// apply the rule
        applicationCoinHandler.setTokenTransferVolumeRuleId(_index);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// determine the maximum transfer amount
        uint256 maxSize = uint256(_maxPercent) * 10;
        /// make sure that transfer under the threshold works
        applicationCoin.transfer(user1, maxSize - 1);
        assertEq(applicationCoin.balanceOf(user1), maxSize - 1);
        /// now violate the rule and ensure revert
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user1, 1);
        assertEq(applicationCoin.balanceOf(user1), maxSize - 1);
        /// now move 1 block into the future and make sure it works
        vm.warp(block.timestamp + (uint256(_period) * 1 hours) + 1 minutes);
        applicationCoin.transfer(user1, 1);
        assertEq(applicationCoin.balanceOf(user1), maxSize);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user2, maxSize);
        assertEq(applicationCoin.balanceOf(user2), 0);
    }

    function testTotalSupplyVolatilityFuzz(uint8 _addressIndex, uint256 amount, uint16 volLimit) public {
        /// test params 
        vm.assume(volLimit < 9999 && volLimit > 0);
        if (volLimit < 100) volLimit = 100;
        vm.assume(amount < 9999 * (10**18)); 
        vm.warp(Blocktime); 
        uint8 rulePeriod = 24; /// 24 hours 
        uint8 startingTime = 12; /// start at noon 
        uint256 tokenSupply = 0; /// calls totalSupply() for the token
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        user1 = addressList[0];
        /// mint initial supply 
        uint256 initialSupply = 100_000 * (10**18);
        uint256 volume = uint256(volLimit) * 10;
        applicationCoin.mint(defaultAdmin, initialSupply); 
        /// create and activate rule 
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(address(appManager), volLimit, rulePeriod, startingTime, tokenSupply);
        applicationCoinHandler.setTotalSupplyVolatilityRuleId(_index);
        /// test mint 
        vm.stopPrank();
        vm.startPrank(user1); 
        if (user1 != defaultAdmin) {
            if (amount > initialSupply - volume) {
                vm.expectRevert(0x81af27fa); 
                applicationCoin.mint(user1, amount);
            }
        }
        // /// test burn 
        if (user1 != defaultAdmin) {
            if (amount > uint(applicationCoin.totalSupply()) - volume) {
                vm.expectRevert(0x81af27fa); 
                applicationCoin.burn(amount);
            }
        }

        /// reset the total supply 
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoin.burn(applicationCoin.totalSupply());
        applicationCoin.mint(defaultAdmin, initialSupply);
        vm.warp(Blocktime + 36 hours);

        vm.stopPrank();
        vm.startPrank(user1);
        uint256 transferAmount = uint256(volLimit) * (10 * (10**18)); 
        applicationCoin.mint(user1, (transferAmount - (1 * (10**18))));
        vm.expectRevert();
        applicationCoin.mint(user1, transferAmount);

        applicationCoin.transfer(defaultAdmin, applicationCoin.balanceOf(user1)); 

        /// test minimum volatility limits 
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoin.burn(applicationCoin.balanceOf(defaultAdmin));
        applicationCoin.mint(defaultAdmin, initialSupply);
        console.logUint(applicationCoin.totalSupply()); 
        vm.warp(Blocktime + 96 hours);
        uint16 volatilityLimit = 1; /// 0.01% 
        uint32 _ruleIndex = RuleDataFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(address(appManager), volatilityLimit, rulePeriod, startingTime, tokenSupply);
        applicationCoinHandler.setTotalSupplyVolatilityRuleId(_ruleIndex);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.mint(user1, 5 * (10 ** 18));
        applicationCoin.mint(user1, 4 * (10 ** 18));
        applicationCoin.mint(user1, 1 * (10 ** 18));
        vm.expectRevert();
        applicationCoin.mint(user1, 1_000_000_000_000_000); /// 0.0001 tokens 

        /// test above 100% volatility limits 
        applicationCoin.transfer(defaultAdmin, applicationCoin.balanceOf(user1));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoin.burn(applicationCoin.balanceOf(defaultAdmin));
        applicationCoin.mint(defaultAdmin, initialSupply);
        console.logUint(applicationCoin.totalSupply()); 
        vm.warp(Blocktime + 120 hours);
        uint16 newVolatilityLimit = 50000; /// 500%
        uint32 _newRuleIndex = RuleDataFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(address(appManager), newVolatilityLimit, rulePeriod, startingTime, tokenSupply);
        applicationCoinHandler.setTotalSupplyVolatilityRuleId(_newRuleIndex);
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