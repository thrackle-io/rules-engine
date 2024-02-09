// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UpgWhitelistMint.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UProxy.sol";
import "src/client/application/IAppManager.sol";
import "../DeployBase.s.sol";

/**
 * @title This is the deployment script for the ApplicationERC721U.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Application Upgradeable NFT ERC721. It will also register the token with the application's app manager
 */

contract ApplicationERC721UScript is Script, DeployBase {
    function setUp() public {}

    /**
     * @dev This function runs the script
     */
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));
        ApplicationERC721Upgradeable applicationNFT = new ApplicationERC721Upgradeable();
        ApplicationERC721UProxy applicationNFTProxy = new ApplicationERC721UProxy(address(applicationNFT), vm.envAddress("APPLICATIONERC721U_PROXY_OWNER_ADDRESS"), "");
        ApplicationERC721Upgradeable(address(applicationNFTProxy)).initialize("Frankenstein", "FRANK", vm.envAddress("APPLICATION_APP_MANAGER"), "dummy.uri.io", 1);
        HandlerDiamond applicationNFTHandlerDiamond = createERC721HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationNFTHandlerDiamond)).initialize(
            vm.envAddress("RULE_PROCESSOR_DIAMOND"), 
            vm.envAddress("APPLICATION_APP_MANAGER"), 
            address(applicationNFT)
        );
        ApplicationERC721Upgradeable(address(applicationNFTProxy)).connectHandlerToToken(address(applicationNFTHandlerDiamond));
        // Register the token with the application's app manager
        IAppManager(vm.envAddress("APPLICATION_APP_MANAGER")).registerToken("Frankenstein", address(applicationNFTProxy));
        vm.stopBroadcast();
    }
}
