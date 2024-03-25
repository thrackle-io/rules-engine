// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";
import "test/client/token/ERC721/integration/ERC721CommonTests.t.sol";

contract ApplicationERC721Test is ERC721CommonTests {

    function setUp() public {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        testCaseNFT = applicationNFT;
    }
}