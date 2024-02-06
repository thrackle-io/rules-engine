// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {StorageLib as lib} from "../diamond/StorageLib.sol";
import {HandlerBaseS} from "../ruleContracts/HandlerBase.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import "../../../application/IAppManager.sol";
import "./RuleStorage.sol";
import "../ruleContracts/HandlerAccountMaxBuySize.sol";
import "../ruleContracts/HandlerAccountMaxSellSize.sol";

contract TradingRuleFacet is HandlerAccountMaxBuySize, HandlerAccountMaxSellSize{

    /**
     * @dev This function consolidates all the trading rules.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param fromTags tags of the from account
     * @param toTags tags of the from account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkTradingRules(address _from, address _to, bytes32[] memory fromTags, bytes32[] memory toTags, uint256 _amount, ActionTypes action) external {
        //IRuleProcessor ruleProcessor = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor);
        AccountMaxBuySizeS storage maxBuySize = lib.accountMaxBuySizeStorage();
        AccountMaxSellSizeS storage maxSellSize = lib.accountMaxSellSizeStorage();
        if(action == ActionTypes.BUY){
            if (maxBuySize.active) {
                maxBuySize.boughtInPeriod[_to] = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAccountMaxBuySize(
                    maxBuySize.id, 
                    maxBuySize.boughtInPeriod[_to], 
                    _amount, 
                    toTags, 
                    maxBuySize.lastPurchaseTime[_to]);
            maxBuySize.lastPurchaseTime[_to] = uint64(block.timestamp);
            }
            // if(tokenMaxBuyVolumeActive){
            //     totalBoughtInPeriod = ruleProcessor.checkTokenMaxBuyVolume(tokenMaxBuyVolumeId,  IERC20Decimals(msg.sender).totalSupply(),  _amount,  previousPurchaseTime,  totalBoughtInPeriod);
            //     previousPurchaseTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            // }
        }
        else{
            if ( maxSellSize.active) {
                maxSellSize.salesInPeriod[_from] = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAccountMaxSellSize(
                    maxSellSize.id,  
                    maxSellSize.salesInPeriod[_from],  
                    _amount,  
                    fromTags,  
                    maxSellSize.lastSellTime[_from]
                );
                maxSellSize.lastSellTime[_from] = uint64(block.timestamp);
            }
            // if(tokenMaxSellVolumeActive){
            //     totalSoldInPeriod = ruleProcessor.checkTokenMaxSellVolume(tokenMaxSellVolumeId,   IERC20Decimals(msg.sender).totalSupply(),  _amount,  previousSellTime,  totalSoldInPeriod);
            //     previousSellTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            // }
        }
    }


}
