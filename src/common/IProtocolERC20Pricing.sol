// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

/**
 * @title ERC20 Pricing interface
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is a simple pricing mechanism only. Its main purpose is to store prices.
 * @dev This contract doesn't allow any marketplace operations.
 */
interface IProtocolERC20Pricing {
    /**
     * @dev Gets the price of a Token. It will return the Token's specific price.
     * @param tokenContract is the address of the Token contract
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     */
    function getTokenPrice(address tokenContract) external view returns (uint256 price);
}
