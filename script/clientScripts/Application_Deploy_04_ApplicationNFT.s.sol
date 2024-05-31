// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/example/application/ApplicationHandler.sol";
import {ApplicationERC721AdminOrOwnerMint} from "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import "./DeployBase.s.sol";

/**
 * @title Application Deploy 04 Application Non-Fungible Token  Script
 * @dev This script will deploy an ERC721 non-fungible token and Handler.
 * @notice Deploys an application ERC721 non-fungible token and Handler..
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script clientScripts/script/Application_Deploy_01_AppManager.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script clientScripts/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script clientScripts/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployNFTScript is Script, DeployBase {
    HandlerDiamond applicationNFTHandlerDiamond;
    uint256 privateKey;
    address ownerAddress;
    uint256 appAdminKey;
    address appAdminAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        /// Retrieve the App Manager from previous script
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        /// Create NFT
        new ApplicationERC721AdminOrOwnerMint("WolfMan", "WOLF", address(applicationAppManager), vm.envString("APPLICATION_ERC721_URI_1"));
        applicationNFTHandlerDiamond = createERC721HandlerDiamondPt1("WolfMan");

        vm.stopBroadcast();
    }
}
