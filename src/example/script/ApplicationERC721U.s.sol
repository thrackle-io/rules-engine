// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/example/ApplicationERC721U.sol";
import "src/example/ApplicationERC721UProxy.sol";
import "src/application/IAppManager.sol";
import {ApplicationERC721Handler} from "src/example/ApplicationERC721Handler.sol";

/**
 * @title This is the deployment script for the ApplicationERC721U.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Application Upgradeable NFT ERC721. It will also register the token with the application's app manager
 */

contract ApplicationERC721UScript is Script {
    function setUp() public {}

    /**
     * @dev This function runs the script
     */
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));
        ApplicationERC721U applicationNFT = new ApplicationERC721U();
        ApplicationERC721UProxy applicationNFTProxy = new ApplicationERC721UProxy(address(applicationNFT), vm.envAddress("APPLICATIONERC721U_PROXY_OWNER_ADDRESS"), "");
        ApplicationERC721U(address(applicationNFTProxy)).initialize("Frankenstein", "FRANK", vm.envAddress("APPLICATION_APP_MANAGER"));
        ApplicationERC721Handler applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), vm.envAddress("APPLICATION_APP_MANAGER"), false);
        ApplicationERC721U(address(applicationNFTProxy)).connectHandlerToToken(address(applicationNFTHandler));
        // Register the token with the application's app manager
        IAppManager(vm.envAddress("APPLICATION_APP_MANAGER")).registerToken("Frankenstein", address(applicationNFTProxy));
        vm.stopBroadcast();
    }
}
