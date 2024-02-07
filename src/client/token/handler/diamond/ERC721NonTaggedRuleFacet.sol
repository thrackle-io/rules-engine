// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

contract ERC721NonTaggedRuleFacet is HandlerAccountApproveDenyOracle, HandlerTokenMaxSupplyVolatility, HandlerTokenMaxTradingVolume, HandlerTokenMinTxSize, HandlerTokenMinHoldTime{

    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _tokenId id of the NFT being transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkNonTaggedRules(address _from, address _to, uint256 _tokenId, ActionTypes action) external {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        mapping(ActionTypes => Rule[]) storage accountAllowDenyOracle = lib.accountApproveDenyOracleStorage().accountAllowDenyOracle;
        
        if (lib.tokenMinTxSizeStorage().tokenMinTxSize[action].active) 
            IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMinTxSize(lib.tokenMinTxSizeStorage().tokenMinTxSize[action].ruleId, _tokenId);

        for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < accountAllowDenyOracle[action].length; ) {
            if (accountAllowDenyOracle[action][accountApproveDenyOracleIndex].active) 
                IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountApproveDenyOracle(accountAllowDenyOracle[action][accountApproveDenyOracleIndex].ruleId, _to);
            unchecked {
                ++accountApproveDenyOracleIndex;
            }
        }
        if (lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[action].active) {
            TokenMaxTradingVolumeS storage maxTradingVolume = lib.tokenMaxTradingVolumeStorage();
            maxTradingVolume.transferVolume = IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMaxTradingVolume(maxTradingVolume.tokenMaxTradingVolume[action].ruleId, maxTradingVolume.transferVolume, IToken(msg.sender).totalSupply(), _tokenId, maxTradingVolume.lastTransferTime);
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
                _to == address(0x00) ? int(_tokenId) * -1 : int(_tokenId),
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
