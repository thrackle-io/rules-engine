// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC20/integration/ERC20CommonTests.t.sol";

/**
 * @dev This test suite is for testing a deployed application ERC20 token.
 */
contract ApplicationERC20TokenDeploymentTest is Test, TestCommonFoundry, ERC20CommonTests {
    address appManagerAddress;
    bool forkTest;
    event LogAddress(address _address);

    function setUp() public {
        if (vm.envAddress("DEPLOYMENT_OWNER") != address(0x0)) {
            // Verify App Manager has been deployed
            superAdmin = vm.envAddress("DEPLOYMENT_OWNER");
            appAdministrator = vm.envAddress("APP_ADMIN");
            ruleProcessor = RuleProcessorDiamond(payable(vm.envAddress("DEPLOYMENT_RULE_PROCESSOR_DIAMOND")));
            ruleAdmin = vm.envAddress("LOCAL_RULE_ADMIN");
            feeSink = vm.envAddress("ANVIL_ADDRESS_4");
            applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
            assertEq(vm.envAddress("APPLICATION_APP_MANAGER"), address(applicationAppManager));
            // Verify App Handler has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_APPLICATION_HANDLER") != address(0x0)
            );
            applicationHandler = ApplicationHandler(
                vm.envAddress("APPLICATION_APPLICATION_HANDLER")
            );
            assertEq(
                vm.envAddress("APPLICATION_APPLICATION_HANDLER"),
                address(applicationHandler)
            );
            // Verify ERC20 has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_ERC20_ADDRESS") != address(0x0)
            );
            applicationCoin = UtilApplicationERC20(
                vm.envAddress("APPLICATION_ERC20_ADDRESS")
            );
            assertEq(
                vm.envAddress("APPLICATION_ERC20_ADDRESS"),
                address(applicationCoin)
            );

            // Verify ERC20 Handler has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS") !=
                    address(0x0)
            );
            applicationCoinHandler = HandlerDiamond(
                payable(vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS"))
            );
            assertEq(
                vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS"),
                address(applicationCoinHandler)
            );

            // Verify Second ERC20 has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_ERC20_ADDRESS_2") != address(0x0)
            );
            applicationCoin2 = UtilApplicationERC20(
                vm.envAddress("APPLICATION_ERC20_ADDRESS_2")
            );
            assertEq(
                vm.envAddress("APPLICATION_ERC20_ADDRESS_2"),
                address(applicationCoin2)
            );

            // Verify Second ERC20 Handler has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS_2") !=
                    address(0x0)
            );
            applicationCoinHandler2 = HandlerDiamond(
                payable(vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS_2"))
            );
            assertEq(
                vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS_2"),
                address(applicationCoinHandler2)
            );

            // Verify the second ERC721 has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_ERC721_ADDRESS_1") != address(0x0)
            );
            applicationNFT = UtilApplicationERC721(
                vm.envAddress("APPLICATION_ERC721_ADDRESS_1")
            );
            assertEq(
                vm.envAddress("APPLICATION_ERC721_ADDRESS_1"),
                address(applicationNFT)
            );

            // Verify the ERC721 has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_ERC721_HANDLER") != address(0x0)
            );
            applicationNFTHandler = HandlerDiamond(
                payable(vm.envAddress("APPLICATION_ERC721_HANDLER"))
            );
            assertEq(
                vm.envAddress("APPLICATION_ERC721_HANDLER"),
                address(applicationNFTHandler)
            );

            // Verify the ERC20 Pricing Contract has been deployed
            assertTrue(vm.envAddress("ERC20_PRICING_CONTRACT") != address(0x0));
            erc20Pricer = ApplicationERC20Pricing(
                vm.envAddress("ERC20_PRICING_CONTRACT")
            );
            assertEq(
                vm.envAddress("ERC20_PRICING_CONTRACT"),
                address(erc20Pricer)
            );

            // Verify the ERC721 Pricing Contract has been deployed
            assertTrue(
                vm.envAddress("ERC721_PRICING_CONTRACT") != address(0x0)
            );
            erc721Pricer = ApplicationERC721Pricing(
                vm.envAddress("ERC721_PRICING_CONTRACT")
            );
            assertEq(
                vm.envAddress("ERC721_PRICING_CONTRACT"),
                address(erc721Pricer)
            );

            // Verify the Oracle Contracts have been deployed 
            assertTrue(
                vm.envAddress("APPLICATION_ORACLE_ALLOWED_ADDRESS") != address(0x0)
            );
            oracleApproved= OracleApproved(
                vm.envAddress("APPLICATION_ORACLE_ALLOWED_ADDRESS")
            );
            assertEq(
                vm.envAddress("APPLICATION_ORACLE_ALLOWED_ADDRESS"),
                address(oracleApproved)
            );

            assertTrue(
                vm.envAddress("APPLICATION_ORACLE_DENIED_ADDRESS") != address(0x0)
            );
            oracleDenied= OracleDenied(
                vm.envAddress("APPLICATION_ORACLE_DENIED_ADDRESS")
            );
            assertEq(
                vm.envAddress("APPLICATION_ORACLE_DENIED_ADDRESS"),
                address(oracleDenied)
            );

            applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * ATTO);
            testCaseToken = applicationCoin;

            Blocktime = uint64(block.timestamp); 

            switchToAppAdministrator();
    
            HandlerVersionFacet(address(applicationCoinHandler)).updateVersion("2.1.0");
    
            forkTest = true;
            testDeployments = true;
        } else {
            testDeployments = false;
        }
    }
}