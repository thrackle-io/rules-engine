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
    uint32 accountMaxBuySizeId;
    bool accountMaxBuySizeActive;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint64) lastPurchaseTime;
 }

 struct AccountMinMaxTokenBalanceHandlerS{
    mapping(ActionTypes => Rule) accountMinMaxTokenBalance; 
 }

  struct HandlerBaseS{
    address newAppManagerAddress;
    address ruleProcessor;
    address appManager;
 }
