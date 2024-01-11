// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./ProtocolHandlerCommon.sol";

/**
 * @title Protocol Handler Trading-Rules Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 * regarding trading rules (Purchase Limit, Purchase Percentage, Sell Limit, Sell Percentage).
 */
contract ProtocolHandlerTradingRulesCommon is ProtocolHandlerCommon{

    /// RuleIds
    uint32 internal purchaseLimitRuleId;
    uint32 internal sellLimitRuleId;
    uint32 internal purchasePercentageRuleId;
    uint32 internal sellPercentageRuleId;

    /// on-off switches for rules
    bool internal purchaseLimitRuleActive;
    bool internal sellLimitRuleActive;
    bool internal purchasePercentageRuleActive;
    bool internal sellPercentageRuleActive;

    /// purchase/sell data
    uint64 public previousPurchaseTime;
    uint64 public previousSellTime;
    uint256 internal totalPurchasedWithinPeriod; /// total number of tokens purchased in period
    uint256 internal totalSoldWithinPeriod; /// total number of tokens purchased in period
    /// Mapping lastUpdateTime for most recent previous tranaction through Protocol
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) purchasedWithinPeriod;
    mapping(address => uint256) salesWithinPeriod;
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
        if(action == ActionTypes.PURCHASE){
            if (purchaseLimitRuleActive) {
                purchasedWithinPeriod[_to] = ruleProcessor.checkPurchaseLimit(purchaseLimitRuleId, purchasedWithinPeriod[_to], _amount, toTags, lastPurchaseTime[_to]);
                lastPurchaseTime[_to] = uint64(block.timestamp);
            }
            if(purchasePercentageRuleActive){
                totalPurchasedWithinPeriod = ruleProcessor.checkPurchasePercentagePasses(purchasePercentageRuleId,  IERC20(msg.sender).totalSupply(),  _amount,  previousPurchaseTime,  totalPurchasedWithinPeriod);
                previousPurchaseTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }else{
            if ( sellLimitRuleActive) {
                salesWithinPeriod[_from] = ruleProcessor.checkSellLimit(sellLimitRuleId,  salesWithinPeriod[_from],  _amount,  fromTags,  lastSellTime[_from]);
                lastSellTime[_from] = uint64(block.timestamp);
            }
            if(sellPercentageRuleActive){
                totalSoldWithinPeriod = ruleProcessor.checkSellPercentagePasses(sellPercentageRuleId,   IERC20(msg.sender).totalSupply(),  _amount,  previousSellTime,  totalSoldWithinPeriod);
                previousSellTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }
    }


    /**
     * @dev Set the PurchaseLimitRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setPurchaseLimitRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        purchaseLimitRuleId = _ruleId;
        purchaseLimitRuleActive = true;
        emit ApplicationHandlerApplied(PURCHASE_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePurchaseLimitRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        purchaseLimitRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(PURCHASE_LIMIT);
        } else {
            emit ApplicationHandlerDeactivated(PURCHASE_LIMIT);
        }
    }

    /**
     * @dev Retrieve the Purchase Limit rule id
     * @return purchaseLimitRuleId
     */
    function getPurchaseLimitRuleId() external view returns (uint32) {
        return purchaseLimitRuleId;
    }

    /**
     * @dev Tells you if the Purchase Limit Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isPurchaseLimitActive() external view returns (bool) {
        return purchaseLimitRuleActive;
    }

    /**
     * @dev Set the SellLimitRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setSellLimitRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        sellLimitRuleId = _ruleId;
        sellLimitRuleActive = true;
        emit ApplicationHandlerApplied(SELL_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateSellLimitRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        sellLimitRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SELL_LIMIT);
        } else {
            emit ApplicationHandlerDeactivated(SELL_LIMIT);
        }
    }

    /**
     * @dev Retrieve the Purchase Limit rule id
     * @return oracleRuleId
     */
    function getSellLimitRuleId() external view returns (uint32) {
        return sellLimitRuleId;
    }

    /**
     * @dev Tells you if the Purchase Limit Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isSellLimitActive() external view returns (bool) {
        return sellLimitRuleActive;
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
     * @return purchasedWithinPeriod for account
     */
    function getPurchasedWithinPeriod(address account) external view returns (uint256) {
        return purchasedWithinPeriod[account];
    }

    /**
     * @dev Get the cumulative total of the Sales for account during sell period.
     * @return salesWithinPeriod for account
     */
    function getSalesWithinPeriod(address account) external view  returns (uint256) {
        return salesWithinPeriod[account];
    }

    /**
     * @dev Set the purchasePercentageRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setPurchasePercentageRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        purchasePercentageRuleId = _ruleId;
        purchasePercentageRuleActive = true;
        emit ApplicationHandlerApplied(PURCHASE_PERCENTAGE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePurchasePercentageRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        purchasePercentageRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(PURCHASE_PERCENTAGE);
        } else {
            emit ApplicationHandlerDeactivated(PURCHASE_PERCENTAGE);
        }
    }

    /**
     * @dev Retrieve the Purchase Percentage Rule Id
     * @return purchasePercentageRuleId
     */
    function getPurchasePercentageRuleId() external view returns (uint32) {
        return purchasePercentageRuleId;
    }

    /**
     * @dev Tells you if the Purchase Percentage Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isPurchasePercentageRuleActive() external view returns (bool) {
        return purchasePercentageRuleActive;
    }

    /**
     * @dev Set the sellPercentageRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setSellPercentageRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        sellPercentageRuleId = _ruleId;
        sellPercentageRuleActive = true;
        emit ApplicationHandlerApplied(SELL_PERCENTAGE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateSellPercentageRuleIdRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        sellPercentageRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SELL_PERCENTAGE);
        } else {
            emit ApplicationHandlerDeactivated(SELL_PERCENTAGE);
        }
    }

    /**
     * @dev Retrieve the Purchase Percentage Rule Id
     * @return purchasePercentageRuleId
     */
    function getSellPercentageRuleId() external view returns (uint32) {
        return sellPercentageRuleId;
    }

    /**
     * @dev Tells you if the Purchase Percentage Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isSellPercentageRuleActive() external view returns (bool) {
        return sellPercentageRuleActive;
    }


    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev checks the appManager to determine if an address is an AMM or not
     * @param _address the address to check if is an AMM
     * @return true if the _address is an AMM
     */
    function _isAMM(address _address) internal view returns (bool){
        return appManager.isRegisteredAMM(_address);
    }

    /**
     * @dev determines if a transfer is a pure P2P transfer or a trade such as Buying or Selling
     * @param _from the address where the tokens are being moved from
     * @param _to the address where the tokens are going to
     * @param _sender the address triggering the transaction
     * @return action intended in the transfer
     */
    function determineTransferAction(address _from, address _to, address _sender) internal view returns (ActionTypes action){
        action = ActionTypes.TRADE;
        if(!(_sender == _from || address(0) == _from || address(0) == _to)){
            action = ActionTypes.SELL;
        }else if(isContract(_from))
            action = ActionTypes.PURCHASE;
    }
}

