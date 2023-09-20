// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../ERC721/not-upgradeable/ApplicationERC721FreeMint.sol";
import "../../application/IAppManager.sol";
import {ApplicationERC721Handler} from "../ApplicationERC721Handler.sol";

/**
 * @title This is the deployment script for the Application NFT.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Application NFT ERC721. It will also register the token with the application's app manager
 */

contract ApplicationERC721Script is Script {
    function setUp() public {}

    /**
     * @dev This function runs the script
     */
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));

        ApplicationERC721 nft1 = new ApplicationERC721("Frankenstein", "FRANK", vm.envAddress("APPLICATION_APP_MANAGER"), vm.envString("APPLICATION_ERC721_URI_1"));
        ApplicationERC721Handler applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), vm.envAddress("APPLICATION_APP_MANAGER"), address(nft1), false);
        nft1.connectHandlerToToken(address(applicationNFTHandler));
        // Register the token with the application's app manager
        IAppManager(vm.envAddress("APPLICATION_APP_MANAGER")).registerToken("Frankenstein", address(this));
        vm.stopBroadcast();
    }
}
