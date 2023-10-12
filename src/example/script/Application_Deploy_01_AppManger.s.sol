// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../application/ApplicationHandler.sol";
import {ApplicationAppManager} from "../ApplicationAppManager.sol";


/**
 * @title Application Deploy 01 AppManger Script
 * @dev This script will deploy the App Manager, App Handler an ERC20 token and Handler and an ERC721 token and Handler Contract.
 * @notice Deploys the application App Manager, AppHandler, ERC20, ERC721, and associated handlers. 
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script src/example/script/Application_Deploy_01_AppManger.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script src/example/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployAppManagerAndAssetsScript is Script {
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        ApplicationAppManager applicationAppManager = new ApplicationAppManager(vm.envAddress("DEPLOYMENT_OWNER"), "Castlevania", false);
        ApplicationHandler applicationHandler = new ApplicationHandler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler)); 
        vm.stopBroadcast();
    }
}
