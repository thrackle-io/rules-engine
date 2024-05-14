// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "src/common/IProtocolERC20Pricing.sol";
import {IApplicationEvents} from "src/common/IEvents.sol";

/**
 * @title ERC20 Pricing template contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is a simple pricing mechanism only. Its main purpose is to store prices.
 * @dev This contract doesn't allow any marketplace operations.
 */
contract ProtocolERC20Pricing is Ownable, IApplicationEvents, IProtocolERC20Pricing {
    string private constant VERSION="1.2.0";
    
    mapping(address => uint256) public tokenPrices;

    /**
     * @dev set the price for a single Token
     * @param tokenContract is the address of the Token contract
     * @param price price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     * @notice that the token is the whole token and not its atomic unit. This means that if an
     * ERC20 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function setSingleTokenPrice(address tokenContract, uint256 price) external onlyOwner {
        tokenPrices[tokenContract] = price;
        emit AD1467_TokenPrice(tokenContract, price);
    }

    /**
     * @dev gets the price of a Token. It will return the Token's specific price.
     * @param tokenContract is the address of the Token contract
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     * @notice that the price is for the whole token and not of its atomic unit. This means that if
     * an ERC20 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function getTokenPrice(address tokenContract) external view returns (uint256 price) {
        return tokenPrices[tokenContract];
    }

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}
