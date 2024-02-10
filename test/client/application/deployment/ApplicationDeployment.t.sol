// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

/**
 * @dev This test suite is for testing the deployed application.
 */
contract ApplicationDeploymentTest is Test, TestCommonFoundry {

    address appManagerAddress;
    bool forkTest;
    event LogAddress(address _address);

    function setUp() public {
        if(vm.envAddress("TEST_DEPLOY_APPLICATION_APP_MANAGER") != address(0x0)) {
            // Verify App Manager has been deployed
            superAdmin = vm.envAddress("QUORRA");
            applicationAppManager = ApplicationAppManager(vm.envAddress("TEST_DEPLOY_APPLICATION_APP_MANAGER"));
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_APP_MANAGER"), address(applicationAppManager));
            
            // Verify App Handler has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_APPLICATION_APPLICATION_HANDLER") != address(0x0));
            applicationHandler = ApplicationHandler(vm.envAddress("TEST_DEPLOY_APPLICATION_APPLICATION_HANDLER"));
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_APPLICATION_HANDLER"), address(applicationHandler));

            // Verify ERC20 has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_ADDRESS") != address(0x0));
            applicationCoin = ApplicationERC20(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_ADDRESS"));
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_ADDRESS"), address(applicationCoin));

            // Verify ERC20 Handler has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_HANDLER_ADDRESS") != address(0x0));
            applicationCoinHandler = _createERC20HandlerDiamond();
            emit LogAddress(address(applicationCoinHandler));
            ERC20HandlerMainFacet(address(applicationCoinHandler)).initialize(
                address(vm.envAddress("RULE_PROCESSOR_DIAMOND")), 
                address(vm.envAddress("TEST_DEPLOY_APPLICATION_APP_MANAGER")), 
                vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_HANDLER_ADDRESS")
            );
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_HANDLER_ADDRESS"), address(applicationCoinHandler));

            // Verify the second ERC20 has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_ADDRESS_2") != address(0x0));
            applicationCoin2 = ApplicationERC20(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_ADDRESS_2"));
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_ADDRESS_2"), address(applicationCoin2));

            // Verify the second ERC20 Handler has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_HANDLER_ADDRESS_2") != address(0x0));
            applicationCoinHandler2 = _createERC20HandlerDiamond();
            emit LogAddress(address(applicationCoinHandler2));
            ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(
                address(vm.envAddress("RULE_PROCESSOR_DIAMOND")), 
                address(vm.envAddress("TEST_DEPLOY_APPLICATION_APP_MANAGER")), 
                vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_HANDLER_ADDRESS")
            );
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC20_HANDLER_ADDRESS_2"), address(applicationCoinHandler2));

            // Verify the second ERC721 has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC721_ADDRESS_1") != address(0x0));
            applicationNFT = ApplicationERC721(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC721_ADDRESS_1"));
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC721_ADDRESS_1"), address(applicationNFT));

            // Verify the ERC721 has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC721_HANDLER") != address(0x0));
            applicationNFTHandler = _createERC721HandlerDiamond();
            emit LogAddress(address(applicationNFTHandler));
            ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(
                address(vm.envAddress("RULE_PROCESSOR_DIAMOND")), 
                address(vm.envAddress("TEST_DEPLOY_APPLICATION_APP_MANAGER")), 
                vm.envAddress("TEST_DEPLOY_APPLICATION_ERC721_HANDLER")
            );
            assertEq(vm.envAddress("TEST_DEPLOY_APPLICATION_ERC721_HANDLER"), address(applicationNFTHandler));

            // Verify the ERC20 Pricing Contract has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_ERC20_PRICING_CONTRACT") != address(0x0));
            erc20Pricer = ApplicationERC20Pricing(vm.envAddress("TEST_DEPLOY_ERC20_PRICING_CONTRACT"));
            assertEq(vm.envAddress("TEST_DEPLOY_ERC20_PRICING_CONTRACT"), address(erc20Pricer));

            // Verify the ERC721 Pricing Contract has been deployed
            assertTrue(vm.envAddress("TEST_DEPLOY_ERC721_PRICING_CONTRACT") != address(0x0));
            erc721Pricer = ApplicationERC721Pricing(vm.envAddress("TEST_DEPLOY_ERC721_PRICING_CONTRACT"));
            assertEq(vm.envAddress("TEST_DEPLOY_ERC721_PRICING_CONTRACT"), address(erc721Pricer));

            forkTest = true;
        } else {
            vm.warp(Blocktime);
            vm.startPrank(appAdministrator);
            setUpProcotolAndCreateERC20AndDiamondHandler();
            switchToAppAdministrator();

            applicationCoin2 = _createERC20("DRACULA", "DRK", applicationAppManager);
            applicationCoinHandler2 = _createERC20HandlerDiamond();
            ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoin2));
            applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
            /// register the token
            applicationAppManager.registerToken("Dracula Coin", address(applicationCoin2));
            applicationAppManager.registerTreasury(vm.envAddress("FEE_TREASURY"));
            applicationAppManager.addRuleAdministrator(vm.envAddress("QUORRA"));
            applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
            applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
            forkTest = false;
            vm.stopPrank();
        }
    }

    function testApplicationHandlerConnected() public {
            vm.stopPrank();
            vm.startPrank(superAdmin);
            assertEq(applicationAppManager.getHandlerAddress(), address(applicationHandler));
            assertEq(applicationHandler.appManagerAddress(), address(applicationAppManager));
            vm.stopPrank();
    }

    function testERC20HandlerConnections() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        assertEq(applicationCoin.getHandlerAddress(), address(applicationCoinHandler));
        assertEq(applicationCoin2.getHandlerAddress(), address(applicationCoinHandler2));
        assertEq(ERC173Facet(address(applicationCoinHandler)).owner(), address(applicationCoin));
        assertEq(ERC173Facet(address(applicationCoinHandler2)).owner(), address(applicationCoin2));
        assertEq(applicationCoin.getAppManagerAddress(), address(applicationAppManager));
        assertEq(applicationCoin2.getAppManagerAddress(), address(applicationAppManager));
        assertTrue(applicationAppManager.isRegisteredHandler(address(applicationCoinHandler)));
        assertTrue(applicationAppManager.isRegisteredHandler(address(applicationCoinHandler2)));
        vm.stopPrank();
    }

    function testERC721HandlerConnections() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        assertEq(applicationNFT.getAppManagerAddress(), address(applicationAppManager));
        assertEq(applicationNFT.getHandlerAddress(), address(applicationNFTHandler));
        assertTrue(applicationAppManager.isRegisteredHandler(address(applicationNFTHandler)));
        vm.stopPrank();
    }

    function testVerifyTokensRegistered() public {
        if(vm.envAddress("TEST_DEPLOY_APPLICATION_APP_MANAGER") != address(0x0)) {
            assertEq(applicationAppManager.getTokenID(address(applicationCoin)), "Frankenstein Coin");
            assertEq(applicationAppManager.getTokenID(address(applicationCoin2)), "Dracula Coin");
            assertEq(applicationAppManager.getTokenID(address(applicationNFT)), "Frankenstein Picture");
        } else {
            assertEq(applicationAppManager.getTokenID(address(applicationCoin)), "FRANK");
            assertEq(applicationAppManager.getTokenID(address(applicationCoin2)), "Dracula Coin");
            assertEq(applicationAppManager.getTokenID(address(applicationNFT)), "FRANKENSTEIN");
        }

        console.log(applicationHandler.erc20PricingAddress());
    }

    function testVerifyPricingContractsConnectedToHandler() public {
        assertEq(applicationHandler.erc20PricingAddress(), address(erc20Pricer));
        assertEq(applicationHandler.nftPricingAddress(), address(erc721Pricer));
    }

    function testVerifyRuleAdmin() public {
        assertTrue(applicationAppManager.isRuleAdministrator(vm.envAddress("QUORRA")));
    }

    function testVerifyTreasury() public {
        assertTrue(applicationAppManager.isTreasury(vm.envAddress("FEE_TREASURY")));
    }
}