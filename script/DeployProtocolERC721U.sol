// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UProxy.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UpgAdminMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";

/**
 * @title The Post Deployment Configuration Step For the Token
 * @author @VoR0220
 * @notice This is an example script for how to deploy a protocol ERC721 upgradeable token and proxy. This is purely an example and should be modified to fit the needs of the deployment. Other possible implementations one might want to look at include the Openzeppelin Foundry Upgrades library. 
 */

 contract DeployProtocolERC721Upgradeable is Script {

    ApplicationAppManager applicationAppManager;
    uint256 appAdminKey;
    address appAdminAddress;

    function run() external {

        appAdminKey = vm.envUint("APP_ADMIN_PRIVATE_KEY");
        appAdminAddress = vm.envAddress("APP_ADMIN");
        vm.startBroadcast(appAdminKey);

        applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        ApplicationERC721UpgAdminMint _applicationNFTU = new ApplicationERC721UpgAdminMint();
        // substitute names that you would want here for name and symbol of NFT and base URI
        bytes memory callData = abi.encodeWithSelector(_applicationNFTU.initialize.selector, "ERC721U", "ERC721U", address(applicationAppManager), "https://");
        ApplicationERC721UProxy proxy = new ApplicationERC721UProxy(address(_applicationNFTU), appAdminAddress, callData);
        vm.stopBroadcast();
        console.log("Deployed ERC721U proxy at address: ", address(proxy));
        console.log("Deployed ERC721U at address: ", address(_applicationNFTU));
    }
 }

