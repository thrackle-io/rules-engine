// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/ERC721/ApplicationERC721WhitelistMint.sol";
import "src/client/application/IAppManager.sol";
import "../DeployBase.s.sol";

/**
 * @title This is the deployment script for the Application NFT.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Application NFT ERC721. It will also register the token with the application's app manager
 */

contract ApplicationERC721Script is Script, DeployBase {
    function setUp() public {}

    /**
     * @dev This function runs the script
     */
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));

        ApplicationERC721WhitelistMint nft1 = new ApplicationERC721WhitelistMint("Frankenstein", "FRANK", vm.envAddress("APPLICATION_APP_MANAGER"), vm.envString("APPLICATION_ERC721_URI_1"), 1);
        HandlerDiamond applicationNFTHandlerDiamond = createERC721HandlerDiamond("Frankenstein");
        ERC20HandlerMainFacet(address(applicationNFTHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), vm.envAddress("APPLICATION_APP_MANAGER"), address(nft1));
        nft1.connectHandlerToToken(address(applicationNFTHandlerDiamond));
        // Register the token with the application's app manager
        IAppManager(vm.envAddress("APPLICATION_APP_MANAGER")).registerToken("Frankenstein", address(this));
        vm.stopBroadcast();
    }
}
