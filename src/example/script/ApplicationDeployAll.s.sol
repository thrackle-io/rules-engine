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

/**
 * @title Application Deploy All Script
 * @dev This script will deploy all application contracts needed to test the protocol interactions.
 * @notice Deploys the application App Manager, AppManager, ERC20, ERC721, AMM and associated handlers, pricing and oracle contracts.
 */
contract ApplicationDeployAllScript is Script {
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationAMMHandler applicationAMMHandler;
    uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];
    uint128[7] yieldPerTimeUnitArray2 = [2, 120, 7_200, 172_800, 1_209_600, 5_184_000, 63_072_000];
    address[] applicationNFTAddresses;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        ApplicationAppManager applicationAppManager = new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), false);
        applicationCoinHandler = new ApplicationERC20Handler(vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), address(applicationAppManager), false);
        applicationAMMHandler = new ApplicationAMMHandler(address(applicationAppManager), vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"));
        applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), address(applicationAppManager));
        /// create two ERC20 tokens
        ApplicationERC20 coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager), address(applicationCoinHandler));
        ApplicationERC20 coin2 = new ApplicationERC20("Dracula Coin", "DRAC", address(applicationAppManager), address(applicationCoinHandler));
        /// create the AMM Linear Calculator
        ApplicationAMMCalcLinear applicationAMMCalcLinear = new ApplicationAMMCalcLinear();
        /// create the AMM Constant Product Calculator
        new ApplicationAMMCalcCP();
        /// create the AMM with Dracula and Frankenstein tokens
        ApplicationAMM amm = new ApplicationAMM(address(coin1), address(coin2), address(applicationAppManager), address(applicationAMMCalcLinear), address(applicationAMMHandler));
        new OracleAllowed();
        new OracleRestricted();
        /// create NFT
        ApplicationERC721 nft1 = new ApplicationERC721("Frankenstein", "FRANKPIC", address(applicationAppManager), address(applicationNFTHandler), vm.envString("APPLICATION_ERC721_URI_1"));
        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Frankenstein Coin", address(coin1));
        applicationAppManager.registerToken("Dracula Coin", address(coin2));
        applicationAppManager.registerToken("Frankenstein Picture", address(nft1));
        /// Register the AMM's with the application's app manager
        applicationAppManager.registerAMM(address(amm));
        /// Set the AMM treasury address account
        amm.setTreasuryAddress(vm.envAddress("AMM_TREASURY"));
        // register NFT with NFT Handler(for tagging purposes and application of NFT trade counters
        applicationNFTHandler.setERC721Address(address(nft1));
        /// Set the token's prices
        ApplicationERC721Pricing openOcean = new ApplicationERC721Pricing();
        ApplicationERC20Pricing exchange = new ApplicationERC20Pricing();
        exchange.setSingleTokenPrice(address(coin1), 1 * (10 ** 18));
        exchange.setSingleTokenPrice(address(coin2), 1 * (10 ** 18));
        openOcean.setNFTCollectionPrice(address(nft1), 5 * (10 ** 18));
        /// Link the pricing module to the Franks ApplicationERC20Handler
        applicationCoinHandler.setERC20PricingAddress(address(exchange));
        applicationCoinHandler.setNFTPricingAddress(address(openOcean));
        applicationNFTHandler.setERC20PricingAddress(address(exchange));
        applicationNFTHandler.setNFTPricingAddress(address(openOcean));
        /// Deploy ERC20 Staking and set reward rate
        ERC20Staking stakingContract = new ERC20Staking(address(coin2), address(coin1), address(applicationAppManager));
        stakingContract.updateMinStakeAllowed(1_000_000);
        stakingContract.updateRewardsPerMillStakedPerTimeUnit(yieldPerTimeUnitArray);
        /// Deploy ERC20 Auto Mint Staking and set reward rate
        ERC20AutoMintStaking autoMintStaking = new ERC20AutoMintStaking(address(coin2), address(coin1), address(applicationAppManager));
        autoMintStaking.updateMinStakeAllowed(1);
        autoMintStaking.updateRewardsPerMillStakedPerTimeUnit(yieldPerTimeUnitArray);
        applicationAppManager.registerStaking(address(autoMintStaking));
        /// Deploy ERC721 Staking and set reward rate
        uint128[7][] memory rewardsPerAddress = new uint128[7][](1);
        rewardsPerAddress[0] = yieldPerTimeUnitArray;
        applicationNFTAddresses = [address(nft1)];
        new ERC721Staking(address(coin2), applicationNFTAddresses, rewardsPerAddress, address(applicationAppManager));
        /// Deploy ERC721 Auto Mint Staking and set reward rate
        ERC721AutoMintStaking nftAutoMintStaking = new ERC721AutoMintStaking(address(coin2), applicationNFTAddresses, rewardsPerAddress, address(applicationAppManager));
        applicationAppManager.registerStaking(address(nftAutoMintStaking));
        /// register the coin treasury
        applicationAppManager.registerTreasury(vm.envAddress("FEE_TREASURY"));
        /// This is a new app manager used for upgrade testing
        new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), true);
        new ApplicationERC20Handler(vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), address(applicationAppManager), true);
        vm.stopBroadcast();
    }
}
