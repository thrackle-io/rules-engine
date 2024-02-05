// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// import "./IRuleStorage.sol";
import {AccountMinMaxTokenBalanceHandlerS, ACCOUNT_MIN_MAX_TOKEN_BALANCE_POSITION} from "../ruleContracts/HandlerAccountMinMaxTokenBalance.sol";
import {HandlerBaseS, HANDLER_BASE_POSITION} from "../ruleContracts/HandlerBase.sol";
import {FeeS, FEES_POSITION} from "../ruleContracts/Fees.sol";
import {AccountApproveDenyOracleS, ACCOUNT_APPROVE_DENY_ORACLE_POSITION} from "../ruleContracts/HandlerAccountApproveDenyOracle.sol";
import {AccountMaxBuySizeS, ACCOUNT_MAX_BUY_SIZE_POSITION} from "../ruleContracts/HandlerAccountMaxBuySize.sol";

/**
 * @title Rules Storage Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract serves as the storage library for the rules Diamond. It basically serves up the storage position for all rules
 * @notice Library for Rules
 */
library StorageLib {
    bytes32 constant DIAMOND_CUT_STORAGE_HANDLER_POS = bytes32(uint256(keccak256("diamond-cut.storage-handler")) - 1);
    
    /**
     * @dev Function to store Handler Base
     * @return ds Data Storage of Handler Base
     */
    function handlerBaseStorage() internal pure returns (HandlerBaseS storage ds) {
        bytes32 position = HANDLER_BASE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store the fees
     * @return ds Data Storage of Fees
     */
    function feeStorage() internal pure returns (FeeS storage ds) {
        bytes32 position = FEES_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store Purchase rules
     * @return ds Data Storage of Purchase Rule
     */
    function accountMaxBuySizeStorage() internal pure returns (AccountMaxBuySizeS storage ds) {
        bytes32 position = ACCOUNT_MAX_BUY_SIZE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    // /**
    //  * @dev Function to store Sell rules
    //  * @return ds Data Storage of Sell Rule
    //  */
    // function accountMaxSellSizeStorage() internal pure returns (IRuleStorage.AccountMaxSellSizeS storage ds) {
    //     bytes32 position = ACCOUNT_MAX_SELL_SIZE_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Account Max Buy Volume rules
    //  * @return ds Data Storage of Account Max Buy Volume Rule
    //  */
    // function accountMaxBuyVolumeStorage() internal pure returns (IRuleStorage.TokenMaxBuyVolumeS storage ds) {
    //     bytes32 position = ACCOUNT_MAX_BUY_VOLUME_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Account Max Sell Volume rules
    //  * @return ds Data Storage of Account Max Sell Volume Rule
    //  */
    // function accountMaxSellVolumeStorage() internal pure returns (IRuleStorage.TokenMaxSellVolumeS storage ds) {
    //     bytes32 position = ACCOUNT_MAX_SELL_VOLUME_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Purchase Fee by Volume rules
    //  * @return ds Data Storage of Purchase Fee by Volume Rule
    //  */
    // function purchaseFeeByVolumeStorage() internal pure returns (IRuleStorage.PurchaseFeeByVolRuleS storage ds) {
    //     bytes32 position = BUY_FEE_BY_TOKEN_MAX_TRADING_VOLUME_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Price Volitility rules
    //  * @return ds Data Storage of Price Volitility Rule
    //  */
    // function tokenMaxPriceVolatilityStorage() internal pure returns (IRuleStorage.TokenMaxPriceVolatilityS storage ds) {
    //     bytes32 position = TOKEN_MAX_PRICE_VOLATILITY_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Max Trading Volume rules
    //  * @return ds Data Storage of Max Trading Volume Rule
    //  */
    // function tokenMaxTradingVolumeStorage() internal pure returns (IRuleStorage.TokenMaxTradingVolumeS storage ds) {
    //     bytes32 position = TOKEN_MAX_TRADING_VOLUME_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Admin Min Token Balance rules
    //  * @return ds Data Storage of Admin Min Token Balance Rule
    //  */
    // function adminMinTokenBalanceStorage() internal pure returns (IRuleStorage.AdminMinTokenBalanceS storage ds) {
    //     bytes32 position = ADMIN_MIN_TOKEN_BALANCE_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Token Min Transaction Size rules
    //  * @return ds Data Storage of Token Min Transaction Size Rule
    //  */
    // function tokenMinTxSizePosition() internal pure returns (IRuleStorage.TokenMinTxSizeS storage ds) {
    //     bytes32 position = TOKEN_MIN_TX_SIZE_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    /**
     * @dev Function to store Account Min Max Token Balance rules
     * @return ds Data Storage of Account Min Max Token Balance Rule
     */
    function accountMinMaxTokenBalanceStorage() internal pure returns (AccountMinMaxTokenBalanceHandlerS storage ds) {
        bytes32 position = ACCOUNT_MIN_MAX_TOKEN_BALANCE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    // /**
    //  * @dev Function to store Max Supply Volitility rules
    //  * @return ds Data Storage of Max Supply Volitility Rule
    //  */
    // function tokenMaxSupplyVolatilityStorage() internal pure returns (IRuleStorage.TokenMaxSupplyVolatilityS storage ds) {
    //     bytes32 position = TOKEN_MAX_SUPPLY_VOLATILITY_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    /**
     * @dev Function to store Oracle rules
     * @return ds Data Storage of Oracle Rule
     */
    function accountApproveDenyOracleStorage() internal pure returns (AccountApproveDenyOracleS storage ds) {
        bytes32 position = ACCOUNT_APPROVE_DENY_ORACLE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    // /**
    //  * @dev Function to store Account Max Value Access Level rules
    //  * @return ds Data Storage of Account Max Value Access Level Rule
    //  */
    // function accountMaxValueByAccessLevelStorage() internal pure returns (IRuleStorage.AccountMaxValueByAccessLevelS storage ds) {
    //     bytes32 position = ACC_MAX_VALUE_BY_ACCESS_LEVEL_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Account Max Tx Value by Risk rules
    //  * @return ds Data Storage of Account Max Tx Value by Risk Rule
    //  */
    // function accountMaxTxValueByRiskScoreStorage() internal pure returns (IRuleStorage.AccountMaxTxValueByRiskScoreS storage ds) {
    //     bytes32 position = ACC_MAX_TX_VALUE_BY_RISK_SCORE_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Account Max Value By Risk Score rules
    //  * @return ds Data Storage of Account Max Value By Risk Score Rule
    //  */
    // function accountMaxValueByRiskScoreStorage() internal pure returns (IRuleStorage.AccountMaxValueByRiskScoreS storage ds) {
    //     bytes32 position = ACCOUNT_MAX_VALUE_BY_RISK_SCORE_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Token Max Daily Trades rules
    //  * @return ds Data Storage of Token Max Daily Trades rule
    //  */
    // function TokenMaxDailyTradesStorage() internal pure returns (IRuleStorage.TokenMaxDailyTradesS storage ds) {
    //     bytes32 position = TOKEN_MAX_DAILY_TRADES_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store AMM Fee rules
    //  * @return ds Data Storage of AMM Fee rule
    //  */
    // function ammFeeRuleStorage() internal pure returns (IRuleStorage.AMMFeeRuleS storage ds) {
    //     bytes32 position = AMM_FEE_RULE_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    // /**
    //  * @dev Function to store Account Max Value Out By Access Level rules
    //  * @return ds Data Storage of Account Max Value Out By Access Level rule
    //  */
    // function accountMaxValueOutByAccessLevelStorage() internal pure returns (IRuleStorage.AccountMaxValueOutByAccessLevelS storage ds) {
    //     bytes32 position = ACC_MAX_VALUE_OUT_ACCESS_LEVEL_HANDLER_POS;
    //     assembly {
    //         ds.slot := position
    //     }
    // }
}
