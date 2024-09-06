// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;
/// This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
/// of "Test" because naming it "Test" causes problems with Foundry testing.
import {ERC173} from "diamond-std/implementations/ERC173/ERC173.sol";
import {ERC173Lib} from "diamond-std/implementations/ERC173/ERC173Lib.sol";

contract SampleUpgradeFacet is ERC173 {

    bytes32 constant SAMPLE_STORAGE_POSITION = keccak256("sample.storage");
    struct SampleStorage {
        uint256 v1;
    }

    /// @notice Return the storage struct for reading and writing.
    /// @return storageStruct The sample  storage struct.
    function s() internal pure returns (SampleStorage storage storageStruct) {
        bytes32 position = SAMPLE_STORAGE_POSITION;
        assembly {
            storageStruct.slot := position
        }
    }
    function sampleUpgradeFunction() external view onlyOwner returns (string memory) {
        return "good";
    }
}