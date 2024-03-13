// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/application/ApplicationCommonTests.t.sol";

// contract AppManagerBaseTest is TestCommonFoundry, ApplicationCommonTests {
    contract ApplicationDeploymentTest is Test, TestCommonFoundry, ApplicationCommonTests {
    
    function setUp() public {
        setUpProcotolAndCreateERC20AndDiamondHandler();
        vm.warp(Blocktime); // set block.timestamp
        testDeployments = true;
    }
}
