// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

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
    string name;
    HandlerDiamond applicationNFTHandlerDiamond;

    function run() external {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        name = vm.envString("HANDLER_DIAMOND_TO_DEPLOY"); // name of the token
        vm.startBroadcast(privateKey);

        applicationNFTHandlerDiamond = createERC721HandlerDiamondPt1(name);
        createERC721HandlerDiamondPt2(name, address(applicationNFTHandlerDiamond));
        setENVVariable("HANDLER_DIAMOND_TO_DEPLOY", ""); // we clear the env for safe future deployments

        vm.stopBroadcast();
        
    }

}