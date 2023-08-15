// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "src/example/ApplicationAppManager.sol";
import "src/example/application/ApplicationHandler.sol";
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";
import "src/example/ApplicationERC20.sol";
import "src/example/ApplicationERC20Handler.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "src/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {RuleStorageDiamond, RuleStorageDiamondArgs} from "src/economic/ruleStorage/RuleStorageDiamond.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";

/**
 * @title Test Common
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests. NOTE: function prefixes and their usages are as follows:
 * setup = set to proper user, deploy contracts, set global variables, reset user
 * create = set to proper user, deploy contracts, reset user, return the contract
 * _create = deploy contract, return the contract
 */
abstract contract TestCommon is Test {
    FacetCut[] _ruleProcessorFacetCuts;
    FacetCut[] _ruleStorageFacetCuts;

    // common addresses
    address superAdmin = address(0xDaBEEF);
    address appAdministrator = address(0xDEAD);
    address ruleAdmin = address(0xACDC);
    address accessLevelAdmin = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address user = address(0xDDD);
    address priorAddress;
    // shared objects
    ApplicationAppManager public applicationAppManager;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationHandler applicationHandler;
    ApplicationERC20 applicationCoin;
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;

    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

    /**
     * @dev Deploy and set up the Rules Storage Diamond
     * @return diamond fully configured storage diamond
     */
    function _createRuleStorageDiamond() internal returns (RuleStorageDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[6] memory facets = [
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
        string[12] memory facets = [
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
     * @dev Deploy and set up an AppManager
     * @return _appManager fully configured app manager
     */
    function _createAppManager() public returns (ApplicationAppManager _appManager) {
        _appManager = new ApplicationAppManager(superAdmin, "Castlevania", false);
        assertTrue(_appManager.isSuperAdmin(superAdmin));
        return _appManager;
    }

    /**
     * @dev Deploy and set up an AppHandler
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @return _applicationHandler application handler
     */
    function _createAppHandler(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager) public returns (ApplicationHandler _applicationHandler) {
        return new ApplicationHandler(address(_ruleProcessor), address(_appManager));
    }

    /**
     * @dev Deploy and set up an ERC20
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC20(string memory _name, string memory _symbol, ApplicationAppManager _appManager) public returns (ApplicationERC20 _token) {
        return new ApplicationERC20(_name, _symbol, address(_appManager));
    }

    /**
     * @dev Deploy and set up an ERC20Handler
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC20
     * @return _handler ERC20 handler
     */
    function _createERC20Handler(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager, ApplicationERC20 _token) public returns (ApplicationERC20Handler _handler) {
        _handler = new ApplicationERC20Handler(address(_ruleProcessor), address(_appManager), address(_token), false);
        _token.connectHandlerToToken(address(_handler));
        return _handler;
    }

    /**
     * @dev Deploy and set up an ERC20Handler
     * @return _pricer ERC20 pricer
     */
    function _createERC20Pricing() public returns (ApplicationERC20Pricing _pricer) {
        return new ApplicationERC20Pricing();
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
     * 1. StorageDiamond, 2. ProcessorDiamond, 3. configuring the ProcessorDiamond to point to the StorageDiamond, 4. AppManager with its handler connected, 5. ApplicationERC20 with its handler, minted tokens, and default price
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
        // creat the ERC20 and connect it to its handler
        applicationCoin = _createERC20("FRANK", "FRK", applicationAppManager);
        applicationCoinHandler = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoin);
        /// register the token
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * (10 ** 18));
        erc20Pricer = _createERC20Pricing();
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1

        /// reset the user to the original
        switchToOriginalUser();
    }

    /**
     * @dev Deploy and set up a protocol supported ERC20
     */
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

    ///---------------USER SWITCHING--------------------
    function switchToAppAdministrator() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationAppManager.addAppAdministrator(appAdministrator); //set a app administrator
        assertEq(applicationAppManager.isAppAdministrator(appAdministrator), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(appAdministrator); //interact as the created app administrator
    }

    function switchToAccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addAccessTier(accessLevelAdmin); //add AccessLevel admin
        assertEq(applicationAppManager.isAccessTier(accessLevelAdmin), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
    }

    function switchToRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addRiskAdmin(riskAdmin); //add Risk admin
        assertEq(applicationAppManager.isRiskAdmin(riskAdmin), true);

        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(riskAdmin); //interact as the created Risk admin
    }

    function switchToRuleAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.

        applicationAppManager.addRuleAdministrator(ruleAdmin); //add Rule admin
        assertEq(applicationAppManager.isRuleAdministrator(ruleAdmin), true);

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
