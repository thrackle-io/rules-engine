// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// tests the shared functionality of the erc20 and erc721 combined together

contract ProtocolApplicationHandlerTests is TestCommonFoundry {

    function setUp() external {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndDiamondHandler();
    }

    // note: make a test for get acc total valuation 
    function test_getAccTotalValuation_SlamWithTokensFindGasBreakageValueLimitLow() public {
        uint loops = vm.envOr("SLAM_TOKEN_LOOPS", uint(20));
        for (uint i = 0; i < loops; ++i) {
            switchToAppAdministrator();
            (ApplicationERC721 TestNFTCoin, ) = deployAndSetupERC721(string.concat("TestNFT", Strings.toString(i)), string.concat("TESTNFT", Strings.toString(i)));
            switchToAppAdministrator();
            for (uint j = 0; j < 100; ++j) {
                ProtocolERC721(address(TestNFTCoin)).safeMint(appAdministrator);
            }
            erc721Pricer.setNFTCollectionPrice(address(TestNFTCoin), 10 * ATTO);
            (ApplicationERC20 TestCoin, ) = deployAndSetupERC20(string.concat("TestERC", Strings.toString(i)), string.concat("TEST", Strings.toString(i)));
            ProtocolERC20(address(TestCoin)).mint(appAdministrator, 100);
        }

        uint gasBegin = gasleft();
        uint valuation = applicationHandler.getAccTotalValuation(appAdministrator, 0);
        uint gasEnd = gasleft();
        // console2.log("gas: ", gasBegin - gasEnd);
        // console2.log("valuation: ", valuation);
        assertEq(valuation, loops * 100 * 100 * 1e17);
        assertLt(gasBegin - gasEnd, 15000000); // assert that it is less than the gas limit
    }
}