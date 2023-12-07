// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {INonTaggedRules, ITaggedRules, IFeeRules, IApplicationRules} from "./RuleDataInterfaces.sol";

/**
 * @title IRuleStorage
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev The data structure of each rule storage inside the diamond.
 * @notice This interface outlines the storage structures for each rule stored in diamond
 */
interface IRuleStorage {
    /**
     * Note The following are market-related rules. Checks must be
     * made in AMMs rather than at token level.
     */
    struct PurchaseRuleS {
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.PurchaseRule)) purchaseRulesPerUser;
        uint64 startTime; ///Time the rule is applied
        uint32 purchaseRulesIndex; /// increments every time someone adds a rule
    }

    /// ******** Account Sell Rules ********
    struct SellRuleS {
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.SellRule)) sellRulesPerUser;
        uint64 startTime; /// Time the rule is created
        uint32 sellRulesIndex; /// increments every time someone adds a rule
    }

    /// ******** Token Purchase Percentage Rules ********
    struct PctPurchaseRuleS {
        mapping(uint32 => INonTaggedRules.TokenPercentagePurchaseRule) percentagePurchaseRules;
        uint32 percentagePurchaseRuleIndex;
    }

    /// ******** Token Percentage Sell Rules ********
    struct PctSellRuleS {
        mapping(uint32 => INonTaggedRules.TokenPercentageSellRule) percentageSellRules;
        uint32 percentageSellRuleIndex;
    }

    /// ******** Token Purchase Fee By Volume Rules ********
    struct PurchaseFeeByVolRuleS {
        mapping(uint32 => INonTaggedRules.TokenPurchaseFeeByVolume) purchaseFeeByVolumeRules;
        uint32 purchaseFeeByVolumeRuleIndex;
    }

    /// ******** Token Volatility ********
    struct VolatilityRuleS {
        mapping(uint32 => INonTaggedRules.TokenVolatilityRule) volatilityRules;
        uint32 volatilityRuleIndex;
    }

    /// ******** Token Transfer Volume ********
    struct TransferVolRuleS {
        mapping(uint32 => INonTaggedRules.TokenTransferVolumeRule) transferVolumeRules;
        uint32 transferVolRuleIndex;
    }

    /// ******** Withdrawal Rules ********

    struct WithdrawalRuleS {
        /// ruleIndex => taggedAccount => SupplyVolatilityRules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.WithdrawalRule)) withdrawalRulesPerToken;
        uint32 withdrawalRulesIndex; /// increments every time someone adds a rule
    }

    /// ******** Admin Withdrawal Rules ********

    struct AdminWithdrawalRuleS {
        mapping(uint32 => ITaggedRules.AdminWithdrawalRule) adminWithdrawalRulesPerToken;
        uint32 adminWithdrawalRulesIndex;
    }

    /// ******** Minimum Transaction ********
    struct MinTransferRuleS {
        mapping(uint32 => INonTaggedRules.TokenMinimumTransferRule) minimumTransferRules;
        uint32 minimumTransferRuleIndex; /// increments every time someone adds a rule
    }

    /// ******** Minimum/Maximum Account Balances ********
    struct MinMaxBalanceRuleS {
        /// ruleIndex => taggedAccount => minimumTransfer
        mapping(uint32 => mapping(bytes32 => ITaggedRules.MinMaxBalanceRule)) minMaxBalanceRulesPerUser;
        uint32 minMaxBalanceRuleIndex; /// increments every time someone adds a rule
    }

    /// ******** Minimum Balance By Date ********
    struct MinBalByDateRuleS {
        /// ruleIndex => userTag => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.MinBalByDateRule)) minBalByDateRulesPerUser;
        uint32 minBalByDateRulesIndex; /// increments every time someone adds a rule
    }

    /// ******** Supply Volatility ********
    struct SupplyVolatilityRuleS {
        mapping(uint32 => INonTaggedRules.SupplyVolatilityRule) supplyVolatilityRules;
        uint32 supplyVolatilityRuleIndex;
    }

    /// ******** Oracle ********
    struct OracleRuleS {
        mapping(uint32 => INonTaggedRules.OracleRule) oracleRules;
        uint32 oracleRuleIndex;
    }

    /*****************************************
    ************* AccessLevel Rules ***********
    /*****************************************/
    /// Balance Limit by Access Level
    struct AccessLevelRuleS {
        /// ruleIndex => level => max
        mapping(uint32 => mapping(uint8 => uint48)) accessRulesPerToken;
        uint32 accessRuleIndex; /// increments every time someone adds a rule
    }

    /// Withdrawal Limit by Access Level
    struct AccessLevelWithrawalRuleS {
        /// ruleIndex => access level => max
        mapping(uint32 => mapping(uint8 => uint48)) accessLevelWithdrawal;
        uint32 accessLevelWithdrawalRuleIndex;
    }
    /*****************************************
    *************** NFT Rules ****************
    /*****************************************/
    struct NFTTransferCounterRuleS {
        /// ruleIndex => taggedNFT => tradesAllowed
        mapping(uint32 => mapping(bytes32 => ITaggedRules.NFTTradeCounterRule)) NFTTransferCounterRule;
        uint32 NFTTransferCounterRuleIndex; /// increments every time someone adds a rule
    }
    /*****************************************
    *************** Risk Rules ****************
    /*****************************************/

    /// ******** Transaction Size Rules ********
    struct TxSizeToRiskRuleS {
        mapping(uint32 => ITaggedRules.TransactionSizeToRiskRule) txSizeToRiskRule;
        uint32 txSizeToRiskRuleIndex;
    }

    /// ******** Account Balance Rules ********
    struct AccountBalanceToRiskRuleS {
        mapping(uint32 => IApplicationRules.AccountBalanceToRiskRule) balanceToRiskRule;
        uint32 balanceToRiskRuleIndex;
    }

    /// ******** Transaction Size Per Period Rules ********
    struct TxSizePerPeriodToRiskRuleS {
        mapping(uint32 => IApplicationRules.TxSizePerPeriodToRiskRule) txSizePerPeriodToRiskRule;
        uint32 txSizePerPeriodToRiskRuleIndex;
    }

    /*****************************************
    *************** Fee Rules ****************
    /*****************************************/

    /// ******** AMM Fee Rule ********
    struct AMMFeeRuleS {
        mapping(uint32 => IFeeRules.AMMFeeRule) ammFeeRules;
        uint32 ammFeeRuleIndex;
    }
}
