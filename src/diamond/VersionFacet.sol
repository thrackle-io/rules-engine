// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC173} from  "lib/diamond-std/implementations/ERC173/ERC173.sol";


struct VersionStorage{
    string VERSION;
}

contract VersionFacet is ERC173 {

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

    /**
    * @dev Function to update the version of the Rule Processor Diamond
    * @param newVersion string of the representation of the version in semantic
    * versioning format: --> "MAJOR.MINOR.PATCH".
    */
    function updateVersion(string memory newVersion) external onlyOwner{
        VersionStorage storage v = versionStorage();
        v.VERSION = newVersion;
    }

    /**
    * @dev returns the version of the Rule Processor Diamond.
    * @return string version.
    */
    function version() external view returns(string memory){
        VersionStorage storage v = versionStorage();
        return v.VERSION;
    }


}