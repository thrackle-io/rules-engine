// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "./DeployBase.s.sol";
import {HandlerDiamond, HandlerDiamondArgs} from "src/client/token/handler/diamond/HandlerDiamond.sol";

/**
 * @title Deploy ERC721 Handler Diamond Script
 * @dev This script will deploy the ERC721 Handler Diamons.
 */
contract DeployERC721Handler is Script, DeployBase {
    /// address and private key used to for deployment
    uint256 privateKey;
    address ownerAddress;
    HandlerDiamond applicationCoinHandlerDiamond;

    function run() external {
        privateKey = vm.envUint("LOCAL_DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("LOCAL_DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);

        applicationCoinHandlerDiamond = createERC721HandlerDiamond();

        vm.stopBroadcast();
    }

}