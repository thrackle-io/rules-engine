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
import {DiamondScriptUtil} from "../DiamondScriptUtil.sol";
import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";

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

contract DeployBase is Script, DiamondScriptUtil {

    /**
     * @dev Deploy and set up the ERC20 Handler Diamond
     * @return diamond fully configured ERC20 Handler diamond
     */
    function createERC20HandlerDiamondPt1(string memory name) public returns (HandlerDiamond diamond) {
        validateName(name);
        bool recordAllChains;
        recordAllChains = vm.envBool("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS");
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();
        FacetCut[] memory _erc20HandlerFacetCuts = new FacetCut[](4);

        // Register all facets.
        string[4] memory facets = [
            // diamond version
            "VersionFacet",
            // Native facets,
            "ProtocolNativeFacet",
            // // Raw implementation facets.
            "ProtocolRawFacet",
            // Protocol facets.
            //rule processor facets
            "ERC20HandlerMainFacet"
        ];

        string[4] memory directories = [
            "./out/VersionFacet.sol/",
            "./out/ProtocolNativeFacet.sol/",
            "./out/ProtocolRawFacet.sol/",
            "./out/ERC20HandlerMainFacet.sol/"
        ];

        name = replace(name, " ", "_");
        string[] memory getSelectorsInput = new string[](3);
        getSelectorsInput[0] = "python3";
        getSelectorsInput[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];
            string memory directory = directories[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(directory, string.concat(facet, ".json")));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            recordFacet(string.concat(name, "HandlerDiamond"), facet, facetAddress, recordAllChains);

            // Get the facet selectors.
            getSelectorsInput[2] = facet;
            bytes memory res = vm.ffi(getSelectorsInput);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _erc20HandlerFacetCuts[facetIndex] = FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors});
        }

        // Build the DiamondArgs.
        HandlerDiamondArgs memory diamondArgs = HandlerDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Build the diamond
        HandlerDiamond handlerInternal = new HandlerDiamond(_erc20HandlerFacetCuts, diamondArgs);

        /// record the diamond address
        recordFacet(string.concat(name, "HandlerDiamond"), "diamond", address(handlerInternal), recordAllChains);
        setENVVariable("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS", "false");

        // Deploy the diamond.
        return handlerInternal;
    }

    function createERC20HandlerDiamondPt2(string memory name, address handlerAddress) public {
                validateName(name);
        bool recordAllChains;
        recordAllChains = vm.envBool("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS");
        FacetCut[] memory _erc20HandlerFacetCuts = new FacetCut[](4);

        // Register all facets.
        string[4] memory facets = [
            "ERC20TaggedRuleFacet",
            "ERC20NonTaggedRuleFacet",
            "TradingRuleFacet",
            "FeesFacet"
        ];

        string[4] memory directories = [
            "./out/ERC20TaggedRuleFacet.sol/",
            "./out/ERC20NonTaggedRuleFacet.sol/",
            "./out/TradingRuleFacet.sol/",
            "./out/FeesFacet.sol/"
        ];

        name = replace(name, " ", "_");
        string[] memory getSelectorsInput = new string[](3);
        getSelectorsInput[0] = "python3";
        getSelectorsInput[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];
            string memory directory = directories[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(directory, string.concat(facet, ".json")));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            recordFacet(string.concat(name, "HandlerDiamond"), facet, facetAddress, recordAllChains);

            // Get the facet selectors.
            getSelectorsInput[2] = facet;
            bytes memory res = vm.ffi(getSelectorsInput);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _erc20HandlerFacetCuts[facetIndex] = FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors});
        }

        IDiamondCut(handlerAddress).diamondCut(_erc20HandlerFacetCuts, address(0x0), "");

    }

    /**
     * @dev Deploy and set up the ERC721 Handler Diamond
     * @return diamond fully configured ERC721 Handler diamond
     */
    function createERC721HandlerDiamondPt1(string memory name) public returns (HandlerDiamond diamond) {
        validateName(name);
        bool recordAllChains;
        recordAllChains = vm.envBool("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS");
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();
        FacetCut[] memory _erc721HandlerFacetCuts = new FacetCut[](4);

        // Register all facets.
        string[4] memory facets = [
            // diamond version
            "VersionFacet",
            // Native facets,
            "ProtocolNativeFacet",
            // Raw implementation facets.
            "ProtocolRawFacet",
            // Protocol facets.
            //rule processor facets
            "ERC721HandlerMainFacet"
        ];

        string[4] memory directories = [
            "./out/VersionFacet.sol/",
            "./out/ProtocolNativeFacet.sol/",
            "./out/ProtocolRawFacet.sol/",
            "./out/ERC721HandlerMainFacet.sol/"
        ];

        name = replace(name, " ", "_");
        string[] memory getSelectorsInput = new string[](3);
        getSelectorsInput[0] = "python3";
        getSelectorsInput[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];
            string memory directory = directories[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(directory, string.concat(facet, ".json")));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            recordFacet(string.concat(name, "HandlerDiamond"), facet, facetAddress, recordAllChains);

            // Get the facet selectors.
            getSelectorsInput[2] = facet;
            bytes memory res = vm.ffi(getSelectorsInput);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _erc721HandlerFacetCuts[facetIndex] = FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors});
        }

        // Build the DiamondArgs.
        HandlerDiamondArgs memory diamondArgs = HandlerDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Build the diamond
        HandlerDiamond handlerInternal = new HandlerDiamond(_erc721HandlerFacetCuts, diamondArgs);

        /// record the diamond address
        recordFacet(string.concat(name, "HandlerDiamond"), "diamond", address(handlerInternal), recordAllChains);
        setENVVariable("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS", "false");
        // Deploy the diamond.
        return handlerInternal;
    }

        function createERC721HandlerDiamondPt2(string memory name, address handlerAddress) public {
                validateName(name);
        bool recordAllChains;
        recordAllChains = vm.envBool("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS");
        FacetCut[] memory _erc20HandlerFacetCuts = new FacetCut[](3);

        // Register all facets.
        string[3] memory facets = [
            "ERC721TaggedRuleFacet",
            "ERC721NonTaggedRuleFacet",
            "TradingRuleFacet"
        ];

        string[3] memory directories = [
            "./out/ERC721TaggedRuleFacet.sol/",
            "./out/ERC721NonTaggedRuleFacet.sol/",
            "./out/TradingRuleFacet.sol/"
        ];

        name = replace(name, " ", "_");
        string[] memory getSelectorsInput = new string[](3);
        getSelectorsInput[0] = "python3";
        getSelectorsInput[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];
            string memory directory = directories[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(directory, string.concat(facet, ".json")));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            recordFacet(string.concat(name, "HandlerDiamond"), facet, facetAddress, recordAllChains);

            // Get the facet selectors.
            getSelectorsInput[2] = facet;
            bytes memory res = vm.ffi(getSelectorsInput);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _erc20HandlerFacetCuts[facetIndex] = FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors});
        }

        IDiamondCut(handlerAddress).diamondCut(_erc20HandlerFacetCuts, address(0x0), "");

    }

    function validateName(string memory name) internal pure {
        if(bytes(name).length == 0)
            revert("HANDLER_DIAMOND_TO_DEPLOY not set in the env file");
    }

}