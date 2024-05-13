// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UProxy.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UpgAdminMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import "./DeployBase.s.sol";

/**
 * @title The Post Deployment Configuration Step For the Token
 * @author @VoR0220, @ShaneDuncan, @TJEverett, @GordanPalmer
 * @notice This is an example script for how to deploy a protocol ERC721 upgradeable token and proxy. 
 ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **. 
 * Deploy Scripts:
 * forge script clientScripts/script/Application_Deploy_01_AppManager.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_04_ApplicationNFTUpgradable.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script clientScripts/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

 contract DeployProtocolERC721Upgradeable is Script, DeployBase {

    HandlerDiamond applicationNFTHandlerDiamond;
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
        bytes memory callData = abi.encodeWithSelector(_applicationNFTU.initialize.selector, "Jekyll&Hyde", "JKH", address(applicationAppManager), "https://jekyllandhydecollectibles.io");
        new ApplicationERC721UProxy(address(_applicationNFTU), appAdminAddress, callData);
        applicationNFTHandlerDiamond = createERC721HandlerDiamondPt1("DAWGUniversity");
        
        vm.stopBroadcast();
    }
 }

