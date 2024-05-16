// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ITagInputErrors, IRuleProcessorErrors, IMaxTagLimitError, IInputErrors} from "src/common/IErrors.sol";

/**
 * @title Tag interface Contract
 * @notice Stores tag data for accounts
 * @dev Tags storage retrieval functions are defined here
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface ITags is ITagInputErrors, IRuleProcessorErrors, IMaxTagLimitError, IInputErrors {
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

    /**
     * @dev Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address. This limit is also enforced by the
protocol, so keeping this limit here prevents transfers to unexpectedly revert
     */
    function addTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external;

    /**
     * @dev Add a general tag to an account at index in array. Restricted to Application Administrators. Loops through existing tags on accounts and will emit  an event if tag is already applied.
     * @param _accounts Address array to be tagged
     * @param _tags Tag array for the account at index. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addMultipleTagToMultipleAccounts(address[] memory _accounts, bytes32[] memory _tags) external;
}
