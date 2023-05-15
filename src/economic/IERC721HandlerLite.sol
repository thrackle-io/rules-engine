// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../application/IAppManager.sol";

/**
 * @title ITokenRuleRouter
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev the light version of the TokenRuleRouter. This is only used by the NFT contracts that
 * require tokenId
 */

interface IERC721HandlerLite {
    /**
     * @dev Check the rules of the Protocol
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param _from Sender address
     * @param _to Recipient address
     * @param amount total number of tokens to be transferred
     * @param tokenId Id of token
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return Success equals true and Failure equals false
     */
    function checkAllRules(
        uint256 balanceFrom,
        uint256 balanceTo,
        address _from,
        address _to,
        uint256 amount,
        uint256 tokenId,
        ApplicationRuleProcessorDiamondLib.ActionTypes _action
    ) external returns (bool);

    /**
     * @dev Set the parent ERC721 address
     * @param _address address of the ERC721
     */
    function setERC721Address(address _address) external;
}
