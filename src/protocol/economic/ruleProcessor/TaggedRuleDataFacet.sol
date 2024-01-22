// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";
import "../RuleAdministratorOnly.sol";

/**
 * @title Tagged Rule Data Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev setters and getters for Tagged token specific rules
 * @notice This contract sets and gets the Tagged Rules for the protocol. Rules will be applied via General Tags to accounts.
 */
contract TaggedRuleDataFacet is Context, RuleAdministratorOnly, IEconomicEvents, IInputErrors, ITagInputErrors, ITagRuleInputErrors, IZeroAddressError {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8; 
    using RuleProcessorCommonLib for bytes32[]; 


    /********************** Purchase Getters/Setters ***********************/
    /**
     * @dev Function add a Token Purchase Percentage rule
     * @dev Function has RuleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _accountTypes Types of Accounts
     * @param _purchaseAmounts Allowed total purchase limits
     * @param _purchasePeriods Hours purhchases allowed
     * @param _startTime timestamp period to start
     * @return position of new rule in array
     */
    function addPurchaseRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _purchaseAmounts,
        uint16[] calldata _purchasePeriods,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_accountTypes.length != _purchaseAmounts.length || _accountTypes.length != _purchasePeriods.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        _accountTypes.areTagsValid();
        return _addPurchaseRule(_accountTypes, _purchaseAmounts, _purchasePeriods, _startTime);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _purchaseAmounts Allowed total purchase limits
     * @param _purchasePeriods Hours purhchases allowed
     * @param _startTime timestamp for first period to start
     * @return position of new rule in array
     */
    function _addPurchaseRule(bytes32[] calldata _accountTypes, uint256[] calldata _purchaseAmounts, uint16[] calldata _purchasePeriods, uint64 _startTime) internal returns (uint32) {
        RuleS.PurchaseRuleS storage data = Storage.purchaseStorage();
        uint32 index = data.purchaseRulesIndex;
        _startTime.validateTimestamp();
        for (uint256 i; i < _accountTypes.length; ) {
            if (_purchaseAmounts[i] == 0 || _purchasePeriods[i] == 0) revert ZeroValueNotPermited();
            data.purchaseRulesPerUser[index][_accountTypes[i]] = TaggedRules.PurchaseRule(_purchaseAmounts[i], _purchasePeriods[i]);

            unchecked {
                ++i;
            }
        }
        data.startTimes[index] = _startTime;
        emit ProtocolRuleCreated(PURCHASE_LIMIT, index, _accountTypes);
        ++data.purchaseRulesIndex;
        return index;
    }

    /********************** Sell Getters/Setters **********************/

    /**
     * @dev Function to add set of sell rules
     * @param _appManagerAddr Address of App Manager
     * @param _accountTypes Types of Accounts
     * @param _sellAmounts Allowed total sell limits
     * @param _sellPeriod Period for sales
     * @param _startTime rule starts
     * @return position of new rule in array
     */
    function addSellRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint192[] calldata _sellAmounts,
        uint16[] calldata _sellPeriod,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTypes.length != _sellAmounts.length || _accountTypes.length != _sellPeriod.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        _accountTypes.areTagsValid();
        return _addSellRule(_accountTypes, _sellAmounts, _sellPeriod, _startTime);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _sellAmounts Allowed total sell limits
     * @param _sellPeriod Period for sales
     * @param _startTime rule starts
     * @return position of new rule in array
     */
    function _addSellRule(bytes32[] calldata _accountTypes, uint192[] calldata _sellAmounts, uint16[] calldata _sellPeriod, uint64 _startTime) internal returns (uint32) {
        RuleS.SellRuleS storage data = Storage.sellStorage();
        uint32 index = data.sellRulesIndex;
        _startTime.validateTimestamp();
        for (uint256 i; i < _accountTypes.length; ) {
            if (_sellAmounts[i] == 0 || _sellPeriod[i] == 0) revert ZeroValueNotPermited();
            data.sellRulesPerUser[index][_accountTypes[i]] = TaggedRules.SellRule(_sellAmounts[i], _sellPeriod[i]);
            unchecked {
                ++i;
            }
        }
        data.startTimes[index] = _startTime;
        emit ProtocolRuleCreated(SELL_LIMIT, index, _accountTypes);
        ++data.sellRulesIndex;
        return index;
    }

    /********************** Balance Limit Getters/Setters ***********************/

    /**
     * @dev Function adds Balance Limit Rule
     * @param _appManagerAddr App Manager Address
     * @param _accountTypes Types of Accounts
     * @param _minimum Minimum Balance allowed for tagged accounts
     * @param _maximum Maximum Balance allowed for tagged accounts
     * @return _addMinMaxBalanceRule which returns location of rule in array
     */
    function addMinMaxBalanceRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _minimum,
        uint256[] calldata _maximum
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTypes.length != _minimum.length || _accountTypes.length != _maximum.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        _accountTypes.areTagsValid();
        return _addMinMaxBalanceRule(_accountTypes, _minimum, _maximum);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _minimum Minimum Balance allowed for tagged accounts
     * @param _maximum Maximum Balance allowed for tagged accounts
     * @return position of new rule in array
     */
    function _addMinMaxBalanceRule(bytes32[] calldata _accountTypes, uint256[] calldata _minimum, uint256[] calldata _maximum) internal returns (uint32) {
        RuleS.MinMaxBalanceRuleS storage data = Storage.minMaxBalanceStorage();
        uint32 index = data.minMaxBalanceRuleIndex;
        for (uint256 i; i < _accountTypes.length; ) {
            if (_minimum[i] == 0 || _maximum[i] == 0) revert ZeroValueNotPermited();
            if (_minimum[i] > _maximum[i]) revert InvertedLimits();
            TaggedRules.MinMaxBalanceRule memory rule = TaggedRules.MinMaxBalanceRule(_minimum[i], _maximum[i]);
            data.minMaxBalanceRulesPerUser[index][_accountTypes[i]] = rule;
            unchecked {
                ++i;
            }
        }
        emit ProtocolRuleCreated(MIN_MAX_BALANCE_LIMIT, index, _accountTypes);
        ++data.minMaxBalanceRuleIndex;
        return index;
    }

    /************ Admin Account Withdrawal Getters/Setters ***********/

    /**
     * @dev Function adds Withdrawal Rule for admins
     * @param _appManagerAddr Address of App Manager
     * @param _amount Transaction total
     * @param _releaseDate Date of release
     * @return adminWithdrawalRulesPerToken position of new rule in array
     */
    function addAdminWithdrawalRule(address _appManagerAddr, uint256 _amount, uint256 _releaseDate) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        RuleS.AdminWithdrawalRuleS storage data = Storage.adminWithdrawalStorage();
        if (_amount == 0) revert ZeroValueNotPermited();
        if (_releaseDate <= block.timestamp) revert DateInThePast(_releaseDate);
        uint32 index = data.adminWithdrawalRulesIndex;
        TaggedRules.AdminWithdrawalRule memory rule = TaggedRules.AdminWithdrawalRule(_amount, _releaseDate);
        data.adminWithdrawalRulesPerToken[index] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(ADMIN_WITHDRAWAL, index, empty);
        ++data.adminWithdrawalRulesIndex;
        return index;
    }
    
    /********************** Minimum Account Balance By Date Getters/Setters ***********************/
    /**
     * @dev Function add a Minimum Account Balance By Date rule
     * @dev Function has RuleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _accountTags Types of Accounts
     * @param _holdAmounts Allowed total purchase limits
     * @param _holdPeriods Hours purchases allowed
     * @param _startTimestamp Timestamp that the check should start
     * @return ruleId of new rule in array
     */
    function addMinBalByDateRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTags,
        uint256[] calldata _holdAmounts,
        uint16[] calldata _holdPeriods,
        uint64 _startTimestamp
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTags.length != _holdAmounts.length || _accountTags.length != _holdPeriods.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTags.length == 0) revert InvalidRuleInput();
        _accountTags.areTagsValid();
        return _addMinBalByDateRule(_accountTags, _holdAmounts, _holdPeriods, _startTimestamp);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTags Types of Accounts
     * @param _holdAmounts Allowed total purchase limits
     * @param _holdPeriods Hours purhchases allowed
     * @param _startTimestamp Timestamp that the check should start
     * @return ruleId of new rule in array
     */
    function _addMinBalByDateRule(bytes32[] calldata _accountTags, uint256[] calldata _holdAmounts, uint16[] calldata _holdPeriods, uint64 _startTimestamp) internal returns (uint32) {
        RuleS.MinBalByDateRuleS storage data = Storage.minBalByDateRuleStorage();
        uint32 index = data.minBalByDateRulesIndex;
        /// if defaults sent for timestamp, start them with current block time
        if (_startTimestamp == 0) _startTimestamp = uint64(block.timestamp);
        for (uint256 i; i < _accountTags.length; ) {
            if (_holdAmounts[i] == 0 || _holdPeriods[i] == 0) revert ZeroValueNotPermited();
            data.minBalByDateRulesPerUser[index][_accountTags[i]] = TaggedRules.MinBalByDateRule(_holdAmounts[i], _holdPeriods[i]);
            unchecked {
                ++i;
            }
        }
        data.startTimes[index] = _startTimestamp;
        emit ProtocolRuleCreated(MIN_ACCT_BAL_BY_DATE, index, _accountTags);
        ++data.minBalByDateRulesIndex;
        return index;
    }

    /************ NFT Getters/Setters ***********/
    /**
     * @dev Function adds Balance Limit Rule
     * @param _appManagerAddr App Manager Address
     * @param _nftTypes Types of NFTs
     * @param _tradesAllowed Maximum trades allowed within 24 hours
     * @param _startTs starting timestamp for the rule
     * @return _nftTransferCounterRules which returns location of rule in array
     */
    function addNFTTransferCounterRule(
        address _appManagerAddr,
        bytes32[] calldata _nftTypes,
        uint8[] calldata _tradesAllowed,
        uint64 _startTs
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_nftTypes.length == 0 || _startTs == 0) revert ZeroValueNotPermited();
        if (_nftTypes.length != _tradesAllowed.length) revert InputArraysMustHaveSameLength();
        _startTs.validateTimestamp();
        _nftTypes.areTagsValid();
        return _addNFTTransferCounterRule(_nftTypes, _tradesAllowed, _startTs);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _nftTypes Types of NFTs
     * @param _tradesAllowed Maximum trades allowed within 24 hours
     * @param _startTs starting timestamp for the rule
     * @return position of new rule in array
     */
    function _addNFTTransferCounterRule(bytes32[] calldata _nftTypes, uint8[] calldata _tradesAllowed, uint64 _startTs) internal returns (uint32) {
        RuleS.NFTTransferCounterRuleS storage data = Storage.nftTransferStorage();
        uint32 index = data.NFTTransferCounterRuleIndex;
        for (uint256 i; i < _nftTypes.length; ) {
            TaggedRules.NFTTradeCounterRule memory rule = TaggedRules.NFTTradeCounterRule(_tradesAllowed[i], _startTs);
            data.NFTTransferCounterRule[index][_nftTypes[i]] = rule;
            unchecked {
                ++i;
            }
        }
        bytes32[] memory empty;
        emit ProtocolRuleCreated(NFT_TRANSFER, index, empty);
        ++data.NFTTransferCounterRuleIndex;
        return index;
    }

}
