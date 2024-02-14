// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ActionTypes} from "src/common/ActionEnum.sol";
import {Rule} from "../common/DataStructures.sol";


struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
}

struct FeeS{    
    mapping(bytes32 => Fee) feesByTag;
    uint256 feeTotal;
    bool feeActive;
}

struct TokenMinTxSizeS{
    mapping(ActionTypes => Rule) tokenMinTxSize;
}

 struct AccountApproveDenyOracleS{
    mapping(ActionTypes => Rule[]) accountApproveDenyOracle;
 }

 struct AccountMaxBuySizeS{
    uint32 id;
    bool active;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
 }

 struct AccountMaxSellSizeS{
    uint32 id;
    bool active;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;
 }

 struct TokenMaxBuyVolumeS{
    uint32 id;
    bool active;
    uint256 boughtInPeriod;
    uint64 lastPurchaseTime;
 }

 struct TokenMaxSellVolumeS{
    uint32 id;
    bool active;
    uint256 salesInPeriod;
    uint64 lastSellTime;
 }

 struct AccountMinMaxTokenBalanceHandlerS{
    mapping(ActionTypes => Rule) accountMinMaxTokenBalance; 
 }

  struct HandlerBaseS{
    address newAppManagerAddress;
    address ruleProcessor;
    address appManager;
    address assetAddress;
 }

 struct AdminMinTokenBalanceS{
    mapping(ActionTypes => Rule) adminMinTokenBalance; 
 }

 struct TokenMaxSupplyVolatilityS{
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    uint64 lastSupplyUpdateTime;
    int256 volumeTotalForPeriod;
    uint256 totalSupplyForPeriod;
 }

 struct TokenMaxTradingVolumeS{
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    uint256 transferVolume;
    uint64 lastTransferTime;
 }

 struct TokenMaxDailyTradesS{
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;
    mapping(uint256 => uint256) tradesInPeriod;
    mapping(uint256 => uint64) lastTxDate;
 }

struct TokenMinHoldTime{
    uint32 ruleId;
    bool active;
    uint32 period; //hours
}

 struct TokenMinHoldTimeS {
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
    mapping(uint256 => uint256) ownershipStart;
 }

 struct NFTValuationLimitS{
    uint16 nftValuationLimit;
 }

struct InitializedS{
    bool initialized;
}