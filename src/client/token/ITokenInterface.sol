// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title Token Interface 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */

interface IToken {
    function balanceOf(address owner) external view returns (uint256 balance);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);
}