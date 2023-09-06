// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/token/ProtocolERC721U.sol";

/**
 * @title ApplicationERC721U
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This is an example implementation that App Devs should use.
 * During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
 * must be performed
 */

contract ApplicationERC721UExtra is ProtocolERC721U {
    /// Optional Function Variables and Errors. Uncomment these if using option functions:
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIdCounter;
    error OnlyOwnerCanMint();
    uint256 testVariable1;
    string testVariable2;

    function setTestVariable1(uint256 _value) public {
        testVariable1 = _value;
    }

    function getTestVariable1() public view returns (uint256) {
        return testVariable1;
    }

    function setTestVariable2(string memory _value) public {
        testVariable2 = _value;
    }

    function getTestVariable2() public view returns (string memory) {
        return testVariable2;
    }
}
