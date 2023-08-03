// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {RuleDataFacet} from "../ruleStorage/RuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";
import {IRuleProcessorErrors, IERC20Errors} from "../../interfaces/IErrors.sol";
import "../ruleStorage/RuleCodeData.sol";
import "./IOracle.sol";
import "./RuleProcessorCommonLib.sol";

/**
 * @title ERC20 Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check token rules compliance
 * @notice Implements Token Fee Rules on Accounts.
 */
contract ERC20RuleProcessorFacet is IRuleProcessorErrors, IERC20Errors {
    using RuleProcessorCommonLib for uint64;

    /**
     * @dev Check if transaction passes minTransfer rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param amountToTransfer total number of tokens to be transferred
     */
    function checkMinTransferPasses(uint32 _ruleId, uint256 amountToTransfer) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);

        if (data.getTotalMinimumTransferRules() != 0) {
            try data.getMinimumTransferRule(_ruleId) returns (uint min) {
                if (min > amountToTransfer) revert BelowMinTransfer();
            } catch {
                revert RuleDoesNotExist();
            }
        }
    }

    /**
     * @dev This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param _address user address to be checked
     */
    function checkOraclePasses(uint32 _ruleId, address _address) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);

        if (data.getTotalOracleRules() != 0) {
            try data.getOracleRule(_ruleId) returns (NonTaggedRules.OracleRule memory oracleRule) {
                uint256 oType = oracleRule.oracleType;
                address oracleAddress = oracleRule.oracleAddress;
                /// White List type
                if (oType == uint(ORACLE_TYPE.ALLOWED_LIST)) {
                    if (!IOracle(oracleAddress).isAllowed(_address)) {
                        revert AddressNotOnAllowedList();
                    }

                    /// Black List type
                } else if (oType == uint(ORACLE_TYPE.RESTRICTED_LIST)) {
                    if (IOracle(oracleAddress).isRestricted(_address)) {
                        revert AddressIsRestricted();
                    }
                    /// Invalid oracle type
                } else {
                    revert OracleTypeInvalid();
                }
            } catch {
                revert RuleDoesNotExist();
            }
        }
    }

    /**
     * @dev Function receives a rule id, retrieves the rule data and checks if the Purchase Percentage Rule passes
     * @param ruleId id of the rule to be checked
     * @param currentTotalSupply total supply value passed in by the handler. This is for ERC20 tokens with a fixed total supply.
     * @param amountToTransfer total number of tokens to be transferred in transaction.
     * @param lastPurchaseTime time of the most recent purchase from AMM. This starts the check if current transaction is within a purchase window.
     * @param purchasedWithinPeriod total amount of tokens purchased in current period
     */
    function checkPurchasePercentagePasses(
        uint32 ruleId,
        uint256 currentTotalSupply,
        uint256 amountToTransfer,
        uint64 lastPurchaseTime,
        uint256 purchasedWithinPeriod
    ) external view returns (uint256) {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalPctPurchaseRule();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();
        NonTaggedRules.TokenPercentagePurchaseRule memory percentagePurchaseRule = data.getPctPurchaseRule(ruleId);
        uint256 totalPurchasedWithinPeriod;
        if (percentagePurchaseRule.startTime.isRuleActive()) {
            totalPurchasedWithinPeriod = amountToTransfer; /// resets value for purchases outside of purchase period
            uint256 totalSupply = percentagePurchaseRule.totalSupply;
            /// check if totalSupply in rule struct is 0 and if it is use currentTotalSupply, if < 0 use rule value
            if (percentagePurchaseRule.totalSupply == 0) totalSupply = currentTotalSupply;
            // check if within current purchase period
            if (percentagePurchaseRule.startTime.isWithinPeriod(percentagePurchaseRule.purchasePeriod, lastPurchaseTime)) {
                /// update soldWithinPeriod to include the amountToTransfer when inside purchase period
                totalPurchasedWithinPeriod = amountToTransfer + purchasedWithinPeriod;
            } else {
                totalPurchasedWithinPeriod = amountToTransfer;
            }
            /// perform rule check if amountToTransfer + soldWithinPeriod is over allowed amount of total supply
            uint16 percentOfTotalSupply = uint16((totalPurchasedWithinPeriod * 10000) / totalSupply);
            if (percentOfTotalSupply >= percentagePurchaseRule.tokenPercentage) revert SellPercentageReached();
        }
        return totalPurchasedWithinPeriod;
    }

    /**
     *
     * @param ruleId id of the rule to be checked
     * @param currentTotalSupply total supply value passed in by the handler. This is for ERC20 tokens with a fixed total supply.
     * @param amountToTransfer total number of tokens to be transferred in transaction.
     * @param lastSellTime time of the most recent purchase from AMM. This starts the check if current transaction is within a purchase window.
     * @param soldWithinPeriod total amount of tokens sold within current period
     */
    function checkSellPercentagePasses(uint32 ruleId, uint256 currentTotalSupply, uint256 amountToTransfer, uint64 lastSellTime, uint256 soldWithinPeriod) external view returns (uint256) {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        uint totalRules = data.getTotalPctSellRule();
        if ((totalRules > 0 && totalRules <= ruleId) || totalRules == 0) revert RuleDoesNotExist();
        NonTaggedRules.TokenPercentageSellRule memory percentageSellRule = data.getPctSellRule(ruleId);
        uint256 totalSoldWithinPeriod = amountToTransfer; /// resets value for purchases outside of purchase period
        if (percentageSellRule.startTime.isRuleActive()) {
            uint256 totalSupply = percentageSellRule.totalSupply;
            /// check if totalSupply in rule struct is 0 and if it is use currentTotalSupply, if < 0 use rule value
            if (percentageSellRule.totalSupply == 0) totalSupply = currentTotalSupply;
            // check if within current purchase period
            if (percentageSellRule.startTime.isWithinPeriod(percentageSellRule.sellPeriod, lastSellTime)) {
                /// update soldWithinPeriod to include the amountToTransfer when inside purchase period
                totalSoldWithinPeriod = amountToTransfer + soldWithinPeriod;
            } else {
                totalSoldWithinPeriod = amountToTransfer;
            }
            /// perform rule check if amountToTransfer + soldWithinPeriod is over allowed amount of total supply
            uint16 percentOfTotalSupply = uint16((totalSoldWithinPeriod * 10000) / totalSupply);
            if (percentOfTotalSupply >= percentageSellRule.tokenPercentage) revert SellPercentageReached();
        }

        return totalSoldWithinPeriod;
    }

    /**
     * @dev Rule checks if the token transfer volume rule will be violated.
     * @param _ruleId Rule identifier for rule arguments
     * @param _volume token's trading volume thus far
     * @param _amount Number of tokens to be transferred from this account
     * @param _supply Number of tokens in supply
     * @param _lastTransferTs the time of the last transfer
     * @return volumeTotal new accumulated volume
     */
    function checkTokenTransferVolumePasses(uint32 _ruleId, uint256 _volume, uint256 _supply, uint256 _amount, uint64 _lastTransferTs) external view returns (uint256) {
        /// we create the 'data' variable which is simply a connection to the rule diamond
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        /// validation block
        if ((data.getTotalTransferVolumeRules() == 0)) revert RuleDoesNotExist();
        /// we procede to retrieve the rule
        try data.getTransferVolumeRule(_ruleId) returns (NonTaggedRules.TokenTransferVolumeRule memory rule) {
            if (rule.startTime.isRuleActive()) {
                /// we perform the rule check
                if (rule.startTime.isWithinPeriod(rule.period, _lastTransferTs)) {
                    /// This means that the last trades "tradesWithinPeriod" were inside current period,
                    /// and we need to acumulate this trade to the those ones
                    _volume += _amount;
                } else {
                    _volume = _amount;
                }
                /// if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)
                if (rule.totalSupply != 0) {
                    _supply = rule.totalSupply;
                }
                // we check the numbers against the rule
                if ((_volume * 100000000) / _supply >= uint(rule.maxVolume) * 10000) {
                    revert TransferExceedsMaxVolumeAllowed();
                }
            }
        } catch {
            revert RuleDoesNotExist();
        }
        return _volume;
    }

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
        try data.getSupplyVolatilityRule(_ruleId) returns (NonTaggedRules.SupplyVolatilityRule memory rule) {
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
        } catch {
            revert RuleDoesNotExist();
        }
        return (_volumeTotalForPeriod, _tokenTotalSupply);
    }
}
