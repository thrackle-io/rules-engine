// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {StorageLib as lib} from "../diamond/StorageLib.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import "../../../application/IAppManager.sol";
import "./RuleStorage.sol";
import "../../ITokenInterface.sol";
import "../common/AppAdministratorOrOwnerOnlyDiamondVersion.sol";
import "../ruleContracts/HandlerAccountApproveDenyOracle.sol";
import "../ruleContracts/HandlerTokenMaxSupplyVolatility.sol";
import "../ruleContracts/HandlerTokenMaxTradingVolume.sol";
import "../ruleContracts/HandlerTokenMinTxSize.sol";
import "../ruleContracts/HandlerTokenMinHoldTime.sol";
import "../ruleContracts/HandlerTokenMaxDailyTrades.sol";

contract ERC721NonTaggedRuleFacet is
    AppAdministratorOrOwnerOnlyDiamondVersion,
    HandlerAccountApproveDenyOracle,
    HandlerTokenMaxSupplyVolatility,
    HandlerTokenMaxTradingVolume,
    HandlerTokenMinTxSize,
    HandlerTokenMinHoldTime,
    HandlerTokenMaxDailyTrades
{
    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _tokenId id of the NFT being transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkNonTaggedRules(ActionTypes action, address _from, address _to, uint256 _amount, uint256 _tokenId) external onlyOwner {
        _from;
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        address handlerBase = handlerBaseStorage.ruleProcessor;
        if (lib.tokenMinTxSizeStorage().tokenMinTxSize[action].active) {
            _checkTokenMinTxSizeRule(_amount, action, handlerBase);
        }

        _checkAccountApproveDenyOraclesRule(_from, _to, action, handlerBase);

        if (lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[action]) {
            _checkTokenMaxTradingVolumeRule(_amount, handlerBase);
        }

        if (lib.tokenMaxSupplyVolatilityStorage().tokenMaxSupplyVolatility[action] && (_from == address(0x00) || _to == address(0x00))) {
            _checkTokenMaxSupplyVolatilityRule(_to, _amount, handlerBase);
        }

        if (lib.tokenMaxDailyTradesStorage().tokenMaxDailyTrades[action].active) {
           _checkTokenMaxDailyTradesRule(action, _tokenId);
        }
        _checkSimpleRules(action, _tokenId, handlerBase);
    }

    /**
     * @dev Internal function to check the Token Min Transaction Size rule 
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     * @param handlerBase address of the handler proxy
     */
    function _checkTokenMinTxSizeRule(uint256 _amount, ActionTypes action, address handlerBase) internal view {
        IRuleProcessor(handlerBase).checkTokenMinTxSize(lib.tokenMinTxSizeStorage().tokenMinTxSize[action].ruleId, _amount);
    }

    /**
     * @dev Internal function to check the Account Approve Deny Oracle Rules 
     * @param _from address of the from account
     * @param _to address of the to account
     * @param action if selling or buying (of ActionTypes type)
     * @param handlerBase address of the handler proxy
     */
    function _checkAccountApproveDenyOraclesRule(address _from, address _to, ActionTypes action, address handlerBase) internal view {
        mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
        /// The action type determines if the _to or _from is checked by the oracle
        /// _from address is checked for Burn and Sell action types
        if (action == ActionTypes.BURN || action == ActionTypes.SELL){
            IRuleProcessor(handlerBase).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _from);
        } 
        /// _to address is checked  for Mint, Buy, Transfer actions 
        if (action == ActionTypes.MINT || action == ActionTypes.BUY || action == ActionTypes.P2P_TRANSFER){
            IRuleProcessor(handlerBase).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _to);
        }
    }

    /**
     * @dev Internal function to check the Token Max Trading Volume rule 
     * @param _amount number of tokens transferred
     * @param handlerBase address of the handler proxy
     */
    function _checkTokenMaxTradingVolumeRule(uint256 _amount, address handlerBase) internal {
        TokenMaxTradingVolumeS storage maxTradingVolume = lib.tokenMaxTradingVolumeStorage();
        maxTradingVolume.transferVolume = IRuleProcessor(handlerBase).checkTokenMaxTradingVolume(
            maxTradingVolume.ruleId,
            maxTradingVolume.transferVolume,
            IToken(msg.sender).totalSupply(),
            _amount,
            maxTradingVolume.lastTransferTime
        );
        maxTradingVolume.lastTransferTime = uint64(block.timestamp);
    }

    /**
     * @dev Internal function to check the Token Max Supply Volatility rule 
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param handlerBase address of the handler proxy
     */
    function _checkTokenMaxSupplyVolatilityRule(address _to, uint256 _amount, address handlerBase) internal {
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        TokenMaxSupplyVolatilityS storage maxSupplyVolatility = lib.tokenMaxSupplyVolatilityStorage();
        (maxSupplyVolatility.volumeTotalForPeriod, maxSupplyVolatility.totalSupplyForPeriod) = IRuleProcessor(handlerBase).checkTokenMaxSupplyVolatility(
            maxSupplyVolatility.ruleId,
            maxSupplyVolatility.volumeTotalForPeriod,
            maxSupplyVolatility.totalSupplyForPeriod,
            IToken(msg.sender).totalSupply(),
            _to == address(0x00) ? int(_amount) * -1 : int(_amount),
            maxSupplyVolatility.lastSupplyUpdateTime
        );
        maxSupplyVolatility.lastSupplyUpdateTime = uint64(block.timestamp);
    }

    /**
     * @dev Internal function to check the TokenMaxDailyTrades rule 
     * @param _tokenId id of the NFT being transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTokenMaxDailyTradesRule(ActionTypes action, uint256 _tokenId) internal {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        // get all the tags for this NFT
        bytes32[] memory tags = IAppManager(handlerBaseStorage.appManager).getAllTags(handlerBaseStorage.assetAddress);
        TokenMaxDailyTradesS storage maxDailyTrades = lib.tokenMaxDailyTradesStorage();
        // in order to prevent cross contamination of action specific rules, the data is further broken down by action
        maxDailyTrades.tradesInPeriod[maxDailyTrades.tokenMaxDailyTrades[action].ruleId][_tokenId] = IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMaxDailyTrades(
            maxDailyTrades.tokenMaxDailyTrades[action].ruleId,
            maxDailyTrades.tradesInPeriod[maxDailyTrades.tokenMaxDailyTrades[action].ruleId][_tokenId],
            tags,
            maxDailyTrades.lastTxDate[maxDailyTrades.tokenMaxDailyTrades[action].ruleId][_tokenId]
        );
        // if the tokenId has not been traded in the period, create the tokenIdsByRuleId elements
        if (maxDailyTrades.lastTxDate[maxDailyTrades.tokenMaxDailyTrades[action].ruleId][_tokenId] == 0){
            maxDailyTrades.tokenIdsByRuleId[maxDailyTrades.tokenMaxDailyTrades[action].ruleId].push(_tokenId);
        }
        maxDailyTrades.lastTxDate[maxDailyTrades.tokenMaxDailyTrades[action].ruleId][_tokenId] = uint64(block.timestamp);
    }       

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the simple rule checks.(Ones that have simple parameters and so are not stored in the rule storage diamond)
     * @param _action action to be checked
     * @param _tokenId the specific token to check 
     * @param handlerBase address of the handler proxy 
     */
    function _checkSimpleRules(ActionTypes _action, uint256 _tokenId, address handlerBase) internal view {
        TokenMinHoldTimeS storage minHoldTime = lib.tokenMinHoldTimeStorage();
        if (minHoldTime.tokenMinHoldTime[_action].active && minHoldTime.ownershipStart[_tokenId] > 0)
            IRuleProcessor(handlerBase).checkTokenMinHoldTime(minHoldTime.tokenMinHoldTime[_action].period, minHoldTime.ownershipStart[_tokenId]);
    }


}
