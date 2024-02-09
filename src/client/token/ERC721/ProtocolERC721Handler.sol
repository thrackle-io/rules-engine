// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../ProtocolHandlerCommon.sol";
import "../ProtocolHandlerTradingRulesCommon.sol";

/**
 * @title Protocol ERC721 Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC721 that implements it.
 *      Any rule handlers may be updated by modifying this contract, redeploying, and pointing the ERC721 to the new version.
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */

contract ProtocolERC721Handler is Ownable, ProtocolHandlerCommon, ProtocolHandlerTradingRulesCommon, IProtocolTokenHandler, IAdminMinTokenBalanceCapable, ERC165 {
    
    address public erc721Address;
    
    struct TokenMinHoldTime{
        uint32 ruleId;
        bool active;
        uint32 period; //hours
    }
    /// Rule mappings
    mapping(ActionTypes => Rule) accountMinMaxTokenBalance;   
    mapping(ActionTypes => Rule) adminMinTokenBalance;   
    mapping(ActionTypes => Rule) tokenMaxTradingVolume;
    mapping(ActionTypes => Rule) tokenMaxSupplyVolatility;
    mapping(ActionTypes => Rule) tokenMaxDailyTrades;

    /// Oracle rule mapping(allows multiple rules per action)
    mapping(ActionTypes => Rule[]) accountApproveDenyOracle;
    /// RuleIds for implemented tagged rules of the ERC721
    Rule[] private accountApproveDenyOracleRules;

    /// Simple Rule Mapping
    mapping(ActionTypes => TokenMinHoldTime) tokenMinHoldTime;

    /// NFT Collection Valuation Limit
    uint16 private nftValuationLimit = 100;

    /// Trade Counter data
    // map the tokenId of this NFT to the number of trades in the period
    mapping(uint256 => uint256) tradesInPeriod;
    // map the tokenId of this NFT to the last transaction timestamp
    mapping(uint256 => uint64) lastTxDate;

    /// Minimum Hold time data
    mapping(uint256 => uint256) ownershipStart;
    /// Max Hold time hours
    uint16 constant MAX_HOLD_TIME_HOURS = 43830;

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _ruleProcessorProxyAddress of token rule router proxy
     * @param _appManagerAddress Address of App Manager
     * @param _assetAddress Address of the controlling address
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode) {
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);

        transferOwnership(_assetAddress);
        setERC721Address(_assetAddress);
        if (!_upgradeMode) {
            emit HandlerDeployed(_appManagerAddress);
        } else {
            emit HandlerDeployed(_appManagerAddress);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IAdminMinTokenBalanceCapable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This function is the one called from the token contract that implements this handler. It's the entry point to protocol.
     * @notice Standard rules do not apply when either to or from address is a Rule Bypass Account.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _tokenId the token's specific ID
     * @return _success equals true if all checks pass
     */

    function checkAllRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,  address _sender, uint256 _tokenId) external override onlyOwner returns (bool) {
        bool isFromBypassAccount = appManager.isRuleBypassAccount(_from);
        bool isToBypassAccount = appManager.isRuleBypassAccount(_to);
        ActionTypes action = determineTransferAction(_from, _to, _sender);
        uint256 _amount = 1; /// currently not supporting batch NFT transactions. Only single NFT transfers.
        if (!isFromBypassAccount && !isToBypassAccount) {
            appManager.checkApplicationRules(address(msg.sender), _from, _to, _amount, nftValuationLimit, _tokenId, action, HandlerTypes.ERC721HANDLER);
            _checkTaggedAndTradingRules(_balanceFrom, _balanceTo, _from, _to, _amount, action);
            _checkNonTaggedRules(action, _from, _to, _amount, _tokenId);
            _checkSimpleRules(action, _tokenId);
            /// set the ownership start time for the token if the Minimum Hold time rule is active or action is mint
            if (tokenMinHoldTime[action].active || action == ActionTypes.MINT) ownershipStart[_tokenId] = block.timestamp;
        } else if (adminMinTokenBalance[action].active && isFromBypassAccount) {
            ruleProcessor.checkAdminMinTokenBalance(adminMinTokenBalance[action].ruleId, _balanceFrom, _amount);
            emit RulesBypassedViaRuleBypassAccount(address(msg.sender), appManagerAddress);
        }
        return true;
    }

    /**
     * @dev This function performs the checks for NonTagged rules.
     * @param action current action
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param tokenId the token's specific ID
     */
    function _checkNonTaggedRules(ActionTypes action, address _from, address _to, uint256 _amount, uint256 tokenId) internal {
        _from;
        for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < accountApproveDenyOracle[action].length; ) {
            if (accountApproveDenyOracle[action][accountApproveDenyOracleIndex].active) ruleProcessor.checkAccountApproveDenyOracle(accountApproveDenyOracle[action][accountApproveDenyOracleIndex].ruleId, _to);
            unchecked {
                ++accountApproveDenyOracleIndex;
            }
        }
        if (tokenMaxDailyTrades[action].active) {
            bytes32[] memory tags = appManager.getAllTags(erc721Address);
            tradesInPeriod[tokenId] = ruleProcessor.checkTokenMaxDailyTrades(tokenMaxDailyTrades[action].ruleId, tradesInPeriod[tokenId], tags, lastTxDate[tokenId]);
            lastTxDate[tokenId] = uint64(block.timestamp);
        }
        if (tokenMaxTradingVolume[action].active) {
            transferVolume = ruleProcessor.checkTokenMaxTradingVolume(tokenMaxTradingVolume[action].ruleId, transferVolume, IToken(msg.sender).totalSupply(), _amount, lastTransferTs);
            lastTransferTs = uint64(block.timestamp);
        }
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        if (tokenMaxSupplyVolatility[action].active && (action == ActionTypes.MINT || action == ActionTypes.BURN)) {
            (volumeTotalForPeriod, totalSupplyForPeriod) = ruleProcessor.checkTokenMaxSupplyVolatility(
                tokenMaxSupplyVolatility[action].ruleId,
                volumeTotalForPeriod,
                totalSupplyForPeriod,
                IToken(msg.sender).totalSupply(),
                _to == address(0x00) ? int(_amount) * -1 : int(_amount),
                lastSupplyUpdateTime
            );
            lastSupplyUpdateTime = uint64(block.timestamp);
        }
    }

    /**
     * @dev This function performs the tagged and trading rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTaggedAndTradingRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) internal {
        _checkTaggedIndividualRules(_balanceFrom, _balanceTo, _from, _to, _amount, action);

    }

    /**
     * @dev This function consolidates all the tagged rules that utilize account tags plus all trading rules.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTaggedIndividualRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) internal {
        bytes32[] memory toTags;
        bytes32[] memory fromTags;
        bool mustCheckBuyRules = action == ActionTypes.BUY && !appManager.isTradingRuleBypasser(_to);
        bool mustCheckSellRules = action == ActionTypes.SELL && !appManager.isTradingRuleBypasser(_from);
        if (accountMinMaxTokenBalance[action].active || (mustCheckBuyRules && accountMaxBuySizeActive) || (mustCheckSellRules && accountMaxSellSizeActive)) {
            // We get all tags for sender and recipient
            toTags = appManager.getAllTags(_to);
            fromTags = appManager.getAllTags(_from);
        }
        if (accountMinMaxTokenBalance[action].active) ruleProcessor.checkAccountMinMaxTokenBalance(accountMinMaxTokenBalance[action].ruleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
        if((mustCheckBuyRules && (accountMaxBuySizeActive || tokenMaxBuyVolumeActive)) || (mustCheckSellRules && (accountMaxSellSizeActive || tokenMaxSellVolumeActive)))
            _checkTradingRules(_from, _to, fromTags, toTags, _amount, action);
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the simple rule checks (Ones that have simple parameters and are not stored in the rule storage diamond).
     * @param _action action to be checked
     * @param _tokenId the specific token in question
     */
    function _checkSimpleRules(ActionTypes _action, uint256 _tokenId) internal view {
        if (tokenMinHoldTime[_action].active && ownershipStart[_tokenId] > 0) ruleProcessor.checkTokenMinHoldTime(tokenMinHoldTime[_action].period, ownershipStart[_tokenId]);
    }

     /**
     * @dev Set the accountMinMaxTokenBalance Rule Id. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountMinMaxTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccountMinMaxTokenBalance(_ruleId);
        for (uint i; i < _actions.length; ) {
            accountMinMaxTokenBalance[_actions[i]].ruleId = _ruleId;
            accountMinMaxTokenBalance[_actions[i]].active = true;            
            emit ApplicationHandlerActionApplied(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions[i], _ruleId);
            unchecked {
                        ++i;
            }
        }            
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMinMaxTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            accountMinMaxTokenBalance[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(ACCOUNT_MIN_MAX_TOKEN_BALANCE, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Get the accountMinMaxTokenBalance Rule Id.
     * @param _action the action type
     * @return accountMinMaxTokenBalance rule id.
     */
    function getAccountMinMaxTokenBalanceId(ActionTypes _action) external view returns (uint32) {
        return accountMinMaxTokenBalance[_action].ruleId;
    }

    /**
     * @dev Tells you if the AccountMinMaxTokenBalance is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAccountMinMaxTokenBalanceActive(ActionTypes _action) external view returns (bool) {
        return accountMinMaxTokenBalance[_action].active;
    }


    /**
     * @dev Set the AccountApproveDenyOracleRuleId. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setAccountApproveDenyOracleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccountApproveDenyOracle(_ruleId);
        for (uint i; i < _actions.length; ) {
            if (accountApproveDenyOracle[_actions[i]].length >= MAX_ORACLE_RULES) {
                revert AccountApproveDenyOraclesPerAssetLimitReached();
            }

            Rule memory newEntity;
            newEntity.ruleId = _ruleId;
            newEntity.active = true;
            accountApproveDenyOracle[_actions[i]].push(newEntity);
            emit ApplicationHandlerActionApplied(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i], _ruleId);
            unchecked {
                        ++i;
            }
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     * @param ruleId the id of the rule to activate/deactivate
     */

    function activateAccountApproveDenyOracle(ActionTypes[] calldata _actions, bool _on, uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            
            for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < accountApproveDenyOracle[_actions[i]].length; ) {
                if (accountApproveDenyOracle[_actions[i]][accountApproveDenyOracleIndex].ruleId == ruleId) {
                    accountApproveDenyOracle[_actions[i]][accountApproveDenyOracleIndex].active = _on;

                    if (_on) {
                        emit ApplicationHandlerActionActivated(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i]);
                    } else {
                        emit ApplicationHandlerActionDeactivated(ACCOUNT_APPROVE_DENY_ORACLE, _actions[i]);
                    }
                }
                unchecked {
                    ++accountApproveDenyOracleIndex;
                }
            }
            unchecked {
                    ++i;
            }
        }
    }

    /**
     * @dev Retrieve the account approve deny oracle rule id
     * @param _action the action type
     * @return oracleRuleId
     */
    function getAccountApproveDenyOracleIds(ActionTypes _action) external view returns (uint32[] memory ) {
        uint32[] memory ruleIds = new uint32[](accountApproveDenyOracle[_action].length);
        for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < accountApproveDenyOracle[_action].length; ) {
            ruleIds[accountApproveDenyOracleIndex] = accountApproveDenyOracle[_action][accountApproveDenyOracleIndex].ruleId;
            unchecked {
                ++accountApproveDenyOracleIndex;
            }
        }
        return ruleIds;
    }

    /**
     * @dev Tells you if the Account Approve Deny Oracle Rule is active or not.
     * @param _action the action type
     * @param ruleId the id of the rule to check
     * @return boolean representing if the rule is active
     */
    function isAccountApproveDenyOracleActive(ActionTypes _action, uint32 ruleId) external view returns (bool) {
        for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < accountApproveDenyOracle[_action].length; ) {
            if (accountApproveDenyOracle[_action][accountApproveDenyOracleIndex].ruleId == ruleId) {
                return accountApproveDenyOracle[_action][accountApproveDenyOracleIndex].active;
            }
            unchecked {
                ++accountApproveDenyOracleIndex;
            }
        }
        return false;
    }

    /**
     * @dev Removes an account approve deny oracle rule from the list.
     * @param _actions the action types
     * @param ruleId the id of the rule to remove
     */
    function removeAccountApproveDenyOracle(ActionTypes[] calldata _actions, uint32 ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            Rule memory lastId = accountApproveDenyOracle[_actions[i]][accountApproveDenyOracle[_actions[i]].length -1];
            if(ruleId != lastId.ruleId){
                uint index = 0;
                for (uint256 accountApproveDenyOracleIndex; accountApproveDenyOracleIndex < accountApproveDenyOracle[_actions[i]].length; ) {
                    if (accountApproveDenyOracle[_actions[i]][accountApproveDenyOracleIndex].ruleId == ruleId) {
                        index = accountApproveDenyOracleIndex; 
                        break;
                    }
                    unchecked {
                        ++accountApproveDenyOracleIndex;
                    }
                }
                accountApproveDenyOracle[_actions[i]][index] = lastId;
            }

            accountApproveDenyOracle[_actions[i]].pop();
            unchecked {
                        ++i;
            }
        }
    }

    /**
     * @dev Set the tokenMaxDailyTrades Rule Id. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action types
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxDailyTradesId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateTokenMaxDailyTrades(_ruleId);
        for (uint i; i < _actions.length; ) {
            tokenMaxDailyTrades[_actions[i]].ruleId = _ruleId;
            tokenMaxDailyTrades[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TOKEN_MAX_DAILY_TRADES, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action types
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMaxDailyTrades(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            tokenMaxDailyTrades[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MAX_DAILY_TRADES, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MAX_DAILY_TRADES, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Retrieve the token max daily trades rule id
     * @param _action the action type
     * @return tokenMaxDailyTradesRuleId
     */
    function getTokenMaxDailyTradesId(ActionTypes _action) external view returns (uint32) {
        return tokenMaxDailyTrades[_action].ruleId;
    }

    /**
     * @dev Tells you if the tokenMaxDailyTrades Rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxDailyTradesActive(ActionTypes _action) external view returns (bool) {
        return tokenMaxDailyTrades[_action].active;
    }

    /**
     * @dev Set the parent ERC721 address
     * @param _address address of the ERC721
     */
    function setERC721Address(address _address) public appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_address == address(0)) revert ZeroAddress();
        erc721Address = _address;
        emit ERC721AddressSet(_address);
    }

     /**
     * @dev Set the AdminMinTokenBalance Rule Id. Restricted to rule administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setAdminMinTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAdminMinTokenBalance(_ruleId);
        if (isAdminMinTokenBalanceActiveForAnyAction()) {
            if (isAdminMinTokenBalanceActiveAndApplicable()) revert AdminMinTokenBalanceisActive();
        }
        for (uint i; i < _actions.length; ) {
            /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
            adminMinTokenBalance[_actions[i]].ruleId = _ruleId;
            adminMinTokenBalance[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(ADMIN_MIN_TOKEN_BALANCE, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev This function is used by the app manager to determine if the AdminMinTokenBalance rule is active for any actions
     * @return Success equals true if all checks pass
     */
    function isAdminMinTokenBalanceActiveAndApplicable() public view override returns (bool) {
        bool active;
        uint8 action = 0;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= LAST_POSSIBLE_ACTION) { 
            if (adminMinTokenBalance[ActionTypes(action)].active) {
                try ruleProcessor.checkAdminMinTokenBalance(adminMinTokenBalance[ActionTypes(action)].ruleId, 1, 1) {} catch {
                    active = true;
                    break;
                }
            }
            action++;
        }
        return active;
    }

    /**
     * @dev This function is used internally to check if the admin min token balance is active for any actions
     * @return Success equals true if all checks pass
     */
    function isAdminMinTokenBalanceActiveForAnyAction() internal view returns (bool) {
        bool active;
        uint8 action = 0;
        /// if the rule is active for any actions, set it as active and applicable.
        while (action <= LAST_POSSIBLE_ACTION) { 
            if (adminMinTokenBalance[ActionTypes(action)].active) {
                active = true;
                break;
            }
            action++;
        }
        return active;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _actions the action type
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAdminMinTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            if (isAdminMinTokenBalanceActiveAndApplicable()) revert AdminMinTokenBalanceisActive();
        }
        for (uint i; i < _actions.length; ) {
            adminMinTokenBalance[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(ADMIN_MIN_TOKEN_BALANCE, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(ADMIN_MIN_TOKEN_BALANCE, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the admin min token balance rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isAdminMinTokenBalanceActive(ActionTypes _action) external view returns (bool) {
        return adminMinTokenBalance[_action].active;
    }

    /**
     * @dev Retrieve the admin min token balance rule id
     * @param _action the action type
     * @return adminMinTokenBalanceRuleId rule id
     */
    function getAdminMinTokenBalanceId(ActionTypes _action) external view returns (uint32) {
        return adminMinTokenBalance[_action].ruleId;
    }

/**
     * @dev Retrieve the token max trading volume rule id
     * @param _action the action type
     * @return tokenMaxTradingVolumeRuleId rule id
     */
    function getTokenMaxTradingVolumeId(ActionTypes _action) external view returns (uint32) {
        return tokenMaxTradingVolume[_action].ruleId;
    }

    /**
     * @dev Set the tokenMaxTradingVolume Rule Id. Restricted to rule admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxTradingVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            ruleProcessor.validateTokenMaxTradingVolume(_ruleId);
            tokenMaxTradingVolume[_actions[i]].ruleId = _ruleId;
            tokenMaxTradingVolume[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TOKEN_MAX_TRADING_VOLUME, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the token max trading volume rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMaxTradingVolume(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            tokenMaxTradingVolume[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MAX_TRADING_VOLUME, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MAX_TRADING_VOLUME, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the token max trading volume rule is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxTradingVolumeActive(ActionTypes _action) external view returns (bool) {
        return tokenMaxTradingVolume[_action].active;
    }

    /**
     * @dev Retrieve the token max supply volatility rule id
     * @param _action the action type
     * @return totalTokenMaxSupplyVolatilityId rule id
     */
    function getTokenMaxSupplyVolatilityId(ActionTypes _action) external view returns (uint32) {
        return tokenMaxSupplyVolatility[_action].ruleId;
    }

    /**
     * @dev Set the tokenMaxTradingVolumeRuleId. Restricted to rule admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _actions the action type
     * @param _ruleId Rule Id to set
     */
    function setTokenMaxSupplyVolatilityId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            ruleProcessor.validateTokenMaxSupplyVolatility(_ruleId);
            tokenMaxSupplyVolatility[_actions[i]].ruleId = _ruleId;
            tokenMaxSupplyVolatility[_actions[i]].active = true;
            emit ApplicationHandlerActionApplied(TOKEN_MAX_SUPPLY_VOLATILITY, _actions[i], _ruleId);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the Token Max Supply Volatility rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMaxSupplyVolatility(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            tokenMaxSupplyVolatility[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MAX_SUPPLY_VOLATILITY, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MAX_SUPPLY_VOLATILITY, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Tells you if the Token Max Supply Volatility is active or not.
     * @param _action the action type
     * @return boolean representing if the rule is active
     */
    function isTokenMaxSupplyVolatilityActive(ActionTypes _action) external view returns (bool) {
        return tokenMaxSupplyVolatility[_action].active;
    }

    /// -------------SIMPLE RULE SETTERS and GETTERS---------------
    /**
     * @dev Tells you if the minimum hold time rule is active or not.
     * @param _actions the action type
     * @param _on boolean representing if the rule is active
     */
    function activateTokenMinHoldTime(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        for (uint i; i < _actions.length; ) {
            tokenMinHoldTime[_actions[i]].active = _on;
            if (_on) {
                emit ApplicationHandlerActionActivated(TOKEN_MIN_HOLD_TIME, _actions[i]);
            } else {
                emit ApplicationHandlerActionDeactivated(TOKEN_MIN_HOLD_TIME, _actions[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Setter the minimum hold time rule hold hours
     * @param _actions the action types
     * @param _minHoldTimeHours minimum amount of time to hold the asset
     */
    function setTokenMinHoldTime(ActionTypes[] calldata _actions, uint32 _minHoldTimeHours) external ruleAdministratorOnly(appManagerAddress) {
        if (_minHoldTimeHours == 0) revert ZeroValueNotPermited();
        if (_minHoldTimeHours > MAX_HOLD_TIME_HOURS) revert PeriodExceeds5Years();
        for (uint i; i < _actions.length; ) {
            tokenMinHoldTime[_actions[i]].period = _minHoldTimeHours;
            tokenMinHoldTime[_actions[i]].active = true;
            emit ApplicationHandlerSimpleActionApplied(TOKEN_MIN_HOLD_TIME, _actions[i], uint256(_minHoldTimeHours));
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Get the minimum hold time rule hold hours
     * @param _action the action type
     * @return period minimum amount of time to hold the asset
     */
    function getTokenMinHoldTimePeriod(ActionTypes _action) external view returns (uint32) {
        return tokenMinHoldTime[_action].period;
    }

    /**
     * @dev function to check if Minumum Hold Time is active
     * @param _action the action type
     * @return bool
     */
    function isTokenMinHoldTimeActive(ActionTypes _action) external view returns (bool) {
        return tokenMinHoldTime[_action].active;
    }

    /**
     * @dev Set the NFT Valuation limit that will check collection price vs looping through each tokenId in collections
     * @param _newNFTValuationLimit set the number of NFTs in a wallet that will check for collection price vs individual token prices
     */
    function setNFTValuationLimit(uint16 _newNFTValuationLimit) public appAdministratorOrOwnerOnly(appManagerAddress) {
        nftValuationLimit = _newNFTValuationLimit;
        emit NFTValuationLimitUpdated(_newNFTValuationLimit);
    }

    /**
     * @dev Get the nftValuationLimit
     * @return nftValautionLimit number of NFTs in a wallet that will check for collection price vs individual token prices
     */
    function getNFTValuationLimit() external view returns (uint256) {
        return nftValuationLimit;
    }
}
