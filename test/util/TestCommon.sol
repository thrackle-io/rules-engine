// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "example/application/ApplicationAppManager.sol";
import "example/application/ApplicationHandler.sol";
import "example/pricing/ApplicationERC20Pricing.sol";
import "example/ERC20/ApplicationERC20.sol";
import "example/ERC20/ApplicationERC20Handler.sol";
import "example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import "example/ERC721/ApplicationERC721Handler.sol";
import "example/pricing/ApplicationERC721Pricing.sol";
import "src/client/liquidity/ProtocolERC20AMM.sol";
import "src/client/liquidity/ProtocolAMMFactory.sol";
import "src/client/liquidity/ProtocolAMMCalculatorFactory.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";

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

    uint256 constant ATTO = 10 ** 18;

    // common addresses
    address superAdmin = address(0xDaBEEF);
    address appAdministrator = address(0xDEAD);
    address ruleAdmin = address(0xACDC);
    address accessLevelAdmin = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address user = address(0xAAA);
    address priorAddress;
    // shared objects
    ApplicationAppManager public applicationAppManager;
    RuleProcessorDiamond ruleProcessor;
    ApplicationHandler applicationHandler;
    ApplicationERC20 applicationCoin;
    ApplicationERC20 applicationCoin2;
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721 applicationNFT;
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationERC721Pricing erc721Pricer;
    ProtocolAMMFactory protocolAMMFactory;
    ProtocolAMMCalculatorFactory protocolAMMCalculatorFactory;
    ProtocolERC20AMM protocolAMM;
    ProtocolERC721AMM dualLinearERC271AMM;
    // common block time
    uint64 Blocktime = 1769924800;

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
     * @dev Deploy and set up an ProtocolAMMFactory
     * @return _ammFactory ProtocolAMMFactory
     */
    function _createProtocolAMMFactory() public returns (ProtocolAMMFactory _ammFactory) {
        return new ProtocolAMMFactory(address(_createProtocolAMMCalculatorFactory()));
    }

    /**
     * @dev Deploy and set up an ProtocolAMMCalculatorFactory
     * @return _ammCalcFactory ProtocolAMMCalculatorFactory
     */
    function _createProtocolAMMCalculatorFactory() public returns (ProtocolAMMCalculatorFactory _ammCalcFactory) {
        return new ProtocolAMMCalculatorFactory();
    }
}
