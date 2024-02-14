// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ProtocolHandlerCommon.sol";

/**
 * @title Protocol Handler Trading-Rules Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 * regarding trading rules (Purchase Limit, Purchase Percentage, Sell Limit, Sell Percentage).
 */
contract ProtocolHandlerTradingRulesCommon is ProtocolHandlerCommon, RuleAdministratorOnly{

    /// RuleIds
    uint32 internal accountMaxBuySizeId;
    uint32 internal accountMaxSellSizeId;
    uint32 internal tokenMaxBuyVolumeId;
    uint32 internal tokenMaxSellVolumeId;

    /// on-off switches for rules
    bool internal accountMaxBuySizeActive;
    bool internal accountMaxSellSizeActive;
    bool internal tokenMaxBuyVolumeActive;
    bool internal tokenMaxSellVolumeActive;

    /// purchase/sell data
    uint64 public previousPurchaseTime;
    uint64 public previousSellTime;
    uint256 internal totalBoughtInPeriod; /// total number of tokens purchased in period
    uint256 internal totalSoldInPeriod; /// total number of tokens purchased in period
    /// Mapping lastUpdateTime for most recent previous tranaction through Protocol
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) boughtInPeriod;
    mapping(address => uint256) salesInPeriod;
    mapping(address => uint64) lastSellTime;

     /// token level accumulators
    uint256 internal transferVolume;
    uint64 internal lastTransferTs;
    uint64 internal lastSupplyUpdateTime;
    int256 internal volumeTotalForPeriod;
    uint256 internal totalSupplyForPeriod;


    /**
     * @dev This function consolidates all the trading rules.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param fromTags tags of the from account
     * @param toTags tags of the from account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTradingRules(address _from, address _to, bytes32[] memory fromTags, bytes32[] memory toTags, uint256 _amount, ActionTypes action)internal{
        if(action == ActionTypes.BUY){
            if (accountMaxBuySizeActive) {
                boughtInPeriod[_to] = ruleProcessor.checkAccountMaxBuySize(accountMaxBuySizeId, boughtInPeriod[_to], _amount, toTags, lastPurchaseTime[_to]);
                lastPurchaseTime[_to] = uint64(block.timestamp);
            }
            if(tokenMaxBuyVolumeActive){
                totalBoughtInPeriod = ruleProcessor.checkTokenMaxBuyVolume(tokenMaxBuyVolumeId,  IERC20Decimals(msg.sender).totalSupply(),  _amount,  previousPurchaseTime,  totalBoughtInPeriod);
                previousPurchaseTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }else{
            if ( accountMaxSellSizeActive) {
                salesInPeriod[_from] = ruleProcessor.checkAccountMaxSellSize(accountMaxSellSizeId,  salesInPeriod[_from],  _amount,  fromTags,  lastSellTime[_from]);
                lastSellTime[_from] = uint64(block.timestamp);
            }
            if(tokenMaxSellVolumeActive){
                totalSoldInPeriod = ruleProcessor.checkTokenMaxSellVolume(tokenMaxSellVolumeId,   IERC20Decimals(msg.sender).totalSupply(),  _amount,  previousSellTime,  totalSoldInPeriod);
                previousSellTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }
    }


    /**
     * @dev Set the AccountMaxBuySize Rule Id. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxBuySizeId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxBuySizeId = _ruleId;
        accountMaxBuySizeActive = true;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.BUY;
        emit ApplicationHandlerActionApplied(ACCOUNT_MAX_BUY_SIZE, actionsArray, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxBuySize(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxBuySizeActive = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.BUY;
        if (_on) {
            emit ApplicationHandlerActionActivated(ACCOUNT_MAX_BUY_SIZE, actionsArray);
        } else {
            emit ApplicationHandlerActionDeactivated(ACCOUNT_MAX_BUY_SIZE, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Account Max Buy Size Rule Id
     * @return accountMaxBuySizeId
     */
    function getAccountMaxBuySizeId() external view returns (uint32) {
        return accountMaxBuySizeId;
    }

    /**
     * @dev Tells you if the Account Max Buy Size Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountMaxBuySizeActive() external view returns (bool) {
        return accountMaxBuySizeActive;
    }

    /**
     * @dev Set the accountMaxSellSize Rule Id. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxSellSizeId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxSellSizeId = _ruleId;
        accountMaxSellSizeActive = true;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.SELL;
        emit ApplicationHandlerActionApplied(ACCOUNT_MAX_SELL_SIZE, actionsArray, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxSellSize(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxSellSizeActive = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.SELL;
        if (_on) {
            emit ApplicationHandlerActionActivated(ACCOUNT_MAX_SELL_SIZE, actionsArray);
        } else {
            emit ApplicationHandlerActionDeactivated(ACCOUNT_MAX_SELL_SIZE, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Account Max Sell Rule Id
     * @return oracleRuleId
     */
    function getAccountMaxSellSizeId() external view returns (uint32) {
        return accountMaxSellSizeId;
    }

    /**
     * @dev Tells you if the Account Max Sell Size Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountMaxSellSizeActive() external view returns (bool) {
        return accountMaxSellSizeActive;
    }

    /**
     * @dev Get the block timestamp of the last purchase for account.
     * @return LastPurchaseTime for account
     */
    function getLastPurchaseTime(address account) external view ruleAdministratorOnly(appManagerAddress) returns (uint256) {
        return lastPurchaseTime[account];
    }

    /**
     * @dev Get the block timestamp of the last Sell for account.
     * @return LastSellTime for account
     */
    function getLastSellTime(address account) external view returns (uint256) {
        return lastSellTime[account];
    }

    /**
     * @dev Get the cumulative total of the purchases for account in purchase period.
     * @return boughtInPeriod for account
     */
    function getPurchasedWithinPeriod(address account) external view returns (uint256) {
        return boughtInPeriod[account];
    }

    /**
     * @dev Get the cumulative total of the Sales for account during sell period.
     * @return salesInPeriod for account
     */
    function getSalesWithinPeriod(address account) external view  returns (uint256) {
        return salesInPeriod[account];
    }

    /**
     * @dev Set the tokenMaxBuyVolume Rule Id. Restricted to Rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxBuyVolumeId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        tokenMaxBuyVolumeId = _ruleId;
        tokenMaxBuyVolumeActive = true;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.BUY;
        emit ApplicationHandlerActionApplied(TOKEN_MAX_BUY_VOLUME, actionsArray, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxBuyVolume(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        tokenMaxBuyVolumeActive = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.BUY;
        if (_on) {
            emit ApplicationHandlerActionActivated(TOKEN_MAX_BUY_VOLUME, actionsArray);
        } else {
            emit ApplicationHandlerActionDeactivated(TOKEN_MAX_BUY_VOLUME, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Token Max Buy Volume Rule Id
     * @return tokenMaxBuyVolumeId
     */
    function getTokenMaxBuyVolumeId() external view returns (uint32) {
        return tokenMaxBuyVolumeId;
    }

    /**
     * @dev Tells you if the Token Max Buy Volume Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTokenMaxBuyVolumeActive() external view returns (bool) {
        return tokenMaxBuyVolumeActive;
    }

    /**
     * @dev Set the tokenMaxSellVolume Rule Id. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxSellVolumeId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        tokenMaxSellVolumeId = _ruleId;
        tokenMaxSellVolumeActive = true;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.SELL;
        emit ApplicationHandlerActionApplied(TOKEN_MAX_SELL_VOLUME, actionsArray, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxSellVolume(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        tokenMaxSellVolumeActive = _on;
        ActionTypes[] memory actionsArray = new ActionTypes[](1);
        actionsArray[0] = ActionTypes.SELL;
        if (_on) {
            emit ApplicationHandlerActionActivated(TOKEN_MAX_SELL_VOLUME, actionsArray);
        } else {
            emit ApplicationHandlerActionDeactivated(TOKEN_MAX_SELL_VOLUME, actionsArray);
        }
    }

    /**
     * @dev Retrieve the Token Max Sell Volume Rule Id
     * @return tokenMaxBuyVolumeId
     */
    function getTokenMaxSellVolumeId() external view returns (uint32) {
        return tokenMaxSellVolumeId;
    }

    /**
     * @dev Tells you if the Token Max Sell Volume Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTokenMaxSellVolumeActive() external view returns (bool) {
        return tokenMaxSellVolumeActive;
    }    

    /**
     * @dev Checks the appManager to determine if an address is a registered AMM or not
     * @param _address the address to check if is an AMM
     * @return true if the _address is an AMM
     */
    function _isAMM(address _address) internal view returns (bool){
        return appManager.isRegisteredAMM(_address);
    }
    
}

