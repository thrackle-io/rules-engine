// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "../economic/ruleProcessor/ActionEnum.sol";

/**
 * @title Asset Handler Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This interface provides the ABI for assets to access their handlers in an efficient way
 */

interface IProtocolERC721Handler {
    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point to protocol.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param amount number of tokens transferred
     * @param _tokenId the token's specific ID
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return Success equals true if all checks pass
     */
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, uint256 amount, uint256 _tokenId, ActionTypes _action) external returns (bool);
}
