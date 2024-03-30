// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Context.sol";
import "./RuleProcessorDiamondImports.sol";
import {TaggedRuleDataFacet} from "./TaggedRuleDataFacet.sol";

/**
 * @title ERC20 Tagged Rule Processor Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Contract implements rules to be checked by Handler.
 * @notice  Implements Token Rules on Tagged Accounts.
 */
contract ERC20TaggedRuleProcessorFacet is IRuleProcessorErrors, IInputErrors, ITagRuleErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8;
    using RuleProcessorCommonLib for bytes32[];
    bytes32 constant BLANK_TAG = bytes32("");

    /**
     * @dev Check the min/max token balance rule. This rule ensures that both the to and from accounts do not
     * exceed the max balance or go below the min balance.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param amount total number of tokens to be transferred
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkAccountMinMaxTokenBalance(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, uint256 amount, bytes32[] memory toTags, bytes32[] memory fromTags) external view {
        checkAccountMinTokenBalance(balanceFrom, fromTags, amount, ruleId);
        checkAccountMaxTokenBalance(balanceTo, toTags, amount, ruleId);
    }

    /**
     * @dev Check the min/max token balance rule through the AMM Swap
     * @param ruleIdToken0 Uint value of the ruleId storage pointer for applicable rule.
     * @param ruleIdToken1 Uint value of the ruleId storage pointer for applicable rule.
     * @param tokenBalance0 Token balance of the token being swapped
     * @param tokenBalance1 Token balance of the received token
     * @param amountIn total number of tokens to be swapped
     * @param amountOut total number of tokens to be received
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkAccountMinMaxTokenBalanceAMM(
        uint32 ruleIdToken0,
        uint32 ruleIdToken1,
        uint256 tokenBalance0,
        uint256 tokenBalance1,
        uint256 amountIn,
        uint256 amountOut,
        bytes32[] calldata fromTags
    ) public view {
        // no need to check for max tags here since it is checked in the min and max functions
        checkAccountMinTokenBalance(tokenBalance0, fromTags, amountOut, ruleIdToken0);
        checkAccountMaxTokenBalance(tokenBalance1, fromTags, amountIn, ruleIdToken1);
    }

    /**
     * @dev Check if tagged account passes AccountMaxTokenBalance rule
     * @param balanceTo Number of tokens held by recipient address
     * @param toTags Account tags applied to recipient via App Manager
     * @param amount Number of tokens to be transferred
     * @param ruleId Rule identifier for rule arguments
     * @notice If the rule applies to all users, it checks blank tag only. Otherwise loop through
     * tags and check for specific application. This was done in a minimal way to allow for
     * modifications later while not duplicating rule check logic.
     */
    function checkAccountMaxTokenBalance(uint256 balanceTo, bytes32[] memory toTags, uint256 amount, uint32 ruleId) public view {
        toTags.checkMaxTags();
        if (getAccountMinMaxTokenBalance(ruleId, BLANK_TAG).max > 0) {
            toTags = new bytes32[](1);
            toTags[0] = BLANK_TAG;
        }
        uint64 startTime = getAccountMinMaxTokenBalanceStart(ruleId);
        // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
        // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
        // slither-disable-next-line timestamp
        if (startTime <= block.timestamp) {
            for (uint i; i < toTags.length; ++i) {
                TaggedRules.AccountMinMaxTokenBalance memory rule = getAccountMinMaxTokenBalance(ruleId, toTags[i]);
                /// check if period is 0, 0 means a period hasn't been applied to this rule
                if (rule.period != 0) {
                    // slither-disable-next-line timestamp
                    if ((block.timestamp - (uint256(rule.period) * 1 hours)) < startTime) {
                        if (rule.max > 0 && balanceTo + amount > rule.max) revert TxnInFreezeWindow();
                    }
                } else {
                    /// if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0
                    if (rule.max > 0 && balanceTo + amount > rule.max) revert OverMaxBalance();
                }
            }
        }
    }

    /**
     * @dev Check if tagged account passes AccountMinTokenBalance rule
     * @param balanceFrom Number of tokens held by sender address
     * @param fromTags Account tags applied to sender via App Manager
     * @param amount Number of tokens to be transferred
     * @param ruleId Rule identifier for rule arguments
     * @notice If the rule applies to all users, it checks blank tag only. Otherwise loop through
     * tags and check for specific application. This was done in a minimal way to allow for
     * modifications later while not duplicating rule check logic.
     */
    function checkAccountMinTokenBalance(uint256 balanceFrom, bytes32[] memory fromTags, uint256 amount, uint32 ruleId) public view {
        // if the balanceFrom is 0, then skip processing because this is a mint and it's impossible for a mint to violate the minium balance
        if (balanceFrom != 0) {
            fromTags.checkMaxTags();
            if (getAccountMinMaxTokenBalance(ruleId, BLANK_TAG).min > 0) {
                fromTags = new bytes32[](1);
                fromTags[0] = BLANK_TAG;
            }
            uint64 startTime = getAccountMinMaxTokenBalanceStart(ruleId);
            // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
            // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
            // slither-disable-next-line timestamp
            if (startTime <= block.timestamp) {
                for (uint i = 0; i < fromTags.length; ++i) {
                    TaggedRules.AccountMinMaxTokenBalance memory rule = getAccountMinMaxTokenBalance(ruleId, fromTags[i]);
                    /// check if period is 0, 0 means a period hasn't been applied to this rule
                    if (rule.period != 0) {
                        /// Check to see if still in the hold period
                        if ((block.timestamp - (uint256(rule.period) * 1 hours)) < startTime) {
                            /// If the transaction will violate the rule, then revert
                            if (rule.min > 0 && balanceFrom - amount < rule.min) revert TxnInFreezeWindow();
                        }
                    } else {
                        /// if a min is 0 it means it is an empty-rule/no-rule. a min should be greater than 0
                        if (rule.min > 0 && balanceFrom - amount < rule.min) revert UnderMinBalance();
                    }
                }
            }
        }
    }

    /**
     * @dev Function get the min/max rule start timestamp
     * @param _index position of rule in array
     * @return startTime rule start time
     */
    function getAccountMinMaxTokenBalanceStart(uint32 _index) public view returns (uint64 startTime) {
        _index.checkRuleExistence(getTotalAccountMinMaxTokenBalances());
        RuleS.AccountMinMaxTokenBalanceS storage data = Storage.accountMinMaxTokenBalanceStorage();
        if (_index >= data.accountMinMaxTokenBalanceIndex) revert IndexOutOfRange();
        return data.startTimes[_index];
    }

    /**
     * @dev Function get the accountMinMaxTokenBalance Rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountType Type of Accounts
     * @return accountMinMaxTokenBalance Rule at index location in array
     */
    function getAccountMinMaxTokenBalance(uint32 _index, bytes32 _accountType) public view returns (TaggedRules.AccountMinMaxTokenBalance memory) {
        _index.checkRuleExistence(getTotalAccountMinMaxTokenBalances());
        RuleS.AccountMinMaxTokenBalanceS storage data = Storage.accountMinMaxTokenBalanceStorage();
        if (_index >= data.accountMinMaxTokenBalanceIndex) revert IndexOutOfRange();
        return data.accountMinMaxTokenBalanceRules[_index][_accountType];
    }

    /**
     * @dev Function gets total AccountMinMaxTokenBalances rules
     * @return Total length of array
     */
    function getTotalAccountMinMaxTokenBalances() public view returns (uint32) {
        RuleS.AccountMinMaxTokenBalanceS storage data = Storage.accountMinMaxTokenBalanceStorage();
        return data.accountMinMaxTokenBalanceIndex;
    }

    /**
     * @dev Checks that an admin won't hold less tokens than promised until a certain date
     * @param ruleId Rule identifier for rule arguments
     * @param currentBalance of tokens held by the admin
     * @param amount Number of tokens to be transferred
     * @notice that the function will revert if the check finds a violation of the rule, but won't give anything
     * back if everything checks out.
     */
    function checkAdminMinTokenBalance(uint32 ruleId, uint256 currentBalance, uint256 amount) external view {
        TaggedRules.AdminMinTokenBalance memory rule = getAdminMinTokenBalance(ruleId);
        if (amount > currentBalance) revert NotEnoughBalance();
        // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
        // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
        // slither-disable-next-line timestamp
        if ((block.timestamp < rule.endTime) && (currentBalance - amount < rule.amount)) revert UnderMinBalance();
    }

    /**
     * @dev Function gets AdminMinTokenBalance rule at index
     * @param _index position of rule in array
     * @return adminMinTokenBalanceRules rule at indexed postion
     */
    function getAdminMinTokenBalance(uint32 _index) public view returns (TaggedRules.AdminMinTokenBalance memory) {
        _index.checkRuleExistence(getTotalAdminMinTokenBalance());
        RuleS.AdminMinTokenBalanceS storage data = Storage.adminMinTokenBalanceStorage();
        if (_index >= data.adminMinTokenBalanceIndex) revert IndexOutOfRange();
        return data.adminMinTokenBalanceRules[_index];
    }

    /**
     * @dev Function to get total AdminMinTokenBalance rules
     * @return adminMinTokenBalanceRules total length of array
     */
    function getTotalAdminMinTokenBalance() public view returns (uint32) {
        RuleS.AdminMinTokenBalanceS storage data = Storage.adminMinTokenBalanceStorage();
        return data.adminMinTokenBalanceIndex;
    }

    /**
     * @dev Rule checks if recipient balance + amount exceeded max amount for that action type during rule period, prevent transactions for that action for freeze period
     * @param ruleId Rule identifier for rule arguments
     * @param transactedInPeriod Number of tokens transacted during Period
     * @param amount Number of tokens to be transferred
     * @param toTags Account tags applied to sender via App Manager
     * @param lastTransactionTime block.timestamp of most recent transaction transaction from sender for action type.
     * @return cumulativeTotal total amount of tokens bought or sold within Trade period.
     * @notice If the rule applies to all users, it checks blank tag only. Otherwise loop through
     * tags and check for specific application. This was done in a minimal way to allow for
     * modifications later while not duplicating rule check logic.
     */
    function checkAccountMaxTradeSize(uint32 ruleId, uint256 transactedInPeriod, uint256 amount, bytes32[] memory toTags, uint64 lastTransactionTime) external view returns (uint256) {
        toTags.checkMaxTags();
        uint64 startTime = getAccountMaxTradeSizeStart(ruleId);
        uint256 cumulativeTotal = 0;
        // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
        // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
        // slither-disable-next-line timestamp
        if (startTime <= block.timestamp) {
            if (getAccountMaxTradeSize(ruleId, BLANK_TAG).period > 0) {
                toTags = new bytes32[](1);
                toTags[0] = BLANK_TAG;
            }
            for (uint i = 0; i < toTags.length; ++i) {
                TaggedRules.AccountMaxTradeSize memory rule = getAccountMaxTradeSize(ruleId, toTags[i]);
                if (rule.period > 0 && rule.maxSize > 0) {
                    if (startTime.isWithinPeriod(rule.period, lastTransactionTime)) cumulativeTotal = transactedInPeriod + amount;
                    else cumulativeTotal = amount;
                    if (cumulativeTotal > rule.maxSize) revert OverMaxSize();
                }
            }
        }
        return cumulativeTotal;
    }

    /**
     * @dev Function get the account max Trade size rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountType Type of account
     * @return AccountMaxBuySize rule at index position
     */
    function getAccountMaxTradeSize(uint32 _index, bytes32 _accountType) public view returns (TaggedRules.AccountMaxTradeSize memory) {
        RuleS.AccountMaxTradeSizeS storage data = Storage.accountMaxTradeSizeStorage();
        return (data.accountMaxTradeSizeRules[_index][_accountType]);
    }

    /**
     * @dev Function get the account max trade size rule start timestamp
     * @param _index position of rule in array
     * @return startTime startTimestamp of rule at index position
     */
    function getAccountMaxTradeSizeStart(uint32 _index) public view returns (uint64 startTime) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalAccountMaxTradeSize());
        RuleS.AccountMaxTradeSizeS storage data = Storage.accountMaxTradeSizeStorage();
        if (_index >= data.accountMaxTradeSizeIndex) revert IndexOutOfRange();
        return data.startTimes[_index];
    }

    /**
     * @dev Function to get total account max trade size rules
     * @return Total length of array
     */
    function getTotalAccountMaxTradeSize() public view returns (uint32) {
        RuleS.AccountMaxTradeSizeS storage data = Storage.accountMaxTradeSizeStorage();
        return data.accountMaxTradeSizeIndex;
    }
}
