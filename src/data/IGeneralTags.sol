// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./IDataModule.sol";

/**
 * @title General Tag interface Contract
 * @notice Stores tag data for accounts
 * @dev Tags storage retrieval functions are defined here
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IGeneralTags is IDataModule {
    /**
     * @dev Add the tag. Restricted to owner.
     * @param _address user address
     * @param _tag metadata tag to be added
     */
    function addTag(address _address, bytes32 _tag) external;

    /**
     * @dev Remove the tag. Restricted to owner.
     * @param _address user address
     * @param _tag metadata tag to be removed
     */
    function removeTag(address _address, bytes32 _tag) external;

    /**
     * @dev Check is a user has a certain tag
     * @param _address user address
     * @param _tag metadata tag
     * @return hasTag true if it has the tag, false if it doesn't
     */
    function hasTag(address _address, bytes32 _tag) external view returns (bool);

    /**
     * @dev Get all the tags for the address
     * @param _address user address
     * @return tags array of tags
     */
    function getAllTags(address _address) external view returns (bytes32[] memory);
}
