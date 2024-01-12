// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

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
import {ERC173Facet} from "diamond-std/implementations/ERC173/ERC173Facet.sol";
import {VersionFacet} from "src/protocol/diamond/VersionFacet.sol";
/// Protocol Diamond imports 
import {ERC20RuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import {ERC721TaggedRuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol";
import {ApplicationAccessLevelProcessorFacet} from "src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol";
import {TaggedRuleDataFacet} from "src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules} from "src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol";
/// ERC721 Example test imports 
import {ApplicationERC721 as MintForAFeeERC721} from "src/example/ERC721/ApplicationERC721MintForAFee.sol";
import {ApplicationERC721 as WhitelistMintERC721} from "src/example/ERC721/ApplicationERC721WhitelistMint.sol";
import {ApplicationERC721 as FreeForAllERC721} from "src/example/ERC721/ApplicationERC721FreeMint.sol";
import {ApplicationERC721HandlerMod} from "test/util/ApplicationERC721HandlerMod.sol";
import {ApplicationERC721Upgradeable as MintForAFeeERC721Upgradeable} from "src/example/ERC721/upgradeable/ApplicationERC721UpgMintForAFee.sol";
import {ApplicationERC721Upgradeable as WhitelistMintERC721Upgradeable} from "src/example/ERC721/upgradeable/ApplicationERC721UpgWhitelistMint.sol";
import {ApplicationERC721Upgradeable as FreeForAllERC721Upgradeable} from "src/example/ERC721/upgradeable/ApplicationERC721UpgFreeMint.sol";
import {ApplicationERC721HandlerMod} from "test/util/ApplicationERC721HandlerMod.sol";

/// Client Contract imports 
import {ApplicationAssetHandlerMod} from "test/util/ApplicationAssetHandlerMod.sol";
import {ApplicationERC721HandlerMod} from "test/util/ApplicationERC721HandlerMod.sol";
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import "src/example/application/ApplicationAppManager.sol";

import "src/example/ERC20/ApplicationERC20.sol";
import "src/example/ERC20/ApplicationERC20Handler.sol";

import "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import "src/example/ERC721/ApplicationERC721Handler.sol";
import "test/util/ApplicationERC721WithBatchMintBurn.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UProxy.sol";
import "src/example/ERC721/upgradeable/ApplicationERC721UpgAdminMint.sol";
import "test/util/ApplicationERC721UExtra.sol";
import "test/util/ApplicationERC721UExtra2.sol";

import "src/client/application/data/IPauseRules.sol";
import "src/client/token/data/Fees.sol";
import "src/client/application/data/GeneralTags.sol";
import "src/client/application/data/PauseRules.sol";
import "src/client/application/data/AccessLevels.sol";
import "src/client/application/data/RiskScores.sol";
import "src/client/application/data/Accounts.sol";
import "src/client/application/data/IDataModule.sol";
import "src/client/token/IAdminWithdrawalRuleCapable.sol";
/// common imports 
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";
import "src/example/OracleDenied.sol";
import "src/example/OracleAllowed.sol";
import "src/protocol/economic/ruleProcessor/ActionEnum.sol";


/**
 * @title Test Common
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests. NOTE: function prefixes and their usages are as follows:
 * setup = set to proper user, deploy contracts, set global variables, reset user
 * create = set to proper user, deploy contracts, reset user, return the contract
 * _create = deploy contract, return the contract
 */
abstract contract TestCommon is Test, GenerateSelectors, TestArrays {
    FacetCut[] _ruleProcessorFacetCuts;

    uint256 constant ATTO = 10 ** 18;

    // common addresses
    address superAdmin = address(0xDaBEEF);
    address appAdministrator = address(0xDEAD);
    address ruleBypassAccount = address(0xAAA);
    address ruleAdmin = address(0xACDC);
    address accessLevelAdmin = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address user = address(0xDDD);
    address bob = address(0xB0B);
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address user4 = address(44);
    address user5 = address(55);
    address user6 = address(66);
    address user7 = address(77);
    address user8 = address(88);
    address user9 = address(99);
    address user10 = address(100);
    address transferFromUser = address(110);
    address accessTier = address(3);
    address rich_user = address(45);
    address proxyOwner = address(787);
    address priorAddress;
    address[] badBoys;
    address[] goodBoys;

    // shared objects
    RuleProcessorDiamond public ruleProcessor;

    ApplicationAppManager public applicationAppManager;
    ApplicationHandler public applicationHandler;
    ApplicationAppManager public applicationAppManager2;
    ApplicationHandler public applicationHandler2;
    ApplicationAssetHandlerMod public newAssetHandler;

    ApplicationERC20 public applicationCoin;
    ApplicationERC20 public applicationCoin2;
    ApplicationERC20Handler public applicationCoinHandler;
    ApplicationERC20Handler public applicationCoinHandler2;
    ApplicationERC20Handler public applicationCoinHandlerSpecialOwner;
    ApplicationERC20Pricing public erc20Pricer;

    ApplicationERC721 public applicationNFT;
    ApplicationERC721Handler public applicationNFTHandler;
    ApplicationERC721Handler public applicationNFTHandler2;
    ApplicationERC721HandlerMod public ERC721AssetHandler;
    ApplicationERC721Pricing public erc721Pricer;

    ApplicationERC721Upgradeable public applicationNFTU;
    ApplicationERC721Upgradeable public applicationNFT2;
    ApplicationERC721UExtra public applicationNFTExtra;
    ApplicationERC721UExtra2 public applicationNFTExtra2;
    ApplicationERC721UProxy public applicationNFTProxy;

    OracleAllowed public oracleAllowed;
    OracleDenied public oracleDenied; 

    ApplicationERC721 public boredWhaleNFT;
    ApplicationERC721Handler public boredWhaleHandler;
    ApplicationERC721 public boredReptilianNFT;
    ApplicationERC721Handler public boredReptileHandler;
    ApplicationERC721Pricing public openOcean; 

    MintForAFeeERC721 public mintForAFeeNFT;
    WhitelistMintERC721 public whitelistMintNFT;
    FreeForAllERC721 public freeNFT;
    MintForAFeeERC721Upgradeable public mintForAFeeNFTUpImplementation;
    WhitelistMintERC721Upgradeable public whitelistMintNFTUpImplementation;
    FreeForAllERC721Upgradeable public freeNFTUpImplementation;
    ApplicationERC721UProxy public mintForAFeeNFTUp;
    ApplicationERC721UProxy public whitelistMintNFTUp;
    ApplicationERC721UProxy public freeNFTUp;
    ApplicationERC721Handler public MintForAFeeNFTHandler;
    ApplicationERC721Handler public WhitelistNFTHandler;
    ApplicationERC721Handler public FreeForAllnNFTHandler;
    ApplicationERC721Handler public MintForAFeeNFTHandlerUp;
    ApplicationERC721Handler public WhitelistNFTHandlerUp;
    ApplicationERC721Handler public FreeForAllnNFTHandlerUp;

    // common block time
    uint64 Blocktime = 1769924800;

    // common starting time 
    uint32 startTime = 12;

    // common starting supply 
    uint256 totalSupply = 100_000_000_000;

    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 public constant RULE_BYPASS_ACCOUNT = keccak256("RULE_BYPASS_ACCOUNT");
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    bytes32 public constant PROPOSED_SUPER_ADMIN_ROLE = keccak256("PROPOSED_SUPER_ADMIN_ROLE");

    /**
     * @dev Deploy and set up an AppManager
     * @return _appManager fully configured app manager
     */
    function _createAppManager() public virtual returns (ApplicationAppManager _appManager) {
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
     * @dev Deploy and set up an ERC20Handler specialized for Handler Testing 
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC20
     * @param _appAdmin App Admin Address 
     * @return _handler ERC20 handler
     */
    function _createERC20HandlerSpecialized(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager,ApplicationERC20 _token, address _appAdmin) public returns (ApplicationERC20Handler _handler) {
        _handler = new ApplicationERC20Handler(address(_ruleProcessor), address(_appManager), address(_appAdmin), false);
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
     * @dev Deploy and set up an ERC721
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC721(string memory _name, string memory _symbol, ApplicationAppManager _appManager) public returns (ApplicationERC721 _token) {
        return new ApplicationERC721(_name, _symbol, address(_appManager), "https://SampleApp.io");
    }

    /**
     * @dev Deploy and set up an ERC721 Mint Fee 
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC721MintFee(string memory _name, string memory _symbol, ApplicationAppManager _appManager, uint256 price) public returns (MintForAFeeERC721 _token) {
        return new MintForAFeeERC721(_name, _symbol, address(_appManager), "blindsailers.com/iseeyou", price);
    }

    /**
     * @dev Deploy and set up an ERC721 free for all 
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC721Free(string memory _name, string memory _symbol, ApplicationAppManager _appManager) public returns (FreeForAllERC721 _token) {
        return new FreeForAllERC721(_name, _symbol, address(_appManager), "bloodinmyhands.com/bookyourcut");
    
    }
    /**
     * @dev Deploy and set up an ERC721 allowList 
     * @param _name token name
     * @param _symbol token symbol
     * @param _appManager previously created appManager
     * @return _token token
     */
    function _createERC721Whitelist(string memory _name, string memory _symbol, ApplicationAppManager _appManager, uint8 _mintsAllowed) public returns (WhitelistMintERC721 _token) {
        return new WhitelistMintERC721(_name, _symbol, address(_appManager), "monkeysdontknowwhattodo.com/havingfun", _mintsAllowed);
    }

    /**
     * @dev Deploy and set up an ERC721 Upgradeable
     * @return _token token
     */
    function _createERC721Upgradeable() public returns (ApplicationERC721Upgradeable _token) {
        return new ApplicationERC721Upgradeable();
    }

    /**
     * @dev Deploy and set up an ERC721 Upgradeable Fee Mint 
     * @return _token token
     */
    function _createERC721UpgradeableFeeMint() public returns (MintForAFeeERC721Upgradeable _token) {
        return new MintForAFeeERC721Upgradeable();
    }

    /**
     * @dev Deploy and set up an ERC721 Upgradeable AllowList
     * @return _token token
     */
    function _createERC721UpgradeableAllowList() public returns (WhitelistMintERC721Upgradeable _token) {
        return new WhitelistMintERC721Upgradeable();
    }

    /**
     * @dev Deploy and set up an ERC721 Upgradeable Free For All 
     * @return _token token
     */
    function _createERC721UpgradeableFreeForAll() public returns (FreeForAllERC721Upgradeable _token) {
        return new FreeForAllERC721Upgradeable();
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
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC721
     * @return _handler ERC721 handler
     */
    function _createERC721Handler(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager, ApplicationERC721 _token) public returns (ApplicationERC721Handler _handler) {
        _handler = new ApplicationERC721Handler(address(_ruleProcessor), address(_appManager), address(_token), false);
        _token.connectHandlerToToken(address(_handler));
        return _handler;
    }

    /**
     * @dev Deploy and set up an ERC721Handler Mint Fee 
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC721
     * @return _handler ERC721 handler
     */
    function _createERC721HandlerMintFee(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager, MintForAFeeERC721 _token) public returns (ApplicationERC721Handler _handler) {
        _handler = new ApplicationERC721Handler(address(_ruleProcessor), address(_appManager), address(_token), false);
        _token.connectHandlerToToken(address(_handler));
        return _handler;
    }

    /**
     * @dev Deploy and set up an ERC721Handler Allow List 
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC721
     * @return _handler ERC721 handler
     */
    function _createERC721HandlerAllowList(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager, WhitelistMintERC721 _token) public returns (ApplicationERC721Handler _handler) {
        _handler = new ApplicationERC721Handler(address(_ruleProcessor), address(_appManager), address(_token), false);
        _token.connectHandlerToToken(address(_handler));
        return _handler;
    }

    /**
     * @dev Deploy and set up an ERC721Handler Free Mint 
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC721
     * @return _handler ERC721 handler
     */
    function _createERC721HandlerFreeMint(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager, FreeForAllERC721 _token) public returns (ApplicationERC721Handler _handler) {
        _handler = new ApplicationERC721Handler(address(_ruleProcessor), address(_appManager), address(_token), false);
        _token.connectHandlerToToken(address(_handler));
        return _handler;
    }

    /**
     * @dev Deploy and set up an ERC721HandlerForProxy
     * @param _ruleProcessor rule processor
     * @param _appManager previously created appManager
     * @param _token ERC721
     * @return _handler ERC721 handler
     */
    function _createERC721HandlerForProxy(RuleProcessorDiamond _ruleProcessor, ApplicationAppManager _appManager, ApplicationERC721UProxy _token) public returns (ApplicationERC721Handler _handler) {
        _handler = new ApplicationERC721Handler(address(_ruleProcessor), address(_appManager), address(_token), false);
        ApplicationERC721Upgradeable(address(_token)).connectHandlerToToken(address(_handler));
        return _handler;
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
    function _createOracleAllowed() public returns (OracleAllowed _oracleAllowed){
        return new OracleAllowed(); 
    }

    /** 
     * @dev Deploy Oracle contracts 
     * @return _oracleDenied address
     */
    function _createOracleDenied() public returns (OracleDenied _oracleDenied){
        return new OracleDenied(); 
    }
}
