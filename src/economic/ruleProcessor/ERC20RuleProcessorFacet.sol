// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RuleProcessorDiamondLib as Diamond} from "./RuleProcessorDiamondLib.sol";
import {RuleStoragePositionLib as Storage} from "./RuleStoragePositionLib.sol";
import {INonTaggedRules as NonTaggedRules} from "./RuleDataInterfaces.sol";
import {IRuleStorage as RuleS} from "./IRuleStorage.sol";
import {RuleDataFacet} from "./RuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "./RuleDataInterfaces.sol";
import {IInputErrors, IRuleProcessorErrors, IERC20Errors} from "../../interfaces/IErrors.sol";
import "./RuleCodeData.sol";
import "./IOracle.sol";
import "./RuleProcessorCommonLib.sol";

/**
 * @title ERC20 Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check token rules compliance
 * @notice Implements Token Fee Rules on Accounts.
 */
contract ERC20RuleProcessorFacet is IInputErrors, IRuleProcessorErrors, IERC20Errors {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;

    /**
     * @dev Check if transaction passes minTransfer rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param amountToTransfer total number of tokens to be transferred
     */
    function checkMinTransferPasses(uint32 _ruleId, uint256 amountToTransfer) external view {
        if (getTotalMinimumTransferRule() != 0) {
            NonTaggedRules.TokenMinimumTransferRule memory rule = getMinimumTransferRules(_ruleId);
            if (rule.minTransferAmount > amountToTransfer) revert BelowMinTransfer();
        }
    }

    /**
     * @dev Function to get Minimum Transfer rules by index
     * @param _index position of rule in array
     * @return Rule at index
     */
    function getMinimumTransferRules(uint32 _index) public view returns (NonTaggedRules.TokenMinimumTransferRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalMinimumTransferRule());
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        return data.minimumTransferRules[_index];
    }

    /**
     * @dev Function to get total Minimum Transfer rules
     * @return Total length of array
     */
    function getTotalMinimumTransferRule() public view returns (uint32) {
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        return data.minimumTransferRuleIndex;
    }

    /**
     * @dev This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param _address user address to be checked
     */
    function checkOraclePasses(uint32 _ruleId, address _address) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        if (data.getTotalOracleRules() != 0) {
            NonTaggedRules.OracleRule memory oracleRule = data.getOracleRule(_ruleId);
            uint256 oType = oracleRule.oracleType;
            address oracleAddress = oracleRule.oracleAddress;
            /// Allow List type
            if (oType == uint(ORACLE_TYPE.ALLOWED_LIST)) {
                /// If Allow List Oracle rule active, address(0) is exempt to allow for burning
                if (_address != address(0)) {
                    if (!IOracle(oracleAddress).isAllowed(_address)) {
                        revert AddressNotOnAllowedList();
                    }
                }
                /// Deny List type
            } else if (oType == uint(ORACLE_TYPE.RESTRICTED_LIST)) {
                /// If Deny List Oracle rule active all transactions to addresses registered to deny list (including address(0)) will be denied.
                if (IOracle(oracleAddress).isRestricted(_address)) {
                    revert AddressIsRestricted();
                }
                /// Invalid oracle type
            } else {
                revert OracleTypeInvalid();
            }
        }
    }

    /**
     * @dev Rule checks if the token transfer volume rule will be violated.
     * @param _ruleId Rule identifier for rule arguments
     * @param _volume token's trading volume thus far
     * @param _amount Number of tokens to be transferred from this account
     * @param _supply Number of tokens in supply
     * @param _lastTransferTs the time of the last transfer
     * @return _volume new accumulated volume
     */
    function checkTokenTransferVolumePasses(uint32 _ruleId, uint256 _volume, uint256 _supply, uint256 _amount, uint64 _lastTransferTs) external view returns (uint256) {
        /// we create the 'data' variable which is simply a connection to the rule diamond
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        /// validation block
        if ((data.getTotalTransferVolumeRules() == 0)) revert RuleDoesNotExist();
        /// we procede to retrieve the rule
        NonTaggedRules.TokenTransferVolumeRule memory rule = data.getTransferVolumeRule(_ruleId);
        if (rule.startTime.isRuleActive()) {
            /// If the last trades "tradesWithinPeriod" were inside current period,
            /// we need to acumulate this trade to the those ones. If not, reset to only current amount.
            _volume = rule.startTime.isWithinPeriod(rule.period, _lastTransferTs) ? 
            _volume + _amount : _amount;
            /// if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)
            if (rule.totalSupply != 0) {
                _supply = rule.totalSupply;
            }
            // we check the numbers against the rule
            if ((_volume * 100000000) / _supply >= uint(rule.maxVolume) * 10000) {
                revert TransferExceedsMaxVolumeAllowed();
            }
        }
        return _volume;
    }

    /**
     * @dev Rule checks if the token total supply volatility rule will be violated.
     * @param _ruleId Rule identifier for rule arguments
     * @param _volumeTotalForPeriod token's trading volume for the period
     * @param _tokenTotalSupply the total supply from token tallies
     * @param _supply token total supply value
     * @param _amount amount in the current transfer
     * @param _lastSupplyUpdateTime the last timestamp the supply was updated
     * @return _volumeTotalForPeriod properly adjusted total for the current period
     * @return _tokenTotalSupply properly adjusted token total supply. This is necessary because if the token's total supply is used it skews results within the period
     */
    function checkTotalSupplyVolatilityPasses(
        uint32 _ruleId,
        int256 _volumeTotalForPeriod,
        uint256 _tokenTotalSupply,
        uint256 _supply,
        int256 _amount,
        uint64 _lastSupplyUpdateTime
    ) external view returns (int256, uint256) {
        int256 volatility;
        /// we create the 'data' variable which is simply a connection to the rule diamond
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        /// validation block
        if ((data.getTotalSupplyVolatilityRules() == 0)) revert RuleDoesNotExist();
        /// we procede to retrieve the rule
        NonTaggedRules.SupplyVolatilityRule memory rule = data.getSupplyVolatilityRule(_ruleId);
        if (rule.startingTime.isRuleActive()) {
            /// check if totalSupply is specified in rule params
            if (rule.totalSupply != 0) {
                _supply = rule.totalSupply;
            }
            /// Account for the very first period
            if (_tokenTotalSupply == 0) _tokenTotalSupply = _supply;
            /// check if current transaction is inside rule period
            if (rule.startingTime.isWithinPeriod(rule.period, _lastSupplyUpdateTime)) {
                /// if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)
                _volumeTotalForPeriod += _amount;
                /// the _tokenTotalSupply is not modified during the rule period. It needs to stay the same value as what it was at the beginning of the period to keep consistent results since mints/burns change totalSupply in the token
            } else {
                _volumeTotalForPeriod = _amount;
                /// update total supply of token when outside of rule period
                _tokenTotalSupply = _supply;
            }
            volatility = (_volumeTotalForPeriod * 100000000) / int(_tokenTotalSupply);
            if (volatility < 0) volatility = volatility * -1;
            if (uint256(volatility) > uint(rule.maxChange) * 10000) {
                revert TotalSupplyVolatilityLimitReached();
            }
        }
        return (_volumeTotalForPeriod, _tokenTotalSupply);
    }
}
