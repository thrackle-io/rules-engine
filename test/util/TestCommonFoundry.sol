// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommon.sol";
import "test/util/EndWithStopPrank.sol";
import "script/EnabledActionPerRuleArray.sol";

/**
 * @title Test Common Foundry
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the Foundry tests. NOTE: function prefixes and their usages are as follows:
 * setup = set to proper user, deploy contracts, set global variables, reset user
 * create = set to proper user, deploy contracts, reset user, return the contract
 * _create = deploy contract, return the contract
 */
abstract contract TestCommonFoundry is TestCommon, EndWithStopPrank, EnabledActionPerRuleArray {
    modifier ifDeploymentTestsEnabled() {
        if (testDeployments) {
            _;
        }
    }

    /**
     * @dev Deploy and set up the Rules Processor Diamond
     * @return diamond fully configured rules processor diamond
     */
    function _createRulesProcessorDiamond() public returns (RuleProcessorDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();
        _addNativeFacetsToFacetCut();
        _addStorageFacetsToFacetCut();
        _addProcessingFacetsToFacetCut();

        // Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        /// Build the diamond
        vm.expectEmit(false, false, false, false);
        emit AD1467_RuleProcessorDiamondDeployed();
        // Deploy the diamond.
        RuleProcessorDiamond ruleProcessorInternal = new RuleProcessorDiamond(_ruleProcessorFacetCuts, diamondArgs);
        /// setup enabled actions
        _setEnabledActionsPerRule(address(ruleProcessorInternal));
        return ruleProcessorInternal;
    }

    function _setEnabledActionsPerRule(address ruleProcessorAddress) internal {
        for (uint i; i < enabledActionPerRuleArray.length; ++i) {
            RuleApplicationValidationFacet(ruleProcessorAddress).enabledActionsInRule(enabledActionPerRuleArray[i].ruleName, enabledActionPerRuleArray[i].enabledActions);
        }
    }

    function _addNativeFacetsToFacetCut() public {
        // Protocol Facets
        ProtocolNativeFacet protocolNativeFacet = new ProtocolNativeFacet();
        ProtocolRawFacet protocolRawFacet = new ProtocolRawFacet();
        VersionFacet versionFacet = new VersionFacet();

        // Native
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(protocolNativeFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ProtocolNativeFacet")}));

        // Raw
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(protocolRawFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ProtocolRawFacet")}));

        // Version
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(versionFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("VersionFacet")}));
    }

    function _addProcessingFacetsToFacetCut() public {
        // Rule Processor Facets
        ERC20RuleProcessorFacet erc20RuleProcessorFacet = new ERC20RuleProcessorFacet();
        ERC721RuleProcessorFacet erc721RuleProcessorFacet = new ERC721RuleProcessorFacet();
        ApplicationRiskProcessorFacet applicationRiskProcessorFacet = new ApplicationRiskProcessorFacet();
        ApplicationAccessLevelProcessorFacet applicationAccessLevelProcessorFacet = new ApplicationAccessLevelProcessorFacet();
        ApplicationPauseProcessorFacet applicationPauseProcessorFacet = new ApplicationPauseProcessorFacet();
        RuleApplicationValidationFacet ruleApplicationValidationFacet = new RuleApplicationValidationFacet();
        ERC721TaggedRuleProcessorFacet erc721TaggedRuleProcessorFacet = new ERC721TaggedRuleProcessorFacet();
        ERC20TaggedRuleProcessorFacet erc20TaggedRuleProcessorFacet = new ERC20TaggedRuleProcessorFacet();

        // Standard
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(erc20RuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC20RuleProcessorFacet")}));

        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(erc721RuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC721RuleProcessorFacet")}));

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(applicationRiskProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ApplicationRiskProcessorFacet")})
        );

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(applicationAccessLevelProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ApplicationAccessLevelProcessorFacet")})
        );

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(applicationPauseProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ApplicationPauseProcessorFacet")})
        );

        // Tagged
        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(erc20TaggedRuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC20TaggedRuleProcessorFacet")})
        );

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(erc721TaggedRuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC721TaggedRuleProcessorFacet")})
        );

        // Validation
        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(ruleApplicationValidationFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("RuleApplicationValidationFacet")})
        );
    }

    function _addStorageFacetsToFacetCut() public {
        // Rule Processing Facets
        RuleDataFacet ruleDataFacet = new RuleDataFacet();
        TaggedRuleDataFacet taggedRuleDataFacet = new TaggedRuleDataFacet();
        AppRuleDataFacet appRuleDataFacet = new AppRuleDataFacet();

        // Standard
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(ruleDataFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("RuleDataFacet")}));

        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(appRuleDataFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("AppRuleDataFacet")}));

        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(taggedRuleDataFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("TaggedRuleDataFacet")}));
    }

    /**
     * @dev Create the selector array for the facet
     * @return _selectors loaded selector array
     */
    function _createSelectorArray(string memory _facet) public returns (bytes4[] memory _selectors) {
        string[] memory _inputs = new string[](3);
        _inputs[0] = "python3";
        _inputs[1] = "script/python/get_selectors.py";
        _inputs[2] = _facet;
        bytes memory res = vm.ffi(_inputs);
        return abi.decode(res, (bytes4[]));
    }

    /**
     * @dev Deploy and set up the ERC20 Handler Diamond
     * @return diamond fully configured ERC20 Handler diamond
     */
    function _createERC20HandlerDiamond() public returns (HandlerDiamond diamond) {
        FacetCut[] memory _erc20HandlerFacetCuts = new FacetCut[](8);
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[8] memory facets = [
            // diamond version
            "VersionFacet",
            // Native facets,
            "ProtocolNativeFacet",
            // // Raw implementation facets.
            "ProtocolRawFacet",
            // ERC20 Handler Facets
            "ERC20HandlerMainFacet",
            "ERC20TaggedRuleFacet",
            "ERC20NonTaggedRuleFacet",
            "TradingRuleFacet",
            "FeesFacet"
        ];

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            // Create the FacetCut struct for this facet.
            _erc20HandlerFacetCuts[facetIndex] = FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: _createSelectorArray(facet)});
        }

        // Build the DiamondArgs.
        HandlerDiamondArgs memory diamondArgs = HandlerDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Build the diamond
        HandlerDiamond handlerInternal = new HandlerDiamond(_erc20HandlerFacetCuts, diamondArgs);

        // Deploy the diamond.
        return handlerInternal;
    }

    /**
     * @dev Deploy and set up the ERC721 Handler Diamond
     * @return diamond fully configured ERC721 Handler diamond
     */
    function _createERC721HandlerDiamond() public returns (HandlerDiamond diamond) {
        FacetCut[] memory _erc721HandlerFacetCuts = new FacetCut[](7);
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[7] memory facets = [
            // diamond version
            "VersionFacet",
            // Native facets,
            "ProtocolNativeFacet",
            // Raw implementation facets.
            "ProtocolRawFacet",
            // ERC721 Handler Facets
            "ERC721HandlerMainFacet",
            "ERC721TaggedRuleFacet",
            "ERC721NonTaggedRuleFacet",
            "TradingRuleFacet"
        ];

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            // Create the FacetCut struct for this facet.
            _erc721HandlerFacetCuts[facetIndex] = FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: _createSelectorArray(facet)});
        }

        // Build the DiamondArgs.
        HandlerDiamondArgs memory diamondArgs = HandlerDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Build the diamond
        HandlerDiamond handlerInternal = new HandlerDiamond(_erc721HandlerFacetCuts, diamondArgs);

        // Deploy the diamond.
        return handlerInternal;
    }

    /**
     * @dev Deploy and set up the main protocol contracts.
     */
    function setUpProtocol() public endWithStopPrank {
        switchToSuperAdmin();
        ruleProcessor = _createRulesProcessorDiamond();
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. ProcessorDiamond 2. AppManager
     */
    function setUpProtocolAndAppManager() public endWithStopPrank {
        switchToSuperAdmin();
        ruleProcessor = _createRulesProcessorDiamond();
        applicationAppManager = _createAppManager();
        switchToAppAdministrator(); // app admin should set up everything after creation of the appManager
        applicationAppManager.setNewApplicationHandlerAddress(address(_createAppHandler(ruleProcessor, applicationAppManager)));
        applicationHandler = ApplicationHandler(applicationAppManager.getHandlerAddress());
    }

    function setUpProtocolAndAppManagerAndTokensWithERC721HandlerDiamond() public endWithStopPrank {
        setUpProtocolAndAppManager();
        (applicationCoin, applicationCoinHandler) = deployAndSetupERC20("FRANK", "FRK");
        (applicationNFTv2, applicationNFTHandlerv2) = deployAndSetupERC721("ToughTurtles", "THTR");
        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        (applicationNFT, applicationNFTHandler) = deployAndSetupERC721("FRANKENSTEIN", "FRK");
        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        /// connect the pricers to both handlers
        switchToRuleAdmin();
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();
        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    /**
     * @dev Deploy and set up the protocol with app manager and 2 supported ERC721 tokens with pricing contract
     * ERC721 tokens and Pricing contract are named for Pricing.t.sol
     */

    function setUpProtocolAndAppManagerAndPricingAndTokens() public {
        setUpProtocolAndAppManager();
        (boredWhaleNFT, boredWhaleHandler) = deployAndSetupERC721("Bored Whale Island Club", "BWYC");
        (boredReptilianNFT, boredReptileHandler) = deployAndSetupERC721("Board Reptilian Spaceship Club", "BRSC");
        (boredCoin, boredCoinHandler) = deployAndSetupERC20("Bored Whale Coin", "BRDC");
        (reptileToken, reptileTokenHandler) = deployAndSetupERC20("Reptile Token", "RTR");
        /// Deploy the pricing contract
        openOcean = _createERC721Pricing();
        uniBase = _createERC20Pricing();
    }

    /**
     * @dev this function ensures that unique addresses can be randomly retrieved from the address array.
     */
    function getUniqueAddresses(uint256 _seed, uint8 _number) public view returns (address[] memory _addressList) {
        _addressList = new address[](ADDRESSES.length);
        // first one will simply be the seed
        _addressList[0] = ADDRESSES[_seed];
        uint256 j;
        if (_number > 1) {
            // loop until all unique addresses are returned
            for (uint256 i = 1; i < _number; i++) {
                // find the next unique address
                j = _seed;
                do {
                    j++;
                    // if end of list reached, start from the beginning
                    if (j == ADDRESSES.length) {
                        j = 0;
                    }
                    if (!exists(ADDRESSES[j], _addressList)) {
                        _addressList[i] = ADDRESSES[j];
                        break;
                    }
                } while (0 == 0);
            }
        }
        return _addressList;
    }

    // Check if an address exists in the list
    function exists(address _address, address[] memory _addressList) public pure returns (bool) {
        for (uint256 i = 0; i < _addressList.length; i++) {
            if (_address == _addressList[i]) {
                return true;
            }
        }
        return false;
    }

    ///--------------- CREATE FUNCTIONS WITH SENDER SETTING --------------------

    /**
     * @dev Deploy and set up the Rules Processor Diamond. This includes sender setting/resetting
     * @return diamond fully configured rules processor diamond
     */
    function createRulesProcessorDiamond() public returns (RuleProcessorDiamond diamond) {
        switchToSuperAdmin();
        RuleProcessorDiamond d = _createRulesProcessorDiamond();
        vm.stopPrank();
        return d;
    }

    /**
     * @dev Deploy and set up an AppManager
     * @param _ruleProcessor rule processor
     * @return _appManager fully configured app manager
     */
    function createAppManager(RuleProcessorDiamond _ruleProcessor) public returns (ApplicationAppManager _appManager) {
        switchToSuperAdmin();
        ApplicationAppManager a = _createAppManager();
        a.setNewApplicationHandlerAddress(address(_createAppHandler(_ruleProcessor, a)));
        vm.stopPrank();
        return a;
    }

    ///--------------SPECIALIZED CREATE FUNCTIONS---------------

    /**
     * @dev Deploy and set up Specialized ERC20 token and handler
     */
    function setUpProcotolAndCreateERC20AndHandlerSpecialOwner() public endWithStopPrank {
        setUpProtocolAndAppManager();

        /// NOTE: this set up logic must be different because the handler must be owned by appAdministrator so it may be called directly. It still
        /// requires a token be attached and registered for permissions in appManager
        // this ERC20Handler has to be created specially so that the owner is the appAdministrator. This is so we can access it directly in the tests.
        switchToAppAdministrator();
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        // create the ERC20 and connect it to its handler
        applicationCoinHandlerSpecialOwner = _createERC20HandlerDiamond();
        VersionFacet(address(applicationCoinHandlerSpecialOwner)).updateVersion("1.1.0");
        ERC20HandlerMainFacet(address(applicationCoinHandlerSpecialOwner)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoin));
        switchToAppAdministrator();
        applicationCoin.connectHandlerToToken(address(applicationCoinHandlerSpecialOwner));
        /// register the token
        applicationAppManager.registerToken("application2", address(applicationCoin));
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        /// create an ERC721
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);
        (applicationNFT, applicationNFTHandler) = deployAndSetupERC721("FRANKENSTEIN", "FRK");
        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        switchToRuleAdmin();
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. ProcessorDiamond, 2. AppManager with its handler connected, 3. ApplicationERC20 with its handler, and default price
     */
    function setUpProtocolAndAppManagerAndTokensUpgradeable() public endWithStopPrank {
        setUpProtocolAndAppManager();

        // create the ERC20 and connect it to its handler
        (applicationCoin, applicationCoinHandler) = deployAndSetupERC20("FRANK", "FRK");
        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create ERC721
        (applicationNFT, applicationNFTHandler) = deployAndSetupERC721("FRANKENSTEIN", "FRK");
        switchToAppAdministrator();

        /// create an ERC721U
        applicationNFTU = _createERC721Upgradeable();
        applicationNFTProxy = _createERC721UpgradeableProxy(address(applicationNFTU), address(proxyOwner));

        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).initialize("Dracula Prime", "DRAC", address(applicationAppManager), "dummy.uri.io");
        applicationNFTHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationNFTProxy));
        switchToAppAdministrator();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).connectHandlerToToken(address(applicationNFTHandler));

        /// register the token
        applicationAppManager.registerToken("THRK", address(applicationNFTProxy));

        ///Pricing Contracts
        erc721Pricer = new ApplicationERC721Pricing();
        erc20Pricer = new ApplicationERC20Pricing();

        /// set up the pricer for erc721
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFTU), 1 * (10 ** 18)); //setting at $1
        /// connect the pricers to handler
        switchToRuleAdmin();
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    /**
     * @dev Deploy and set up ERC20 token with DIAMOND handler
     */
    function setUpProcotolAndCreateERC20AndDiamondHandler() public endWithStopPrank {
        setUpProtocolAndAppManager();
        /// NOTE: this set up logic must be different because the handler must be owned by appAdministrator so it may be called directly. It still
        /// requires a token be attached and registered for permissions in appManager
        // this ERC20Handler has to be created specially so that the owner is the appAdministrator. This is so we can access it directly in the tests.
        (applicationCoin, applicationCoinHandler) = deployAndSetupERC20("FRANK", "FRK");
        (applicationCoin2, applicationCoinHandler2) = deployAndSetupERC20("application2", "GMC2");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        (applicationNFT, applicationNFTHandler) = deployAndSetupERC721("Clyde", "CLYDEPIC");
        (applicationNFTv2, applicationNFTHandlerv2) = deployAndSetupERC721("ToughTurtles", "THTR");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        switchToRuleAdmin();
        vm.expectEmit(true, false, false, false);
        emit AD1467_ERC721PricingAddressSet(address(erc721Pricer));
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        vm.expectEmit(true, false, false, false);
        emit AD1467_ERC20PricingAddressSet(address(erc20Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();

        applicationAppManager.registerTreasury(feeTreasury);

        switchToSuperAdmin();
        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    /**
     * @dev Deploy and set up ERC20 token with DIAMOND handler
     */
    function setUpProcotolAndCreateERC721MinAndDiamondHandler() public endWithStopPrank {
        setUpProtocolAndAppManager();
        /// NOTE: this set up logic must be different because the handler must be owned by appAdministrator so it may be called directly. It still
        /// requires a token be attached and registered for permissions in appManager
        // this ERC20Handler has to be created specially so that the owner is the appAdministrator. This is so we can access it directly in the tests.
        (applicationCoin, applicationCoinHandler) = deployAndSetupERC20("FRANK", "FRK");
        (applicationCoin2, applicationCoinHandler2) = deployAndSetupERC20("application2", "GMC2");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        (minimalNFT, applicationNFTHandler) = deployAndSetupERC721Min("FRANKENSTEIN", "FRK");
        (applicationNFTv2, applicationNFTHandlerv2) = deployAndSetupERC721("ToughTurtles", "THTR");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(minimalNFT), 1 * (10 ** 18)); //setting at $1
        switchToRuleAdmin();
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToSuperAdmin();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    /**
     * @dev Deploy and set up ERC20 token with DIAMOND handler
     */
    function setUpProcotolAndCreateERC721MinLegacyAndDiamondHandler() public endWithStopPrank {
        setUpProtocolAndAppManager();
        /// NOTE: this set up logic must be different because the handler must be owned by appAdministrator so it may be called directly. It still
        /// requires a token be attached and registered for permissions in appManager
        // this ERC20Handler has to be created specially so that the owner is the appAdministrator. This is so we can access it directly in the tests.
        (applicationCoin, applicationCoinHandler) = deployAndSetupERC20("Frankenstein Coin", "FRANK");
        (applicationCoin2, applicationCoinHandler2) = deployAndSetupERC20("application2", "GMC2");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        (minimalNFTLegacy, applicationNFTHandler) = deployAndSetupERC721MinLegacy("FRANKENSTEIN", "FRK");
        (applicationNFTv2, applicationNFTHandlerv2) = deployAndSetupERC721("ToughTurtles", "THTR");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(minimalNFTLegacy), 1 * (10 ** 18)); //setting at $1
        switchToRuleAdmin();
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    /**
     * @dev Deploy and set up ERC20 token with DIAMOND handler
     */
    function setUpProcotolAndCreateERC20MinAndDiamondHandler() public endWithStopPrank {
        setUpProtocolAndAppManager();
        /// NOTE: this set up logic must be different because the handler must be owned by appAdministrator so it may be called directly. It still
        /// requires a token be attached and registered for permissions in appManager
        // this ERC20Handler has to be created specially so that the owner is the appAdministrator. This is so we can access it directly in the tests.
        (minimalCoin, applicationCoinHandler) = deployAndSetupERC20Min("FRANK", "FRK");
        (applicationCoin2, applicationCoinHandler2) = deployAndSetupERC20("application2", "GMC2");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(minimalCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        (applicationNFT, applicationNFTHandler) = deployAndSetupERC721("FRANKENSTEIN", "FRK");
        (applicationNFTv2, applicationNFTHandlerv2) = deployAndSetupERC721("ToughTurtles", "THTR");

        switchToAppAdministrator();
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        switchToRuleAdmin();
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToSuperAdmin();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
    }

    function deployAndSetupERC721(string memory name, string memory symbol) internal endWithStopPrank returns (ApplicationERC721 erc721, HandlerDiamond handler) {
        (erc721, handler) = deployAndSetupERC721(name, symbol, applicationAppManager);
    }

    function deployAndSetupERC721(
        string memory name,
        string memory symbol,
        ApplicationAppManager _applicationAppManager
    ) internal endWithStopPrank returns (ApplicationERC721 erc721, HandlerDiamond handler) {
        switchToSuperAdmin();
        erc721 = _createERC721(name, symbol, _applicationAppManager);
        handler = _createERC721HandlerDiamond();
        VersionFacet(address(handler)).updateVersion("1.1.0");
        ERC721HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(_applicationAppManager), address(erc721));
        switchToAppAdministrator();
        erc721.connectHandlerToToken(address(handler));
        /// register the token
        _applicationAppManager.registerToken(name, address(erc721));
    }

    function deployAndSetupERC721NoRegister(string memory name, string memory symbol) internal endWithStopPrank returns (ApplicationERC721 erc721, HandlerDiamond handler) {
        switchToSuperAdmin();
        erc721 = _createERC721(name, symbol, applicationAppManager);
        handler = _createERC721HandlerDiamond();
        VersionFacet(address(handler)).updateVersion("1.1.0");
        ERC721HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(applicationAppManager), address(erc721));
        switchToAppAdministrator();
        erc721.connectHandlerToToken(address(handler));
    }

    function deployAndSetupERC721Min(string memory name, string memory symbol) internal endWithStopPrank returns (MinimalERC721 erc721, HandlerDiamond handler) {
        switchToSuperAdmin();
        erc721 = _createERC721Min(name, symbol, applicationAppManager);
        handler = _createERC721HandlerDiamond();
        VersionFacet(address(handler)).updateVersion("1.1.0");
        ERC721HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(applicationAppManager), address(erc721));
        switchToAppAdministrator();
        erc721.connectHandlerToToken(address(handler));
        /// register the token
        applicationAppManager.registerToken(name, address(erc721));
    }

    function deployAndSetupERC721MinLegacy(string memory name, string memory symbol) internal endWithStopPrank returns (MinimalERC721Legacy erc721, HandlerDiamond handler) {
        switchToSuperAdmin();
        erc721 = new MinimalERC721Legacy(name, symbol);
        handler = _createERC721HandlerDiamond();
        VersionFacet(address(handler)).updateVersion("1.1.0");
        ERC721HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(applicationAppManager), address(erc721));
        switchToAppAdministrator();
        erc721.connectHandlerToToken(address(handler));
        /// register the token
        applicationAppManager.registerToken(name, address(erc721));
    }

    function deployAndSetupERC20(string memory name, string memory symbol) internal endWithStopPrank returns (ApplicationERC20 erc20, HandlerDiamond handler) {
        (erc20, handler) = deployAndSetupERC20(name, symbol, applicationAppManager);
    }

    function deployAndSetupERC20(
        string memory name,
        string memory symbol,
        ApplicationAppManager _applicationAppManager
    ) internal endWithStopPrank returns (ApplicationERC20 erc20, HandlerDiamond handler) {
        switchToSuperAdmin();
        erc20 = _createERC20(name, symbol, _applicationAppManager);
        handler = _createERC20HandlerDiamond();
        VersionFacet(address(handler)).updateVersion("1.1.0");
        ERC20HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(_applicationAppManager), address(erc20));
        switchToAppAdministrator();
        erc20.connectHandlerToToken(address(handler));
        /// register the token
        vm.expectEmit(true, true, false, false);
        emit AD1467_TokenRegistered(name, address(erc20));
        _applicationAppManager.registerToken(name, address(erc20));
    }

    function deployAndSetupERC20NoRegister(string memory name, string memory symbol) internal endWithStopPrank returns (ApplicationERC20 erc20, HandlerDiamond handler) {
        switchToSuperAdmin();
        erc20 = _createERC20(name, symbol, applicationAppManager);
        handler = _createERC20HandlerDiamond();
        VersionFacet(address(handler)).updateVersion("1.1.0");
        ERC20HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(applicationAppManager), address(erc20));
        switchToAppAdministrator();
        erc20.connectHandlerToToken(address(handler));
    }

    function deployAndSetupERC20Min(string memory name, string memory symbol) internal endWithStopPrank returns (MinimalERC20 erc20, HandlerDiamond handler) {
        switchToSuperAdmin();
        erc20 = _createERC20Min(name, symbol, applicationAppManager);
        handler = _createERC20HandlerDiamond();
        VersionFacet(address(handler)).updateVersion("1.1.0");
        ERC20HandlerMainFacet(address(handler)).initialize(address(ruleProcessor), address(applicationAppManager), address(erc20));
        switchToAppAdministrator();
        erc20.connectHandlerToToken(address(handler));
        /// register the token
        applicationAppManager.registerToken(name, address(erc20));
    }

    /**
     * @dev Deploy and set up an ERC20Handler specialized for Handler Testing
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC20
     * @param _appAdmin App Admin Address
     * @return handler ERC20 handler
     */
    function _createERC20HandlerSpecialized(
        RuleProcessorDiamond _ruleProcessor,
        ApplicationAppManager _appManager,
        ApplicationERC20 _token,
        address _appAdmin
    ) public returns (HandlerDiamond handler) {
        handler = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(handler)).initialize(address(_ruleProcessor), address(_appManager), address(_appAdmin));
        switchToAppAdministrator();
        _token.connectHandlerToToken(address(handler));
        return handler;
    }

    ///---------------USER SWITCHING--------------------
    function switchToAppAdministrator() public {
        vm.stopPrank();
        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(appAdministrator); //set a app administrator
        vm.stopPrank(); //stop interacting as the app admin
        vm.startPrank(appAdministrator); //interact as the created app administrator
    }

    function switchToAccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        vm.stopPrank(); //stop interacting as the access level admin
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
    }

    function switchToRuleBypassAccount() public {
        switchToAppAdministrator();
        applicationAppManager.addRuleBypassAccount(ruleBypassAccount);
        vm.stopPrank();
        vm.startPrank(ruleBypassAccount);
    }

    function switchToRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addRiskAdmin(riskAdmin); //add Risk admin
        vm.stopPrank(); //stop interacting as the risk admin
        vm.startPrank(riskAdmin); //interact as the created Risk admin
    }

    function switchToRuleAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        applicationAppManager.addRuleAdministrator(ruleAdmin); //add Rule admin
        vm.stopPrank(); //stop interacting as the rule admin
        vm.startPrank(ruleAdmin); //interact as the created Rule admin
    }

    function switchToUser() public {
        vm.stopPrank(); //stop interacting as the previous admin
        vm.startPrank(user); //interact as the user
    }

    /**
     * @dev Function to set the super admin as the calling address. It stores the current address for future resetting
     *
     */
    function switchToSuperAdmin() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
    }

    function switchToNewAdmin() public {
        vm.stopPrank();
        vm.startPrank(newAdmin);
    }

    function _addAdminsToAddressArray() public {
        ADDRESSES = [
            address(0xFF1),
            address(0xFF2),
            address(0xFF3),
            address(0xFF4),
            address(0xFF5),
            address(0xFF6),
            address(0xFF7),
            address(0xFF8),
            address(superAdmin),
            address(appAdministrator),
            address(ruleAdmin),
            address(riskAdmin),
            address(accessLevelAdmin)
        ];
    }

    function _grantAdminRolesToAdmins() public {
        switchToAppAdministrator();
        applicationAppManager.addAccessLevelAdmin(accessLevelAdmin);
        applicationAppManager.addRiskAdmin(riskAdmin);
        applicationAppManager.addRuleAdministrator(ruleAdmin);
    }

    function _get1RandomAddress(uint8 _addressIndex) internal view returns (address randomUser) {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        randomUser = addressList[0];
    }

    function _get2RandomAddresses(uint8 _addressIndex) internal view returns (address, address) {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        return (addressList[0], addressList[1]);
    }

    function _get3RandomAddresses(uint8 _addressIndex) internal view returns (address, address, address) {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 3);
        return (addressList[0], addressList[1], addressList[2]);
    }

    function _get4RandomAddresses(uint8 _addressIndex) internal view returns (address, address, address, address) {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        return (addressList[0], addressList[1], addressList[2], addressList[3]);
    }

    function _get5RandomAddresses(uint8 _addressIndex) internal view returns (address, address, address, address, address) {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        return (addressList[0], addressList[1], addressList[2], addressList[3], addressList[4]);
    }

    function _parameterizeRisk(uint8 _risk) internal pure returns (uint8 risk) {
        risk = uint8((uint16(_risk) * 100) / 256);
    }
}
