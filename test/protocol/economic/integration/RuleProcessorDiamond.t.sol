// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/util/RuleCreation.sol";
import "test/protocol/economic/RuleProcessorDiamondCommonTests.sol";

contract RuleProcessorDiamondTest is Test, TestCommonFoundry, RuleCreation, RuleProcessorDiamondCommonTests {

    function setUp() public {
        setUpProcotolAndCreateERC20AndDiamondHandler();
        testDeployments = true;
        vm.warp(Blocktime);
    }
}
