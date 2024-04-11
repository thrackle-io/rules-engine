// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {StorageLib as lib} from "../diamond/StorageLib.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import "../../../application/IAppManager.sol";
import "./RuleStorage.sol";
import "../../ITokenInterface.sol";
import "../ruleContracts/HandlerAccountApproveDenyOracle.sol";
import "../ruleContracts/HandlerTokenMaxSupplyVolatility.sol";
import "../ruleContracts/HandlerTokenMaxTradingVolume.sol";
import "../ruleContracts/HandlerTokenMinTxSize.sol";
import "../ruleContracts/HandlerTokenMinHoldTime.sol";
import "../ruleContracts/HandlerTokenMaxDailyTrades.sol";

contract ERC721NonTaggedRuleFacet is
    HandlerAccountApproveDenyOracle,
    HandlerTokenMaxSupplyVolatility,
    HandlerTokenMaxTradingVolume,
    HandlerTokenMinTxSize,
    HandlerTokenMinHoldTime,
    HandlerTokenMaxDailyTrades
{
    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _tokenId id of the NFT being transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkNonTaggedRules(ActionTypes action, address _from, address _to, uint256 _amount, uint256 _tokenId) external {
        _from;
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
        if (action == ActionTypes.BURN || action == ActionTypes.SELL){
            IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _from);
        } else {
            IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _to);
        }

        if (lib.tokenMaxDailyTradesStorage().tokenMaxDailyTrades[action].active) {
            // get all the tags for this NFT
            bytes32[] memory tags = IAppManager(handlerBaseStorage.appManager).getAllTags(handlerBaseStorage.assetAddress);
            TokenMaxDailyTradesS storage maxDailyTrades = lib.tokenMaxDailyTradesStorage();
            maxDailyTrades.tradesInPeriod[_tokenId] = IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMaxDailyTrades(
                maxDailyTrades.tokenMaxDailyTrades[action].ruleId,
                maxDailyTrades.tradesInPeriod[_tokenId],
                tags,
                maxDailyTrades.lastTxDate[_tokenId]
            );
            maxDailyTrades.lastTxDate[_tokenId] = uint64(block.timestamp);
        }
        if (lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[action].active) {
            TokenMaxTradingVolumeS storage maxTradingVolume = lib.tokenMaxTradingVolumeStorage();
            maxTradingVolume.transferVolume = IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMaxTradingVolume(
                maxTradingVolume.tokenMaxTradingVolume[action].ruleId,
                maxTradingVolume.transferVolume,
                IToken(msg.sender).totalSupply(),
                _amount,
                maxTradingVolume.lastTransferTime
            );
            maxTradingVolume.lastTransferTime = uint64(block.timestamp);
        }
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        if (lib.tokenMaxSupplyVolatilityStorage().tokenMaxSupplyVolatility[action].active && (_from == address(0x00) || _to == address(0x00))) {
            TokenMaxSupplyVolatilityS storage maxSupplyVolatility = lib.tokenMaxSupplyVolatilityStorage();
            (maxSupplyVolatility.volumeTotalForPeriod, maxSupplyVolatility.totalSupplyForPeriod) = IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMaxSupplyVolatility(
                maxSupplyVolatility.tokenMaxSupplyVolatility[action].ruleId,
                maxSupplyVolatility.volumeTotalForPeriod,
                maxSupplyVolatility.totalSupplyForPeriod,
                IToken(msg.sender).totalSupply(),
                _to == address(0x00) ? int(_amount) * -1 : int(_amount),
                maxSupplyVolatility.lastSupplyUpdateTime
            );
            maxSupplyVolatility.lastSupplyUpdateTime = uint64(block.timestamp);
        }
        _checkSimpleRules(action, _tokenId);
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the simple rule checks.(Ones that have simple parameters and so are not stored in the rule storage diamond)
     * @param _action action to be checked
     * @param _tokenId the specific token in question
     */
    function _checkSimpleRules(ActionTypes _action, uint256 _tokenId) internal view {
        TokenMinHoldTimeS storage minHodlTime = lib.tokenMinHoldTimeStorage();
        if (minHodlTime.tokenMinHoldTime[_action].active && minHodlTime.ownershipStart[_tokenId] > 0)
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkTokenMinHoldTime(minHodlTime.tokenMinHoldTime[_action].period, minHodlTime.ownershipStart[_tokenId]);
    }
}
