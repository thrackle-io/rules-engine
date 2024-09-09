// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import "src/example/ERC20/ApplicationERC20.sol";
import {ApplicationERC721AdminOrOwnerMint} from "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import "src/example/OracleDenied.sol";
import "src/example/OracleApproved.sol";
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";

/**
 * @title Application Deploy 05 Oracle Script
 * @dev This script will deploy the Oracle Contracts.
 * @notice Deploys the oracle contracts.
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script example/script/Application_Deploy_01_AppManagerAndAssets.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_02_OracleAndPricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_03_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script example/script/Application_Deploy_04_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployOracleScript is Script {
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("APP_ADMIN_PRIVATE_KEY");
        ownerAddress = vm.envAddress("APP_ADMIN");
        vm.startBroadcast(privateKey);

        /// Deploy Oracle Contracts
        new OracleApproved();
        new OracleDenied();

        vm.stopBroadcast();
    }
}
