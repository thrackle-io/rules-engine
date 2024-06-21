// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/util/RuleCreation.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";
import "test/protocol/economic/RuleProcessorDiamondCommonTests.sol";

/**
 * @dev This test suite is for testing the deployed protocol via forking the desired network
 * The test will check if the addresses in the env are valid and then run the tests. If address is not added to the env these will be skkipped.
 * This test suite contains if checks that assume you have followed the deployment guide docs and have added an NFTTransferCounter and AccountBalanceByAccessLevel rule when testing forked contracts.
 */

contract RuleProcessorDiamondTest is Test, TestCommonFoundry, ERC721Util, RuleProcessorDiamondCommonTests {

    address ruleProcessorDiamondAddress;
    bool forkTest;

    function setUp() public {
        if (vm.envAddress("DEPLOYMENT_OWNER") != address(0x0)) {
            /// grab the deployed diamond addresses and set superAdmin and forkTest bool
            vm.warp(Blocktime);
            superAdmin = vm.envAddress("DEPLOYMENT_OWNER");
            appAdministrator = vm.envAddress("APP_ADMIN");
            ruleAdmin = vm.envAddress("LOCAL_RULE_ADMIN");
            user1 = vm.envAddress("ANVIL_ADDRESS_2");
            user2 = vm.envAddress("ANVIL_ADDRESS_3");
            applicationNFT = UtilApplicationERC721(vm.envAddress("APPLICATION_ERC721_ADDRESS_1"));
            applicationNFTHandler = HandlerDiamond(payable(vm.envAddress("APPLICATION_ERC721_HANDLER")));
            applicationCoin = UtilApplicationERC20(vm.envAddress("APPLICATION_ERC20_ADDRESS"));
            ruleProcessor = RuleProcessorDiamond(payable(vm.envAddress("DEPLOYMENT_RULE_PROCESSOR_DIAMOND")));
            ruleProcessorDiamondAddress = vm.envAddress("DEPLOYMENT_RULE_PROCESSOR_DIAMOND");
            oracleApproved = OracleApproved(vm.envAddress("APPLICATION_ORACLE_ALLOWED_ADDRESS"));
            oracleDenied = OracleDenied(vm.envAddress("APPLICATION_ORACLE_DENIED_ADDRESS"));
            assertEq(ruleProcessorDiamondAddress, vm.envAddress("DEPLOYMENT_RULE_PROCESSOR_DIAMOND"));
            applicationAppManager = ApplicationAppManager(payable(vm.envAddress("APPLICATION_APP_MANAGER")));
            forkTest = true;
            testDeployments = true;
        } else {
            testDeployments = false;
        }
    }
}
