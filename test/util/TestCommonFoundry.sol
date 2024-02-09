// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommon.sol";

/**
 * @title Test Common Foundry
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the Foundry tests. NOTE: function prefixes and their usages are as follows:
 * setup = set to proper user, deploy contracts, set global variables, reset user
 * create = set to proper user, deploy contracts, reset user, return the contract
 * _create = deploy contract, return the contract
 */
abstract contract TestCommonFoundry is TestCommon {

    /**
     * @dev Deploy and set up the Rules Processor Diamond
     * @return diamond fully configured rules processor diamond
     */
    function _createRulesProcessorDiamond() public returns (RuleProcessorDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[16] memory facets = [
            // diamond version
            "VersionFacet",
            // Native facets,
            "ProtocolNativeFacet",
            // Raw implementation facets.
            "ProtocolRawFacet",
            // Protocol facets.
            //rule processor facets
            "ERC721RuleProcessorFacet",
            "ERC20RuleProcessorFacet",
            "FeeRuleProcessorFacet",
            "ApplicationRiskProcessorFacet",
            "ApplicationAccessLevelProcessorFacet",
            "ApplicationPauseProcessorFacet",
            //ERC20TaggedRuleFacets:
            "ERC20TaggedRuleProcessorFacet",
            "ERC721TaggedRuleProcessorFacet",
            "RuleApplicationValidationFacet",
            "RuleDataFacet",
            "TaggedRuleDataFacet",
            "FeeRuleDataFacet",
            "AppRuleDataFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            // Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _ruleProcessorFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        // Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Build the diamond
        RuleProcessorDiamond ruleProcessorInternal = new RuleProcessorDiamond(_ruleProcessorFacetCuts, diamondArgs);

        // Deploy the diamond.
        return ruleProcessorInternal;
    }


    /**
     * @dev Deploy and set up the ERC20 Handler Diamond
     * @return diamond fully configured ERC20 Handler diamond
     */
    function _createERC20HandlerDiamond() public returns (HandlerDiamond diamond) {
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

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            // Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _erc20HandlerFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
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
        delete _erc721HandlerFacetCuts;
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

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            // Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _erc721HandlerFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
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
    function setUpProtocol() public {
        switchToSuperAdmin();
        ruleProcessor = _createRulesProcessorDiamond();
        /// reset the user to the original
        switchToOriginalUser();
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. ProcessorDiamond 2. AppManager
     */
    function setUpProtocolAndAppManager() public {
        switchToSuperAdminWithSave();
        ruleProcessor = _createRulesProcessorDiamond();
        applicationAppManager = _createAppManager();
        switchToAppAdministrator(); // app admin should set up everything after creation of the appManager
        applicationAppManager.setNewApplicationHandlerAddress(address(_createAppHandler(ruleProcessor, applicationAppManager)));
        applicationHandler = ApplicationHandler(applicationAppManager.getHandlerAddress());
        /// reset the user to the original
        switchToOriginalUser();
    }

    function setupApplicationCoinAndHandler(address ownerAddress) public {
        switchToSuperAdminWithSave();
        applicationCoinHandler = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandler)).initialize(address(ruleProcessor), address(applicationAppManager), ownerAddress);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        switchToAppAdministrator();
    }

    function setupApplicationNFTAndHandler(address ownerAddress) public {
        switchToSuperAdminWithSave();
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);
        applicationNFTHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationNFT));
        applicationNFT.connectHandlerToToken(address(applicationNFTHandler));
        switchToAppAdministrator();
    }

    function setUpProtocolAndAppManagerAndTokensWithERC721HandlerDiamond() public {
        setUpProtocolAndAppManager();
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        // create the ERC20 and connect it to its handler
        setupApplicationCoinAndHandler(address(applicationCoin));
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);
        setupApplicationNFTAndHandler(address(applicationNFT));
        VersionFacet(address(applicationNFTHandler)).updateVersion("1.1.0");
        /// register the token
        applicationAppManager.registerToken("FRANKENSTEIN", address(applicationNFT));
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
        /// reset the user to the original
        switchToOriginalUser();
    }

    /**
     * @dev Deploy and set up the protocol with app manager and 2 supported ERC721 tokens with pricing contract 
     * ERC721 tokens and Pricing contract are named for Pricing.t.sol 
     */
    
    function setUpProtocolAndAppManagerAndPricingAndTokens() public {
        setUpProtocolAndAppManager();
        
        boredWhaleNFT = _createERC721("Bored Whale Island Club", "BWYC", applicationAppManager);
        boredWhaleHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(boredWhaleHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(boredWhaleNFT));
        boredWhaleNFT.connectHandlerToToken(address(boredWhaleHandler));
        boredReptilianNFT = _createERC721("Board Reptilian Spaceship Club", "BRSC", applicationAppManager);
        boredReptileHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(boredReptileHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(boredReptilianNFT));
        boredReptilianNFT.connectHandlerToToken(address(boredReptileHandler));

        /// Deploy the pricing contract
        openOcean = _createERC721Pricing();
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
        /// reset the user to the original
        switchToOriginalUser();
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
        /// reset the user to the original
        switchToOriginalUser();
        return a;
    }

    ///--------------SPECIALIZED CREATE FUNCTIONS---------------

    /**
     * @dev Deploy and set up Specialized ERC20 token and handler 
     */
    function setUpProcotolAndCreateERC20AndHandlerSpecialOwner() public {
        setUpProtocolAndAppManager();

        /// NOTE: this set up logic must be different because the handler must be owned by appAdministrator so it may be called directly. It still
        /// requires a token be attached and registered for permissions in appManager
        // this ERC20Handler has to be created specially so that the owner is the appAdministrator. This is so we can access it directly in the tests.
        switchToAppAdministrator();
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        // create the ERC20 and connect it to its handler
        setupApplicationCoinAndHandler(address(appAdministrator));
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        /// create an ERC721
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);
        setupApplicationNFTAndHandler(address(applicationNFT));
        /// register the token
        applicationAppManager.registerToken("FRANKENSTEIN", address(applicationNFT));
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        switchToRuleAdmin(); 
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
        /// reset the user to the original
        switchToOriginalUser();

    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. ProcessorDiamond, 2. AppManager with its handler connected, 3. ApplicationERC20 with its handler, and default price
     */
    function setUpProtocolAndAppManagerAndTokensUpgradeable() public {
        setUpProtocolAndAppManager();

        // create the ERC20 and connect it to its handler
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        setupApplicationCoinAndHandler(address(applicationCoin));
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        
        /// create ERC721 
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);

        /// create an ERC721U
        applicationNFTU = _createERC721Upgradeable();
        applicationNFTProxy = _createERC721UpgradeableProxy(address(applicationNFTU), address(proxyOwner));
        ApplicationERC721Upgradeable(address(applicationNFTProxy)).initialize("Dracula Prime", "DRAC", address(applicationAppManager), "dummy.uri.io");
        applicationNFTHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationNFTProxy));
        ApplicationERC721Upgradeable(address(applicationNFTProxy)).connectHandlerToToken(address(applicationNFTHandler));
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
        /// reset the user to the original
        switchToOriginalUser();
    }


    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * This function sets up the ERC721Examples.t.sol test
     */
    function setUpProtocolAndAppManagerAndTokensForExampleTest() public {
        setUpProtocolAndAppManager();

        // create the ERC20 and connect it to its handler
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        setupApplicationCoinAndHandler(address(applicationCoin));
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        /// create an ERC721
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);
        setupApplicationNFTAndHandler(address(applicationNFT));
        /// register the token
        applicationAppManager.registerToken("FRANKENSTEIN", address(applicationNFT));
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        /// connect pricing contracts to handler 
        switchToRuleAdmin(); 
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();

        /// create ERC721 examples
        mintForAFeeNFT = _createERC721MintFee("BlindSailers", "BSL", applicationAppManager, 1 ether);
        whitelistMintNFT = _createERC721Whitelist("MonkeysPlayingInBonsaiTrees", "MBT", applicationAppManager, 2);
        freeNFT = _createERC721Free("ParkinsonBarbers", "PKB", applicationAppManager);

        MintForAFeeNFTHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(MintForAFeeNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(mintForAFeeNFT));

        WhitelistNFTHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(WhitelistNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(whitelistMintNFT));

        FreeForAllnNFTHandler = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(FreeForAllnNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(freeNFT));

        applicationAppManager.registerToken("BlindSailers", address(mintForAFeeNFT));
        applicationAppManager.registerToken("MonkeysPlayingInBonsaiTrees", address(whitelistMintNFT));
        applicationAppManager.registerToken("ParkinsonBarbers", address(freeNFT));

        /// create ERC721 examples upgradeable
        mintForAFeeNFTUpImplementation = _createERC721UpgradeableFeeMint();
        whitelistMintNFTUpImplementation = _createERC721UpgradeableAllowList();
        freeNFTUpImplementation = _createERC721UpgradeableFreeForAll();

        mintForAFeeNFTUp = _createERC721UpgradeableProxy(address(mintForAFeeNFTUpImplementation), address(proxyOwner));
        whitelistMintNFTUp = _createERC721UpgradeableProxy(address(whitelistMintNFTUpImplementation), address(proxyOwner));
        freeNFTUp = _createERC721UpgradeableProxy(address(freeNFTUpImplementation), address(proxyOwner));

        MintForAFeeERC721Upgradeable(payable(address(mintForAFeeNFTUp))).initialize("BlindSailersUp", "BSLU", address(applicationAppManager), "blindsailers.com/iseeyou", 1 ether);
        WhitelistMintERC721Upgradeable(payable(address(whitelistMintNFTUp))).initialize(
            "MonkeysPlayingInBonsaiTreesUp",
            "MBTU",
            address(applicationAppManager),
            "monkeysdontknowwhattodo.com/havingfun",
            2
        );
        FreeForAllERC721Upgradeable(payable(address(freeNFTUp))).initialize("ParkinsonBarbersUp", "PKBU", address(applicationAppManager), "bloodinmyhands.com/bookyourcut");

        MintForAFeeNFTHandlerUp = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(MintForAFeeNFTHandlerUp)).initialize(address(ruleProcessor), address(applicationAppManager), address(mintForAFeeNFTUp));

        WhitelistNFTHandlerUp = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(WhitelistNFTHandlerUp)).initialize(address(ruleProcessor), address(applicationAppManager), address(whitelistMintNFTUp));

        FreeForAllnNFTHandlerUp = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(FreeForAllnNFTHandlerUp)).initialize(address(ruleProcessor), address(applicationAppManager), address(freeNFTUp));


        applicationAppManager.registerToken("BlindSailersUp", address(mintForAFeeNFTUp));
        applicationAppManager.registerToken("MonkeysPlayingInBonsaiTreesUp", address(whitelistMintNFTUp));
        applicationAppManager.registerToken("ParkinsonBarbersUp", address(freeNFTUp));


        /// reset the user to the original
        switchToOriginalUser();
    }

    /**
     * @dev Deploy and set up ERC20 token with DIAMOND handler 
     */
    function setUpProcotolAndCreateERC20AndDiamondHandler() public {
        setUpProtocolAndAppManager();
        /// NOTE: this set up logic must be different because the handler must be owned by appAdministrator so it may be called directly. It still
        /// requires a token be attached and registered for permissions in appManager
        // this ERC20Handler has to be created specially so that the owner is the appAdministrator. This is so we can access it directly in the tests.
        switchToAppAdministrator();
        // create the ERC20 and connect it to its handler
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        setupApplicationCoinAndHandler(address(applicationCoin));
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        /// set up the pricer for erc20
        erc20Pricer = _createERC20Pricing();

        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// create an ERC721
        applicationNFT = _createERC721("FRANKENSTEIN", "FRK", applicationAppManager);
        setupApplicationNFTAndHandler(address(applicationNFT));
        /// register the token
        applicationAppManager.registerToken("FRANKENSTEIN", address(applicationNFT));
        /// set up the pricer for erc20
        erc721Pricer = _createERC721Pricing();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18)); //setting at $1
        switchToRuleAdmin(); 
        applicationHandler.setNFTPricingAddress(address(erc721Pricer));
        applicationHandler.setERC20PricingAddress(address(erc20Pricer));

        switchToAppAdministrator();

        oracleApproved = _createOracleApproved();
        oracleDenied = _createOracleDenied();
        /// reset the user to the original
        switchToOriginalUser();

    }

    

    ///---------------USER SWITCHING--------------------
    function switchToAppAdministrator() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
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

    /**
     * @dev Function to set the super admin as the calling address. It stores the current address for future resetting
     *
     */
    function switchToSuperAdminWithSave() public {
        priorAddress = msg.sender;
        vm.stopPrank();
        vm.startPrank(superAdmin);
    }

    /**
     * @dev Function to set the address back to the original user. It clears priorAddress
     *
     */
    function switchToOriginalUser() public {
        vm.stopPrank();
        vm.startPrank(priorAddress);
        priorAddress = address(0);
    }
}
