// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./DataModule.sol";
import "./ITags.sol";
import { INoAddressToRemove } from "src/common/IErrors.sol";

/**
 * @title Tags Data Contract
 * @notice Stores tag data for accounts
 * @dev Tags are stored as an internal mapping
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract Tags is DataModule, ITags, INoAddressToRemove {
    mapping(address => bytes32[]) public tagRecords;
    mapping(address => mapping(bytes32 => uint)) tagToIndex;
    mapping(address => mapping(bytes32 => bool)) isTagRegistered;

    uint8 constant MAX_TAGS = 10;


    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     * @param _dataModuleAppManagerAddress address of the owning app manager
     */
    constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress) {
        _transferOwnership(_dataModuleAppManagerAddress);
    }

    /**
     * @dev Add the tag. Restricted to owner.
     * @param _address user address
     * @param _tag metadata tag to be added
     * @notice There is a hard limit of MAX_TAGS tags per address. This limit is also enforced by the
     * protocol, so keeping this limit here prevents transfers to unexpectedly revert.
     */
    function addTag(address _address, bytes32 _tag) public virtual onlyOwner {
        if (_tag == "") revert BlankTag();
        if (_address == address(0)) revert ZeroAddress();
        if (hasTag(_address, _tag)) emit TagAlreadyApplied(_address);
        else {
            if (tagRecords[_address].length >= MAX_TAGS) revert MaxTagLimitReached();
            tagToIndex[_address][_tag] = tagRecords[_address].length;
            tagRecords[_address].push(_tag);
            isTagRegistered[_address][_tag] = true;
            emit Tag(_address, _tag, true);

        }
    }

    /**
     * @dev Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice There is a hard limit of MAX_TAGS tags per address. This limit is also enforced by the
     * protocol, so keeping this limit here prevents transfers to unexpectedly revert.
     */
    function addTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external virtual onlyOwner {
        if (_tag == "") revert BlankTag();
        for (uint256 i; i < _accounts.length; ) {
            if (hasTag(_accounts[i], _tag)) emit TagAlreadyApplied(_accounts[i]);
            else {
                if (tagRecords[_accounts[i]].length >= MAX_TAGS) revert MaxTagLimitReached();
                tagToIndex[_accounts[i]][_tag] = tagRecords[_accounts[i]].length;
                tagRecords[_accounts[i]].push(_tag);
                isTagRegistered[_accounts[i]][_tag] = true;
                emit Tag(_accounts[i], _tag, true);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Remove the tag. Restricted to owner.
     * @param _address user address
     * @param _tag metadata tag to be removed
     */
    function removeTag(address _address, bytes32 _tag) external virtual onlyOwner {
        /// we only remove the tag if this exists in the account's tag list
        if( hasTag(_address, _tag)){
            /// we store the last tag on a local variable to avoid unnecessary costly memory reads
            bytes32 LastTag = tagRecords[_address][tagRecords[_address].length -1];
            /// we check if we are trying to remove the last tag since this would mean we can skip some steps
            if(LastTag != _tag){
                /// if it is not the last tag, then we store the index of the address to remove
                uint index = tagToIndex[_address][_tag];
                /// we remove the tag by replacing it in the array with the last tag (now duplicated)
                tagRecords[_address][index] = LastTag;
                /// we update the last tag index to its new position (the removed-tag index)
                tagToIndex[_address][LastTag] = index;
            }
            /// we remove the last element of the tag array since it is now duplicated
            tagRecords[_address].pop();
            /// we set to false the membership mapping for this tag in this account
            delete isTagRegistered[_address][_tag];
            /// we set the index to zero for this tag in this account
            delete tagToIndex[_address][_tag];
            /// only one event should be emitted and only if a tag was actually removed
            emit Tag(_address, _tag, false);
        }else revert NoAddressToRemove();

    }

   /**
     * @dev Add a general tag to an account at index in array. Restricted to Application Administrators. Loops through existing tags on accounts and will emit  an event if tag is already applied.
     * @param _accounts Address array to be tagged
     * @param _tags Tag array for the account at index. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addMultipleTagToMultipleAccounts(address[] memory _accounts, bytes32[] memory _tags) external onlyOwner() {
        if (_accounts.length != _tags.length) revert InputArraysMustHaveSameLength();
        for (uint256 i; i < _accounts.length; ) {
            addTag(_accounts[i], _tags[i]);
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
    function hasTag(address _address, bytes32 _tag) public view virtual returns (bool) {
        return isTagRegistered[_address][_tag];
    }

    // Get all the tags for the address
    function getAllTags(address _address) public view virtual returns (bytes32[] memory) {
        return tagRecords[_address];
    }
}
