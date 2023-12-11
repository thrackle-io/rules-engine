// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/client/application/ApplicationHandler.sol";
import "../ERC20/ApplicationERC20Handler.sol";
import "../ERC20/ApplicationERC20.sol";
import {ApplicationERC721Handler} from "../ERC721/ApplicationERC721Handler.sol";
import {ApplicationERC721} from "../ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "src/client/application/ApplicationAppManager.sol";
import "../OracleRestricted.sol";
import "../OracleAllowed.sol";
import "src/client/pricing/ApplicationERC20Pricing.sol";
import "src/client/pricing/ApplicationERC721Pricing.sol";

/**
 * @title Application Deploy 05 Oracle Script
 * @dev This script will deploy the Oracle Contracts.
 * @notice Deploys the pricing and oracle contracts.
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script example/script/Application_Deploy_01_AppMangerAndAssets.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
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
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);

        /// Deploy Oracle Contracts
        new OracleAllowed();
        new OracleRestricted();

        vm.stopBroadcast();
    }
}
