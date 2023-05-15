// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../application/IAppManager.sol";

/**
 * @title ITokenRuleRouter
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev the light version of the TokenRuleRouter. This is only used by the client contracts that
 * implement any of the Protocol capable contracts.
 */

interface IAssetHandlerLite {
    /**
     * @dev Check the Rules for the protocol
     * @param _balanceFrom Token balance of the sender address
     * @param _balanceTo Token balance of the recipient address
     * @param _from Sender address
     * @param _to Recipient address
     * @param _amount total number of tokens to be transferred
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return Success equals true and Failure equals false
     */
    function checkAllRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, ApplicationRuleProcessorDiamondLib.ActionTypes _action) external returns (bool);

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
     * @return targetAccounts list of where the fees are sent
     * @return feePercentages list of all applicable fees/discounts
     */
    function getApplicableFees(address _from, uint256 _balanceFrom) external returns (address[] memory targetAccounts, int24[] memory feePercentages);
}
