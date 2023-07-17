// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC20.sol";
import "../src/example/liquidity/ApplicationAMM.sol";
import "../src/example/liquidity/ApplicationAMMCalcLinear.sol";
import "../src/example/liquidity/ApplicationAMMCalcCP.sol";
import "../src/example/liquidity/ApplicationAMMCalcSample01.sol";
import "../src/example/liquidity/ApplicationAMMDynamicCalc.sol";
import "src/example/liquidity/DynamicCalc.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/example/ApplicationERC20Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";
import {ApplicationAMMHandler} from "../src/example/liquidity/ApplicationAMMHandler.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {FeeRuleDataFacet} from "../src/economic/ruleStorage/FeeRuleDataFacet.sol";
import {ApplicationAMMHandlerMod} from "./helpers/ApplicationAMMHandlerMod.sol";

/**
 * @title Test all AMM related functions
 * @notice This tests every function related to the AMM including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMDynamicTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationAMMHandler handler;
    ApplicationAMM applicationAMM;
    ApplicationAMMCalcLinear applicationAMMLinearCalc;
    ApplicationAMMCalcCP applicationAMMCPCalc;
    ApplicationAMMCalcSample01 applicationAMMSample01Calc;
    ApplicationAMMDynamicCalc applicationAMMDynamicCalc;
    ApplicationERC20 applicationCoin;
    ApplicationERC20 applicationCoin2;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationAMMHandler applicationAMMHandler;
    ApplicationAppManager appManager;
    ApplicationHandler public applicationHandler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;
    ApplicationAMMHandlerMod newAssetHandler;

    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address rich_user = address(44);
    address treasuryAddress = address(55);
    address[] badBoys;
    address[] goodBoys;
    uint256 Blocktime = 1675723152;
    address[] addresses = [user1, user2, user3, rich_user];
    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

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
        appManager.addAccessTier(AccessTier);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));

        /// Create two tokens and mint a bunch
        applicationCoin = new ApplicationERC20("application", "GMC", address(appManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), false);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationCoin.mint(defaultAdmin, 1_000_000_000_000 * (10 ** 18));
        applicationCoin2 = new ApplicationERC20("application2", "GMC2", address(appManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), false);
        applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
        applicationCoin2.mint(defaultAdmin, 1_000_000_000_000 * (10 ** 18));

        /// Create calculators for the AMM
        applicationAMMLinearCalc = new ApplicationAMMCalcLinear();
        applicationAMMCPCalc = new ApplicationAMMCalcCP();
        applicationAMMSample01Calc = new ApplicationAMMCalcSample01();
        applicationAMMDynamicCalc = new ApplicationAMMDynamicCalc();
        /// Set up the AMM
        handler = new ApplicationAMMHandler(address(appManager), address(ruleProcessor));
        applicationAMM = new ApplicationAMM(address(applicationCoin), address(applicationCoin2), address(appManager), address(applicationAMMLinearCalc));
        applicationAMM.connectHandlerToAMM(address(handler));
        applicationAMMHandler = ApplicationAMMHandler(applicationAMM.getHandlerAddress());
        /// Register AMM
        appManager.registerAMM(address(applicationAMM));
        /// set the treasury address
        applicationAMM.setTreasuryAddress(treasuryAddress);
        appManager.addAppAdministrator(treasuryAddress);

        /// set the erc20 pricer
        erc20Pricer = new ApplicationERC20Pricing();
        /// connect ERC20 pricer to applicationCoinHandler
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        applicationCoinHandler2.setERC20PricingAddress(address(erc20Pricer));
        vm.warp(Blocktime);

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }

    /// Test dynamic swaps
    function testDynamicToken0for1() public {
        /// change amm to dynamic calc
        applicationAMM.setCalculatorAddress(address(applicationAMMDynamicCalc));
        /// add the dynamic equation to the calculator
        applicationAMMDynamicCalc.setEquation0for1(buildConstantProductEquation0for1());
        // Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000000);
        applicationCoin2.approve(address(applicationAMM), 1000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000);
        assertEq(applicationAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 100000);
        applicationAMM.swap(address(applicationCoin), 100000);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve0(), 1100000);
        assertEq(applicationAMM.getReserve1(), 909091);
        // vm.stopPrank();
        // vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 90909);
    }

    /// Test constant product swaps
    function testSwapCPToken0Dyn() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMCPCalc));
        // Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000000);
        applicationCoin2.approve(address(applicationAMM), 1000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000);
        assertEq(applicationAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 100000);
        applicationAMM.swap(address(applicationCoin), 100000);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve0(), 1100000);
        assertEq(applicationAMM.getReserve1(), 909091);
        // vm.stopPrank();
        // vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 90909);
    }

    function buildConstantProductEquation0for1() internal pure returns (DynamicCalc.Equation memory eq) {
        int256[] memory _x = new int256[](3);
        int256[] memory _y = new int256[](3);
        DynamicCalc.Variables[] memory _xSubstitution = new DynamicCalc.Variables[](3);
        uint8[] memory _xSubstitutionStoragePosition = new uint8[](3);
        DynamicCalc.Variables[] memory _ySubstitution = new DynamicCalc.Variables[](3);
        uint8[] memory _ySubstitutionStoragePosition = new uint8[](3);
        DynamicCalc.Operator[] memory _operator = new DynamicCalc.Operator[](3);
        bool[] memory _holdResult = new bool[](3);
        // Constant product equation0 should be (_amount0 * _reserve1) / (_reserve0 + _amount0)

        // 1. _amount0 * _reserve1, the result will be stored in slot 0
        {
            _x[0] = 0;
            _y[0] = 0;
            _xSubstitution[0] = DynamicCalc.Variables.AMOUNT0;
            _xSubstitutionStoragePosition[0] = 0;
            _ySubstitution[0] = DynamicCalc.Variables.RESERVE1;
            _ySubstitutionStoragePosition[0] = 0;
            _operator[0] = DynamicCalc.Operator.MULTIPLY;
            _holdResult[0] = true;
        }
        // 2. _reserve0 + _amount0, the result will be stored in slot  1
        {
            _x[1] = 0;
            _y[1] = 0;
            _xSubstitution[1] = DynamicCalc.Variables.RESERVE0;
            _xSubstitutionStoragePosition[1] = 0;
            _ySubstitution[1] = DynamicCalc.Variables.AMOUNT0;
            _ySubstitutionStoragePosition[1] = 0;
            _operator[1] = DynamicCalc.Operator.ADD;
            _holdResult[1] = true;
        }
        // 3. result0/result1
        {
            _x[2] = 0;
            _y[2] = 0;
            _xSubstitution[2] = DynamicCalc.Variables.SAVEDRESULT;
            _xSubstitutionStoragePosition[2] = 0;
            _ySubstitution[2] = DynamicCalc.Variables.SAVEDRESULT;
            _ySubstitutionStoragePosition[2] = 1;
            _operator[2] = DynamicCalc.Operator.DIVIDE;
            _holdResult[2] = false;
        }

        // put it into the struct and return it
        return DynamicCalc.Equation(_x, _y, _xSubstitution, _xSubstitutionStoragePosition, _ySubstitution, _ySubstitutionStoragePosition, _operator, _holdResult);
    }

    function buildConstantProductEquation1for0() internal pure returns (DynamicCalc.Equation memory eq) {
        int256[] memory _x = new int256[](3);
        int256[] memory _y = new int256[](3);
        DynamicCalc.Variables[] memory _xSubstitution = new DynamicCalc.Variables[](3);
        uint8[] memory _xSubstitutionStoragePosition = new uint8[](3);
        DynamicCalc.Variables[] memory _ySubstitution = new DynamicCalc.Variables[](3);
        uint8[] memory _ySubstitutionStoragePosition = new uint8[](3);
        DynamicCalc.Operator[] memory _operator = new DynamicCalc.Operator[](3);
        bool[] memory _holdResult = new bool[](3);
        // Constant product equation0 should be (_amount1 * _reserve0) / (_reserve1 + _amount1)

        // 1. amount1 * reserve0, the result will be stored in slot 0
        {
            _x[0] = 0;
            _y[0] = 0;
            _xSubstitution[0] = DynamicCalc.Variables.AMOUNT1;
            _xSubstitutionStoragePosition[0] = 0;
            _ySubstitution[0] = DynamicCalc.Variables.RESERVE0;
            _ySubstitutionStoragePosition[0] = 0;
            _operator[0] = DynamicCalc.Operator.MULTIPLY;
            _holdResult[0] = true;
        }
        // 2. _reserve1 + _amount1, the result will be stored in slot  1
        {
            _x[1] = 0;
            _y[1] = 0;
            _xSubstitution[1] = DynamicCalc.Variables.RESERVE1;
            _xSubstitutionStoragePosition[1] = 0;
            _ySubstitution[1] = DynamicCalc.Variables.AMOUNT1;
            _ySubstitutionStoragePosition[1] = 0;
            _operator[1] = DynamicCalc.Operator.ADD;
            _holdResult[1] = true;
        }
        // 3. result0/result1
        {
            _x[2] = 0;
            _y[2] = 0;
            _xSubstitution[2] = DynamicCalc.Variables.SAVEDRESULT;
            _xSubstitutionStoragePosition[2] = 0;
            _ySubstitution[2] = DynamicCalc.Variables.SAVEDRESULT;
            _ySubstitutionStoragePosition[2] = 1;
            _operator[2] = DynamicCalc.Operator.DIVIDE;
            _holdResult[2] = false;
        }

        // put it into the struct and return it
        return DynamicCalc.Equation(_x, _y, _xSubstitution, _xSubstitutionStoragePosition, _ySubstitution, _ySubstitutionStoragePosition, _operator, _holdResult);
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
}
