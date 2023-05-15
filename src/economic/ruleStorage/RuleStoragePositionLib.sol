// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./IRuleStorage.sol";

/**
 * @title Rules Storage Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract serves as the storage library for the rules Diamond
 * @notice Library for Rules
 */
library RuleStoragePositionLib {
    bytes32 constant DIAMOND_CUT_STORAGE_POSITION = keccak256("diamond-cut.storage");
    /// every rule has its own storage
    bytes32 constant PURCHASE_RULE_POSITION = keccak256("amm.purchase");
    bytes32 constant SELL_RULE_POSITION = keccak256("amm.sell");
    bytes32 constant PCT_PURCHASE_RULE_POSITION = keccak256("amm.pct-purchase");
    bytes32 constant PCT_SELL_RULE_POSITION = keccak256("amm.pct.sell");
    bytes32 constant PURCHASE_FEE_BY_VOLUME_RULE_POSITION = keccak256("amm.fee-by-volume");
    bytes32 constant PRICE_VOLATILITY_RULE_POSITION = keccak256("amm.price.volatility");
    bytes32 constant VOLUME_RULE_POSITION = keccak256("amm.volume");
    bytes32 constant WITHDRAWAL_RULE_POSITION = keccak256("vault.withdrawal");
    bytes32 constant ADMIN_WITHDRAWAL_RULE_POSITION = keccak256("vault.admin-withdrawal");
    bytes32 constant MIN_TRANSFER_RULE_POSITION = keccak256("token.min-transfer");
    bytes32 constant BALANCE_LIMIT_RULE_POSITION = keccak256("token.balance-limit");
    bytes32 constant SUPPLY_VOLATILITY_RULE_POSITION = keccak256("token.supply-volatility");
    bytes32 constant ORACLE_RULE_POSITION = keccak256("all.oracle");
    bytes32 constant AccessLevel_RULE_POSITION = keccak256("token.access");
    bytes32 constant TX_SIZE_TO_RISK_RULE_POSITION = keccak256("token.tx-size-to-risk");
    bytes32 constant TX_SIZE_PER_PERIOD_TO_RISK_RULE_POSITION = keccak256("token.tx-size-per-period-to-risk");
    bytes32 constant BALANCE_LIMIT_TO_RISK_RULE_POSITION = keccak256("token.balance-limit-to-risk");
    bytes32 constant NFT_TRANSFER_RULE_POSITION = keccak256("NFT.transfer-rule");
    bytes32 constant MIN_BAL_BY_DATE_RULE_POSITION = keccak256("token.min-bal-by-date-rule");

    bytes32 constant AMM_FEE_RULE_POSITION = keccak256("AMM.fee-rule");

    /**
     * @dev Function to store Purchase rules
     * @return ds Data Storage of Purchase Rule
     */
    function purchaseStorage() internal pure returns (IRuleStorage.PurchaseRuleS storage ds) {
        bytes32 position = PURCHASE_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Sell rules
     * @return ds Data Storage of Sell Rule
     */
    function sellStorage() internal pure returns (IRuleStorage.SellRuleS storage ds) {
        bytes32 position = SELL_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Percent Purchase rules
     * @return ds Data Storage of Percent Purchase Rule
     */
    function pctPurchaseStorage() internal pure returns (IRuleStorage.PctPurchaseRuleS storage ds) {
        bytes32 position = PCT_PURCHASE_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Percent Sell rules
     * @return ds Data Storage of Percent Sell Rule
     */
    function pctSellStorage() internal pure returns (IRuleStorage.PctSellRuleS storage ds) {
        bytes32 position = PCT_SELL_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Purchase Fee by Volume rules
     * @return ds Data Storage of Purchase Fee by Volume Rule
     */
    function purchaseFeeByVolumeStorage() internal pure returns (IRuleStorage.PurchaseFeeByVolRuleS storage ds) {
        bytes32 position = PURCHASE_FEE_BY_VOLUME_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Price Volitility rules
     * @return ds Data Storage of Price Volitility Rule
     */
    function priceVolatilityStorage() internal pure returns (IRuleStorage.VolatilityRuleS storage ds) {
        bytes32 position = PRICE_VOLATILITY_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Volume rules
     * @return ds Data Storage of Volume Rule
     */
    function volumeStorage() internal pure returns (IRuleStorage.TradingVolRuleS storage ds) {
        bytes32 position = VOLUME_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Withdrawal rules
     * @return ds Data Storage of Withdrawal Rule
     */
    function withdrawalStorage() internal pure returns (IRuleStorage.WithdrawalRuleS storage ds) {
        bytes32 position = WITHDRAWAL_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store AppAdministrator Withdrawal rules
     * @return ds Data Storage of AppAdministrator Withdrawal Rule
     */
    function adminWithdrawalStorage() internal pure returns (IRuleStorage.AdminWithdrawalRuleS storage ds) {
        bytes32 position = ADMIN_WITHDRAWAL_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Minimum Transfer rules
     * @return ds Data Storage of Minimum Transfer Rule
     */
    function minTransferStorage() internal pure returns (IRuleStorage.MinTransferRuleS storage ds) {
        bytes32 position = MIN_TRANSFER_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Balance Limit rules
     * @return ds Data Storage of Balance Limit Rule
     */
    function balanceLimitStorage() internal pure returns (IRuleStorage.BalanceLimitRuleS storage ds) {
        bytes32 position = BALANCE_LIMIT_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Supply Volitility rules
     * @return ds Data Storage of Supply Volitility Rule
     */
    function supplyVolatilityStorage() internal pure returns (IRuleStorage.SupplyVolatilityRuleS storage ds) {
        bytes32 position = SUPPLY_VOLATILITY_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Oracle rules
     * @return ds Data Storage of Oracle Rule
     */
    function oracleStorage() internal pure returns (IRuleStorage.OracleRuleS storage ds) {
        bytes32 position = ORACLE_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store AccessLevel rules
     * @return ds Data Storage of AccessLevel Rule
     */
    function accessStorage() internal pure returns (IRuleStorage.AccessLevelRuleS storage ds) {
        bytes32 position = AccessLevel_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Transaction Size by Risk rules
     * @return ds Data Storage of Transaction Size by Risk Rule
     */
    function txSizeToRiskStorage() internal pure returns (IRuleStorage.TxSizeToRiskRuleS storage ds) {
        bytes32 position = TX_SIZE_TO_RISK_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Transaction Size by Risk per Period rules
     * @return ds Data Storage of Transaction Size by Risk per Period Rule
     */
    function txSizePerPeriodToRiskStorage() internal pure returns (IRuleStorage.TxSizePerPeriodToRiskRuleS storage ds) {
        bytes32 position = TX_SIZE_PER_PERIOD_TO_RISK_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Account Balance rules
     * @return ds Data Storage of Account Balance Rule
     */
    function accountBalanceToRiskStorage() internal pure returns (IRuleStorage.AccountBalanceToRiskRuleS storage ds) {
        bytes32 position = BALANCE_LIMIT_TO_RISK_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store NFT Transfer rules
     * @return ds Data Storage of NFT Transfer rule
     */
    function nftTransferStorage() internal pure returns (IRuleStorage.NFTTransferCounterRuleS storage ds) {
        bytes32 position = NFT_TRANSFER_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store AMM Fee rules
     * @return ds Data Storage of AMM Fee rule
     */
    function ammFeeRuleStorage() internal pure returns (IRuleStorage.AMMFeeRuleS storage ds) {
        bytes32 position = AMM_FEE_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Minimum Balance By Date rules
     * @return ds Data Storage of Minimum Balance by Date rule
     */
    function minBalByDateRuleStorage() internal pure returns (IRuleStorage.MinBalByDateRuleS storage ds) {
        bytes32 position = MIN_BAL_BY_DATE_RULE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
