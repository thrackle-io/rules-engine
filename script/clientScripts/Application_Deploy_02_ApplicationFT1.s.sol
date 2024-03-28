// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/example/ERC20/ApplicationERC20.sol";
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import {HandlerDiamond, HandlerDiamondArgs} from "src/client/token/handler/diamond/HandlerDiamond.sol";
import {ERC20HandlerMainFacet} from "src/client/token/handler/diamond/ERC20HandlerMainFacet.sol";
import {ERC721HandlerMainFacet} from "src/client/token/handler/diamond/ERC721HandlerMainFacet.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
import "./DeployBase.s.sol";
/**
 * @title Application Deploy 02 Application Fungible Token 1 Script
 * @dev This script will deploy an ERC20 fungible token and Handler.
 * @notice Deploys an application ERC20 and Handler.
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script example/script/Application_Deploy_01_AppManager.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script example/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployFT1Script is Script, DeployBase {
    HandlerDiamond applicationCoinHandlerDiamond;
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

        /// Create ERC20 token 1
        ApplicationERC20 coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager));
        applicationCoinHandlerDiamond = createERC20HandlerDiamond("Frankenstein Coin");
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin1));
        appAdminKey = vm.envUint("APP_ADMIN_PRIVATE_KEY");
        appAdminAddress = vm.envAddress("APP_ADMIN");
        vm.stopBroadcast();
        vm.startBroadcast(appAdminKey);
        coin1.connectHandlerToToken(address(applicationCoinHandlerDiamond));

        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("FRANK", address(coin1));

        vm.stopBroadcast();
    }
}
