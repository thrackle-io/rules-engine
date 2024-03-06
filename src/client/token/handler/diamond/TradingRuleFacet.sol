// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {StorageLib as lib} from "../diamond/StorageLib.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import "../../../application/IAppManager.sol";
import "./RuleStorage.sol";
import "../ruleContracts/HandlerAccountMaxBuySize.sol";
import "../ruleContracts/HandlerAccountMaxSellSize.sol";
import "../ruleContracts/HandlerTokenMaxBuyVolume.sol";
import "../ruleContracts/HandlerTokenMaxSellVolume.sol";
import "../../ERC20/IERC20Decimals.sol";

contract TradingRuleFacet is HandlerAccountMaxBuySize, HandlerTokenMaxBuyVolume, HandlerAccountMaxSellSize, HandlerTokenMaxSellVolume {

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
        
        if(action == ActionTypes.BUY){
            if (lib.accountMaxBuySizeStorage().active) {
                 AccountMaxBuySizeS storage maxBuySize = lib.accountMaxBuySizeStorage();
                maxBuySize.boughtInPeriod[_to] = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAccountMaxBuySize(
                    maxBuySize.id, 
                    maxBuySize.boughtInPeriod[_to], 
                    _amount, 
                    toTags, 
                    maxBuySize.lastPurchaseTime[_to]);
            maxBuySize.lastPurchaseTime[_to] = uint64(block.timestamp);
            }
            if(lib.tokenMaxBuyVolumeStorage().active){
                TokenMaxBuyVolumeS storage maxBuyVolume = lib.tokenMaxBuyVolumeStorage();
                maxBuyVolume.boughtInPeriod = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkTokenMaxBuyVolume(
                    maxBuyVolume.id,  
                    IERC20Decimals(msg.sender).totalSupply(),  
                    _amount,  
                    maxBuyVolume.lastPurchaseTime,  
                    maxBuyVolume.boughtInPeriod
                );
                maxBuyVolume.lastPurchaseTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }
        else{
            if ( lib.accountMaxSellSizeStorage().active) {
                AccountMaxSellSizeS storage maxSellSize = lib.accountMaxSellSizeStorage();
                maxSellSize.salesInPeriod[_from] = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAccountMaxSellSize(
                    maxSellSize.id,  
                    maxSellSize.salesInPeriod[_from],  
                    _amount,  
                    fromTags,  
                    maxSellSize.lastSellTime[_from]
                );
                maxSellSize.lastSellTime[_from] = uint64(block.timestamp);
            }
            if(lib.tokenMaxSellVolumeStorage().active){
                TokenMaxSellVolumeS storage maxSellVolume = lib.tokenMaxSellVolumeStorage();
                maxSellVolume.salesInPeriod = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkTokenMaxSellVolume(
                    maxSellVolume.id,   
                    IERC20Decimals(msg.sender).totalSupply(),  
                    _amount,  
                    maxSellVolume.lastSellTime,  
                    maxSellVolume.salesInPeriod
                );
                maxSellVolume.lastSellTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }
    }


}
