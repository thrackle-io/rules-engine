// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/token/ERC721/upgradeable/ProtocolERC721U.sol";

/**
 * @title ApplicationERC721UpgAdminOrOwnerMint
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This is an upgradeable example implementation of the protocol ERC721 where minting is only available for app administrators.
 * During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
 * must be performed
 */

contract ApplicationERC721UpgAdminMint is ProtocolERC721U {
    /**
     * @dev These storage slots are saved for future upgrades. Please be aware of common constraints for upgradeable contracts regarding storage slots,
     * like maintaining the order of the variables to avoid mislabeling of storage slots, and to keep some reserved slots to avoid storage collisions.
     * @notice the length of this array must be shrunk by the same amount of new variables added in an upgrade. This is to keep track of the remaining
     * storage slots available for variables in future upgrades and avoid storage collisions.
     */
    uint256[50] reservedStorage;
}
