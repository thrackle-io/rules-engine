// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "test/util/GenerateSelectors.sol";
import "test/util/TestArrays.sol";

/// common diamond imports
import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {SampleUpgradeFacet} from "src/protocol/diamond/SampleUpgradeFacet.sol";
import "src/protocol/diamond/ProtocolNativeFacet.sol";
import "src/protocol/diamond/ProtocolRawFacet.sol";
import {ERC173Facet} from "diamond-std/implementations/ERC173/ERC173Facet.sol";
import {VersionFacet} from "src/protocol/diamond/VersionFacet.sol";
/// Protocol Diamond imports
import {ERC20RuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import {ERC721TaggedRuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol";
import {ERC721RuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC721RuleProcessorFacet.sol";
import {RuleApplicationValidationFacet} from "src/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol";
import {ApplicationRiskProcessorFacet} from "src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol";
import {ApplicationPauseProcessorFacet} from "src/protocol/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol";
import {ApplicationAccessLevelProcessorFacet} from "src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol";
import {ApplicationRiskProcessorFacet} from "src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol";
import {TaggedRuleDataFacet} from "src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules, IApplicationRules as AppRules} from "src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol";
import {IAppLevelEvents, IAppManagerAddressSet, IOracleEvents, IApplicationHandlerEvents, ICommonApplicationHandlerEvents, IRuleProcessorDiamondEvents, IEconomicEvents, IHandlerDiamondEvents, ITokenHandlerEvents, IApplicationEvents, IIntegrationEvents, ITokenEvents} from "src/common/IEvents.sol";

/// Client Contract imports
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import {HandlerDiamond, HandlerDiamondArgs} from "src/client/token/handler/diamond/HandlerDiamond.sol";
import "src/example/application/ApplicationAppManager.sol";

import "src/example/ERC20/ApplicationERC20.sol";
import "src/example/ERC20/upgradeable/ApplicationERC20UMin.sol";

import {ApplicationERC721AdminOrOwnerMint as ApplicationERC721} from "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
//import "test/util/ApplicationERC721WithBatchMintBurn.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UProxy.sol";
import "src/example/ERC20/upgradeable/ApplicationERC20UProxy.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UpgAdminMint.sol";
import "src/example/ERC20/upgradeable/ApplicationERC20UMinUpgAdminMint.sol";
import "test/util/ApplicationERC721UExtra.sol";
import "test/util/ApplicationERC721UExtra2.sol";
import "test/util/MinimalERC20.sol";
import "test/util/MinimalERC721.sol";
import "test/util/MinimalERC721Legacy.sol";
import {UtilApplicationERC20} from "test/util/UtilApplicationERC20.sol";
import {UtilApplicationERC721} from "test/util/UtilApplicationERC721.sol";

import "src/client/application/data/IPauseRules.sol";
import "src/client/application/data/Tags.sol";
import "src/client/application/data/PauseRules.sol";
import "src/client/application/data/AccessLevels.sol";
import "src/client/application/data/RiskScores.sol";

import "src/client/token/handler/diamond/ERC20TaggedRuleFacet.sol";
import "src/client/token/handler/diamond/ERC20NonTaggedRuleFacet.sol";
import "src/client/token/handler/diamond/ERC721TaggedRuleFacet.sol";
import "src/client/token/handler/diamond/ERC721NonTaggedRuleFacet.sol";
import "src/client/token/handler/diamond/TradingRuleFacet.sol";
import {FeesFacet} from "src/client/token/handler/diamond/FeesFacet.sol";
import {ERC20HandlerMainFacet} from "src/client/token/handler/diamond/ERC20HandlerMainFacet.sol";
import {ERC721HandlerMainFacet} from "src/client/token/handler/diamond/ERC721HandlerMainFacet.sol";
import "src/client/token/handler/diamond/FeesFacet.sol";
import "src/client/token/handler/diamond/RuleStorage.sol";
import {HandlerVersionFacet} from "src/client/token/handler/diamond/HandlerVersionFacet.sol";
/// common imports
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";
import "src/example/OracleDenied.sol";
import "src/example/OracleApproved.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import "./CommonAddresses.sol";
import {DummyAcceptor} from "test/client/token/TestTokenCommon.sol";

/**
 * @title Test Common
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests. NOTE: function prefixes and their usages are as follows:
 * setup = set to proper user, deploy contracts, set global variables, reset user
 * create = set to proper user, deploy contracts, reset user, return the contract
 * _create = deploy contract, return the contract
 */
abstract contract TestCommon is
    Test,
    GenerateSelectors,
    TestArrays,
    CommonAddresses,
    IAppLevelEvents,
    IAppManagerAddressSet,
    IOracleEvents,
    IApplicationHandlerEvents,
    ICommonApplicationHandlerEvents,
    IRuleProcessorDiamondEvents,
    IEconomicEvents,
    IHandlerDiamondEvents,
    ITokenHandlerEvents,
    IApplicationEvents,
    IIntegrationEvents,
    ITokenEvents
{
    FacetCut[] _ruleProcessorFacetCuts;

    uint256 constant ATTO = 10 ** 18;
    uint256 constant BIGNUMBER = 10 ** 70;

    // shared objects
    RuleProcessorDiamond public ruleProcessor;

    ApplicationAppManager public applicationAppManager;
    ApplicationHandler public applicationHandler;
    ApplicationAppManager public applicationAppManager2;
    ApplicationHandler public applicationHandler2;
    // ApplicationAssetHandlerMod public newAssetHandler;

    MinimalERC20 public minimalCoin;
    ApplicationERC20UMin public minimalUCoin;
    ApplicationERC20UMin public minimalUCoin2;
    UtilApplicationERC20 public applicationCoin;
    UtilApplicationERC20 public applicationCoin2;
    HandlerDiamond public applicationCoinHandler;
    HandlerDiamond public applicationCoinHandler2;
    HandlerDiamond public applicationCoinHandlerUMin;
    HandlerDiamond public applicationCoinHandlerUMin2;
    HandlerDiamond public applicationNFTHandler;
    HandlerDiamond public applicationNFTHandler2;
    HandlerDiamond public applicationNFTHandlerv2;
    ApplicationERC20Pricing public erc20Pricer;
    HandlerDiamond public applicationCoinHandlerSpecialOwner;

    UtilApplicationERC721 public applicationNFT;
    UtilApplicationERC721 public applicationNFTv2;
    MinimalERC721 public minimalNFT;
    MinimalERC721Legacy public minimalNFTLegacy;
    // ApplicationERC721HandlerMod public ERC721AssetHandler;
    ApplicationERC721Pricing public erc721Pricer;

    ApplicationERC721UpgAdminMint public applicationNFTU;
    ApplicationERC721UpgAdminMint public applicationNFT2;
    ApplicationERC721UExtra public applicationNFTExtra;
    ApplicationERC721UExtra2 public applicationNFTExtra2;
    ApplicationERC721UProxy public applicationNFTProxy;
    ApplicationERC20UProxy public applicationCoinProxy;

    OracleApproved public oracleApproved;
    OracleDenied public oracleDenied;

    UtilApplicationERC721 public boredWhaleNFT;
    HandlerDiamond public boredWhaleHandler;
    UtilApplicationERC721 public boredReptilianNFT;
    HandlerDiamond public boredReptileHandler;
    UtilApplicationERC20 public boredCoin;
    HandlerDiamond public boredCoinHandler;
    UtilApplicationERC20 public reptileToken;
    HandlerDiamond public reptileTokenHandler;

    ApplicationERC721Pricing public openOcean;
    ApplicationERC20Pricing public uniBase;

    DummyAcceptor public testAppManager; 

    bool public testDeployments = true;

    // common block time
    uint64 Blocktime = 1769924800;

    // common starting time
    uint32 startTime = 12;

    // common starting supply
    uint256 totalSupply = 100_000_000_000;

    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 public constant TREASURY_ACCOUNT = keccak256("TREASURY_ACCOUNT");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_LEVEL_ADMIN_ROLE = keccak256("ACCESS_LEVEL_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    bytes32 public constant PROPOSED_SUPER_ADMIN_ROLE = keccak256("PROPOSED_SUPER_ADMIN_ROLE");
    bytes32 public constant RULE_ADMIN_ROLE = keccak256("RULE_ADMIN_ROLE");
    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
    uint8 public constant MAX_ACTION_TYPES = 4;

    /**
     * @dev Deploy and set up an AppManager
     * @return _appManager fully configured app manager
     */
    function _createAppManager() public virtual returns (ApplicationAppManager _appManager) {
        vm.expectEmit(true, true, false, false);
        emit AD1467_AppManagerDeployed(superAdmin, "Castlevania");
        _appManager = new ApplicationAppManager(superAdmin, "Castlevania", false);
        return _appManager;
    }

    /**
     * @dev Deploy and set up an AppHandler
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @return _applicationHandler application handler
     */
    function _createAppHandler(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager) public returns (ApplicationHandler _applicationHandler) {
        vm.expectEmit(true, false, false, false);
        emit AD1467_ApplicationHandlerDeployed(address(_appManager));
        return new ApplicationHandler(address(_ruleProcessor), address(_appManager));
    }

    /**
     * @dev Deploy and set up an ERC20
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC20(string memory _name, string memory _symbol, ApplicationAppManager _appManager) public returns (UtilApplicationERC20 _token) {
        return new UtilApplicationERC20(_name, _symbol, address(_appManager));
    }

    /**
     * @dev Deploy and set up a minimal protocol ERC20
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC20Min(string memory _name, string memory _symbol, ApplicationAppManager _appManager) public returns (MinimalERC20 _token) {
        return new MinimalERC20(_name, _symbol, address(_appManager));
    }

    /**
     * @dev Deploy and set up an ERC20Handler
     * @return _pricer ERC20 pricer
     */
    function _createERC20Pricing() public returns (ApplicationERC20Pricing _pricer) {
        return new ApplicationERC20Pricing();
    }

    /**
     * @dev Deploy and set up an ERC721 Upgradeable
     * @return _token token
     */
    function _createERC20UMin() public returns (ApplicationERC20UMinUpgAdminMint _token) {
        return new ApplicationERC20UMinUpgAdminMint();
    }

    /**
     * @dev Deploy and set up an ERC20 Upgradeable Proxy
     * @param _applicationCoinU logic contract
     * @param _proxyOwner address of the proxy owner
     * @return _proxy token
     */
    function _createERC20UpgradeableProxy(address _applicationCoinU, address _proxyOwner) public returns (ApplicationERC20UProxy _proxy) {
        return new ApplicationERC20UProxy(address(_applicationCoinU), _proxyOwner, "");
    }

    /**
     * @dev Deploy and set up an ERC721
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC721(string memory _name, string memory _symbol, ApplicationAppManager _appManager) public returns (UtilApplicationERC721 _token) {
        return new UtilApplicationERC721(_name, _symbol, address(_appManager), "https://SampleApp.io");
    }

    /**
     * @dev Deploy and set up a Minimal ERC721
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC721Min(string memory _name, string memory _symbol, ApplicationAppManager _appManager) public returns (MinimalERC721 _token) {
        return new MinimalERC721(_name, _symbol, address(_appManager), "https://SampleApp.io");
    }

    /**
     * @dev Deploy and set up an ERC721 Upgradeable
     * @return _token token
     */
    function _createERC721Upgradeable() public returns (ApplicationERC721UpgAdminMint _token) {
        return new ApplicationERC721UpgAdminMint();
    }

    /**
     * @dev Deploy and set up an ERC721 Upgradeable Proxy
     * @param _applicationNFTU logic contract
     * @param _proxyOwner address of the proxy owner
     * @return _proxy token
     */
    function _createERC721UpgradeableProxy(address _applicationNFTU, address _proxyOwner) public returns (ApplicationERC721UProxy _proxy) {
        return new ApplicationERC721UProxy(address(_applicationNFTU), _proxyOwner, "");
    }

    /**
     * @dev Deploy and set up an ERC721Handler
     * @return _pricer ERC721 pricer
     */
    function _createERC721Pricing() public returns (ApplicationERC721Pricing _pricer) {
        return new ApplicationERC721Pricing();
    }

    /**
     * @dev Deploy Allowed Oracle
     * @return _oracleAllowed address
     */
    function _createOracleApproved() public returns (OracleApproved _oracleAllowed) {
        vm.expectEmit(false, false, false, false);
        emit AD1467_ApproveListOracleDeployed();
        return new OracleApproved();
    }

    /**
     * @dev Deploy Oracle contracts
     * @return _oracleDenied address
     */
    function _createOracleDenied() public returns (OracleDenied _oracleDenied) {
        vm.expectEmit(false, false, false, false);
        emit AD1467_DeniedListOracleDeployed();
        return new OracleDenied();
    }

    function _createActionsArray() public pure returns (ActionTypes[] memory) {
        ActionTypes[] memory actionTypes = new ActionTypes[](1);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        return actionTypes;
    }

    function _createActionsArray(ActionTypes action) public pure returns (ActionTypes[] memory) {
        ActionTypes[] memory actionTypes = new ActionTypes[](1);
        actionTypes[0] = action;
        return actionTypes;
    }
}
