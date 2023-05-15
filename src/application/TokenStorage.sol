// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Token Storage
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This files serves as the storage declaration for the Token data structure
 * @notice Declaration for token structure
 */

/// Token Registry(for lookup purposes)
struct Token {
    address tokenAddress;
    uint256 tokenId;
}
