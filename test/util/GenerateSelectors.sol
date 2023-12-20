// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "forge-std/Test.sol";

contract GenerateSelectors is Test {
    // Used to get all the possible selectors for a facet to deploy.
    function generateSelectors(string memory _facetName) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "python3";
        cmd[1] = "script/python/get_selectors.py";
        cmd[2] = _facetName;
        // Deploy the facet.
        // bytes memory bytecode = vm.getCode(string.concat(_facetName, ".sol"));
        // address facetAddress;
        // assembly {
        //     facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        // }
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }
}
