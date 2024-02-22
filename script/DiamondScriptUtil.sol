// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";

/**
 * @dev String operations. Copied from Openzeppelin library but converted into a contract to be able to
 * use it in a script
 */
contract DiamondScriptUtil is Script {
    
    function validateFacetToUpgrade(string memory _facetToUpgrade) internal pure {
        if(bytes(_facetToUpgrade).length == 0)
            revert("FACET_TO_UPGRADE not set in the env file");
    }

    function validateDiamondToUpgrade(string memory _diamondToUpgrade) internal pure {
        if(bytes(_diamondToUpgrade).length == 0)
            revert("DIAMOND_TO_UPGRADE not set in the env file");
    }

    function validateFacetNameToRevert(string memory _facetNameToRevert) internal pure {
        if(bytes(_facetNameToRevert).length == 0)
            revert("FACET_NAME_TO_REVERT not set in the env file");
    }

    function validateRevertToFacetAddress(address _revertToFacetAddress) internal pure {
        if(_revertToFacetAddress == address(0))
            revert("REVERT_TO_FACET_ADDRESS not set in the env file");
    }

    function recordFacet(string memory diamondName, string memory facetName, address facetAddress, bool recordAllChains) internal {
        string[] memory recordFacetInput = new string[](8);
        recordFacetInput[0] = "python3";
        recordFacetInput[1] = "script/python/record_facets.py";
        recordFacetInput[2] = diamondName;
        recordFacetInput[3] = facetName;
        recordFacetInput[4] = vm.toString(facetAddress);
        recordFacetInput[5] = vm.toString(block.chainid);
        recordFacetInput[6] = vm.toString(block.timestamp);
        recordFacetInput[7] = recordAllChains ? "--allchains" : "--no-allchains";
        vm.ffi(recordFacetInput);
        if(block.chainid != 31337 || recordAllChains )
            console.log("recorded new facet ", facetName, facetAddress);
    }

    function setENVVariable(string memory variable, string memory value) internal {
        /// we clear the value of the RULE_PROCESSOR_DIAMOND in the env file
        string[] memory setENVInput = new string[](4);
        setENVInput[0] = "python3";
        setENVInput[1] = "script/python/set_env_variable.py";
        setENVInput[2] = variable;
        setENVInput[3] = value;
        vm.ffi(setENVInput);
    }

    function replace(string memory subject, string memory search, string memory replacement)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)
            let replacementLength := mload(replacement)

            subject := add(subject, 0x20)
            search := add(search, 0x20)
            replacement := add(replacement, 0x20)
            result := add(mload(0x40), 0x20)

            let subjectEnd := add(subject, subjectLength)
            if iszero(gt(searchLength, subjectLength)) {
                let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 32)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(32, and(searchLength, 31)))
                let s := mload(search)
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                mstore(result, t)
                                result := add(result, 1)
                                subject := add(subject, 1)
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        for { let o := 0 } 1 {} {
                            mstore(add(result, o), mload(add(replacement, o)))
                            o := add(o, 0x20)
                            if iszero(lt(o, replacementLength)) { break }
                        }
                        result := add(result, replacementLength)
                        subject := add(subject, searchLength)
                        if searchLength {
                            if iszero(lt(subject, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    mstore(result, t)
                    result := add(result, 1)
                    subject := add(subject, 1)
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
            }

            let resultRemainder := result
            result := add(mload(0x40), 0x20)
            let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
            // Copy the rest of the string one word at a time.
            for {} lt(subject, subjectEnd) {} {
                mstore(resultRemainder, mload(subject))
                resultRemainder := add(resultRemainder, 0x20)
                subject := add(subject, 0x20)
            }
            result := sub(result, 0x20)
            // Zeroize the slot after the string.
            let last := add(add(result, 0x20), k)
            mstore(last, 0)
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, and(add(last, 31), not(31)))
            // Store the length of the result.
            mstore(result, k)
        }
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
