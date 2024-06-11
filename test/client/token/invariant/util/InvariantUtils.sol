// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract InvariantUtils {
    function _convertActorAddressToEOA(address actor) internal pure returns (address eoa) {
        eoa = address(uint160(actor) - 11);
    }
}
