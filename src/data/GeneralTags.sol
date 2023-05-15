// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "./DataModule.sol";
import "./IGeneralTags.sol";

/**
 * @title General Tag Data Contract
 * @notice Stores tag data for accounts
 * @dev Tags are stored as an internal mapping
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract GeneralTags is DataModule, IGeneralTags {
    mapping(address => bytes32[]) public tagRecords;

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     */
    constructor() {
        dataModuleAppManagerAddress = owner();
    }

    /**
     * @dev Add the tag. Restricted to owner.
     * @param _address user address
     * @param _tag metadata tag to be added
     */
    function addTag(address _address, bytes32 _tag) public onlyOwner {
        require(_tag != "");
        /// first, check to see if the tag already exists for the user
        tagRecords[_address].push(_tag);
    }

    /**
     * @dev Helper function to remove tags
     * @param _address of the account to remove tag
     * @param i index of the tag to remove
     */
    function _removeTag(address _address, uint256 i) internal {
        uint256 tagCount = tagRecords[_address].length;
        tagRecords[_address][i] = tagRecords[_address][tagCount - 1];
        tagRecords[_address].pop();
    }

    /**
     * @dev Remove the tag. Restricted to owner.
     * @param _address user address
     * @param _tag metadata tag to be removed
     */
    function removeTag(address _address, bytes32 _tag) external onlyOwner {
        uint256 i;
        while (i < tagRecords[_address].length) {
            while (tagRecords[_address].length > 0 && i < tagRecords[_address].length && keccak256(abi.encodePacked(tagRecords[_address][i])) == keccak256(abi.encodePacked(_tag))) {
                _removeTag(_address, i);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Check is a user has a certain tag
     * @param _address user address
     * @param _tag metadata tag
     * @return hasTag true if it has the tag, false if it doesn't
     */
    function hasTag(address _address, bytes32 _tag) external view returns (bool) {
        for (uint256 i = 0; i < tagRecords[_address].length; ) {
            if (keccak256(abi.encodePacked(tagRecords[_address][i])) == keccak256(abi.encodePacked(_tag))) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    // Get all the tags for the address
    function getAllTags(address _address) public view returns (bytes32[] memory) {
        return tagRecords[_address];
    }
}
