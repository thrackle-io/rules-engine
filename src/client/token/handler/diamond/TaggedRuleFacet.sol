// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {StorageLib as lib} from "../diamond/StorageLib.sol";
import {HandlerBaseS} from "../ruleContracts/HandlerBase.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import "../../../application/IAppManager.sol";
import "../ruleContracts/AccountMinMaxTokenBalance.sol";

contract TaggedRuleFacet is AccountMinMaxTokenBalanceGetterSetter{

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkTaggedAndTradingRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) external view {
        _checkTaggedIndividualRules(_balanceFrom, _balanceTo, _from, _to, _amount, action);
    }

    /**
     * @dev This function consolidates all the tagged rules that utilize account tags plus all trading rules.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTaggedIndividualRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) internal view {
        bytes32[] memory toTags;
        bytes32[] memory fromTags;
        
        // bool mustCheckBuyRules = action == ActionTypes.BUY && !appManager.isTradingRuleBypasser(_to);
        // bool mustCheckSellRules = action == ActionTypes.SELL && !appManager.isTradingRuleBypasser(_from);
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        mapping(ActionTypes => Rule) storage accountMinMaxTokenBalance = lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance;
        if (accountMinMaxTokenBalance[action].active 
            // ||
            // (mustCheckBuyRules && accountMaxBuySizeActive) ||
            // (mustCheckSellRules && accountMaxSellSizeActive)
        )
        {
            // We get all tags for sender and recipient
            toTags = IAppManager(handlerBaseStorage.appManager).getAllTags(_to);
            fromTags = IAppManager(handlerBaseStorage.appManager).getAllTags(_from);
        }
        if (accountMinMaxTokenBalance[action].active) 
            IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAccountMinMaxTokenBalance(accountMinMaxTokenBalance[action].ruleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
        // if((mustCheckBuyRules && (accountMaxBuySizeActive || tokenMaxBuyVolumeActive)) || 
        //     (mustCheckSellRules && (accountMaxSellSizeActive || tokenMaxSellVolumeActive))
        // )
        //     _checkTradingRules(_from, _to, fromTags, toTags, _amount, action);
    }
}
