// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "test/util/GenerateSelectors.sol";
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
/// Client Contract imports 
import {ApplicationAssetHandlerMod} from "test/util/ApplicationAssetHandlerMod.sol";
import {ApplicationERC721HandlerMod} from "test/util/ApplicationERC721HandlerMod.sol";
import "example/application/ApplicationAppManager.sol";
import "example/application/ApplicationHandler.sol";
import "example/ERC20/ApplicationERC20.sol";
import "example/ERC20/ApplicationERC20Handler.sol";
import "example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import "example/ERC721/ApplicationERC721Handler.sol";
import "test/util/ApplicationERC721WithBatchMintBurn.sol";
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
import "example/pricing/ApplicationERC20Pricing.sol";
import "example/pricing/ApplicationERC721Pricing.sol";
import "example/OracleDenied.sol";
import "example/OracleAllowed.sol";


/**
 * @title Test Common
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests. NOTE: function prefixes and their usages are as follows:
 * setup = set to proper user, deploy contracts, set global variables, reset user
 * create = set to proper user, deploy contracts, reset user, return the contract
 * _create = deploy contract, return the contract
 */
abstract contract TestCommon is Test, GenerateSelectors {
    FacetCut[] _ruleProcessorFacetCuts;

    // common addresses
    address superAdmin = address(0xDaBEEF);
    address appAdministrator = address(0xDEAD);
    address ruleAdmin = address(0xACDC);
    address accessLevelAdmin = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address user = address(0xDDD);
    address priorAddress;
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
    ApplicationERC20Handler public applicationCoinHandler;
    ApplicationERC20Handler public applicationCoinHandler2;
    ApplicationERC20Pricing public erc20Pricer;

    ApplicationERC721 public applicationNFT;
    ApplicationERC721Handler public applicationNFTHandler;
    ApplicationERC721Handler public applicationNFTHandler2;
    ApplicationERC721HandlerMod public ERC721AssetHandler;
    ApplicationERC721Pricing public erc721Pricer;

    OracleAllowed public oracleAllowed;
    OracleDenied public oracleDenied; 

    ApplicationERC721 public boredWhaleNFT;
    ApplicationERC721Handler public boredWhaleHandler;
    ApplicationERC721 public boredReptilianNFT;
    ApplicationERC721Handler public boredReptileHandler;
    ApplicationERC721Pricing public openOcean; 


    // common block time
    uint64 Blocktime = 1769924800;

    // common starting time 
    uint32 startTime = 12;

    // common starting supply 
    uint256 totalSupply = 100_000_000_000;

    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

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
