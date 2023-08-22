// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC173} from  "lib/diamond-std/implementations/ERC173/ERC173.sol";
import {VersionFacetLib as lib} from "./VersionFacetLib.sol";

contract VersionFacet is ERC173 {

    /**
    * @dev Function to update the version of the Rule Processor Diamond
    * @param newVersion string of the representation of the version in semantic
    * versioning format: --> "MAJOR.MINOR.PATCH".
    */
    function updateVersion(string memory newVersion) external onlyOwner{
        lib.versionStorage().VERSION = newVersion;
    }

    /**
    * @dev returns the version of the Rule Processor Diamond.
    * @return string version.
    */
    function version() external view returns(string memory){
        return lib.versionStorage().VERSION;
    }


}