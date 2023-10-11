// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
            try data.getMinimumTransferRule(_ruleId) returns (NonTaggedRules.TokenMinimumTransferRule memory rule) {
                if (rule.minTransferAmount > amountToTransfer) revert BelowMinTransfer();
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
            } catch {
                revert RuleDoesNotExist();
            }
        }
    }

    /**
     * @dev This function receives a rule id, which it uses to get the status oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param account user address to be checked
     * @param tokenAddress address of the NFT contract
     */
    function checkStatusOraclePasses(uint32 _ruleId, address account, address tokenAddress) external payable returns(uint8 status, uint128 _requestId) {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);
        if ( data.getTotalStatusOracleRules() <= _ruleId ) revert RuleDoesNotExist();
        NonTaggedRules.StatusOracleRule memory statusOracleRule = data.getStatusOracleRule(_ruleId);
        address oracleAddress = statusOracleRule.oracleAddress;
        /// bytes4(keccak256(bytes('requestStatus(address,address)'))) = 0x7c44325c
        (bool success, bytes memory res) = oracleAddress.call{value: msg.value}(abi.encodeWithSelector(0x7c44325c, account, tokenAddress));
        if(! success) revert OracleCheckFailed(res);
        /// improve following line with Yul
        (status, _requestId) = abi.decode(res, (uint8, uint128));
        if (status == 0) revert OracleCheckFailed("ACCOUNT DENIED");
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
        try data.getTransferVolumeRule(_ruleId) returns (NonTaggedRules.TokenTransferVolumeRule memory rule) {
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
        } catch {
            revert RuleDoesNotExist();
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
        } catch {
            revert RuleDoesNotExist();
        }
        return (_volumeTotalForPeriod, _tokenTotalSupply);
    }
}
