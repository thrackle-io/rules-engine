// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./FacetsCommonImports.sol";
import "./RuleStorage.sol";
import "../../ITokenInterface.sol";
import "../ruleContracts/HandlerAccountApproveDenyOracle.sol";
import "../ruleContracts/HandlerTokenMaxSupplyVolatility.sol";
import "../ruleContracts/HandlerTokenMaxTradingVolume.sol";
import "../ruleContracts/HandlerTokenMinTxSize.sol";

contract ERC20NonTaggedRuleFacet is HandlerAccountApproveDenyOracle, HandlerTokenMaxSupplyVolatility, HandlerTokenMaxTradingVolume, HandlerTokenMinTxSize {
    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;

        if (lib.tokenMinTxSizeStorage().tokenMinTxSize[action].active)
            IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMinTxSize(lib.tokenMinTxSizeStorage().tokenMinTxSize[action].ruleId, _amount);
        if (action == ActionTypes.BURN || action == ActionTypes.SELL){
            IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _from);
        } 
        if (action == ActionTypes.MINT || action == ActionTypes.BUY || action == ActionTypes.P2P_TRANSFER){
            IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _to);
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
    }
}
