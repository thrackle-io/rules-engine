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

contract NonTaggedRuleFacet is HandlerAccountApproveDenyOracle, HandlerTokenMaxSupplyVolatility{

    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        mapping(ActionTypes => Rule[]) storage accountAllowDenyOracle = lib.accountApproveDenyOracleStorage().accountAllowDenyOracle;
        //if (tokenMinTxSize[action].active) ruleProcessor.checkTokenMinTxSize(tokenMinTxSize[action].ruleId, _amount);

        for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < accountAllowDenyOracle[action].length; ) {
            if (accountAllowDenyOracle[action][accountApproveDenyOracleIndex].active) 
                IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountApproveDenyOracle(accountAllowDenyOracle[action][accountApproveDenyOracleIndex].ruleId, _to);
            unchecked {
                ++accountApproveDenyOracleIndex;
            }
        }
        // if (tokenMaxTradingVolume[action].active) {
        //     transferVolume = ruleProcessor.checkTokenMaxTradingVolume(tokenMaxTradingVolume[action].ruleId, transferVolume, IToken(msg.sender).totalSupply(), _amount, lastTransferTs);
        //     lastTransferTs = uint64(block.timestamp);
        // }
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
    }



}
