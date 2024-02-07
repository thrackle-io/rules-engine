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

 struct AccountApproveDenyOracleS{
    mapping(ActionTypes => Rule[]) accountAllowDenyOracle;
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
