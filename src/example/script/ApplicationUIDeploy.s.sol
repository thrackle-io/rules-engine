// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/ApplicationERC20Handler.sol";
import {ApplicationERC721Handler} from "src/example/ApplicationERC721Handler.sol";
import "src/example/ApplicationERC20.sol";
import {ApplicationERC721} from "src/example/ERC721/not-upgradeable/ApplicationERC721FreeMint.sol";
import "src/example/liquidity/ApplicationAMMCalcLinear.sol";
import "src/example/liquidity/ApplicationAMMCalcCP.sol";
import "src/example/liquidity/ApplicationAMM.sol";
import "src/example/liquidity/ApplicationAMMHandler.sol";
import {ApplicationAppManager} from "src/example/ApplicationAppManager.sol";
import "src/example/application/ApplicationHandler.sol";
import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";
import "src/example/staking/ERC20Staking.sol";
import "src/example/staking/ERC20AutoMintStaking.sol";
import "src/example/staking/ERC721Staking.sol";
import "src/example/staking/ERC721AutoMintStaking.sol";

//
// *******This deployment script is for UI testing only*************
// * @Dev this deployment script is for deploying the minimum application ecosystem for testing. It deploys:
// * AppManager, AppManager, Token Handlers, ERC20 tokens and an ERC721 token.

contract ApplicationUIDeployAllScript is Script {
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationERC20Handler applicationCoinHandler3;
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationAMMHandler applicationAMMHandler;
    uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];
    uint128[7] yieldPerTimeUnitArray2 = [2, 120, 7_200, 172_800, 1_209_600, 5_184_000, 63_072_000];
    address[] applicationNFTAddresses;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        ApplicationAppManager applicationAppManager = new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", false);
        ApplicationHandler applicationHandler = new ApplicationHandler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler));
        /// create ERC20 token 1
        ApplicationERC20 coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager));
        applicationCoinHandler = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin1), false);
        coin1.connectHandlerToToken(address(applicationCoinHandler));
        /// create ERC20 token 2
        ApplicationERC20 coin2 = new ApplicationERC20("Dracula Coin", "DRAC", address(applicationAppManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin2), false);
        coin2.connectHandlerToToken(address(applicationCoinHandler2));
        /// create NFT
        ApplicationERC721 nft1 = new ApplicationERC721("Frankenstein", "FRANKPIC", address(applicationAppManager), vm.envString("APPLICATION_ERC721_URI_1"));
        applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(nft1), false);
        nft1.connectHandlerToToken(address(applicationNFTHandler));
        applicationNFTHandler.setERC721Address(address(nft1));
        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Frankenstein Coin", address(coin1));
        applicationAppManager.registerToken("Dracula Coin", address(coin2));
        applicationCoinHandler3 = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin2), false);
        applicationAppManager.registerToken("Frankenstein Picture", address(nft1));
        applicationNFTHandler.setERC721Address(address(nft1));
        ///These are deployed to test fire events for indexer testing
        /// create the AMM with Dracula and Frankenstein tokens
        /// create the AMM Linear Calculator
        ApplicationAMMCalcLinear applicationAMMCalcLinear = new ApplicationAMMCalcLinear();
        ApplicationAMM amm = new ApplicationAMM(address(coin1), address(coin2), address(applicationAppManager), address(applicationAMMCalcLinear));
        applicationAMMHandler = new ApplicationAMMHandler(address(applicationAppManager), vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(amm));
        applicationCoinHandler3 = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin2), false);

        vm.stopBroadcast();
    }
}
