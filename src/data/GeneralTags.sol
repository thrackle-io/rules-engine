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
    mapping(address => mapping(bytes32 => uint)) tagToIndex;
    mapping(address => mapping(bytes32 => bool)) isTagRegistered;

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
     * @notice there is a hard limit of 10 tags per address. This limit is also enforced by the
     * protocol, so keeping this limit here prevents transfers to unexpectedly revert.
     */
    function addTag(address _address, bytes32 _tag) public virtual onlyOwner {
        if (_tag == "") revert BlankTag();
        if (_address == address(0)) revert ZeroAddress();
        if (hasTag(_address, _tag)) emit TagAlreadyApplied(_address);
        else {
            if (tagRecords[_address].length >= 10) revert MaxTagLimitReached();
            tagToIndex[_address][_tag] = tagRecords[_address].length;
            tagRecords[_address].push(_tag);
            isTagRegistered[_address][_tag] = true;
            emit GeneralTagAdded(_address, _tag, block.timestamp);
        }
    }

    /**
     * @dev Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address. This limit is also enforced by the
     * protocol, so keeping this limit here prevents transfers to unexpectedly revert.
     */
    function addGeneralTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external virtual onlyOwner {
        if (_tag == "") revert BlankTag();
        for (uint256 i; i < _accounts.length; ) {
            if (hasTag(_accounts[i], _tag)) emit TagAlreadyApplied(_accounts[i]);
            else {
                if (tagRecords[_accounts[i]].length >= 10) revert MaxTagLimitReached();
                tagToIndex[_accounts[i]][_tag] = tagRecords[_accounts[i]].length;
                tagRecords[_accounts[i]].push(_tag);
                isTagRegistered[_accounts[i]][_tag] = true;
                emit GeneralTagAdded(_accounts[i], _tag, block.timestamp);
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
        if( hasTag(_address, _tag)){
            bytes32 LastTag = tagRecords[_address][tagRecords[_address].length -1];
            if(LastTag != _tag){
                uint index = tagToIndex[_address][_tag];
                /// we replace the position of the tag to remove with the last tag
                tagRecords[_address][index] = LastTag;
                /// we update the last tag index
                tagToIndex[_address][LastTag] = index;
            }
            delete isTagRegistered[_address][_tag];
            delete tagToIndex[_address][_tag];
            tagRecords[_address].pop();
            /// only one event should be emitted and only if a tag was actually removed
            emit GeneralTagRemoved(_address, _tag, block.timestamp);
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
