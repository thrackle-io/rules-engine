// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "./PredefinedRules.sol";
import "src/example/application/ApplicationAppManager.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";

/**
 * @title RuleProcessingInvariantCommon
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev Stores common variables/imports used for rule storage invariant tests
 */
abstract contract RuleProcessingInvariantCommon is TestCommonFoundry, PredefinedRules {
    function prepRuleProcessingInvariant() internal {
        switchToSuperAdmin();
        setUpProcotolAndCreateERC20AndDiamondHandler();
        vm.warp(Blocktime);
    }

    function prepareTradingRuleProcessingInvariant() internal returns (DummySingleTokenAMM amm, ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) {
        prepRuleProcessingInvariant();
        (amm, coinPricer, nftPricer) = setupAMMandPricers();
    }

    function setupAMMandPricers() internal returns (DummySingleTokenAMM amm, ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) {
        amm = new DummySingleTokenAMM();
        (coinPricer, nftPricer) = deployPricers();
    }

    function deployPricers() internal returns (ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) {
        coinPricer = _createERC20Pricing();
        nftPricer = _createERC721Pricing();
    }

    function deployAndSetNewApp(ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) internal returns (ApplicationAppManager testAppManager, ApplicationHandler testAppHandler) {
        switchToSuperAdmin();
        testAppManager = _createAppManager();
        testAppManager.addAppAdministrator(appAdministrator);
        switchToAppAdministrator(); // app admin should set up everything after creation of the appManager
        testAppManager.addRuleAdministrator(ruleAdmin); //add Rule admin
        testAppManager.setNewApplicationHandlerAddress(address(_createAppHandler(ruleProcessor, testAppManager)));
        testAppHandler = ApplicationHandler(applicationAppManager.getHandlerAddress());
        switchToRuleAdmin();
        testAppHandler.setNFTPricingAddress(address(nftPricer));
        testAppHandler.setERC20PricingAddress(address(coinPricer));
    }

    function deployFullApplicationWithCoin(
        uint j,
        ProtocolERC20Pricing coinPricer,
        ProtocolERC721Pricing nftPricer
    ) internal returns (ApplicationAppManager testAppManager, ApplicationHandler testAppHandler, ApplicationERC20 testCoin, HandlerDiamond testCoinHandler) {
        switchToSuperAdmin();
        (testAppManager, testAppHandler) = deployAndSetNewApp(coinPricer, nftPricer);
        (testCoin, testCoinHandler) = deployAndSetupERC20(string.concat("coin", vm.toString(j)), string.concat("C", vm.toString(j)), testAppManager);
        coinPricer.setSingleTokenPrice(address(testCoin), 1 * (10 ** 18)); //setting at $1
        /// connect the pricers to both handlers
        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    function deployFullApplicationWithNFT(
        uint j,
        ProtocolERC20Pricing coinPricer,
        ProtocolERC721Pricing nftPricer
    ) internal returns (ApplicationAppManager testAppManager, ApplicationHandler testAppHandler, ApplicationERC721 testNFT, HandlerDiamond testNFTHandler) {
        switchToSuperAdmin();
        (testAppManager, testAppHandler) = deployAndSetNewApp(coinPricer, nftPricer);
        /// create an ERC721
        (testNFT, testNFTHandler) = deployAndSetupERC721(string.concat("nft", vm.toString(j)), string.concat("NFT", vm.toString(j)), testAppManager);
        /// set up the pricer for erc721
        nftPricer.setNFTCollectionPrice(address(testNFT), 1 * (10 ** 18)); //setting at $1
        /// connect the pricers to both handlers
        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    function deployFullApplicationWithCoinAndNFT(
        uint j,
        ProtocolERC20Pricing coinPricer,
        ProtocolERC721Pricing nftPricer
    )
        internal
        returns (
            ApplicationAppManager testAppManager,
            ApplicationHandler testAppHandler,
            ApplicationERC20 testCoin,
            HandlerDiamond testCoinHandler,
            ApplicationERC721 testNFT,
            HandlerDiamond testNFTHandler
        )
    {
        (testAppManager, testAppHandler, testCoin, testCoinHandler) = deployFullApplicationWithCoin(j, coinPricer, nftPricer);
        switchToSuperAdmin();
        /// create an ERC721
        (testNFT, testNFTHandler) = deployAndSetupERC721(string.concat("nft", vm.toString(j)), string.concat("NFT", vm.toString(j)));
        /// set up the pricer for erc721
        nftPricer.setNFTCollectionPrice(address(testNFT), 1 * (10 ** 18)); //setting at $1
    }
}
