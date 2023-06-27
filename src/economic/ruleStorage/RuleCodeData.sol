// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/**
 * @notice VERSION 1
 * @title RULE enum
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This enum is a representation of the positioning inside the
 * rule_set array of the protocol.
 * @notice Rule enum houses enumerative list of rules for immutability
 */

enum RULE {
    PURCHASE, // 0
    SELL, //1
    PCT_PURCHASE,
    PCT_SELL,
    PURCHASE_FEE_PER_VOL,
    VOLATILITY,
    TRADING_VOL,
    WIDTHDRAWAL,
    ADMIN_WIDTHDRAWAL,
    MIN_TRANSFER,
    BALANCE_LIMIT,
    MIN_BALANCE_HELD_BY_PERIOD,
    SUPPLY_VOLATILITY,
    AccessLevel,
    TX_SIZE_TO_RISK,
    TX_SIZE_PER_PERIOD_TO_RISK,
    ACCOUNT_BALANCE,
    ORACLE,
    WITHDRAWAL_LIMIT_ACCESS_LEVEL
}

enum ORACLE_TYPE {
    RESTRICTED_LIST,
    ALLOWED_LIST
}

// Rule Code Constants
bytes32 constant AMM_FEE = "AMM_FEE";
bytes32 constant PURCHASE_LIMIT = "PURCHASE_LIMIT";
bytes32 constant SELL_LIMIT = "SELL_LIMIT";
bytes32 constant PURCHASE_PERCENTAGE = "PURCHASE_PERCENTAGE";
bytes32 constant SELL_PERCENTAGE = "SELL_PERCENTAGE";
bytes32 constant MIN_MAX_BALANCE_LIMIT = "MIN_MAX_BALANCE_LIMIT";
bytes32 constant MIN_ACCT_BAL_BY_DATE = "MIN_ACCT_BAL_BY_DATE";
bytes32 constant WITHDRAWAL = "WITHDRAWAL";
bytes32 constant ADMIN_WITHDRAWAL = "ADMIN_WITHDRAWAL";
bytes32 constant BALANCE_BY_ACCESSLEVEL = "BALANCE_BY_ACCESSLEVEL";
bytes32 constant MAX_TX_PER_PERIOD = "MAX_TX_PER_PERIOD";
bytes32 constant TX_SIZE_BY_RISK = "TX_SIZE_BY_RISK";
bytes32 constant BALANCE_BY_RISK = "BALANCE_BY_RISK";
bytes32 constant MIN_BALANCE_BY_DATE = "MIN_BALANCE_BY_DATE";
bytes32 constant PURCHASE_PERCENT = "PURCHASE_PERCENT";
bytes32 constant SELL_PERCENT = "SELL_PERCENT";
bytes32 constant PURCHASE_FEE_BY_VOLUME = "PURCHASE_FEE_BY_VOLUME";
bytes32 constant TOKEN_VOLATILITY = "TOKEN_VOLATILITY";
bytes32 constant TRANSFER_VOLUME = "TRANSFER_VOLUME";
bytes32 constant MIN_TRANSFER = "MIN_TRANSFER";
bytes32 constant SUPPLY_VOLATILITY = "SUPPLY_VOLATILITY";
bytes32 constant ORACLE = "ORACLE";
bytes32 constant NFT_TRANSFER = "NFT_TRANSFER";
bytes32 constant ACCESS_LEVEL_WITHDRAWAL = "ACCESS_LEVEL_WITHDRAWAL";
