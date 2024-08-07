// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "./DeployBase.s.sol";
import {HandlerDiamond, HandlerDiamondArgs} from "src/client/token/handler/diamond/HandlerDiamond.sol";

/**
 * @title Deploy ERC721 Handler Diamond Script
 * @dev This script will deploy the ERC721 Handler Diamons.
 */

contract DeployERC721HandlerPt2 is Script, DeployBase {
    HandlerDiamond applicationNFTHandlerDiamond;
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        string memory name = vm.envString("HANDLER_DIAMOND_TO_DEPLOY"); // name of the Diamond
        vm.startBroadcast(privateKey);
        applicationNFTHandlerDiamond = HandlerDiamond(payable(vm.envAddress("APPLICATION_ERC721_HANDLER")));
        createERC721HandlerDiamondPt2(name, address(applicationNFTHandlerDiamond));
        ERC721HandlerMainFacet(address(applicationNFTHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), vm.envAddress("APPLICATION_APP_MANAGER"), vm.envAddress("APPLICATION_ERC721_ADDRESS_1"));
        setENVVariable("HANDLER_DIAMOND_TO_DEPLOY", ""); // we clear the env for safe future deployments
        vm.stopBroadcast();
    }
}