// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";
import "test/client/token/ERC20/integration/ERC20CommonTests.t.sol";

contract ProtocolERC20MinTest is ERC20CommonTests {
    function setUp() public endWithStopPrank {
        setUpProcotolAndCreateERC20MinAndDiamondHandler();
        switchToAppAdministrator();
        minimalCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * ATTO);
        testCaseToken = minimalCoin;
        vm.warp(Blocktime);
    }
}
