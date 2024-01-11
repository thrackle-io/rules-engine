// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";
import "./IOracle.sol";

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
            NonTaggedRules.TokenMinimumTransferRule memory rule = getMinimumTransferRule(_ruleId);
            if (rule.minTransferAmount > amountToTransfer) revert BelowMinTransfer();
    }

    /**
     * @dev Function to get Minimum Transfer rules by index
     * @param _index position of rule in array
     * @return Rule at index
     */
    function getMinimumTransferRule(uint32 _index) public view returns (NonTaggedRules.TokenMinimumTransferRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalMinimumTransferRules());
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        return data.minimumTransferRules[_index];
    }

    /**
     * @dev Function to get total Minimum Transfer rules
     * @return Total length of array
     */
    function getTotalMinimumTransferRules() public view returns (uint32) {
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        return data.minimumTransferRuleIndex;
    }

    /**
     * @dev This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param _address user address to be checked
     */
    function checkOraclePasses(uint32 _ruleId, address _address) external view {
            NonTaggedRules.OracleRule memory oracleRule = getOracleRule(_ruleId);
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
            } else if (oType == uint(ORACLE_TYPE.DENIED_LIST)) {
                /// If Deny List Oracle rule active all transactions to addresses registered to deny list (including address(0)) will be denied.
                if (IOracle(oracleAddress).isDenied(_address)) {
                    revert AddressIsDenied();
                }
                /// Invalid oracle type
            } else {
                revert OracleTypeInvalid();
            }
    }

    /**
     * @dev Function get Oracle Rule by index
     * @param _index Position of rule in storage
     * @return OracleRule at index
     */
    function getOracleRule(uint32 _index) public view returns (NonTaggedRules.OracleRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalOracleRules());
        RuleS.OracleRuleS storage data = Storage.oracleStorage();
        return data.oracleRules[_index];
    }

    /**
     * @dev Function get total Oracle rules
     * @return total oracleRules array length
     */
    function getTotalOracleRules() public view returns (uint32) {
        RuleS.OracleRuleS storage data = Storage.oracleStorage();
        return data.oracleRuleIndex;
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
        NonTaggedRules.TokenPercentagePurchaseRule memory percentagePurchaseRule = getPctPurchaseRule(ruleId);
        uint256 totalPurchasedWithinPeriod = amountToTransfer; /// resets value for purchases outside of purchase period
        uint256 totalSupply = percentagePurchaseRule.totalSupply;
        /// check if totalSupply in rule struct is 0 and if it is use currentTotalSupply, if < 0 use rule value
        if (percentagePurchaseRule.totalSupply == 0) totalSupply = currentTotalSupply;
        uint16 percentOfTotalSupply = uint16(((amountToTransfer + purchasedWithinPeriod) * 10000) / totalSupply);
        // check if within current purchase period
        /// we perform the rule check
        if (percentagePurchaseRule.startTime.isWithinPeriod(percentagePurchaseRule.purchasePeriod, lastPurchaseTime)) {
            /// update totalPurchasedWithinPeriod to include the amountToTransfer when inside purchase period
            totalPurchasedWithinPeriod = amountToTransfer + purchasedWithinPeriod;
            /// perform rule check if amountToTransfer + purchasedWithinPeriod is over allowed amount of total supply
            if (percentOfTotalSupply >= percentagePurchaseRule.tokenPercentage) revert PurchasePercentageReached();
        }
        return totalPurchasedWithinPeriod;
    }

    /**
     * @dev Function get Token Purchase Percentage by index
     * @param _index position of rule in array
     * @return percentagePurchaseRules rule at index position
     */
    function getPctPurchaseRule(uint32 _index) public view returns (NonTaggedRules.TokenPercentagePurchaseRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalPctPurchaseRule());
        RuleS.PctPurchaseRuleS storage data = Storage.pctPurchaseStorage();
        return data.percentagePurchaseRules[_index];
    }

    /**
     * @dev Function to get total Token Purchase Percentage
     * @return Total length of array
     */
    function getTotalPctPurchaseRule() public view returns (uint32) {
        RuleS.PctPurchaseRuleS storage data = Storage.pctPurchaseStorage();
        return data.percentagePurchaseRuleIndex;
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
        NonTaggedRules.TokenPercentageSellRule memory percentageSellRule = getPctSellRule(ruleId);
        uint256 totalSoldWithinPeriod = amountToTransfer; /// resets value for purchases outside of purchase period
        uint256 totalSupply = percentageSellRule.totalSupply;
        /// check if totalSupply in rule struct is 0 and if it is use currentTotalSupply, if < 0 use rule value
        if (percentageSellRule.totalSupply == 0) totalSupply = currentTotalSupply;
        uint16 percentOfTotalSupply = uint16(((amountToTransfer + soldWithinPeriod) * 10000) / totalSupply);
        // check if within current purchase period
        /// we perform the rule check
        if (percentageSellRule.startTime.isWithinPeriod(percentageSellRule.sellPeriod, lastSellTime)) {
            /// update soldWithinPeriod to include the amountToTransfer when inside purchase period
            totalSoldWithinPeriod = amountToTransfer + soldWithinPeriod;
            /// perform rule check if amountToTransfer + soldWithinPeriod is over allowed amount of total supply
            if (percentOfTotalSupply >= percentageSellRule.tokenPercentage) revert SellPercentageReached();
        }
        return totalSoldWithinPeriod;
    }

    /**
     * @dev Function get Token sell Percentage by index
     * @param _index position of rule in array
     * @return percentageSellRules rule at index position
     */
    function getPctSellRule(uint32 _index) public view returns (NonTaggedRules.TokenPercentageSellRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalPctSellRule());
        RuleS.PctSellRuleS storage data = Storage.pctSellStorage();
        return data.percentageSellRules[_index];
    }

    /**
     * @dev Function to get total Token Percentage Sell
     * @return Total length of array
     */
    function getTotalPctSellRule() public view returns (uint32) {
        RuleS.PctSellRuleS storage data = Storage.pctSellStorage();
        return data.percentageSellRuleIndex;
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
        /// we procede to retrieve the rule
        NonTaggedRules.TokenTransferVolumeRule memory rule = getTransferVolumeRule(_ruleId);
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
     * @dev Function get Token Transfer Volume Rule by index
     * @param _index position of rule in array
     * @return TokenTransferVolumeRule rule at index position
     */
    function getTransferVolumeRule(uint32 _index) public view returns (NonTaggedRules.TokenTransferVolumeRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalTransferVolumeRules());
        RuleS.TransferVolRuleS storage data = Storage.volumeStorage();
        return data.transferVolumeRules[_index];
    }

    /**
     * @dev Function to get total Token Transfer Volume rules
     * @return Total length of array
     */
    function getTotalTransferVolumeRules() public view returns (uint32) {
        RuleS.TransferVolRuleS storage data = Storage.volumeStorage();
        return data.transferVolRuleIndex;
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
        /// we procede to retrieve the rule
        NonTaggedRules.SupplyVolatilityRule memory rule = getSupplyVolatilityRule(_ruleId);
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

        function getSupplyVolatilityRule(uint32 _index) public view returns (NonTaggedRules.SupplyVolatilityRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalSupplyVolatilityRules());
        RuleS.SupplyVolatilityRuleS storage data = Storage.supplyVolatilityStorage();
        return data.supplyVolatilityRules[_index];
    }

    /**
     * @dev Function to get total Supply Volitility rules
     * @return supplyVolatilityRules total length of array
     */
    function getTotalSupplyVolatilityRules() public view returns (uint32) {
        RuleS.SupplyVolatilityRuleS storage data = Storage.supplyVolatilityStorage();
        return data.supplyVolatilityRuleIndex;
    }

}
