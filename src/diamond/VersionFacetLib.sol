// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

struct VersionStorage{
    string VERSION;
}

library VersionFacetLib {
     bytes32 constant VERSION_DATA_POSITION = keccak256("protocol-version");

    /**
     * @dev Function to access the version data
     * @return v Data storage for version
     */
    function versionStorage() internal pure returns (VersionStorage storage v) {
        bytes32 position = VERSION_DATA_POSITION;
        assembly {
            v.slot := position
        }
    }

}
