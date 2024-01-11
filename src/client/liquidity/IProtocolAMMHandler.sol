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
     * @return Success equals true and Failure equals false
     */
    function checkAllRules(
        uint256 token0BalanceFrom,
        uint256 token1BalanceFrom,
        address _from,
        address _to,
        uint256 token_amount_0,
        uint256 token_amount_1,
        address _tokenAddress
    ) external returns (bool);

    /**
     * @dev returns the full mapping of fees
     * @return feeActive fee activation status
     */
    function isFeeActive() external view returns (bool);

    /**
     * @dev Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
     * different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.
     * @param _from originating address
     * @param _balanceFrom Token balance of the sender address
     * @return feeCollectorAccounts list of where the fees are sent
     * @return feePercentages list of all applicable fees/discounts
     */
    function getApplicableFees(address _from, uint256 _balanceFrom) external view returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages);
}
