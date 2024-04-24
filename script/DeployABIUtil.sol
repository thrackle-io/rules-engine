// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "forge-std/Script.sol";

/**
 * @dev This script calls a python script to copy ABI to the deployment directory.
 */
contract DeployABIUtil is Script {
    

    function recordABI(string memory contractName, bool recordAllChains, uint256 timestamp) internal {
        string[] memory recordABIInput = new string[](6);
        recordABIInput[0] = "python3";
        recordABIInput[1] = "script/python/record_abi.py";
        recordABIInput[2] = contractName;
        recordABIInput[3] = vm.toString(block.chainid);
        recordABIInput[4] = vm.toString(timestamp);
        recordABIInput[5] = recordAllChains ? "--allchains" : "--no-allchains";
        vm.ffi(recordABIInput);
        if(block.chainid != 31337 || recordAllChains )
            console.log("recorded new ABI ", contractName);
    }
}
