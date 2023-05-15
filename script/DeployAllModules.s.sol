// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../src/application/ApplicationHandler.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import {IDiamondInit} from "../src/diamond/initializers/IDiamondInit.sol";
import {DiamondInit} from "../src/diamond/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "../src/diamond/core/DiamondCut/DiamondCutLib.sol";

import {ApplicationRuleProcessorDiamond, DiamondArgs} from "../src/economic/ruleProcessor/application/ApplicationRuleProcessorDiamond.sol";
import {RuleStorageDiamond, RuleStorageDiamondArgs} from "../src/economic/ruleStorage/RuleStorageDiamond.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "../src/economic/ruleProcessor/nontagged/RuleProcessorDiamond.sol";

import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import {FeeRuleDataFacet} from "../src/economic/ruleStorage/FeeRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import {TokenRuleRouter} from "../src/economic/TokenRuleRouter.sol";

import {TaggedRuleProcessorDiamond, TaggedRuleProcessorDiamondArgs} from "../src/economic/ruleProcessor/tagged/TaggedRuleProcessorDiamond.sol";
import {ERC20TaggedRuleProcessorFacet} from "../src/economic/ruleProcessor/tagged/ERC20TaggedRuleProcessorFacet.sol";

/**
 * @title The deployment script for the Protocol. It deploys protocol contracts and links everything.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract deploys All Contracts for the Protocol
 * @dev This script will set contract addresses needed by protocol interaction in connectAndSetUpAll()
 */

contract DeployAllModulesScript is Script {
    /// Store the FacetCut struct for each facet that is being deployed.
    /// NOTE: using storage array to easily "push" new FacetCut as we
    /// process the facets.
    FacetCut[] private _facetCutsApplicationProcessor;
    FacetCut[] private _facetCutsData;
    FacetCut[] private _facetCutsRuleProcessor;
    FacetCut[] private _facetCutsTaggedRuleProcessor;
    /// address and private key used to for deployment
    uint256 constant privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address constant ownerAddress = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

    ApplicationRuleProcessorDiamond applicationRuleProcessorDiamond;
    TokenRuleRouterProxy tokenRuleProxy;
    RuleStorageDiamond ruleDataDiamond;
    RuleProcessorDiamond tokenRuleProcessors;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    TokenRuleRouter tokenRuleRouter;

    /**
     * @dev This is the main function that gets called by the Makefile or CLI
     */
    function run() external {
        vm.startBroadcast(privateKey);

        deployApplicationRuleProcessor();
        /// appManager = deployApplicationAppManager();
        ruleDataDiamond = deployRuleDataDiamond();
        tokenRuleProcessors = deployRuleProcessorDiamond();
        taggedRuleProcessorDiamond = deployTaggedRuleProcessorDiamond();
        tokenRuleRouter = deployTokenRuleRouter();
        tokenRuleProxy = deployTokenRuleRouterProxy();

        connectAndSetupAll();

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy the applicationRuleProcessor module. This includes the ApplicationRuleProcessorDiamond.
     */
    function deployApplicationRuleProcessor() internal {
        /// Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        /// Register all facets.
        string[7] memory facets = [
            /// Native facets,
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            /// Raw implementation facets.
            "ERC165Facet",
            "ERC173Facet",
            /// Protocol Facets
            "ApplicationRiskProcessorFacet",
            "ApplicationAccessLevelProcessorFacet",
            "ApplicationPauseProcessorFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        /// Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            /// Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            /// Create the FacetCut struct for this facet.
            _facetCutsApplicationProcessor.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        /// Build the DiamondArgs.
        DiamondArgs memory diamondArgs = DiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        /// Deploy the Global Rules Diamond.
        applicationRuleProcessorDiamond = new ApplicationRuleProcessorDiamond(_facetCutsApplicationProcessor, diamondArgs);
    }

    /**
     * @dev Deploy the Economic Rules Diamond
     * @return RuleStorageDiamond address once deployed
     */

    function deployRuleDataDiamond() internal returns (RuleStorageDiamond) {
        /// Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        /// Register all facets.
        string[8] memory facets = [
            /// Native facets,
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            /// Raw implementation facets.
            "ERC165Facet",
            "ERC173Facet",
            /// Protocol facets.
            "RuleDataFacet",
            "TaggedRuleDataFacet",
            "AppRuleDataFacet",
            "FeeRuleDataFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        /// Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            /// Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            /// Create the FacetCut struct for this facet.
            _facetCutsData.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        /// Build the DiamondArgs.
        RuleStorageDiamondArgs memory diamondArgs = RuleStorageDiamondArgs({
            init: address(diamondInit),
            /// NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Deploy the diamond.
        RuleStorageDiamond diamond = new RuleStorageDiamond(_facetCutsData, diamondArgs);

        return diamond;
    }

    /**
     * @dev Deploy the Meta Controls Diamond
     * @return RuleProcessorDiamond address once deployed
     */
    function deployRuleProcessorDiamond() internal returns (RuleProcessorDiamond) {
        /// Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        /// Register all facets.
        string[7] memory facets = [
            /// Native facets,
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            /// Raw implementation facets.
            "ERC165Facet",
            "ERC173Facet",
            /// Protocol facets.
            ///tokenRuleRouter (Rules setters and getters)
            "ERC20RuleProcessorFacet",
            "ERC721RuleProcessorFacet",
            "FeeRuleProcessorFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        /// Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            /// Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            /// Create the FacetCut struct for this facet.
            _facetCutsRuleProcessor.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        /// Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            /// NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        /// Deploy the diamond.
        RuleProcessorDiamond tokenRuleProcessorsDiamond = new RuleProcessorDiamond(_facetCutsRuleProcessor, diamondArgs);

        return tokenRuleProcessorsDiamond;
    }

    /**
     * @dev Deploy the Economic Action Controller
     * @return TokenRuleRouter address once deployed
     */
    function deployTokenRuleRouter() internal returns (TokenRuleRouter) {
        TokenRuleRouter _tokenRuleRouter = new TokenRuleRouter();

        return _tokenRuleRouter;
    }

    /**
     * @dev Deploy the Token Rule Router Proxy
     * @return tokenRuleProxy Address of deployed Proxy contract
     */
    function deployTokenRuleRouterProxy() internal returns (TokenRuleRouterProxy) {
        TokenRuleRouterProxy _tokenRuleProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        return _tokenRuleProxy;
    }

    /**
     * @dev Deploy the Tagged Rule Processor Diamond
     * @return TaggedRuleProcessorDiamond address once deployed
     */
    function deployTaggedRuleProcessorDiamond() public returns (TaggedRuleProcessorDiamond) {
        /// Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        /// Register all facets.
        string[7] memory facets = [
            /// Native facets,
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            /// Raw implementation facets.
            "ERC165Facet",
            "ERC173Facet",
            /// Protocol facets.
            "ERC20TaggedRuleProcessorFacet",
            "ERC721TaggedRuleProcessorFacet",
            "RiskTaggedRuleProcessorFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        /// Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            /// Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            /// Create the FacetCut struct for this facet.
            _facetCutsTaggedRuleProcessor.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        /// Build the DiamondArgs.
        TaggedRuleProcessorDiamondArgs memory diamondArgs = TaggedRuleProcessorDiamondArgs({
            init: address(diamondInit),
            /// NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Deploy the diamond.
        TaggedRuleProcessorDiamond diamond = new TaggedRuleProcessorDiamond(_facetCutsTaggedRuleProcessor, diamondArgs);

        return diamond;
    }

    /**
     * @notice Connect addresses in contracts to interact with Protocol
     * @dev setRuleDataDiamond is called for meta and Individual Diamonds to set the ruleDataDiamond Address
     * Handler sets meta and individual diamond addresses
     */
    function connectAndSetupAll() public {
        /// Connect the ControlsDiamonds into the ruleDataDiamond
        tokenRuleProcessors.setRuleDataDiamond(address(ruleDataDiamond));
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleDataDiamond));
        applicationRuleProcessorDiamond.setRuleDataDiamond(address(ruleDataDiamond));

        /// connect the TokenRuleRouter to its 2 diamonds
        TokenRuleRouter(address(tokenRuleProxy)).initialize(payable(address(tokenRuleProcessors)), payable(address(taggedRuleProcessorDiamond)));
    }
}
