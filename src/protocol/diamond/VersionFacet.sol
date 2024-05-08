// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC173} from  "lib/diamond-std/implementations/ERC173/ERC173.sol";
import {VersionFacetLib as lib} from "./VersionFacetLib.sol";
import {IHandlerDiamondEvents} from "../../common/IEvents.sol";

/**
 * @title Protocol Version Facet 
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is a facet that should be deployed for any protocol diamond.
 * @dev setter and getter functions for Version of a diamond.
 */
contract VersionFacet is ERC173, IHandlerDiamondEvents {
    /**
    * @dev Function to update the version of the Rule Processor Diamond
    * @param newVersion string of the representation of the version in semantic
    * versioning format: --> "MAJOR.MINOR.PATCH".
    */
    function updateVersion(string memory newVersion) external onlyOwner{
        lib.versionStorage().version = newVersion;
        emit AD1467_UpgradedToVersion(msg.sender, newVersion);
    }

    /**
    * @dev returns the version of the Rule Processor Diamond.
    * @return string version.
    */
    function version() external view returns(string memory){
        return lib.versionStorage().version;
    }


}