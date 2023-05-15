// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/example/ApplicationERC20Handler.sol";
import {ApplicationERC721Handler} from "src/example/ApplicationERC721Handler.sol";
import "src/example/ApplicationERC20.sol";
import "src/example/ApplicationERC721.sol";
import "src/example/liquidity/ApplicationAMMCalcLinear.sol";
import "src/example/liquidity/ApplicationAMMCalcCP.sol";
import "src/example/liquidity/ApplicationAMM.sol";
import "src/example/liquidity/ApplicationAMMHandler.sol";
import {ApplicationAppManager} from "src/example/ApplicationAppManager.sol";
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
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationAMMHandler applicationAMMHandler;
    uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];
    uint128[7] yieldPerTimeUnitArray2 = [2, 120, 7_200, 172_800, 1_209_600, 5_184_000, 63_072_000];
    address[] applicationNFTAddresses;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        ApplicationAppManager applicationAppManager = new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", false);
        applicationCoinHandler = new ApplicationERC20Handler(vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), address(applicationAppManager), false);

        applicationAMMHandler = new ApplicationAMMHandler(address(applicationAppManager), vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"));
        applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), address(applicationAppManager));
        /// create two ERC20 tokens
        ApplicationERC20 coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager), address(applicationCoinHandler));
        ApplicationERC20 coin2 = new ApplicationERC20("Dracula Coin", "DRAC", address(applicationAppManager), address(applicationCoinHandler));
        /// create NFT
        ApplicationERC721 nft1 = new ApplicationERC721("Frankenstein", "FRANKPIC", address(applicationAppManager), address(applicationNFTHandler), vm.envString("APPLICATION_ERC721_URI_1"));
        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Frankenstein Coin", address(coin1));
        applicationAppManager.registerToken("Dracula Coin", address(coin2));
        applicationAppManager.registerToken("Frankenstein Picture", address(nft1));
        applicationNFTHandler.setERC721Address(address(nft1));

        vm.stopBroadcast();
    }
}
