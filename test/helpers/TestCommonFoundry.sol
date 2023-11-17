// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/helpers/TestCommon.sol";

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
     * @dev Deploy and set up the Rules Storage Diamond
     * @return diamond fully configured storage diamond
     */
    function _createRuleStorageDiamond() internal returns (RuleStorageDiamond diamond) {
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
            // Protocol facets.
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
            _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

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
     * @dev Deploy and set up the Rules Processor Diamond
     * @param _storageDiamond preconfigured storage diamond
     * @return diamond fully configured rules processor diamond
     */
    function _createRulesProcessorDiamond(RuleStorageDiamond _storageDiamond) public returns (RuleProcessorDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[13] memory facets = [
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
            //TaggedRuleFacets:
            "ERC20TaggedRuleProcessorFacet",
            "ERC721TaggedRuleProcessorFacet",
            "RiskTaggedRuleProcessorFacet",
            "RuleApplicationValidationFacet"
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

        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessorInternal.setRuleDataDiamond(address(_storageDiamond));
        // Deploy the diamond.
        return ruleProcessorInternal;
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. StorageDiamond, 2. ProcessorDiamond, 3. configuring the ProcessorDiamond to point to the StorageDiamond
     */
    function setUpProtocol() public {
        switchToSuperAdmin();
        ruleStorageDiamond = _createRuleStorageDiamond();
        ruleProcessor = _createRulesProcessorDiamond(ruleStorageDiamond);
        /// reset the user to the original
        switchToOriginalUser();
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. StorageDiamond, 2. ProcessorDiamond, 3. configuring the ProcessorDiamond to point to the StorageDiamond, 4. AppManager
     */
    function setUpProtocolAndAppManager() public {
        switchToSuperAdminWithSave();
        ruleStorageDiamond = _createRuleStorageDiamond();
        ruleProcessor = _createRulesProcessorDiamond(ruleStorageDiamond);
        applicationAppManager = _createAppManager();
        switchToAppAdministrator(); // app admin should set up everything after creation of the appManager
        applicationAppManager.setNewApplicationHandlerAddress(address(_createAppHandler(ruleProcessor, applicationAppManager)));
        applicationHandler = ApplicationHandler(applicationAppManager.getHandlerAddress());
        /// reset the user to the original
        switchToOriginalUser();
    }

    /**
     * @dev Deploy and set up the main protocol contracts. This includes:
     * 1. StorageDiamond, 2. ProcessorDiamond, 3. configuring the ProcessorDiamond to point to the StorageDiamond, 4. AppManager with its handler connected, 5. ApplicationERC20 with its handler, and default price
     */
    function setUpProtocolAndAppManagerAndTokens() public {
        switchToSuperAdminWithSave();
        // create the rule storage diamond
        ruleStorageDiamond = _createRuleStorageDiamond();
        // create the rule processor diamond
        ruleProcessor = _createRulesProcessorDiamond(ruleStorageDiamond);
        // create the app manager
        applicationAppManager = _createAppManager();
        switchToAppAdministrator(); // app admin should set up everything after creation of the appManager
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

        // create a second ERC20 and connect it to its handler
        applicationCoin2 = _createERC20("DRACULA", "DRAC", applicationAppManager);
        applicationCoinHandler2 = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoin2);
        /// register the token
        applicationAppManager.registerToken("DRACULA", address(applicationCoin));

        erc20Pricer.setSingleTokenPrice(address(applicationCoin2), 1 * (10 ** 18)); //setting at $1

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
        /// reset the user to the original
        switchToOriginalUser();
    }

    /**
     * @dev Deploy and set up a protocol supported ERC721
     */

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
     * @dev Deploy and set up the Rules Storage Diamond. This includes sender setting/resetting
     * @return diamond fully configured storage diamond
     */
    function createRuleStorageDiamond() internal returns (RuleStorageDiamond diamond) {
        switchToSuperAdmin();
        RuleStorageDiamond d = _createRuleStorageDiamond();
        /// reset the user to the original
        switchToOriginalUser();
        return d;
    }

    /**
     * @dev Deploy and set up the Rules Processor Diamond. This includes sender setting/resetting
     * @param _storageDiamond preconfigured storage diamond
     * @return diamond fully configured rules processor diamond
     */
    function createRulesProcessorDiamond(RuleStorageDiamond _storageDiamond) public returns (RuleProcessorDiamond diamond) {
        switchToSuperAdmin();
        RuleProcessorDiamond d = _createRulesProcessorDiamond(_storageDiamond);
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

    /**
     * @dev Deploy and set up a ProtocolAMMFactory
     * @return _ammFactory fully configured app manager
     */
    function createProtocolAMMFactory() public returns (ProtocolAMMFactory _ammFactory) {
        switchToAppAdministrator();
        _ammFactory = _createProtocolAMMFactory();
        return _ammFactory;
    }

    /**
     * @dev Deploy and set up a ProtocolAMMCalculatorFactory
     * @return _ammCalcFactory fully configured app manager
     */
    function createProtocolAMMCalculatorFactory() public returns (ProtocolAMMCalculatorFactory _ammCalcFactory) {
        switchToAppAdministrator();
        _ammCalcFactory = _createProtocolAMMCalculatorFactory();
        return _ammCalcFactory;
    }


    ///---------------USER SWITCHING--------------------
    function switchToAppAdministrator() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationAppManager.addAppAdministrator(appAdministrator); //set a app administrator

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(appAdministrator); //interact as the created app administrator
    }

    function switchToAccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessTier(accessLevelAdmin); //add AccessLevel admin

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
    }

    function switchToRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add Risk admin

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(riskAdmin); //interact as the created Risk admin
    }

    function switchToRuleAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addRuleAdministrator(ruleAdmin); //add Rule admin

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(ruleAdmin); //interact as the created Rule admin
    }

    function switchToUser() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(user); //interact as the created AccessLevel admin
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
