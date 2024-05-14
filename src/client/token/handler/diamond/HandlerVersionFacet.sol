// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {StorageLib as lib} from "./StorageLib.sol";
import {IHandlerDiamondEvents} from "../../../../common/IEvents.sol";
import "../common/AppAdministratorOrOwnerOnlyDiamondVersion.sol";
/**
 * @title Handler Version Facet 
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @VoR0220, @GordonPalmer
 * @notice This is a facet that should be deployed for any handler diamond to track versions.
 * @dev setter and getter functions for Version of a diamond.
 */
contract HandlerVersionFacet is IHandlerDiamondEvents, AppAdministratorOrOwnerOnlyDiamondVersion {
    /**
    * @dev Function to update the version of the Rule Processor Diamond
    * @param newVersion string of the representation of the version in semantic
    * versioning format: --> "MAJOR.MINOR.PATCH".
    */
    function updateVersion(string memory newVersion) external appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager) {
        lib.handlerVersionStorage().version = newVersion;
        emit AD1467_UpgradedToVersion(msg.sender, newVersion);
    }

    /**
    * @dev returns the version of the Rule Processor Diamond.
    * @return string version.
    */
    function version() external view returns(string memory){
        return lib.handlerVersionStorage().version;
    }


}