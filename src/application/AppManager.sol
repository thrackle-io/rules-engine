// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "../data/Accounts.sol";
import "../data/IAccounts.sol";
import "../data/IAccessLevels.sol";
import "../data/AccessLevels.sol";
import "../data/IRiskScores.sol";
import "../data/RiskScores.sol";
import "../data/IGeneralTags.sol";
import "../data/GeneralTags.sol";
import "../data/IPauseRules.sol";
import "../data/PauseRules.sol";
import "../application/ProtocolApplicationHandler.sol";
import "../economic/ruleProcessor/ActionEnum.sol";
import {IAppLevelEvents} from "../interfaces/IEvents.sol";
import "../application/IAppManagerUser.sol";
import "../data/IDataModule.sol";
import "../token/IAdminWithdrawalRuleCapable.sol";
import "../token/ProtocolTokenCommon.sol";

/**
 * @title App Manager Contract
 * @dev This uses AccessControlEnumerable to maintain user permissions, handles metadata storage, and checks application level rules via its handler.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is the permissions contract
 */
contract AppManager is IAppManager, AccessControlEnumerable, IAppLevelEvents {
    string private constant VERSION="1.0.1";
    using ERC165Checker for address;
    bytes32 constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    bytes32 constant RULE_ADMIN_ROLE = keccak256("RULE_ADMIN_ROLE");
    bytes32 constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");

    /// Data contracts
    IAccounts accounts;
    IAccessLevels accessLevels;
    IRiskScores riskScores;
    IGeneralTags generalTags;
    IPauseRules pauseRules;

    // Data provider proposed addresses
    address newAccessLevelsProviderAddress;
    address newAccountsProviderAddress;
    address newGeneralTagsProviderAddress;
    address newPauseRulesProviderAddress;
    address newRiskScoresProviderAddress;

    /// Application Handler Contract
    ProtocolApplicationHandler public applicationHandler;
    address applicationHandlerAddress;
    bool applicationRulesActive;

    mapping(string => address) tokenToAddress;
    mapping(address => string) addressToToken;
    mapping(address => bool) registeredHandlers;
    /// Token array (for balance tallying)
    address[] tokenList;
    mapping(address => uint) tokenToIndex;
    mapping(address => bool) isTokenRegistered;
    /// AMM List (for token level rule exemptions)
    address[] ammList;
    mapping(address => uint) ammToIndex;
    mapping(address => bool) isAMMRegistered;
    /// Treasury List (for token level rule exemptions)
    address[] treasuryList;
    mapping(address => uint) treasuryToIndex;
    mapping(address => bool) isTreasuryRegistered;

    /// Application name string
    string appName;

    /**
     * @dev This constructor sets up the first default admin and app administrator roles while also forming the hierarchy of roles and deploying data contracts. App Admins are the top tier. They may assign all admins, including other app admins.
     * @param root address to set as the default admin and first app administrator
     * @param _appName Application Name String
     * @param upgradeMode specifies whether this is a fresh AppManager or an upgrade replacement.
     */
    constructor(address root, string memory _appName, bool upgradeMode) {
        // deployer is set as both an AppAdmin and the Default Admin
        _grantRole(SUPER_ADMIN_ROLE, root);
        _grantRole(APP_ADMIN_ROLE, root);
        _setRoleAdmin(APP_ADMIN_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(ACCESS_TIER_ADMIN_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(RISK_ADMIN_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(RULE_ADMIN_ROLE, APP_ADMIN_ROLE);
        appName = _appName;
        if (!upgradeMode) {
            deployDataContracts();
            emit AppManagerDeployed(address(this));
        } else {
            emit AppManagerDeployedForUpgrade(address(this));
        }
    }

    // /// -------------ADMIN---------------
    /**
     * @dev This function is where the Super admin role is actually checked
     * @param account address to be checked
     * @return success true if admin, false if not
     */
    function isSuperAdmin(address account) public view returns (bool) {
        return hasRole(SUPER_ADMIN_ROLE, account);
    }

    /// -------------APP ADMIN---------------

    /**
     * @dev This function is where the app administrator role is actually checked
     * @param account address to be checked
     * @return success true if app administrator, false if not
     */
    function isAppAdministrator(address account) public view returns (bool) {
        return hasRole(APP_ADMIN_ROLE, account);
    }

    /**
     * @dev Add an account to the app administrator role. Restricted to super admins.
     * @param account address to be added
     */
    function addAppAdministrator(address account) external onlyRole(SUPER_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        grantRole(APP_ADMIN_ROLE, account);
        emit AddAppAdministrator(account);
    }

    /**
     * @dev Add an array of accounts to the app administrator role. Restricted to admins.
     * @param _accounts address array to be added
     */
    function addMultipleAppAdministrator(address[] memory _accounts) external onlyRole(SUPER_ADMIN_ROLE) {
        for (uint256 i; i < _accounts.length; ) {
            grantRole(APP_ADMIN_ROLE, _accounts[i]);
            emit AddAppAdministrator(_accounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Remove oneself from the app administrator role.
     */
    function renounceAppAdministrator() external {
        /// If the AdminWithdrawal rule is active, App Admins are not allowed to renounce their role to prevent manipulation of the rule
        checkForAdminWithdrawal();
        renounceRole(APP_ADMIN_ROLE, msg.sender);
        emit RemoveAppAdministrator(address(msg.sender));
    }

    /**
     * @dev Loop through all the registered tokens, if they are capable of admin withdrawal, see if it's active. If so, revert
     */
    function checkForAdminWithdrawal() internal {
        for (uint256 i; i < tokenList.length; ) {
            // check to see if supports the rule first
            if (ProtocolTokenCommon(tokenList[i]).getHandlerAddress().supportsInterface(type(IAdminWithdrawalRuleCapable).interfaceId)) {
                if (IAdminWithdrawalRuleCapable(ProtocolTokenCommon(tokenList[i]).getHandlerAddress()).isAdminWithdrawalActiveAndApplicable()) {
                    revert AdminWithdrawalRuleisActive();
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /// -------------RULE ADMIN---------------

    /**
     * @dev This function is where the rule admin role is actually checked
     * @param account address to be checked
     * @return success true if RULE_ADMIN_ROLE, false if not
     */
    function isRuleAdministrator(address account) public view returns (bool) {
        return hasRole(RULE_ADMIN_ROLE, account);
    }

    /**
     * @dev Add an account to the rule admin role. Restricted to app administrators.
     * @param account address to be added as a rule admin
     */
    function addRuleAdministrator(address account) external onlyRole(APP_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        grantRole(RULE_ADMIN_ROLE, account);
        emit RuleAdminAdded(account);
    }

    /**
     * @dev Add a list of accounts to the rule admin role. Restricted to app administrators.
     * @param account address to be added as a rule admin
     */
    function addMultipleRuleAdministrator(address[] memory account) external onlyRole(APP_ADMIN_ROLE) {
        for (uint256 i; i < account.length; ) {
            grantRole(RULE_ADMIN_ROLE, account[i]);
            emit RuleAdminAdded(account[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Remove oneself from the rule admin role.
     */
    function renounceRuleAdministrator() external {
        renounceRole(RULE_ADMIN_ROLE, msg.sender);
        emit RuleAdminRemoved(address(msg.sender));
    }

    /// -------------ACCESS TIER---------------
    /**
     * @dev Checks for if msg.sender is a Access Tier
     */
    modifier onlyAccessTierAdministrator() {
        if (!isAccessTier(msg.sender)) revert NotAccessTierAdministrator(msg.sender);
        _;
    }

    /**
     * @dev This function is where the access tier role is actually checked
     * @param account address to be checked
     * @return success true if ACCESS_TIER_ADMIN_ROLE, false if not
     */
    function isAccessTier(address account) public view returns (bool) {
        return hasRole(ACCESS_TIER_ADMIN_ROLE, account);
    }

    /**
     * @dev Add an account to the access tier role. Restricted to app administrators.
     * @param account address to be added as a access tier
     */
    function addAccessTier(address account) external onlyRole(APP_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        grantRole(ACCESS_TIER_ADMIN_ROLE, account);
        emit AccessTierAdded(account);
    }

    /**
     * @dev Add a list of accounts to the access tier role. Restricted to app administrators.
     * @param account address to be added as a access tier
     */
    function addMultipleAccessTier(address[] memory account) external onlyRole(APP_ADMIN_ROLE) {
        for (uint256 i; i < account.length; ) {
            grantRole(ACCESS_TIER_ADMIN_ROLE, account[i]);
            emit AccessTierAdded(account[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Remove oneself from the access tier role.
     */
    function renounceAccessTier() external {
        renounceRole(ACCESS_TIER_ADMIN_ROLE, msg.sender);
        emit AccessTierRemoved(address(msg.sender));
    }

    /// -------------RISK ADMIN---------------

    /**
     * @dev This function is where the risk admin role is actually checked
     * @param account address to be checked
     * @return success true if RISK_ADMIN_ROLE, false if not
     */
    function isRiskAdmin(address account) public view returns (bool) {
        return hasRole(RISK_ADMIN_ROLE, account);
    }

    /**
     * @dev Add an account to the risk admin role. Restricted to app administrators.
     * @param account address to be added
     */
    function addRiskAdmin(address account) external onlyRole(APP_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        grantRole(RISK_ADMIN_ROLE, account);
        emit RiskAdminAdded(account);
    }

    /**
     * @dev Add a list of accounts to the risk admin role. Restricted to app administrators.
     * @param account address to be added
     */
    function addMultipleRiskAdmin(address[] memory account) external onlyRole(APP_ADMIN_ROLE) {
        for (uint256 i; i < account.length; ) {
            grantRole(RISK_ADMIN_ROLE, account[i]);
            emit RiskAdminAdded(account[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Remove oneself from the risk admin role.
     */
    function renounceRiskAdmin() external {
        renounceRole(RISK_ADMIN_ROLE, msg.sender);
        emit RiskAdminRemoved(address(msg.sender));
    }

    /// -------------MAINTAIN ACCESS LEVELS---------------

    /**
     * @dev Add the Access Level(0-4) to the account. Restricted to Access Tiers.
     * @param _account address upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevel(address _account, uint8 _level) external onlyRole(ACCESS_TIER_ADMIN_ROLE) {
        accessLevels.addLevel(_account, _level);
    }

    /**
     * @dev Add the Access Level(0-4) to multiple accounts. Restricted to Access Tiers.
     * @param _accounts address upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external onlyRole(ACCESS_TIER_ADMIN_ROLE) {
        accessLevels.addAccessLevelToMultipleAccounts(_accounts, _level);
    }

    /**
     * @dev Add the Access Level(0-4) to the list of account. Restricted to Access Tiers.
     * @param _accounts address array upon which to apply the Access Level
     * @param _level Access Level array to add
     */
    function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external onlyRole(ACCESS_TIER_ADMIN_ROLE) {
        if (_level.length != _accounts.length) revert InputArraysMustHaveSameLength();
        for (uint256 i; i < _accounts.length; ) {
            accessLevels.addLevel(_accounts[i], _level[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Get the AccessLevel Score for the specified account
     * @param _account address of the user
     * @return
     */
    function getAccessLevel(address _account) external view returns (uint8) {
        return accessLevels.getAccessLevel(_account);
    }

    /// -------------MAINTAIN RISK SCORES---------------

    /**
     * @dev  Add the Risk Score. Restricted to Risk Admins.
     * @param _account address upon which to apply the Risk Score
     * @param _score Risk Score(0-100)
     */
    function addRiskScore(address _account, uint8 _score) external onlyRole(RISK_ADMIN_ROLE) {
        riskScores.addScore(_account, _score);
    }

    /**
     * @dev  Add the Risk Score to each address in array. Restricted to Risk Admins.
     * @param _accounts address array upon which to apply the Risk Score
     * @param _score Risk Score(0-100)
     */
    function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external onlyRole(RISK_ADMIN_ROLE) {
        riskScores.addRiskScoreToMultipleAccounts(_accounts, _score);
    }

    /**
     * @dev  Add the Risk Score at index to Account at index in array. Restricted to Risk Admins.
     * @param _accounts address array upon which to apply the Risk Score
     * @param _scores Risk Score array (0-100)
     */
    function addMultipleRiskScores(address[] memory _accounts, uint8[] memory _scores) external onlyRole(RISK_ADMIN_ROLE) {
        if (_scores.length != _accounts.length) revert InputArraysMustHaveSameLength();
        for (uint256 i; i < _accounts.length; ) {
            riskScores.addScore(_accounts[i], _scores[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Get the Risk Score for an account.
     * @param _account address upon which the risk score was set
     * @return score risk score(0-100)
     */
    function getRiskScore(address _account) external view returns (uint8) {
        return riskScores.getRiskScore(_account);
    }

    /// --------------MAINTAIN PAUSE RULES---------------

    /**
     * @dev Add a pause rule. Restricted to Application Administrators
     * @param _pauseStart Beginning of the pause window
     * @param _pauseStop End of the pause window
     */
    function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyRole(RULE_ADMIN_ROLE) {
        pauseRules.addPauseRule(_pauseStart, _pauseStop);
    }

    /**
     * @dev Remove a pause rule. Restricted to Application Administrators
     * @param _pauseStart Beginning of the pause window
     * @param _pauseStop End of the pause window
     */
    function removePauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyRole(RULE_ADMIN_ROLE) {
        pauseRules.removePauseRule(_pauseStart, _pauseStop);
    }

    /**
     * @dev Get all pause rules for the token
     * @return PauseRule An array of all the pause rules
     */
    function getPauseRules() external view returns (PauseRule[] memory) {
        return pauseRules.getPauseRules();
    }

    /**
     * @dev Remove any expired pause windows.
     */
    function cleanOutdatedRules() external {
        pauseRules.cleanOutdatedRules();
    }

    /// -------------MAINTAIN GENERAL TAGS---------------

    /**
     * @dev Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _account Address to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addGeneralTag(address _account, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE) {
        generalTags.addTag(_account, _tag);
    }

    /**
     * @dev Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addGeneralTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE) {
        generalTags.addGeneralTagToMultipleAccounts(_accounts, _tag);
    }

    /**
     * @dev Add a general tag to an account at index in array. Restricted to Application Administrators. Loops through existing tags on accounts and will emit  an event if tag is already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag array for the account at index. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addMultipleGeneralTagToMultipleAccounts(address[] memory _accounts, bytes32[] memory _tag) external onlyRole(APP_ADMIN_ROLE) {
        if (_accounts.length != _tag.length) revert InputArraysMustHaveSameLength();
        for (uint256 i; i < _accounts.length; ) {
            generalTags.addTag(_accounts[i], _tag[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Remove a general tag. Restricted to Application Administrators.
     * @param _account Address to have its tag removed
     * @param _tag The tag to remove
     */
    function removeGeneralTag(address _account, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE) {
        generalTags.removeTag(_account, _tag);
    }

    /**
     * @dev Check to see if an account has a specific general tag
     * @param _account Address to check
     * @param _tag Tag to be checked for
     * @return success true if account has the tag, false if it does not
     */
    function hasTag(address _account, bytes32 _tag) public view returns (bool) {
        return generalTags.hasTag(_account, _tag);
    }

    /**
     * @dev Get all the tags for the address
     * @param _address Address to retrieve the tags
     * @return tags Array of all tags for the account
     */
    function getAllTags(address _address) external view returns (bytes32[] memory) {
        return generalTags.getAllTags(_address);
    }

    /**
     * @dev  First part of the 2 step process to set a new risk score provider. First, the new provider address is proposed and saved, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in this contract.
     * @param _newProvider Address of the new provider
     */
    function proposeRiskScoresProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE) {
        if (_newProvider == address(0)) revert ZeroAddress();
        newRiskScoresProviderAddress = _newProvider;
    }

    /**
     * @dev Get the address of the risk score provider
     * @return provider Address of the provider
     */
    function getRiskScoresProvider() external view returns (address) {
        return address(riskScores);
    }

    /**
     * @dev  First part of the 2 step process to set a new general tag provider. First, the new provider address is proposed and saved, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in this contract.
     * @param _newProvider Address of the new provider
     */
    function proposeGeneralTagsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE) {
        if (_newProvider == address(0)) revert ZeroAddress();
        newGeneralTagsProviderAddress = _newProvider;
    }

    /**
     * @dev Get the address of the general tag provider
     * @return provider Address of the provider
     */
    function getGeneralTagProvider() external view returns (address) {
        return address(generalTags);
    }

    /**
     * @dev  First part of the 2 step process to set a new account provider. First, the new provider address is proposed and saved, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in this contract.
     * @param _newProvider Address of the new provider
     */
    function proposeAccountsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE) {
        if (_newProvider == address(0)) revert ZeroAddress();
        newAccountsProviderAddress = _newProvider;
    }

    /**
     * @dev Get the address of the account provider
     * @return provider Address of the provider
     */
    function getAccountProvider() external view returns (address) {
        return address(accounts);
    }

    /**
     * @dev  First part of the 2 step process to set a new pause rule provider. First, the new provider address is proposed and saved, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in this contract.
     * @param _newProvider Address of the new provider
     */
    function proposePauseRulesProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE) {
        if (_newProvider == address(0)) revert ZeroAddress();
        newPauseRulesProviderAddress = _newProvider;
    }

    /**
     * @dev Get the address of the pause rules provider
     * @return provider Address of the provider
     */
    function getPauseRulesProvider() external view returns (address) {
        return address(pauseRules);
    }

    /**
     * @dev  First part of the 2 step process to set a new access level provider. First, the new provider address is proposed and saved, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in this contract.
     * @param _newProvider Address of the new provider
     */
    function proposeAccessLevelsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE) {
        if (_newProvider == address(0)) revert ZeroAddress();
        newAccessLevelsProviderAddress = _newProvider;
    }

    /**
     * @dev Get the address of the Access Level provider
     * @return accessLevelProvider Address of the Access Level provider
     */
    function getAccessLevelProvider() external view returns (address) {
        return address(accessLevels);
    }

    /** APPLICATION CHECKS */
    /**
     * @dev checks if any of the balance prerequisite rules are active
     * @return true if one or more rules are active
     */
    function requireValuations() external returns (bool) {
        if (applicationHandler.requireValuations()) {
            applicationRulesActive = true;
        } else {
            applicationRulesActive = false;
        }
        return applicationRulesActive;
    }

    /**
     * @dev Check Application Rules for valid transactions.
     * @param _action Action to be checked
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _usdBalanceTo recepient address current total application valuation in USD with 18 decimals of precision
     * @param _usdAmountTransferring valuation of the token being transferred in USD with 18 decimals of precision
     */
    function checkApplicationRules(ActionTypes _action, address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) external onlyHandler {
        applicationHandler.checkApplicationRules(_action, _from, _to, _usdBalanceTo, _usdAmountTransferring);
    }

    /**
     * @dev This function checks if the address is a registered handler within one of the registered protocol supported entities
     * @param _address address to be checked
     * @return isHandler true if handler, false if not
     */
    function isRegisteredHandler(address _address) public view returns (bool) {
        return registeredHandlers[_address];
    }

    /**
     * @dev Checks if msg.sender is a registered handler
     */
    modifier onlyHandler() {
        if (!isRegisteredHandler(msg.sender)) revert NotRegisteredHandler(msg.sender);
        _;
    }

    /**
     * @dev This function allows the devs to register their token contract addresses. This keeps everything in sync and will aid with the token factory and application level balance checks.
     * @param _token The token identifier(may be NFT or ERC20)
     * @param _tokenAddress Address corresponding to the tokenId
     */
    function registerToken(string calldata _token, address _tokenAddress) external onlyRole(APP_ADMIN_ROLE) {
        if (_tokenAddress == address(0)) revert ZeroAddress();
        tokenToAddress[_token] = _tokenAddress;
        addressToToken[_tokenAddress] = _token;
        if(!isTokenRegistered[_tokenAddress]){  
            tokenToIndex[_tokenAddress] = tokenList.length;  
            tokenList.push(_tokenAddress);
            isTokenRegistered[_tokenAddress] = true;
            registeredHandlers[ProtocolTokenCommon(_tokenAddress).getHandlerAddress()] = true;
            emit TokenRegistered(_token, _tokenAddress);
        }else emit TokenNameUpdated(_token, _tokenAddress);
        
    }

    /**
     * @dev This function gets token contract address.
     * @param _tokenId The token id(may be NFT or ERC20)
     * @return tokenAddress the address corresponding to the tokenId
     */
    function getTokenAddress(string calldata _tokenId) external view returns (address) {
        return tokenToAddress[_tokenId];
    }

    /**
     * @dev This function gets token identification string.
     * @param _tokenAddress the address of the contract of the token to query
     * @return the identification string.
     */
    function getTokenID(address _tokenAddress) external view returns (string memory) {
        return addressToToken[_tokenAddress];
    }

    /**
     * @dev This function allows the devs to deregister a token contract address. This keeps everything in sync and will aid with the token factory and application level balance checks.
     * @param _tokenId The token id(may be NFT or ERC20)
     */

    function deregisterToken(string calldata _tokenId) external onlyRole(APP_ADMIN_ROLE) {
        address tokenAddress = tokenToAddress[_tokenId];
        if(!isTokenRegistered[tokenAddress]) revert NoAddressToRemove();
        _removeAddressWithMapping(tokenList, tokenToIndex, isTokenRegistered, tokenAddress);
        delete tokenToAddress[_tokenId];
        delete addressToToken[tokenAddress];
        /// also remove its handler from the registration
        delete registeredHandlers[ProtocolTokenCommon(tokenAddress).getHandlerAddress()];
        emit RemoveFromRegistry(_tokenId, tokenAddress);
    }

     /**
     * @dev This function removes an address from a dynamic address array by putting the last element in the one to remove and then removing last element.
     * @param _addressArray The array to have an address removed
     * @param _addressToIndex mapping that keeps track of the indexes in the list by address
     * @param _registerFlag mapping that keeps track of the addresses that are members of the list
     * @param _address The address to remove
     */
    function _removeAddressWithMapping(
        address[] storage  _addressArray, 
        mapping(address => uint) storage _addressToIndex, 
        mapping(address => bool) storage _registerFlag, 
        address _address) 
        private 
        {
            /// we store the last address in the array on a local variable to avoid unnecessary costly memory reads
            address LastAddress = _addressArray[_addressArray.length -1];
            /// we check if we're trying to remove the last address in the array since this means we can skip some steps
            if(_address != LastAddress){
                /// if it is not the last address in the array, then we store the index of the address to remove
                uint index = _addressToIndex[_address];
                /// we remove the address by replacing it in the array with the last address of the array (now duplicated)
                _addressArray[index] = LastAddress;
                /// we update the last address index to its new position (the removed-address index)
                _addressToIndex[LastAddress] = index;
            }
            /// we remove the last element of the _addressArray since it is now duplicated
            _addressArray.pop();
            /// we set to false the membership mapping for this address in _addressArray
            delete _registerFlag[_address];
            /// we set the index to zero for this address in _addressArray
            delete _addressToIndex[_address];
    }

    /**
     * @dev This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions
     * @param _AMMAddress Address for the AMM
     */
    function registerAMM(address _AMMAddress) external onlyRole(APP_ADMIN_ROLE) {
        if (_AMMAddress == address(0)) revert ZeroAddress();
        if (isRegisteredAMM(_AMMAddress)) revert AddressAlreadyRegistered();
        ammToIndex[_AMMAddress] = ammList.length;
        ammList.push(_AMMAddress);
        isAMMRegistered[_AMMAddress] = true;
        emit AMMRegistered(_AMMAddress);
    }

    /**
     * @dev This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions
     * @param _AMMAddress Address for the AMM
     */
    function isRegisteredAMM(address _AMMAddress) public view returns (bool) {
        return isAMMRegistered[_AMMAddress];
    }

    /**
     * @dev This function allows the devs to deregister an AMM contract address.
     * @param _AMMAddress The of the AMM to be de-registered
     */
    function deRegisterAMM(address _AMMAddress) external onlyRole(APP_ADMIN_ROLE) {
        if (!isRegisteredAMM(_AMMAddress)) revert NoAddressToRemove();
        _removeAddressWithMapping(ammList, ammToIndex, isAMMRegistered, _AMMAddress);
    }

    /**
     * @dev This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions
     * @param _treasuryAddress Address for the treasury
     */
    function isTreasury(address _treasuryAddress) public view returns (bool) {
        return isTreasuryRegistered[_treasuryAddress];
    }

    /**
     * @dev This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions
     * @param _treasuryAddress Address for the treasury
     */
    function registerTreasury(address _treasuryAddress) external onlyRole(APP_ADMIN_ROLE) {
        if (_treasuryAddress == address(0)) revert ZeroAddress();
        if (isTreasury(_treasuryAddress)) revert AddressAlreadyRegistered();
        treasuryToIndex[_treasuryAddress] = treasuryList.length;
        treasuryList.push(_treasuryAddress);
        isTreasuryRegistered[_treasuryAddress] = true;
        emit TreasuryRegistered(_treasuryAddress);
    }

    /**
     * @dev This function allows the devs to deregister an treasury address.
     * @param _treasuryAddress The of the AMM to be de-registered
     */
    function deRegisterTreasury(address _treasuryAddress) external onlyRole(APP_ADMIN_ROLE) {
        if (!isTreasury(_treasuryAddress)) revert NoAddressToRemove();
        _removeAddressWithMapping(treasuryList, treasuryToIndex, isTreasuryRegistered, _treasuryAddress);
    }

    /**
     * @dev Getter for the access level contract address
     * @return AccessLevelDataAddress
     */
    function getAccessLevelDataAddress() external view returns (address) {
        return address(accessLevels);
    }

    /**
     * @dev Getter for the Account data contract address
     * @return accountDataAddress
     */
    function getAccountDataAddress() external view returns (address) {
        return address(accounts);
    }

    /**
     * @dev Getter for the risk data contract address
     * @return riskDataAddress
     */
    function getRiskDataAddress() external view returns (address) {
        return address(riskScores);
    }

    /**
     * @dev Getter for the general tags data contract address
     * @return generalTagsDataAddress
     */
    function getGeneralTagsDataAddress() external view returns (address) {
        return address(generalTags);
    }

    /**
     * @dev Getter for the pause rules data contract address
     * @return pauseRulesDataAddress
     */
    function getPauseRulesDataAddress() external view returns (address) {
        return address(pauseRules);
    }

    /**
     * @dev Return the token list for calculation purposes
     * @return tokenList list of all tokens registered
     */
    function getTokenList() external view returns (address[] memory) {
        return tokenList;
    }

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }

    /**
     * @dev Update the Application Handler Contract Address
     * @param _newApplicationHandler address of new Application Handler contract
     * @notice this is for upgrading to a new ApplicationHandler contract
     */
    function setNewApplicationHandlerAddress(address _newApplicationHandler) external onlyRole(APP_ADMIN_ROLE) {
        if (_newApplicationHandler == address(0)) revert ZeroAddress();
        applicationHandler = ProtocolApplicationHandler(_newApplicationHandler);
        applicationHandlerAddress = _newApplicationHandler;
        emit HandlerConnected(applicationHandlerAddress, address(this));
    }

    /**
     * @dev this function returns the application handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return applicationHandlerAddress;
    }

    /**
     * @dev Setter for application Name
     * @param _appName application name string
     */
    function setAppName(string calldata _appName) external onlyRole(APP_ADMIN_ROLE) {
        appName = _appName;
    }

    /**
     * @dev Part of the two step process to set a new AppManager within a Protocol Entity
     * @param _assetAddress address of a protocol entity that uses AppManager
     */
    function confirmAppManager(address _assetAddress) external onlyRole(APP_ADMIN_ROLE) {
        IAppManagerUser(_assetAddress).confirmAppManagerAddress();
    }

    /// -------------DATA CONTRACT DEPLOYMENT---------------
    /**
     * @dev Deploy all the child data contracts. Only called internally from the constructor.
     */
    function deployDataContracts() private {
        accounts = new Accounts(address(this));
        accessLevels = new AccessLevels(address(this));
        riskScores = new RiskScores(address(this));
        generalTags = new GeneralTags(address(this));
        pauseRules = new PauseRules(address(this));
    }

    /**
     * @dev This function is used to propose the new owner for data contracts.
     * @param _newOwner address of the new AppManager
     */
    function proposeDataContractMigration(address _newOwner) external onlyRole(APP_ADMIN_ROLE) {
        accounts.proposeOwner(_newOwner);
        accessLevels.proposeOwner(_newOwner);
        riskScores.proposeOwner(_newOwner);
        generalTags.proposeOwner(_newOwner);
        pauseRules.proposeOwner(_newOwner);
        emit AppManagerDataUpgradeProposed(_newOwner, address(this));
    }

    /**
     * @dev This function is used to confirm this contract as the new owner for data contracts.
     */
    function confirmDataContractMigration(address _oldAppManagerAddress) external onlyRole(APP_ADMIN_ROLE) {
        AppManager oldAppManager = AppManager(_oldAppManagerAddress);
        accounts = Accounts(oldAppManager.getAccountDataAddress());
        accounts.confirmOwner();
        accessLevels = IAccessLevels(oldAppManager.getAccessLevelDataAddress());
        accessLevels.confirmOwner();
        riskScores = RiskScores(oldAppManager.getRiskDataAddress());
        riskScores.confirmOwner();
        generalTags = GeneralTags(oldAppManager.getGeneralTagsDataAddress());
        generalTags.confirmOwner();
        pauseRules = PauseRules(oldAppManager.getPauseRulesDataAddress());
        pauseRules.confirmOwner();
        emit DataContractsMigrated(address(this));
    }

    /**
     * @dev Part of the two step process to set a new Data Provider within a Protocol AppManager. Final confirmation called by new provider
     * @param _providerType the type of data provider
     */
    function confirmNewDataProvider(IDataModule.ProviderType _providerType) external {
        if (_providerType == IDataModule.ProviderType.GENERAL_TAG) {
            if (newGeneralTagsProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (msg.sender != newGeneralTagsProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            generalTags = IGeneralTags(newGeneralTagsProviderAddress);
            emit GeneralTagProviderSet(newGeneralTagsProviderAddress);
            delete newGeneralTagsProviderAddress;
        } else if (_providerType == IDataModule.ProviderType.RISK_SCORE) {
            if (newRiskScoresProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (msg.sender != newRiskScoresProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            riskScores = IRiskScores(newRiskScoresProviderAddress);
            emit RiskProviderSet(newRiskScoresProviderAddress);
            delete newRiskScoresProviderAddress;
        } else if (_providerType == IDataModule.ProviderType.ACCESS_LEVEL) {
            if (newAccessLevelsProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (msg.sender != newAccessLevelsProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            accessLevels = IAccessLevels(newAccessLevelsProviderAddress);
            emit AccessLevelProviderSet(newAccessLevelsProviderAddress);
            delete newAccessLevelsProviderAddress;
        } else if (_providerType == IDataModule.ProviderType.ACCOUNT) {
            if (newAccountsProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (msg.sender != newAccountsProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            accounts = IAccounts(newAccountsProviderAddress);
            emit AccountProviderSet(newAccountsProviderAddress);
            delete newAccountsProviderAddress;
        } else if (_providerType == IDataModule.ProviderType.PAUSE_RULE) {
            if (newPauseRulesProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (msg.sender != newPauseRulesProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            pauseRules = IPauseRules(newPauseRulesProviderAddress);
            emit PauseRuleProviderSet(newPauseRulesProviderAddress);
            delete newPauseRulesProviderAddress;
        }
    }
}
