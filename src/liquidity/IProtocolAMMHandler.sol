// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../application/IAppManager.sol";

/**
 * @title IProtocolAMMHandler
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev the light version of the ApplicationAMMHandler. This is only used by the client contracts that
 * implement any of the Protocol... Economic capable contracts. It is necessary because the function signature for checkRuleStorages is different for AMMs
 */

interface IProtocolAMMHandler {
    /**
     * @dev Function mirrors that of the checkRuleStorages. This is the rule check function to be called by the AMM.
     * @param token0BalanceFrom token balance of sender address
     * @param token1BalanceFrom token balance of sender address
     * @param _from sender address
     * @param _to recipient address
     * @param token_amount_0 number of tokens transferred
     * @param token_amount_1 number of tokens reciveved
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return Success equals true and Failure equals false
     */
    function checkAllRules(
        uint256 token0BalanceFrom,
        uint256 token1BalanceFrom,
        address _from,
        address _to,
        uint256 token_amount_0,
        uint256 token_amount_1,
        address _tokenAddress,
        ActionTypes _action
    ) external returns (bool);

    /**
     * @dev Assess all the fees for the transaction
     * @param _balanceFrom Token balance of the sender address
     * @param _balanceTo Token balance of the recipient address
     * @param _from Sender address
     * @param _to Recipient address
     * @param _amount total number of tokens to be transferred
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return fees total assessed fee for transaction
     */
    function assessFees(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, ActionTypes _action) external view returns (uint256);
}
