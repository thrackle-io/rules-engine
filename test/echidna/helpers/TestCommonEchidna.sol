// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/helpers/TestCommon.sol";
// diamond facets
// storage facets
import "src/diamond/VersionFacet.sol";
import "src/diamond/ProtocolNativeFacet.sol";
import "src/diamond/ProtocolRawFacet.sol";
import "src/economic/ruleStorage/FeeRuleDataFacet.sol";
import "src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import "src/economic/ruleStorage/RuleDataFacet.sol";
import "src/economic/ruleStorage/AppRuleDataFacet.sol";
// processor facets
import "src/economic/ruleProcessor/ERC721RuleProcessorFacet.sol";
import "src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import "src/economic/ruleProcessor/FeeRuleProcessorFacet.sol";
import "src/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol";
import "src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol";
import "src/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol";
import "src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import "src/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol";
import "src/economic/ruleProcessor/RuleApplicationValidationFacet.sol";
import "src/economic/ruleProcessor/RiskTaggedRuleProcessorFacet.sol";

abstract contract TestCommonEchidna is TestCommon {
    string[] inputs = ["python3", "script/python/get_selectors.py", ""];

    /**
     * @dev Deploy and set up an AppManager
     * @return _appManager fully configured app manager
     */
    function _createAppManager() public override returns (ApplicationAppManager _appManager) {
        _appManager = new ApplicationAppManager(msg.sender, "Castlevania", false);
        return _appManager;
    }

    /**
     * @dev Deploy and set up an AppManager
     * @param _address address to be super user
     * @return _appManager fully configured app manager
     */
    function _createAppManager2(address _address) public returns (ApplicationAppManager _appManager) {
        _appManager = new ApplicationAppManager(_address, "Castlevania", false);
        return _appManager;
    }

    /**
     * @dev Deploy and set up the Rules Storage Diamond
     * @return diamond fully configured storage diamond
     */
    function _createRuleStorageDiamond() internal returns (RuleStorageDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Deploy the facet.
        address facetAddress;
        bytes4[] memory selectors;

        // VersionFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(VersionFacet).creationCode, "VersionFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ProtocolNativeFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(ProtocolNativeFacet).creationCode, "ProtocolNativeFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ProtocolRawFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(ProtocolRawFacet).creationCode, "ProtocolRawFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // RuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(RuleDataFacet).creationCode, "RuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // TaggedRuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(TaggedRuleDataFacet).creationCode, "TaggedRuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // AppRuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(AppRuleDataFacet).creationCode, "AppRuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // FeeRuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "FeeRuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // Build the DiamondArgs.
        RuleStorageDiamondArgs memory diamondArgs = RuleStorageDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        // Deploy the diamond.
        return new RuleStorageDiamond(_ruleStorageFacetCuts, diamondArgs);
    }

    /**
     * @dev deploy a facet and return its address
     */
    function _deployFacetAndGetSelectors(bytes memory _bytecode, string memory _facetName) internal returns (address _facetAddress, bytes4[] memory _selectors) {
        // deploy the facet
        assembly {
            _facetAddress := create(0, add(_bytecode, 0x20), mload(_bytecode))
        }

        // Get the facet selectors.
        inputs[2] = _facetName;
        bytes memory res = vm.ffi(inputs);
        _selectors = abi.decode(res, (bytes4[]));
        return (_facetAddress, _selectors);
    }

    /**
     * @dev Deploy and set up the Rules Processor Diamond
     * @param _storageDiamond preconfigured storage diamond
     * @return diamond fully configured rules processor diamond
     */
    function _createRulesProcessorDiamond(RuleStorageDiamond _storageDiamond) public returns (RuleProcessorDiamond diamond) {
        // // Start by deploying the DiamonInit contract.
        // DiamondInit diamondInit = new DiamondInit();
        // // Register all facets.
        // string[13] memory facets = [
        //     // diamond version
        //     "VersionFacet",
        //     // Native facets,
        //     "ProtocolNativeFacet",
        //     // Raw implementation facets.
        //     "ProtocolRawFacet",
        //     // Protocol facets.
        //     //rule processor facets
        //     "ERC721RuleProcessorFacet",
        //     "ERC20RuleProcessorFacet",
        //     "FeeRuleProcessorFacet",
        //     "ApplicationRiskProcessorFacet",
        //     "ApplicationAccessLevelProcessorFacet",
        //     "ApplicationPauseProcessorFacet",
        //     //TaggedRuleFacets:
        //     "ERC20TaggedRuleProcessorFacet",
        //     "ERC721TaggedRuleProcessorFacet",
        //     "RiskTaggedRuleProcessorFacet",
        //     "RuleApplicationValidationFacet"
        // ];
        // // Loop on each facet, deploy them and create the FacetCut.
        // for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
        //     string memory facet = facets[facetIndex];
        //     // Deploy the facet.
        //     bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
        //     address facetAddress;
        //     assembly {
        //         facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        //     }
        //     // Get the facet selectors.
        //     inputs[2] = facet;
        //     bytes memory res = vm.ffi(inputs);
        //     bytes4[] memory selectors = abi.decode(res, (bytes4[]));
        //     // Create the FacetCut struct for this facet.
        //     _ruleProcessorFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        // }
        // // Build the DiamondArgs.
        // RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
        //     init: address(diamondInit),
        //     // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
        //     initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        // });
        // /// Build the diamond
        // RuleProcessorDiamond ruleProcessorInternal = new RuleProcessorDiamond(_ruleProcessorFacetCuts, diamondArgs);
        // /// Connect the ruleProcessor into the ruleStorageDiamond
        // ruleProcessorInternal.setRuleDataDiamond(address(_storageDiamond));
        // // Deploy the diamond.
        // return ruleProcessorInternal;
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. StorageDiamond, 2. ProcessorDiamond, 3. configuring the ProcessorDiamond to point to the StorageDiamond
     */
    function setUpProtocol() public {
        ruleStorageDiamond = _createRuleStorageDiamond();
        ruleProcessor = _createRulesProcessorDiamond(ruleStorageDiamond);
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. StorageDiamond, 2. ProcessorDiamond, 3. configuring the ProcessorDiamond to point to the StorageDiamond, 4. AppManager
     */
    function setUpProtocolAndAppManager() public {
        ruleStorageDiamond = _createRuleStorageDiamond();
        ruleProcessor = _createRulesProcessorDiamond(ruleStorageDiamond);
        applicationAppManager = _createAppManager();
        applicationAppManager.setNewApplicationHandlerAddress(address(_createAppHandler(ruleProcessor, applicationAppManager)));
        applicationHandler = ApplicationHandler(applicationAppManager.getHandlerAddress());
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. StorageDiamond, 2. ProcessorDiamond, 3. configuring the ProcessorDiamond to point to the StorageDiamond, 4. AppManager with its handler connected, 5. ApplicationERC20 with its handler, and default price
     */
    function setUpProtocolAndAppManagerAndTokens() public {
        // create the rule storage diamond
        ruleStorageDiamond = _createRuleStorageDiamond();
        // create the rule processor diamond
        ruleProcessor = _createRulesProcessorDiamond(ruleStorageDiamond);
        // create the app manager
        applicationAppManager = _createAppManager();
        // create the app handler and connect it to the appManager
        applicationAppManager.setNewApplicationHandlerAddress(address(_createAppHandler(ruleProcessor, applicationAppManager)));
        applicationHandler = ApplicationHandler(applicationAppManager.getHandlerAddress());

        // create the ERC20 and connect it to its handler
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        applicationCoinHandler = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoin);
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);
        applicationNFTHandler = _createERC721Handler(ruleProcessor, applicationAppManager, applicationNFT);
        /// register the token
        applicationAppManager.registerToken("FRANKENSTEIN", address(applicationNFT));
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        /// connect the pricers to both handlers
        applicationNFTHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationNFTHandler.setERC20PricingAddress(address(erc20Pricer));
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        applicationCoinHandler.setNFTPricingAddress(address(erc721Pricer));
    }

    /**
     * @dev Deploy and set up an AppManager
     * @param _ruleProcessor rule processor
     * @return _appManager fully configured app manager
     */
    function createAppManager(RuleProcessorDiamond _ruleProcessor) public returns (ApplicationAppManager _appManager) {
        ApplicationAppManager a = _createAppManager();
        a.setNewApplicationHandlerAddress(address(_createAppHandler(_ruleProcessor, a)));
        return a;
    }
}
