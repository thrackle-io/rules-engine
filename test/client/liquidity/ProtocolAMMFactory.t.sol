// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/client/liquidity/ProtocolERC20AMM.sol";
import "src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/client/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/client/liquidity/calculators/ProtocolAMMCalcCP.sol";
import {ProtocolAMMCalcLinear} from "src/client/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/util/TestCommonFoundry.sol";
import {ConstantRatio} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";

/**
 * @title Test all AMM Calculator Factory related functions
 * @notice This tests every function related to the AMM Calculator Factory including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMFactoryTest is TestCommonFoundry {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        protocolAMMFactory = createProtocolAMMFactory();
        switchToAppAdministrator();
    }

    function testCreateAMM() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        ProtocolERC20AMM protocolAMM = ProtocolERC20AMM(protocolAMMFactory.createERC20AMM(address(applicationCoin), address(applicationCoin2), address(applicationAppManager), protocolAMMCalculatorFactory.createConstantProduct(address(applicationAppManager))));
        ProtocolAMMCalcCP calc = ProtocolAMMCalcCP(protocolAMM.calculatorAddress());
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }

    function testCreateAMMLinear() public {
        LinearInput memory curve = LinearInput( 6000, 15 * 10 ** 17);
        ProtocolERC20AMM protocolAMM = ProtocolERC20AMM(protocolAMMFactory.createLinearAMM(address(applicationCoin), address(applicationCoin2),curve,  address(applicationAppManager)));
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(protocolAMM.calculatorAddress());
        (uint256 m_num, uint256 m_den, uint256 b_num, uint256 b_den) = calc.curve();
        b_num;
        b_den;
        m_den;
        assertEq(m_num, 6000);
    }

    function testCreateAMMConstant() public {
        ConstantRatio memory cr = ConstantRatio(1, 2);
        ProtocolERC20AMM protocolAMM = ProtocolERC20AMM(protocolAMMFactory.createConstantAMM(address(applicationCoin), address(applicationCoin2), cr,  address(applicationAppManager)));
        ProtocolAMMCalcConst calc = ProtocolAMMCalcConst(protocolAMM.calculatorAddress());
        (uint32 x, uint32 y )= calc.constRatio();
        assertEq(x,1);
        assertEq(y,2);
    }

    function testCreateAMMConstantProduct() public {
        ProtocolERC20AMM protocolAMM = ProtocolERC20AMM(protocolAMMFactory.createConstantProductAMM(address(applicationCoin), address(applicationCoin2), address(applicationAppManager)));
        ProtocolAMMCalcCP calc = ProtocolAMMCalcCP(protocolAMM.calculatorAddress());
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }
}