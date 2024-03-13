// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";

/**
 * @dev This test suite is for testing the deployed application.
 */
contract ApplicationDeploymentTest is Test, TestCommonFoundry {
    address appManagerAddress;
    bool forkTest;
    event LogAddress(address _address);

    function setUp() public {
        if (vm.envAddress("DEPLOYMENT_OWNER") != address(0x0)) {
            // Verify App Manager has been deployed
            superAdmin = vm.envAddress("LOCAL_DEPLOYMENT_OWNER");
            appAdministrator = vm.envAddress("APP_ADMIN_01");
            applicationAppManager = ApplicationAppManager(
                vm.envAddress("APPLICATION_APP_MANAGER")
            );
            assertEq(
                vm.envAddress("APPLICATION_APP_MANAGER"),
                address(applicationAppManager)
            );

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
            applicationCoin = ApplicationERC20(
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

            // Verify the second ERC20 has been deployed
            assertTrue(
                vm.envAddress("APPLICATION_ERC20_ADDRESS_2") != address(0x0)
            );
            applicationCoin2 = ApplicationERC20(
                vm.envAddress("APPLICATION_ERC20_ADDRESS_2")
            );
            assertEq(
                vm.envAddress("APPLICATION_ERC20_ADDRESS_2"),
                address(applicationCoin2)
            );

            // Verify the second ERC20 Handler has been deployed
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
            applicationNFT = ApplicationERC721(
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

            forkTest = true;
        } else {
            vm.warp(Blocktime);
            setUpProcotolAndCreateERC20AndDiamondHandler();
            switchToAppAdministrator();

            applicationCoin2 = _createERC20(
                "DRACULA",
                "DRK",
                applicationAppManager
            );
            applicationCoinHandler2 = _createERC20HandlerDiamond();
            ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(
                address(ruleProcessor),
                address(applicationAppManager),
                address(applicationCoin2)
            );
            applicationCoin2.connectHandlerToToken(
                address(applicationCoinHandler2)
            );
            /// register the token
            applicationAppManager.registerToken(
                "Dracula Coin",
                address(applicationCoin2)
            );
            applicationAppManager.registerTreasury(
                vm.envAddress("FEE_TREASURY")
            );
            applicationAppManager.addRuleAdministrator(vm.envAddress("QUORRA"));
            applicationCoin.connectHandlerToToken(
                address(applicationCoinHandler)
            );
            applicationCoin2.connectHandlerToToken(
                address(applicationCoinHandler2)
            );
            forkTest = false;
            vm.stopPrank();
        }
    }

    function testApplication_ApplicationDeployment_ApplicationHandlerConnected()
        public
        endWithStopPrank
    {
        assertEq(
            applicationAppManager.getHandlerAddress(),
            address(applicationHandler)
        );
        assertEq(
            applicationHandler.appManagerAddress(),
            address(applicationAppManager)
        );
    }

    function testApplication_ApplicationDeployment_ERC20HandlerConnections()
        public
        endWithStopPrank
    {
        switchToSuperAdmin();
        assertEq(
            applicationCoin.getHandlerAddress(),
            address(applicationCoinHandler)
        );
        assertEq(
            ERC173Facet(address(applicationCoinHandler)).owner(),
            address(applicationCoin)
        );
        assertEq(
            applicationCoin.getAppManagerAddress(),
            address(applicationAppManager)
        );
        assertTrue(
            applicationAppManager.isRegisteredHandler(
                address(applicationCoinHandler)
            )
        );
    }

    function testApplication_ApplicationDeployment_ERC721HandlerConnections()
        public
        endWithStopPrank
    {
        switchToSuperAdmin();
        assertEq(
            applicationNFT.getAppManagerAddress(),
            address(applicationAppManager)
        );
        assertEq(
            applicationNFT.getHandlerAddress(),
            address(applicationNFTHandler)
        );
        assertTrue(
            applicationAppManager.isRegisteredHandler(
                address(applicationNFTHandler)
            )
        );
    }

    function testApplication_ApplicationDeployment_VerifyTokensRegistered()
        public
        view
    {
        if (vm.envAddress("DEPLOYMENT_OWNER") != address(0x0)) {
            assertEq(
                applicationAppManager.getTokenID(address(applicationCoin)),
                "Frankenstein Coin"
            );
            assertEq(
                applicationAppManager.getTokenID(address(applicationNFT)),
                "Clyde Picture"
            );
        } else {
            assertEq(
                applicationAppManager.getTokenID(address(applicationCoin)),
                "FRANK"
            );
            assertEq(
                applicationAppManager.getTokenID(address(applicationNFT)),
                "FRANKENSTEIN"
            );
        }

        console.log(applicationHandler.erc20PricingAddress());
    }

    function testApplication_ApplicationDeployment_VerifyPricingContractsConnectedToHandler()
        public
        view
    {
        assertEq(
            applicationHandler.erc20PricingAddress(),
            address(erc20Pricer)
        );
        assertEq(applicationHandler.nftPricingAddress(), address(erc721Pricer));
    }

    function testApplication_ApplicationDeployment_VerifyRuleAdmin()
        public
        view
    {
        if (vm.envAddress("DEPLOYMENT_OWNER") != address(0x0)) {
            assertTrue(
                applicationAppManager.isRuleAdministrator(
                    vm.envAddress("LOCAL_RULE_ADMIN")
                )
            );
        } else {
            assertTrue(
                applicationAppManager.isRuleAdministrator(
                    vm.envAddress("QUORRA")
                )
            );
        }
    }

    function testApplication_ApplicationDeployment_VerifyTreasury()
        public
        view
    {
        assertTrue(
            applicationAppManager.isTreasury(vm.envAddress("FEE_TREASURY"))
        );
    }
}
