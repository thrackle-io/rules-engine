// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol";
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
import "./ProtocolApplicationHandler.sol";
import "src/economic/ruleProcessor/ActionEnum.sol";
import {IAppLevelEvents} from "../interfaces/IEvents.sol";

/**
 * @title App Manager Contract
 * @dev This uses AccessControlEnumerable to maintain user permissions, handles metadata storage, and checks application level rules via its handler.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is the permissions contract
 */
contract AppManager is IAppManager, AccessControlEnumerable, IAppLevelEvents {
    

    bytes32 constant USER_ROLE = keccak256("USER");
    bytes32 constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");

    /// Data contracts
    IAccounts accounts;
    IAccessLevels accessLevels;
    IRiskScores riskScores;
    IGeneralTags generalTags;
    IPauseRules pauseRules;

    /// Application Handler Contract
    ProtocolApplicationHandler public applicationHandler;
    address applicationHandlerAddress;
    bool applicationRulesActive;

    mapping(string => address) tokenToAddress;
    mapping(address => string) addressToToken;
    /// Token array (for balance tallying)
    address[] tokenList;
    /// AMM List (for token level rule exemptions)
    address[] ammList;
    /// Treasury List (for token level rule exemptions)
    address[] treasuryList;
    /// Staking Contracts List (for token level rule exemptions)
    address[] stakingList;

    /// Application name string
    string appName;

    /**
     * @dev This constructor sets up the first default admin and app administrator roles while also forming the hierarchy of roles and deploying data contracts. App Admins are the top tier. They may assign all admins, including other app admins.
     * @param root address to set as the default admin and first app administrator
     * @param _appName Application Name String
     * @param upgradeMode specifies whether this is a fresh AppManager or an upgrade replacement.
     */
    constructor(address root, string memory _appName, bool upgradeMode) {
        _setupRole(DEFAULT_ADMIN_ROLE, root);
        _setupRole(APP_ADMIN_ROLE, root);
        _setRoleAdmin(APP_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(APP_ADMIN_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(ACCESS_TIER_ADMIN_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(RISK_ADMIN_ROLE, APP_ADMIN_ROLE);
        appName = _appName;
        if (!upgradeMode) {
            deployDataContracts();
            emit AppManagerDeployed(address(this));
        } else {
            emit AppManagerDeployedForUpgrade(address(this));
        }
    }

    // /// -------------ADMIN---------------
    // /**
    //  * @dev This function is where the default admin role is actually checked
    //  * @param account address to be checked
    //  * @return success true if admin, false if not
    //  */
    function isAdmin(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// -------------APP ADMIN---------------
    /**
     * @dev Checks if msg.sender is a Application Administrators role
     */
    modifier onlyAppAdministrator() {
        if (!isAppAdministrator(msg.sender)) revert NotAppAdministrator();
        _;
    }

    /**
     * @dev This function is where the app administrator role is actually checked
     * @param account address to be checked
     * @return success true if app administrator, false if not
     */
    function isAppAdministrator(address account) public view returns (bool) {
        return hasRole(APP_ADMIN_ROLE, account);
    }

    /**
     * @dev Add an account to the app administrator role. Restricted to admins.
     * @param account address to be added
     */
    function addAppAdministrator(address account) external onlyAppAdministrator {
        if (account == address(0)) revert ZeroAddress(); 
        grantRole(APP_ADMIN_ROLE, account);
        emit AddAppAdministrator(account);
    }

    /**
     * @dev Add an array of accounts to the app administrator role. Restricted to admins.
     * @param _accounts address array to be added
     */
    function addMultipleAppAdministrator(address[] memory _accounts) external onlyAppAdministrator {
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
        renounceRole(APP_ADMIN_ROLE, msg.sender);
        emit RemoveAppAdministrator(address(msg.sender));
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
    function addAccessTier(address account) external onlyAppAdministrator {
        if (account == address(0)) revert ZeroAddress();
        grantRole(ACCESS_TIER_ADMIN_ROLE, account);
        emit AccessTierAdded(account);
    }

    /**
     * @dev Add a list of accounts to the access tier role. Restricted to app administrators.
     * @param account address to be added as a access tier
     */
    function addMultipleAccessTier(address[] memory account) external onlyAppAdministrator {
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
     * @dev Checks if msg.sender is a Risk Admin role
     */
    modifier onlyRiskAdmin() {
        if (!isRiskAdmin(msg.sender)) revert NotRiskAdmin(msg.sender);
        _;
    }

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
    function addRiskAdmin(address account) external onlyAppAdministrator {
        if (account == address(0)) revert ZeroAddress();
        grantRole(RISK_ADMIN_ROLE, account);
        emit RiskAdminAdded(account);
    }

    /**
     * @dev Add a list of accounts to the risk admin role. Restricted to app administrators.
     * @param account address to be added
     */
    function addMultipleRiskAdmin(address[] memory account) external onlyAppAdministrator {
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

    /// -------------USER---------------
    /// The user roles are stored in a separate data contract
    /// These roles can be used to specify if the account is simply a verified user in the application.
    /**
     * @dev Checks if the msg.sender is in the user role
     */
    modifier onlyUser() {
        if (!isUser(msg.sender)) revert NotAUser(msg.sender);
        _;
    }

    /**
     * @dev This function is where the user role is actually checked
     * @param _address address to be checked
     * @return success true if USER_ROLE, false if not
     */
    function isUser(address _address) public view returns (bool) {
        return accounts.isUserAccount(_address);
    }

    /**
     * @dev Add an account to the user role. Restricted to app administrators.
     * @param _account address to be added as a user
     */
    function addUser(address _account) external onlyAppAdministrator {
        accounts.addAccount(_account);
        emit AccountAdded(_account, block.timestamp);
    }

    /**
     * @dev Remove an account from the user role. Restricted to app administrators.
     * @param _account address to be removed as a user
     */
    function removeUser(address _account) external onlyAppAdministrator {
        accounts.removeAccount(_account);
    }

    /// -------------MAINTAIN ACCESS LEVELS---------------

    /**
     * @dev Add the Access Level(0-4) to the account. Restricted to Access Tiers.
     * @param _account address upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevel(address _account, uint8 _level) external onlyAccessTierAdministrator {
        accessLevels.addLevel(_account, _level);
    }

    /**
     * @dev Add the Access Level(0-4) to multiple accounts. Restricted to Access Tiers.
     * @param _accounts address upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external onlyAccessTierAdministrator {
        accessLevels.addAccessLevelToMultipleAccounts(_accounts, _level);
    }

    /**
     * @dev Add the Access Level(0-4) to the list of account. Restricted to Access Tiers.
     * @param _accounts address array upon which to apply the Access Level
     * @param _level Access Level array to add
     */
    function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external onlyAccessTierAdministrator {
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
    function addRiskScore(address _account, uint8 _score) external onlyRiskAdmin {
        riskScores.addScore(_account, _score);
    }

    /**
     * @dev  Add the Risk Score to each address in array. Restricted to Risk Admins.
     * @param _accounts address array upon which to apply the Risk Score
     * @param _score Risk Score(0-100)
     */
    function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external onlyRiskAdmin {
        riskScores.addRiskScoreToMultipleAccounts(_accounts, _score);
    }

    /**
     * @dev  Add the Risk Score at index to Account at index in array. Restricted to Risk Admins.
     * @param _accounts address array upon which to apply the Risk Score
     * @param _scores Risk Score array (0-100)
     */
    function addMultipleRiskScores(address[] memory _accounts, uint8[] memory _scores) external onlyRiskAdmin {
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
    function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyAppAdministrator {
        
        pauseRules.addPauseRule(_pauseStart, _pauseStop);
    }

    /**
     * @dev Remove a pause rule. Restricted to Application Administrators
     * @param _pauseStart Beginning of the pause window
     * @param _pauseStop End of the pause window
     */
    function removePauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyAppAdministrator {
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
    function addGeneralTag(address _account, bytes32 _tag) external onlyAppAdministrator {
        generalTags.addTag(_account, _tag);
    }

    /**
     * @dev Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addGeneralTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external onlyAppAdministrator {
         generalTags.addGeneralTagToMultipleAccounts(_accounts, _tag);
    }

    /**
     * @dev Add a general tag to an account at index in array. Restricted to Application Administrators. Loops through existing tags on accounts and will emit  an event if tag is already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag array for the account at index. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address. 
     */
    function addMultipleGeneralTagToMultipleAccounts(address[] memory _accounts, bytes32[] memory _tag) external onlyAppAdministrator {
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
    function removeGeneralTag(address _account, bytes32 _tag) external onlyAppAdministrator {
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
     * @dev  Set the address of the Risk Provider contract. Restricted to Application Administrators
     * @param _provider Address of the provider
     */
    function setRiskProvider(address _provider) external onlyAppAdministrator {
        if (_provider == address(0)) revert ZeroAddress();
        riskScores = IRiskScores(_provider);
    }

    /**
     * @dev Get the address of the risk score provider
     * @return provider Address of the provider
     */
    function getRiskProvider() external view returns (address) {
        return address(riskScores);
    }

    /**
     * @dev  Set the address of the General Tag Provider contract. Restricted to Application Administrators
     * @param _provider Address of the provider
     */
    function setGeneralTagProvider(address _provider) external onlyAppAdministrator {
        if (_provider == address(0)) revert ZeroAddress();
        generalTags = IGeneralTags(_provider);
    }

    /**
     * @dev Get the address of the general tag provider
     * @return provider Address of the provider
     */
    function getGeneralTagProvider() external view returns (address) {
        return address(generalTags);
    }

    /**
     * @dev  Set the address of the Account Provider contract. Restricted to Application Administrators
     * @param _provider Address of the provider
     */
    function setAccountProvider(address _provider) external onlyAppAdministrator {
        if (_provider == address(0)) revert ZeroAddress();
        accounts = IAccounts(_provider);
    }

    /**
     * @dev Get the address of the account provider
     * @return provider Address of the provider
     */
    function getAccountProvider() external view returns (address) {
        return address(accounts);
    }

    /**
     * @dev  Set the address of the Pause Rule Provider contract. Restricted to Application Administrators
     * @param _provider Address of the provider
     */
    function setPauseRuleProvider(address _provider) external onlyAppAdministrator {
        if (_provider == address(0)) revert ZeroAddress();
        pauseRules = IPauseRules(_provider);
    }

    /**
     * @dev Get the address of the pause rules provider
     * @return provider Address of the provider
     */
    function getPauseRulesProvider() external view returns (address) {
        return address(pauseRules);
    }

    /**
     * @dev  Set the address of the Access Level Provider contract. Restricted to Application Administrators
     * @param _accessLevelProvider Address of the Access Level provider
     */
    function setAccessLevelProvider(address _accessLevelProvider) external onlyAppAdministrator {
        if (_accessLevelProvider == address(0)) revert ZeroAddress();
        accessLevels = IAccessLevels(_accessLevelProvider);
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
    function checkApplicationRules(ActionTypes _action, address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) external {
        applicationHandler.checkApplicationRules(_action, _from, _to, _usdBalanceTo, _usdAmountTransferring);
    }

    /**
     * @dev This function allows the devs to register their token contract addresses. This keeps everything in sync and will aid with the token factory and application level balance checks.
     * @param _token The token identifier(may be NFT or ERC20)
     * @param _tokenAddress Address corresponding to the tokenId
     */
    function registerToken(string calldata _token, address _tokenAddress) external onlyAppAdministrator {
        if (_tokenAddress == address(0)) revert ZeroAddress();
        tokenToAddress[_token] = _tokenAddress;
        addressToToken[_tokenAddress] = _token;
        tokenList.push(_tokenAddress);
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
    function deregisterToken(string calldata _tokenId) external onlyAppAdministrator {
        _removeAddress(tokenList, tokenToAddress[_tokenId]);
        address tokenAddress = tokenToAddress[_tokenId];
        delete tokenToAddress[_tokenId];
        delete addressToToken[tokenAddress];
        emit RemoveFromRegistry(_tokenId, tokenAddress);
    }

    /**
     * @dev This function removes an address from a dynamic address array by putting the last element in the one to remove and then removing last element.
     * @param _addressArray The array to have an address removed
     * @param _address The address to remove
     */
    function _removeAddress(address[] storage _addressArray, address _address) private {
        if (_addressArray.length == 0) {
            revert NoAddressToRemove();
        }
        if (_addressArray.length > 1) {
            for (uint256 i = 0; i < _addressArray.length; ) {
                if (_addressArray[i] == _address) {
                    _addressArray[i] = _addressArray[_addressArray.length - 1];
                }
                unchecked {
                    ++i;
                }
            }
        }
        _addressArray.pop();
    }

    /**
     * @dev This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions
     * @param _AMMAddress Address for the AMM
     */
    function registerAMM(address _AMMAddress) external onlyAppAdministrator {
        if (_AMMAddress == address(0)) revert ZeroAddress();
        ammList.push(_AMMAddress);
    }

    /**
     * @dev This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions
     * @param _AMMAddress Address for the AMM
     */
    function isRegisteredAMM(address _AMMAddress) external view returns (bool) {
        for (uint256 i = 0; i < ammList.length; ) {
            if (ammList[i] == _AMMAddress) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /**
     * @dev This function allows the devs to deregister an AMM contract address.
     * @param _AMMAddress The of the AMM to be de-registered
     */
    function deRegisterAMM(address _AMMAddress) external onlyAppAdministrator {
        _removeAddress(ammList, _AMMAddress);
    }

    /**
     * @dev This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions
     * @param _treasuryAddress Address for the treasury
     */
    function isTreasury(address _treasuryAddress) external view returns (bool) {
        for (uint256 i = 0; i < treasuryList.length; ) {
            if (treasuryList[i] == _treasuryAddress) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /**
     * @dev This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions
     * @param _treasuryAddress Address for the treasury
     */
    function registerTreasury(address _treasuryAddress) external onlyAppAdministrator {
        if (_treasuryAddress == address(0)) revert ZeroAddress();
        treasuryList.push(_treasuryAddress);
    }

    /**
     * @dev This function allows the devs to deregister an treasury address.
     * @param _treasuryAddress The of the AMM to be de-registered
     */
    function deRegisterTreasury(address _treasuryAddress) external onlyAppAdministrator {
        _removeAddress(treasuryList, _treasuryAddress);
    }

    /**
     * @dev This function allows the devs to register their Staking contract addresses. Allow contracts to check if contract is registered staking contract within ecosystem.
     * This check is used in minting rewards tokens for example.
     * @param _stakingAddress Address for the AMM
     */
    function registerStaking(address _stakingAddress) external onlyAppAdministrator {
        if (_stakingAddress == address(0)) revert ZeroAddress();
        stakingList.push(_stakingAddress);
    }

    /**
     * @dev This function allows the devs to register their Staking contract addresses.
     * @param _stakingAddress Address for the Staking Contract
     */
    function isRegisteredStaking(address _stakingAddress) external view returns (bool) {
        for (uint256 i = 0; i < stakingList.length; ) {
            if (stakingList[i] == _stakingAddress) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /**
     * @dev This function allows the devs to deregister a Staking contract address.
     * @param _stakingAddress The of the Staking contract to be de-registered
     */
    function deRegisterStaking(address _stakingAddress) external onlyAppAdministrator {
        _removeAddress(stakingList, _stakingAddress);
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
     * @dev Update the Application Handler Contract Address
     * @param _newApplicationHandler address of new Application Handler contract
     * @notice this is for upgrading to a new ApplicationHandler contract
     */
    function setNewApplicationHandlerAddress(address _newApplicationHandler) external onlyAppAdministrator {
        if (_newApplicationHandler == address(0)) revert ZeroAddress();
        applicationHandler = ProtocolApplicationHandler(_newApplicationHandler);
        applicationHandlerAddress = _newApplicationHandler;
        emit HandlerConnected( applicationHandlerAddress, address(this)); 
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
    function setAppName(string calldata _appName) external onlyAppAdministrator {
        appName = _appName;
    }

    /// -------------DATA CONTRACT DEPLOYMENT---------------
    /**
     * @dev Deploy all the child data contracts. Only called internally from the constructor.
     */
    function deployDataContracts() private {
        accounts = new Accounts();
        accessLevels = new AccessLevels();
        riskScores = new RiskScores();
        generalTags = new GeneralTags();
        pauseRules = new PauseRules();
    }

    /**
     * @dev This function is used to migrate the data contracts to a new AppManager. Use with care because it changes ownership. They will no
     * longer be accessible from the original AppManager
     * @param _newOwner address of the new AppManager
     */
    function migrateDataContracts(address _newOwner) external onlyAppAdministrator {
        accounts.setAppManagerAddress(_newOwner);
        accounts.transferDataOwnership(_newOwner);
        accessLevels.setAppManagerAddress(_newOwner);
        accessLevels.transferDataOwnership(_newOwner);
        riskScores.setAppManagerAddress(_newOwner);
        riskScores.transferDataOwnership(_newOwner);
        generalTags.setAppManagerAddress(_newOwner);
        generalTags.transferDataOwnership(_newOwner);
        pauseRules.setAppManagerAddress(_newOwner);
        pauseRules.transferDataOwnership(_newOwner);
        emit AppManagerUpgrade(_newOwner, address(this));
    }

    /**
     * @dev This function is used to connect data contracts from an old AppManager to the current AppManager.
     * @param _oldAppManagerAddress address of the old AppManager
     */
    function connectDataContracts(address _oldAppManagerAddress) external onlyAppAdministrator {
        if (_oldAppManagerAddress == address(0)) revert ZeroAddress();
        AppManager oldAppManager = AppManager(_oldAppManagerAddress);
        accounts = Accounts(oldAppManager.getAccountDataAddress());
        accessLevels = IAccessLevels(oldAppManager.getAccessLevelDataAddress());
        riskScores = RiskScores(oldAppManager.getRiskDataAddress());
        generalTags = GeneralTags(oldAppManager.getGeneralTagsDataAddress());
        pauseRules = PauseRules(oldAppManager.getPauseRulesDataAddress());
    }
}
