// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./FacetsCommonImports.sol";
import "../common/AppAdministratorOrOwnerOnlyDiamondVersion.sol";
import "../ruleContracts/HandlerAccountMinMaxTokenBalance.sol";
import "./TradingRuleFacet.sol";

contract ERC20TaggedRuleFacet is HandlerAccountMinMaxTokenBalance, AppAdministratorOrOwnerOnlyDiamondVersion{

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkTaggedAndTradingRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) external onlyOwner {
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
    function _checkTaggedIndividualRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) internal {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        mapping(ActionTypes => Rule) storage accountMinMaxTokenBalance = lib.accountMinMaxTokenBalanceStorage().accountMinMaxTokenBalance;
        bytes32[] memory toTags;
        bytes32[] memory fromTags;
        
        bool mustCheckBuyRules = action == ActionTypes.BUY && !IAppManager(handlerBaseStorage.appManager).isTradingRuleBypasser(_to);
        bool mustCheckSellRules = action == ActionTypes.SELL && !IAppManager(handlerBaseStorage.appManager).isTradingRuleBypasser(_from);
        if (accountMinMaxTokenBalance[action].active || mustCheckBuyRules|| mustCheckSellRules){
            // We get all tags for sender and recipient
            toTags = IAppManager(handlerBaseStorage.appManager).getAllTags(_to);
            fromTags = IAppManager(handlerBaseStorage.appManager).getAllTags(_from);
        } else {
            toTags = new bytes32[](0);
            fromTags = new bytes32[](0);
        }

        if (accountMinMaxTokenBalance[action].active) {
            /// The action type determines if the _to or _from is checked by the rule 
            if (action == ActionTypes.BUY || action == ActionTypes.MINT) {
                /// _to address and their tags are checked for Buy and Mint action types. Check only the Max Token Balance.
                IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountMaxTokenBalance(_balanceTo, toTags, _amount, accountMinMaxTokenBalance[action].ruleId);
            } else if (action == ActionTypes.SELL || action == ActionTypes.BURN) {
                /// _from address and their tags are checked for Sell and Burn action types. Check only the Min Token Balance.
                IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountMinTokenBalance(_balanceFrom, fromTags, _amount, accountMinMaxTokenBalance[action].ruleId);
            } else if (action == ActionTypes.P2P_TRANSFER) {
                /// check both _from and _to addresses and their tags for transfer action types. Check both Min and Max Token Balance
                IRuleProcessor(handlerBaseStorage.ruleProcessor).checkAccountMinMaxTokenBalance(accountMinMaxTokenBalance[action].ruleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
            }
        }

        if(mustCheckBuyRules || mustCheckSellRules)
            callAnotherFacet(
                0xd874686f, 
                abi.encodeWithSignature(
                    "checkTradingRules(address,address,bytes32[],bytes32[],uint256,uint8)",
                    _from, 
                    _to, 
                    fromTags, 
                    toTags, 
                    _amount, 
                    action
                )
            );
    }
}
