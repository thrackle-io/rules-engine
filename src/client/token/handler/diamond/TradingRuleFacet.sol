// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IHandlerDiamondErrors, IZeroAddressError} from "src/common/IErrors.sol";
import "src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol";
import "src/client/token/handler/diamond/FacetsCommonImports.sol";
import "src/client/application/IAppManager.sol";
import "src/client/token/handler/ruleContracts/HandlerAccountMaxTradeSize.sol";
import "src/client/token/handler/ruleContracts/HandlerTokenMaxBuySellVolume.sol";
import "src/client/token/ERC20/IERC20Decimals.sol";

contract TradingRuleFacet is HandlerAccountMaxTradeSize, HandlerUtils, HandlerTokenMaxBuySellVolume, AppAdministratorOrOwnerOnlyDiamondVersion, IZeroAddressError, IHandlerDiamondErrors {
    
    /**
     * @dev This function consolidates all the trading rules.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _sender address of the caller 
     * @param fromTags tags of the from account
     * @param toTags tags of the from account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkTradingRules(address _from, address _to, address _sender, bytes32[] memory fromTags, bytes32[] memory toTags, uint256 _amount, ActionTypes action) external onlyOwner {
        if(action == ActionTypes.BUY){
            if (isContract(_sender) && _from != _sender){ /// non custodial buy
                _checkTradeRulesBuyAction(_to, toTags, _amount, action);
                _checkTradeRulesSellAction(_from, fromTags, _amount, action);
            }
            _checkTradeRulesBuyAction(_to, toTags, _amount, action);
        } else if(action == ActionTypes.SELL) {
            if (isContract(_sender)&& _to != _sender){ /// non custodial sell 
                _checkTradeRulesBuyAction(_to, toTags, _amount, action);
                _checkTradeRulesSellAction(_from, fromTags, _amount, action);
            }
            _checkTradeRulesSellAction(_from, fromTags, _amount, action);
        }
    }

    /**
     * @dev This function checks the trading rules for Buy actions 
     * @param _to address of the to account
     * @param toTags tags of the from account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTradeRulesBuyAction(address _to, bytes32[] memory toTags, uint256 _amount, ActionTypes action) internal {
        if (lib.accountMaxTradeSizeStorage().accountMaxTradeSize[action].active) {
            AccountMaxTradeSizeS storage maxTradeSize = lib.accountMaxTradeSizeStorage();
            // If the rule has been modified after transaction data was recorded, clear the accumulated transaction data.
            if (maxTradeSize.lastPurchaseTime[_to] < maxTradeSize.ruleChangeDate){
                delete maxTradeSize.boughtInPeriod[_to];
                delete maxTradeSize.lastPurchaseTime[_to];
            }
            maxTradeSize.boughtInPeriod[_to] = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAccountMaxTradeSize(
                maxTradeSize.accountMaxTradeSize[action].ruleId, 
                maxTradeSize.boughtInPeriod[_to], 
                _amount, 
                toTags, 
                maxTradeSize.lastPurchaseTime[_to]);
            maxTradeSize.lastPurchaseTime[_to] = uint64(block.timestamp);
        }
        if(lib.tokenMaxBuySellVolumeStorage().tokenMaxBuySellVolume[action].active){
            TokenMaxBuySellVolumeS storage maxVolume = lib.tokenMaxBuySellVolumeStorage();
            maxVolume.boughtInPeriod = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkTokenMaxBuySellVolume(
                maxVolume.tokenMaxBuySellVolume[action].ruleId,  
                IERC20Decimals(msg.sender).totalSupply(),  
                _amount,  
                maxVolume.lastPurchaseTime,  
                maxVolume.boughtInPeriod
            );           
            maxVolume.lastPurchaseTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
        }
    }

    /**
     * @dev This function checks the trading rules for Sell actions 
     * @param _from address of the from account
     * @param fromTags tags of the from account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTradeRulesSellAction(address _from, bytes32[] memory fromTags, uint256 _amount, ActionTypes action) internal {
        if (lib.accountMaxTradeSizeStorage().accountMaxTradeSize[action].active) {
            AccountMaxTradeSizeS storage maxTradeSize = lib.accountMaxTradeSizeStorage();
            // If the rule has been modified after transaction data was recorded, clear the accumulated transaction data.
            if (maxTradeSize.lastSellTime[_from] < maxTradeSize.ruleChangeDate){
                delete maxTradeSize.salesInPeriod[_from];
                delete maxTradeSize.lastSellTime[_from];
            }
            maxTradeSize.salesInPeriod[_from] = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAccountMaxTradeSize(
                maxTradeSize.accountMaxTradeSize[action].ruleId,  
                maxTradeSize.salesInPeriod[_from],  
                _amount,  
                fromTags,  
                maxTradeSize.lastSellTime[_from]
            );
            maxTradeSize.lastSellTime[_from] = uint64(block.timestamp);
        }
        if(lib.tokenMaxBuySellVolumeStorage().tokenMaxBuySellVolume[action].active){
            TokenMaxBuySellVolumeS storage maxVolume = lib.tokenMaxBuySellVolumeStorage();
            maxVolume.salesInPeriod = IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkTokenMaxBuySellVolume(
                maxVolume.tokenMaxBuySellVolume[action].ruleId, 
                IERC20Decimals(msg.sender).totalSupply(),  
                _amount,  
                maxVolume.lastSellTime,  
                maxVolume.salesInPeriod
            );
            maxVolume.lastSellTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
        }
    }


}
