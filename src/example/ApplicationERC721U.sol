// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../token/ProtocolERC721U.sol";

/**
 * @title ApplicationERC721U
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This is an example implementation that App Devs should use.
 * During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
 * must be performed
 */

contract ApplicationERC721U is ProtocolERC721U {

}
