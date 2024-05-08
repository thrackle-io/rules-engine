// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ActionTypes} from "src/common/ActionEnum.sol";
import {Rule} from "../common/DataStructures.sol";


struct Fee {
   uint256 minBalance;
   uint256 maxBalance;
   int24 feePercentage;
   address feeSink;
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

struct AccountMaxTradeSizeS{
   mapping(ActionTypes => Rule) accountMaxTradeSize; 
   mapping(address => uint256) boughtInPeriod;
   mapping(address => uint64) lastPurchaseTime;
   mapping(address => uint256) salesInPeriod;
   mapping(address => uint64) lastSellTime;
   address[] transactors;
}

struct TokenMaxBuySellVolumeS{
   mapping(ActionTypes => Rule) tokenMaxBuySellVolume;
   uint256 boughtInPeriod;
   uint64 lastPurchaseTime;
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
   uint8 lastPossibleAction;
}

struct TokenMaxSupplyVolatilityS{
   mapping(ActionTypes => bool) tokenMaxSupplyVolatility;
   uint32 ruleId;
   uint64 lastSupplyUpdateTime;
   int256 volumeTotalForPeriod;
   uint256 totalSupplyForPeriod;
}

struct TokenMaxTradingVolumeS{
   mapping(ActionTypes => bool) tokenMaxTradingVolume;
   uint32 ruleId;
   uint256 transferVolume;
   uint64 lastTransferTime;
}

struct TokenMaxDailyTradesS{
   mapping(ActionTypes => Rule) tokenMaxDailyTrades;
   mapping(uint32 => mapping(uint256 => uint256)) tradesInPeriod;
   mapping(uint32 => mapping(uint256 => uint64)) lastTxDate;
   mapping(uint32 => uint256[]) tokenIdsByRuleId;
}

struct TokenMinHoldTime{
   uint32 ruleId;
   bool active;
   uint32 period; //hours
}

struct TokenMinHoldTimeS {
   mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;
   mapping(uint256 => uint256) ownershipStart;
   uint256[] tokenIds;
}

struct NFTValuationLimitS{
   uint16 nftValuationLimit;
}

struct InitializedS{
   bool initialized;
}

struct HandlerVersionS{
   string version;
}
