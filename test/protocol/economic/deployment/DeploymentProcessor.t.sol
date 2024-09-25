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
            user1 = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;// anvil address 2
            user2 = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;// anvil address 3
            ruleProcessor = RuleProcessorDiamond(payable(vm.envAddress("RULE_PROCESSOR_DIAMOND")));
            ruleProcessorDiamondAddress = vm.envAddress("RULE_PROCESSOR_DIAMOND");
            assertEq(ruleProcessorDiamondAddress, vm.envAddress("RULE_PROCESSOR_DIAMOND"));

            applicationAppManager = ApplicationAppManager(payable(vm.envAddress("APPLICATION_APP_MANAGER")));
            applicationNFT = UtilApplicationERC721(vm.envAddress("APPLICATION_ERC721_ADDRESS_1"));
            applicationNFTHandler = HandlerDiamond(payable(vm.envAddress("APPLICATION_ERC721_HANDLER")));
            applicationCoin = UtilApplicationERC20(vm.envAddress("APPLICATION_ERC20_ADDRESS"));
            oracleApproved = OracleApproved(vm.envAddress("APPLICATION_ORACLE_ALLOWED_ADDRESS"));
            oracleDenied = OracleDenied(vm.envAddress("APPLICATION_ORACLE_DENIED_ADDRESS"));
            // This block will run if any application addresses are 0x00 in .env file 
            // This allows for the rule processor tests to work when only the rule processor is deployed to a target chain 
            // Update DEPLOYMENT_OWNER, and RULE_PROCESSOR_DIAMOND in .env only to run tests with locally created App ecosystem
            if (address(applicationAppManager) == address(0x0) || 
                address(applicationNFT) == address(0x0) || 
                address(applicationCoin) == address(0x0)) {
                    // First reset the addresses back to anvil addresses
                    appAdministrator = address(0xDEAD);
                    ruleAdmin = address(0xACDC);
                    user1 = address(11);
                    user2 = address(22);
                    // Second deploy new application and tokens 
                    setUpAppManagerAndCreateTokensAndHandlers();
            }
            

            forkTest = true;
            testDeployments = true;
        } else {
            testDeployments = false;
        }
    }
}
