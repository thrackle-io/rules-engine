// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./RuleProcessorDiamondImports.sol";
import "src/common/IOracle.sol";
import {Rule} from "src/client/token/handler/common/DataStructures.sol";

/**
 * @title ERC20 Handler Facet 
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check token rules compliance
 * @notice Implements Token Fee Rules on Accounts.
 */
contract ERC20RuleProcessorFacet is IInputErrors, IRuleProcessorErrors, IERC20Errors {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for int256;

    uint256 constant _VOLUME_MULTIPLIER = 10**8;
    uint256 constant _BASIS_POINT = 10000;
    /**
     * @dev Check if transaction passes Token Min Tx Size rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param amountToTransfer total number of tokens to be transferred
     */
    function checkTokenMinTxSize(uint32 _ruleId, uint256 amountToTransfer) external view {
            NonTaggedRules.TokenMinTxSize memory rule = getTokenMinTxSize(_ruleId);
            if (rule.minSize > amountToTransfer) revert UnderMinTxSize();
    }

    /**
     * @dev Function to get Token Min Tx Size rules by index
     * @param _index position of rule in array
     * @return Rule at index
     */
    function getTokenMinTxSize(uint32 _index) public view returns (NonTaggedRules.TokenMinTxSize memory) {
        _index.checkRuleExistence(getTotalTokenMinTxSize());
        RuleS.TokenMinTxSizeS storage data = Storage.tokenMinTxSizePosition();
        return data.tokenMinTxSizeRules[_index];
    }

    /**
     * @dev Function to get total Token Min Tx Size rules
     * @return Total length of array
     */
    function getTotalTokenMinTxSize() public view returns (uint32) {
        RuleS.TokenMinTxSizeS storage data = Storage.tokenMinTxSizePosition();
        return data.tokenMinTxSizeIndex;
    }

    /**
     * @dev This function receives an array of rule ids, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _rules Rule Id Array
     * @param _address user address to be checked
     */
    function checkAccountApproveDenyOracles(Rule[] memory _rules, address _address) external view {
        for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < _rules.length; ) {
            if (_rules[accountApproveDenyOracleIndex].active) 
                checkAccountApproveDenyOracle(_rules[accountApproveDenyOracleIndex].ruleId, _address);
            unchecked {
                ++accountApproveDenyOracleIndex;
            }
        }
    }

    /**
     * @dev This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param _address user address to be checked
     */
    function checkAccountApproveDenyOracle(uint32 _ruleId, address _address) internal view {
            NonTaggedRules.AccountApproveDenyOracle memory oracleRule = getAccountApproveDenyOracle(_ruleId);
            uint256 oType = oracleRule.oracleType;
            address oracleAddress = oracleRule.oracleAddress;
            if (oType == uint(ORACLE_TYPE.APPROVED_LIST)) {
                /// If Approve List Oracle rule active, address(0) is exempt to allow for burning
                if (_address != address(0)) {
                    // slither-disable-next-line calls-loop
                    if (!IOracle(oracleAddress).isApproved(_address)) {
                        revert AddressNotApproved();
                    }
                }
            } else if (oType == uint(ORACLE_TYPE.DENIED_LIST)) {
                // slither-disable-next-line calls-loop
                if (IOracle(oracleAddress).isDenied(_address)) {
                    revert AddressIsDenied();
                }
            } else {
                revert OracleTypeInvalid();
            }
    }

    /**
     * @dev Function get Account Approve Deny Oracle Rule by index
     * @param _index Position of rule in storage
     * @return AccountApproveDenyOracle at index
     */
    function getAccountApproveDenyOracle(uint32 _index) public view returns (NonTaggedRules.AccountApproveDenyOracle memory) {
        _index.checkRuleExistence(getTotalAccountApproveDenyOracle());
        RuleS.AccountApproveDenyOracleS storage data = Storage.accountApproveDenyOracleStorage();
        return data.accountApproveDenyOracleRules[_index];
    }

    /**
     * @dev Function get total Account Approve Deny Oracle rules
     * @return total accountApproveDenyOracleRules array length
     */
    function getTotalAccountApproveDenyOracle() public view returns (uint32) {
        RuleS.AccountApproveDenyOracleS storage data = Storage.accountApproveDenyOracleStorage();
        return data.accountApproveDenyOracleIndex;
    }

    /**
     * @dev Rule checks if the Token Max Trading Volume rule will be violated.
     * @notice If the totalSupply value is set in the rule, it is set as the circulating supply. Otherwise, this function uses the ERC20 totalSupply sent from handler.
     * @param _ruleId Rule identifier for rule arguments
     * @param _volume token's trading volume thus far
     * @param _amount Number of tokens to be transferred from this account
     * @param _supply Number of tokens in supply
     * @param _lastTransferTime the time of the last transfer
     * @return _volume new accumulated volume
     */
    function checkTokenMaxTradingVolume(uint32 _ruleId, uint256 _volume, uint256 _supply, uint256 _amount, uint64 _lastTransferTime) external view returns (uint256) {
        NonTaggedRules.TokenMaxTradingVolume memory rule = getTokenMaxTradingVolume(_ruleId);
        if (rule.startTime.isRuleActive()) {
            _volume = rule.startTime.isWithinPeriod(rule.period, _lastTransferTime) ? _volume + _amount : _amount;
            /// if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)
            if (rule.totalSupply != 0) {
                _supply = rule.totalSupply;
            }
            if ((_volume * _VOLUME_MULTIPLIER) / _supply >= uint(rule.max) * _BASIS_POINT) {
                revert OverMaxTradingVolume();
            }
        }
        return _volume;
    }

    /**
     * @dev Function get Token Max Trading Volume by index
     * @param _index position of rule in array
     * @return TokenMaxTradingVolume rule at index position
     */
    function getTokenMaxTradingVolume(uint32 _index) public view returns (NonTaggedRules.TokenMaxTradingVolume memory) {
        _index.checkRuleExistence(getTotalTokenMaxTradingVolume());
        RuleS.TokenMaxTradingVolumeS storage data = Storage.tokenMaxTradingVolumeStorage();
        return data.tokenMaxTradingVolumeRules[_index];
    }

    /**
     * @dev Function to get total Token Max Trading Volume rules
     * @return Total length of array
     */
    function getTotalTokenMaxTradingVolume() public view returns (uint32) {
        RuleS.TokenMaxTradingVolumeS storage data = Storage.tokenMaxTradingVolumeStorage();
        return data.tokenMaxTradingVolumeIndex;
    }

    /**
     * @dev Rule checks if the Token Max Supply Volatility rule will be violated.
     * @notice If the totalSupply value is set in the rule, it is set as the circulating supply. Otherwise, this function uses the ERC20 totalSupply sent from handler.
     * @param _ruleId Rule identifier for rule arguments
     * @param _volumeTotalForPeriod token's trading volume for the period
     * @param _tokenTotalSupply the total supply from token tallies
     * @param _supply token total supply value
     * @param _amount amount in the current transfer
     * @param _lastSupplyUpdateTime the last timestamp the supply was updated
     * @return _volumeTotalForPeriod properly adjusted total for the current period
     * @return _tokenTotalSupply properly adjusted token total supply. This is necessary because if the token's total supply is used it skews results within the period
     */
    function checkTokenMaxSupplyVolatility(
        uint32 _ruleId,
        int256 _volumeTotalForPeriod,
        uint256 _tokenTotalSupply,
        uint256 _supply,
        int256 _amount,
        uint64 _lastSupplyUpdateTime
    ) external view returns (int256, uint256) {
        int256 volatility;
        NonTaggedRules.TokenMaxSupplyVolatility memory rule = getTokenMaxSupplyVolatility(_ruleId);
        if (rule.startTime.isRuleActive()) {
            if (rule.totalSupply != 0) {
                _supply = rule.totalSupply;
            }
            /// Account for the very first period
            if (_tokenTotalSupply == 0) _tokenTotalSupply = _supply;
            if (rule.startTime.isWithinPeriod(rule.period, _lastSupplyUpdateTime)) {
                _volumeTotalForPeriod += _amount;
                /// The _tokenTotalSupply is not modified during the rule period. 
                /// It needs to stay the same value as what it was at the beginning of the period to keep consistent results since mints/burns change totalSupply in the token.
            } else {
                _volumeTotalForPeriod = _amount;
                /// Update total supply of token when outside of rule period
                _tokenTotalSupply = _supply;
            }
            volatility = _volumeTotalForPeriod.calculateVolatility(_VOLUME_MULTIPLIER, _tokenTotalSupply);
            // Disabling the next finding, the multiplication here is used purely to get the absolute value 
            // slither-disable-next-line divide-before-multiply
            if (volatility < 0) volatility = volatility * -1;
            if (uint256(volatility) > uint(rule.max) * _BASIS_POINT) {
                revert OverMaxSupplyVolatility();
            }
        }
        return (_volumeTotalForPeriod, _tokenTotalSupply);
    }

    /**
     * @dev Function to get Token Max Supply Volatility rule by index
     * @param _index position of rule in array
     * @return tokenMaxSupplyVolatility Rule
     */
    function getTokenMaxSupplyVolatility(uint32 _index) public view returns (NonTaggedRules.TokenMaxSupplyVolatility memory) {
        _index.checkRuleExistence(getTotalTokenMaxSupplyVolatility());
        RuleS.TokenMaxSupplyVolatilityS storage data = Storage.tokenMaxSupplyVolatilityStorage();
        return data.tokenMaxSupplyVolatilityRules[_index];
    }

    /**
     * @dev Function to get total Token Max Supply Volatility rules
     * @return tokenMaxSupplyVolatility Rules total length of array
     */
    function getTotalTokenMaxSupplyVolatility() public view returns (uint32) {
        RuleS.TokenMaxSupplyVolatilityS storage data = Storage.tokenMaxSupplyVolatilityStorage();
        return data.tokenMaxSupplyVolatilityIndex;
    }

    /**
     * @dev Function receives a rule id, retrieves the rule data and checks if the Token Max Buy Volume Rule passes
     * @param ruleId id of the rule to be checked
     * @param currentTotalSupply total supply value passed in by the handler. This is for ERC20 tokens with a fixed total supply.
     * @param amountToTransfer total number of tokens to be transferred in transaction.
     * @param lastPurchaseTime time of the most recent purchase from AMM. This starts the check if current transaction is within a purchase window.
     * @param boughtInPeriod total amount of tokens purchased in current period
     */
    function checkTokenMaxBuyVolume(
        uint32 ruleId,
        uint256 currentTotalSupply,
        uint256 amountToTransfer,
        uint64 lastPurchaseTime,
        uint256 boughtInPeriod
    ) external view returns (uint256) {
        NonTaggedRules.TokenMaxBuyVolume memory rule = getTokenMaxBuyVolume(ruleId);
        uint256 totalBoughtInPeriod = rule.startTime.isWithinPeriod(rule.period, lastPurchaseTime) ?
            amountToTransfer + boughtInPeriod : amountToTransfer;
        uint256 totalSupply = rule.totalSupply == 0 ? currentTotalSupply: rule.totalSupply;
        uint16 percentOfTotalSupply = uint16(((totalBoughtInPeriod) * _BASIS_POINT) / totalSupply);
        if (percentOfTotalSupply >= rule.tokenPercentage) revert OverMaxBuyVolume();
        return totalBoughtInPeriod;
    }

    /**
     * @dev Function get Token Max Buy Volume by index
     * @param _index position of rule in array
     * @return tokenMaxBuyVolumeRules rule at index position
     */
    function getTokenMaxBuyVolume(uint32 _index) public view returns (NonTaggedRules.TokenMaxBuyVolume memory) {
        _index.checkRuleExistence(getTotalTokenMaxBuyVolume());
        RuleS.TokenMaxBuyVolumeS storage data = Storage.accountMaxBuyVolumeStorage();
        return data.tokenMaxBuyVolumeRules[_index];
    }

    /**
     * @dev Function to get total Token Max Buy Volume rules
     * @return Total length of array
     */
    function getTotalTokenMaxBuyVolume() public view returns (uint32) {
        RuleS.TokenMaxBuyVolumeS storage data = Storage.accountMaxBuyVolumeStorage();
        return data.tokenMaxBuyVolumeIndex;
    }

    /**
     * @dev Function receives a rule id, retrieves the rule data and checks if the Token Max Sell Volume Rule passes
     * @param ruleId id of the rule to be checked
     * @param currentTotalSupply total supply value passed in by the handler. This is for ERC20 tokens with a fixed total supply.
     * @param amountToTransfer total number of tokens to be transferred in transaction.
     * @param lastSellTime time of the most recent purchase from AMM. This starts the check if current transaction is within a purchase window.
     * @param soldWithinPeriod total amount of tokens sold within current period
     */
    function checkTokenMaxSellVolume(uint32 ruleId, uint256 currentTotalSupply, uint256 amountToTransfer, uint64 lastSellTime, uint256 soldWithinPeriod) external view returns (uint256) {
        NonTaggedRules.TokenMaxSellVolume memory rule = getTokenMaxSellVolume(ruleId);
        uint256 totalSoldInPeriod = rule.startTime.isWithinPeriod(rule.period, lastSellTime) ? 
            amountToTransfer + soldWithinPeriod : amountToTransfer; 
        uint256 totalSupply = rule.totalSupply == 0 ? currentTotalSupply: rule.totalSupply;
        uint16 percentOfTotalSupply = uint16(((totalSoldInPeriod) * _BASIS_POINT) / totalSupply);
        if (percentOfTotalSupply >= rule.tokenPercentage) revert OverMaxSellVolume();
        return totalSoldInPeriod;
    }

    /**
     * @dev Function get Token Max Sell Volume by index
     * @param _index position of rule in array
     * @return tokenMaxSellVolumeRules rule at index position
     */
    function getTokenMaxSellVolume(uint32 _index) public view returns (NonTaggedRules.TokenMaxSellVolume memory) {
        _index.checkRuleExistence(getTotalTokenMaxSellVolume());
        RuleS.TokenMaxSellVolumeS storage data = Storage.accountMaxSellVolumeStorage();
        return data.tokenMaxSellVolumeRules[_index];
    }

    /**
     * @dev Function to get total Token Max Sell Volume rules
     * @return Total length of array
     */
    function getTotalTokenMaxSellVolume() public view returns (uint32) {
        RuleS.TokenMaxSellVolumeS storage data = Storage.accountMaxSellVolumeStorage();
        return data.tokenMaxSellVolumeIndex;
    }

}
