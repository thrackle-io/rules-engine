// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "src/client/application/data/IAccounts.sol";
import "src/client/application/data/IAccessLevels.sol";
import "src/client/application/data/AccessLevels.sol";
import "src/client/application/data/IRiskScores.sol";
import "src/client/application/data/RiskScores.sol";
import "src/client/application/data/ITags.sol";
import "src/client/application/data/Tags.sol";
import "src/client/application/data/IPauseRules.sol";
import "src/client/application/data/PauseRules.sol";
import "src/client/application/ProtocolApplicationHandler.sol";
import "src/client/application/IAppManagerUser.sol";

import "src/client/token/ProtocolTokenCommon.sol";
import "src/client/token/HandlerTypeEnum.sol";
import {IApplicationEvents, IIntegrationEvents} from "src/common/IEvents.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";

/**
 * @title App Manager Contract
 * @dev This uses AccessControlEnumerable to maintain user permissions, handles metadata storage, and checks application level rules via the application handler.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is the permissions contract
 */
contract AppManager is IAppManager, AccessControlEnumerable, IAppLevelEvents, IApplicationEvents, IIntegrationEvents, ReentrancyGuard {
    string private constant VERSION = "2.0.0";
    using ERC165Checker for address;
    bytes32 constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 constant RULE_ADMIN_ROLE = keccak256("RULE_ADMIN_ROLE");
    bytes32 constant ACCESS_LEVEL_ADMIN_ROLE = keccak256("ACCESS_LEVEL_ADMIN_ROLE");
    bytes32 constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    bytes32 constant TREASURY_ACCOUNT = keccak256("TREASURY_ACCOUNT");
    bytes32 constant PROPOSED_SUPER_ADMIN_ROLE = keccak256("PROPOSED_SUPER_ADMIN_ROLE");

    /// Data contracts
    IAccessLevels accessLevels;
    IRiskScores riskScores;
    ITags tags;
    IPauseRules pauseRules;

    /// Data provider proposed addresses
    address newAccessLevelsProviderAddress;
    address newTagsProviderAddress;
    address newPauseRulesProviderAddress;
    address newRiskScoresProviderAddress;

    /// Application name string
    string appName;

    /// Application Handler Contract
    ProtocolApplicationHandler public applicationHandler;
    address applicationHandlerAddress;

    mapping(string => address) tokenToAddress;
    mapping(address => string) addressToToken;
    mapping(address => bool) registeredHandlers;
    /// Token array (for balance tallying)
    address[] tokenList;
    mapping(address => uint) tokenToIndex;
    mapping(address => bool) isTokenRegistered;
    /// Allowlist for trading rule exceptions
    address[] tradingRuleAllowList;
    mapping(address => bool) isTradingRuleAllowlisted;
    mapping(address => uint) tradingRuleAllowlistAddressToIndex;

    /**
     * @dev This constructor sets up the super admin and app administrator roles while also forming the hierarchy of roles and deploying data contracts. App Admins are the top tier. They may assign all admins, including other app admins.
     * @param root address to set as the super admin and first app administrator
     * @param _appName Application Name String
     * @param upgradeMode specifies whether this is a fresh AppManager or an upgrade replacement.
     */
    constructor(address root, string memory _appName, bool upgradeMode) {
        // root is set as the Super Admin
        _grantRole(SUPER_ADMIN_ROLE, root);
        _setRoleAdmin(APP_ADMIN_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(ACCESS_LEVEL_ADMIN_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(RISK_ADMIN_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(RULE_ADMIN_ROLE, APP_ADMIN_ROLE);
        _setRoleAdmin(TREASURY_ACCOUNT, APP_ADMIN_ROLE);
        _setRoleAdmin(SUPER_ADMIN_ROLE, PROPOSED_SUPER_ADMIN_ROLE);
        _setRoleAdmin(PROPOSED_SUPER_ADMIN_ROLE, SUPER_ADMIN_ROLE);
        appName = _appName;
        if (!upgradeMode) {
            deployDataContracts();
            emit AD1467_AppManagerDeployed(root, _appName);
        } else {
            emit AD1467_AppManagerDeployedForUpgrade(root, _appName);
        }
    }

    /**
     * @dev This function overrides the parent's grantRole function. This disables its public nature to make it private.
     * @param role the role to grant to an acount.
     * @param account address being granted the role.
     * @notice This is purposely going to fail every time it will be invoked in order to force users to only use the appropiate
     * channels to grant roles, and therefore enforce the special rules in an app.
     */
    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        /// this is done to funnel all the role granting functions through the app manager functions since
        /// the superAdmins could add other superAdmins through this back door
        role;
        account;
        revert("Function disabled");
    }

    /**
     * @dev This function overrides the parent's renounceRole function. Its purpose is to prevent superAdmins from renouncing through
     * this "backdoor", so they are forced to set another superAdmin through the function proposeNewSuperAdmin.
     * @param role the role to renounce.
     * @param account address renouncing to the role.
     */
    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        /// enforcing the min-1-admin requirement. Only PROPOSED_SUPER_ADMIN_ROLE should be able to bypass this rule
        if (role == SUPER_ADMIN_ROLE) revert BelowMinAdminThreshold();
        AccessControl.renounceRole(role, account);
    }

    /**
     * @dev This function overrides the parent's revokeRole function. Its purpose is to prevent superAdmins from being revoked through
     * this "backdoor" which would effectively leave the app in a superAdmin-orphan state.
     * @param role the role to revoke.
     * @param account address of revoked role.
     */
    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) nonReentrant {
        /// enforcing the min-1-admin requirement.
        if (role == SUPER_ADMIN_ROLE) revert BelowMinAdminThreshold();
        // slither-disable-next-line reentrancy-events
        AccessControl.revokeRole(role, account);
    }

    /// -------------SUPER ADMIN---------------
    /**
     * @dev This function is where the Super admin role is actually checked
     * @param account address to be checked
     * @return success true if admin, false if not
     */
    function isSuperAdmin(address account) public view returns (bool) {
        return hasRole(SUPER_ADMIN_ROLE, account);
    }

    /// -------------- PROPOSE NEW SUPER ADMIN ------------------

    /**
     * @dev Propose a new super admin. Restricted to super admins.
     * @notice We should only have 1 proposed superAdmin. If there is one already in this role, we should remove it to replace it.
     * @param account address to be added (Cannot be zero address and cannot be current super admin)
     */
    function proposeNewSuperAdmin(address account) external onlyRole(SUPER_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        if (isSuperAdmin(account) == true) revert ProposedAddressCannotBeSuperAdmin();
        if (getRoleMemberCount(PROPOSED_SUPER_ADMIN_ROLE) > 0) {
            updateProposedRole(account);
        } else {
            super.grantRole(PROPOSED_SUPER_ADMIN_ROLE, account);
        }
    }

    /**
     * A function used specifically for moving the proposed super admin from one account
     * to another. Allows revoke and grant to be called in the same function without the possibility
     * of re-entrancy.
     * @param newAddress the new Proposed Super Admin account.
     */
    function updateProposedRole(address newAddress) private onlyRole(SUPER_ADMIN_ROLE) {
        AccessControl.revokeRole(PROPOSED_SUPER_ADMIN_ROLE, getRoleMember(PROPOSED_SUPER_ADMIN_ROLE, 0));
        super.grantRole(PROPOSED_SUPER_ADMIN_ROLE, newAddress);
    }

    /**
     * @dev confirm the superAdmin role.
     * @notice only the proposed account can accept this role.
     */
    function confirmSuperAdmin() external {
        address newSuperAdmin = getRoleMember(PROPOSED_SUPER_ADMIN_ROLE, 0);
        if (_msgSender() != newSuperAdmin) revert ConfirmerDoesNotMatchProposedAddress();
        address oldSuperAdmin = getRoleMember(SUPER_ADMIN_ROLE, 0);
        super.grantRole(SUPER_ADMIN_ROLE, newSuperAdmin);
        super.revokeRole(SUPER_ADMIN_ROLE, oldSuperAdmin);
        renounceRole(PROPOSED_SUPER_ADMIN_ROLE, _msgSender());
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
    function addAppAdministrator(address account) public onlyRole(SUPER_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        super.grantRole(APP_ADMIN_ROLE, account);
    }

    /**
     * @dev Add an array of accounts to the app administrator role. Restricted to admins.
     * @param _accounts address array to be added
     */
    function addMultipleAppAdministrator(address[] memory _accounts) external onlyRole(SUPER_ADMIN_ROLE) {
        for (uint256 i; i < _accounts.length; ++i) {
            addAppAdministrator(_accounts[i]);
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
    function addRuleAdministrator(address account) public onlyRole(APP_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        super.grantRole(RULE_ADMIN_ROLE, account);
    }

    /**
     * @dev Add a list of accounts to the rule admin role. Restricted to app administrators.
     * @param account address to be added as a rule admin
     */
    function addMultipleRuleAdministrator(address[] memory account) external onlyRole(APP_ADMIN_ROLE) {
        for (uint256 i; i < account.length; ++i) {
            addRuleAdministrator(account[i]);
        }
    }

    /// -------------TREASURY ACCOUNT ---------------

    /**
     * @dev This function is where the Treasury account role is actually checked
     * @param account address to be checked
     * @return success true if TREASURY_ACCOUNT, false if not
     */
    function isTreasuryAccount(address account) public view returns (bool) {
        return hasRole(TREASURY_ACCOUNT, account);
    }

    /**
     * @dev Add an account to the Treasury account role. Restricted to app administrators.
     * @param account address to be added as a Treasury account
     */
    function addTreasuryAccount(address account) public onlyRole(APP_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        super.grantRole(TREASURY_ACCOUNT, account);
    }

    /**
     * @dev Add a list of accounts to the Treasury account role. Restricted to app administrators.
     * @param _accounts addresses to be added as a Treasury account
     */
    function addMultipleTreasuryAccounts(address[] memory _accounts) external onlyRole(APP_ADMIN_ROLE) {
        for (uint256 i; i < _accounts.length; ++i) {
            addTreasuryAccount(_accounts[i]);
        }
    }

    /// -------------ACCESS LEVEL---------------
    /**
     * @dev This function is where the access level admin role is actually checked
     * @param account address to be checked
     * @return success true if ACCESS_LEVEL_ADMIN_ROLE, false if not
     */
    function isAccessLevelAdmin(address account) public view returns (bool) {
        return hasRole(ACCESS_LEVEL_ADMIN_ROLE, account);
    }

    /**
     * @dev Add an account to the access level role. Restricted to app administrators.
     * @param account address to be added as a access level
     */
    function addAccessLevelAdmin(address account) public onlyRole(APP_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        super.grantRole(ACCESS_LEVEL_ADMIN_ROLE, account);
    }

    /**
     * @dev Add a list of accounts to the access level role. Restricted to app administrators.
     * @param account address to be added as a access level
     */
    function addMultipleAccessLevelAdmins(address[] memory account) external onlyRole(APP_ADMIN_ROLE) {
        for (uint256 i; i < account.length; ++i) {
            addAccessLevelAdmin(account[i]);
        }
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
    function addRiskAdmin(address account) public onlyRole(APP_ADMIN_ROLE) {
        if (account == address(0)) revert ZeroAddress();
        super.grantRole(RISK_ADMIN_ROLE, account);
    }

    /**
     * @dev Add a list of accounts to the risk admin role. Restricted to app administrators.
     * @param account address to be added
     */
    function addMultipleRiskAdmin(address[] memory account) external onlyRole(APP_ADMIN_ROLE) {
        for (uint256 i; i < account.length; ++i) {
            addRiskAdmin(account[i]);
        }
    }

    /// -------------MAINTAIN ACCESS LEVELS---------------

    /**
     * @dev Add the Access Level(0-4) to the account. Restricted to Access Level Admins.
     * @param _account address upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevel(address _account, uint8 _level) public onlyRole(ACCESS_LEVEL_ADMIN_ROLE) {
        accessLevels.addLevel(_account, _level);
    }

    /**
     * @dev Add the Access Level(0-4) to multiple accounts. Restricted to Access Level Admins.
     * @param _accounts address upon which to apply the Access Level
     * @param _level Access Level to add
     */
    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external onlyRole(ACCESS_LEVEL_ADMIN_ROLE) {
        accessLevels.addAccessLevelToMultipleAccounts(_accounts, _level);
    }

    /**
     * @dev Add the Access Level(0-4) to the list of account. Restricted to Access Level Admins.
     * @param _accounts address array upon which to apply the Access Level
     * @param _level Access Level array to add
     */
    function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external onlyRole(ACCESS_LEVEL_ADMIN_ROLE) {
        accessLevels.addMultipleAccessLevels(_accounts, _level);
    }

    /**
     * @dev Get the Access Level for the specified account
     * @param _account address of the user
     * @return
     */
    function getAccessLevel(address _account) external view returns (uint8) {
        return accessLevels.getAccessLevel(_account);
    }

    /**
     * @dev Remove the Access Level for an account.
     * @param _account address which the Access Level will be removed from
     */
    function removeAccessLevel(address _account) external onlyRole(ACCESS_LEVEL_ADMIN_ROLE) {
        accessLevels.removeAccessLevel(_account);
    }

    /// -------------MAINTAIN RISK SCORES---------------

    /**
     * @dev  Add the Risk Score. Restricted to Risk Admins.
     * @param _account address upon which to apply the Risk Score
     * @param _score Risk Score(0-100)
     */
    function addRiskScore(address _account, uint8 _score) public onlyRole(RISK_ADMIN_ROLE) {
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
        riskScores.addMultipleRiskScores(_accounts, _scores);
    }

    /**
     * @dev Get the Risk Score for an account.
     * @param _account address upon which the risk score was set
     * @return score risk score(0-100)
     */
    function getRiskScore(address _account) external view returns (uint8) {
        return riskScores.getRiskScore(_account);
    }

    /**
     * @dev Remove the Risk Score for an account.
     * @param _account address which the risk score will be removed from
     */
    function removeRiskScore(address _account) external onlyRole(RISK_ADMIN_ROLE) {
        riskScores.removeScore(_account);
    }

    /// --------------MAINTAIN PAUSE RULES---------------

    /**
     * @dev Add a pause rule. Restricted to Application Administrators
     * @notice Adding a pause rule will change the bool to true in the hanlder contract and pause rules will be checked.
     * @param _pauseStart Beginning of the pause window
     * @param _pauseStop End of the pause window
     */
    function addPauseRule(uint64 _pauseStart, uint64 _pauseStop) external onlyRole(RULE_ADMIN_ROLE) {
        pauseRules.addPauseRule(_pauseStart, _pauseStop);
        applicationHandler.activatePauseRule(true);
    }

    /**
     * @dev Remove a pause rule. Restricted to Application Administrators
     * @notice If no pause rules exist after removal bool is set to false in handler and pause rules will not be checked until new rule is added.
     * @param _pauseStart Beginning of the pause window
     * @param _pauseStop End of the pause window
     */
    function removePauseRule(uint64 _pauseStart, uint64 _pauseStop) external onlyRole(RULE_ADMIN_ROLE) {
        pauseRules.removePauseRule(_pauseStart, _pauseStop);
        if (pauseRules.isPauseRulesEmpty()) {
            /// set handler bool to false to save gas and prevent pause rule checks when non exist
            applicationHandler.activatePauseRule(false);
        }
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * This function calls the appHandler contract to enable/disable this check.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePauseRuleCheck(bool _on) external onlyRole(RULE_ADMIN_ROLE) {
        applicationHandler.activatePauseRule(_on);
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

    /// -------------MAINTAIN TAGS---------------

    /**
     * @dev Add a tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _account Address to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addTag(address _account, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE) {
        tags.addTag(_account, _tag);
    }

    /**
     * @dev Add a tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.
     * @param _accounts Address array to be tagged
     * @param _tag Tag for the account. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE) {
        tags.addTagToMultipleAccounts(_accounts, _tag);
    }

    /**
     * @dev Add a general tag to an account at index in array. Restricted to Application Administrators. Loops through existing tags on accounts and will emit  an event if tag is already applied.
     * @param _accounts Address array to be tagged
     * @param _tags Tag array for the account at index. Can be any allowed string variant
     * @notice there is a hard limit of 10 tags per address.
     */
    function addMultipleTagToMultipleAccounts(address[] memory _accounts, bytes32[] memory _tags) external onlyRole(APP_ADMIN_ROLE) {
        tags.addMultipleTagToMultipleAccounts(_accounts, _tags);
    }

    /**
     * @dev Remove a tag. Restricted to Application Administrators.
     * @param _account Address to have its tag removed
     * @param _tag The tag to remove
     */
    function removeTag(address _account, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE) {
        tags.removeTag(_account, _tag);
    }

    /**
     * @dev Check to see if an account has a specific tag
     * @param _account Address to check
     * @param _tag Tag to be checked for
     * @return success true if account has the tag, false if it does not
     */
    function hasTag(address _account, bytes32 _tag) public view returns (bool) {
        return tags.hasTag(_account, _tag);
    }

    /**
     * @dev Get all the tags for the address
     * @param _address Address to retrieve the tags
     * @return tags Array of all tags for the account
     */
    function getAllTags(address _address) external view returns (bytes32[] memory) {
        return tags.getAllTags(_address);
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
     * @dev  First part of the 2 step process to set a new tag provider. First, the new provider address is proposed and saved, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in this contract.
     * @param _newProvider Address of the new provider
     */
    function proposeTagsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE) {
        if (_newProvider == address(0)) revert ZeroAddress();
        newTagsProviderAddress = _newProvider;
    }

    /**
     * @dev Get the address of the tag provider
     * @return provider Address of the provider
     */
    function getTagProvider() external view returns (address) {
        return address(tags);
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

    /**
     * @dev Check Application Rules for valid transactions.
     * @param _tokenAddress address of the token calling the rule check
     * @param _sender address of the calling account passed through from the token 
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens to be transferred
     * @param _nftValuationLimit number of tokenID's per collection before checking collection price vs individual token price
     * @param _tokenId tokenId of the NFT token
     * @param _action Action to be checked
     * @param _handlerType type of handler calling checkApplicationRules function
     */
    function checkApplicationRules(
        address _tokenAddress,
        address _sender,
        address _from,
        address _to,
        uint256 _amount,
        uint16 _nftValuationLimit,
        uint256 _tokenId,
        ActionTypes _action,
        HandlerTypes _handlerType
    ) external onlyHandler {
        if (applicationHandler.requireApplicationRulesChecked(_action, _sender)) {
            applicationHandler.checkApplicationRules(_tokenAddress, _sender, _from, _to, _amount, _nftValuationLimit, _tokenId, _action, _handlerType);
        }
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
     * @dev Checks if _msgSender() is a registered handler
     */
    modifier onlyHandler() {
        if (!isRegisteredHandler(_msgSender())) revert NotRegisteredHandler(_msgSender());
        _;
    }

    /**
     * @dev This function allows the devs to register their token contract addresses. This keeps everything in sync and will aid with the token factory and application level balance checks.
     * @notice This function will try to call supportsInterface on registered address. If token does not support ERC165 it is assumed to be ERC20. 
     * Use UpdateRegisteredToken() to register an ERC721 token that does not support ERC165 interface. 
     * @param _token The token identifier(may be NFT or ERC20)
     * @param _tokenAddress Address corresponding to the tokenId
     */
    function registerToken(string calldata _token, address _tokenAddress) public onlyRole(APP_ADMIN_ROLE) {
        uint8 tokenType; 
        if (_tokenAddress == address(0)) revert ZeroAddress();
        tokenToAddress[_token] = _tokenAddress;
        addressToToken[_tokenAddress] = _token;
        if (!isTokenRegistered[_tokenAddress]) {
            _addAddressWithMapping(tokenList, tokenToIndex, isTokenRegistered, _tokenAddress);
            registeredHandlers[ProtocolTokenCommon(_tokenAddress).getHandlerAddress()] = true;
            /// check that the registering token supports the ERC165 interface ID for IERC721 
            try IERC165(_tokenAddress).supportsInterface(0x80ac58cd) returns (bool isERC721) {
                if (isERC721){
                    // tokenType is a parameter for event 
                    tokenType = 1;
                    emit AD1467_TokenRegistered(_token, _tokenAddress, tokenType);
                } else {
                    // tokenType is a parameter for event 
                    tokenType = 0;
                    emit AD1467_TokenRegistered(_token, _tokenAddress, tokenType);
                }
            } catch {
                // tokenType is a parameter for event 
                tokenType = 0;
                emit AD1467_TokenRegistered(_token, _tokenAddress, tokenType);
            }
        } else emit AD1467_TokenNameUpdated(_token, _tokenAddress);
    }

    /**
     * @dev This function Updates the Registered Token to an ERC721 token that does not support ERC165 interface. 
     * @notice Token type is not stored on chain and is only to update events parameters for off chain databasing. 
     * @param _token The token identifier of registered token
     * @param _tokenAddress Address corresponding to the tokenId
     * @param _tokenType The token type to update registered token
     */
    function updateRegisteredToken(string calldata _token, address _tokenAddress, uint8 _tokenType) external onlyRole(APP_ADMIN_ROLE) {
        registerToken(_token, _tokenAddress); 
        emit AD1467_TokenRegistered(_token, _tokenAddress, _tokenType);
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
        if (!isTokenRegistered[tokenAddress]) revert NoAddressToRemove();
        _removeAddressWithMapping(tokenList, tokenToIndex, isTokenRegistered, tokenAddress);
        delete tokenToAddress[_tokenId];
        delete addressToToken[tokenAddress];
        /// also remove its handler from the registration
        delete registeredHandlers[ProtocolTokenCommon(tokenAddress).getHandlerAddress()];
        emit AD1467_RemoveFromRegistry(_tokenId, tokenAddress);
    }

    /**
     * @dev This function removes an address from a dynamic address array by putting the last element in the one to remove and then removing last element.
     * @param _addressArray The array to have an address removed
     * @param _addressToIndex mapping that keeps track of the indexes in the list by address
     * @param _registerFlag mapping that keeps track of the addresses that are members of the list
     * @param _address The address to remove
     */
    function _removeAddressWithMapping(address[] storage _addressArray, mapping(address => uint) storage _addressToIndex, mapping(address => bool) storage _registerFlag, address _address) private {
        /// we store the last address in the array on a local variable to avoid unnecessary costly memory reads
        address LastAddress = _addressArray[_addressArray.length - 1];
        /// we check if we're trying to remove the last address in the array since this means we can skip some steps
        if (_address != LastAddress) {
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
     * @dev This function adds an address to a dynamic address array and takes care of the mappings.
     * @param _addressArray The array to have an address added
     * @param _addressToIndex mapping that keeps track of the indexes in the list by address
     * @param _registerFlag mapping that keeps track of the addresses that are members of the list
     * @param _address The address to add
     */
    function _addAddressWithMapping(address[] storage _addressArray, mapping(address => uint) storage _addressToIndex, mapping(address => bool) storage _registerFlag, address _address) private {
        _addressToIndex[_address] = _addressArray.length;
        _registerFlag[_address] = true;
        _addressArray.push(_address);
    }

    /**
     * @dev manage the approve list for trading-rule bypasser accounts
     * @param _address account in the list to manage
     * @param isApproved set to true to indicate that _address can bypass trading rules.
     */
    function approveAddressToTradingRuleAllowlist(address _address, bool isApproved) external onlyRole(APP_ADMIN_ROLE) {
        if (!isApproved) {
            if (!isTradingRuleAllowlisted[_address]) revert NoAddressToRemove();
            _removeAddressWithMapping(tradingRuleAllowList, tradingRuleAllowlistAddressToIndex, isTradingRuleAllowlisted, _address);
        } else {
            if (isTradingRuleAllowlisted[_address]) revert AddressAlreadyRegistered();
            _addAddressWithMapping(tradingRuleAllowList, tradingRuleAllowlistAddressToIndex, isTradingRuleAllowlisted, _address);
        }
        emit AD1467_TradingRuleAddressAllowlist(_address, isApproved);
    }

    /**
     * @dev tells if an address can bypass trading rules
     * @param _address the address to check for
     * @return true if the address can bypass trading rules, or false otherwise.
     */
    function isTradingRuleBypasser(address _address) public view returns (bool) {
        return isTradingRuleAllowlisted[_address];
    }

    /**
     * @dev Getter for the access level contract address
     * @return AccessLevelDataAddress
     */
    function getAccessLevelDataAddress() external view returns (address) {
        return address(accessLevels);
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
     * @return tagsDataAddress
     */
    function getTagsDataAddress() external view returns (address) {
        return address(tags);
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
        emit AD1467_HandlerConnected(applicationHandlerAddress, address(this));
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
        emit AD1467_AppNameChanged(appName);
    }

    /**
     * @dev Getter for application Name
     * @return appName
     */
    function getAppName() external view returns(string memory) {
        return appName;
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
        accessLevels = new AccessLevels(address(this));
        riskScores = new RiskScores(address(this));
        tags = new Tags(address(this));
        pauseRules = new PauseRules(address(this));
    }

    /**
     * @dev This function is used to propose the new owner for data contracts.
     * @param _newOwner address of the new AppManager
     */
    function proposeDataContractMigration(address _newOwner) external nonReentrant onlyRole(APP_ADMIN_ROLE) {
        DataModule(address(accessLevels)).proposeOwner(_newOwner);
        DataModule(address(riskScores)).proposeOwner(_newOwner);
        DataModule(address(tags)).proposeOwner(_newOwner);
        DataModule(address(pauseRules)).proposeOwner(_newOwner);
        // Disabling this finding, it is a false positive. A reentrancy lock modifier has been
        // applied to this function
        // slither-disable-next-line reentrancy-events
        emit AD1467_AppManagerDataUpgradeProposed(_newOwner, address(this));
    }

    /**
     * @dev This function is used to confirm this contract as the new owner for data contracts.
     */
    function confirmDataContractMigration(address _oldAppManagerAddress) external nonReentrant onlyRole(APP_ADMIN_ROLE) {
        AppManager oldAppManager = AppManager(_oldAppManagerAddress);
        accessLevels = IAccessLevels(oldAppManager.getAccessLevelDataAddress());
        riskScores = RiskScores(oldAppManager.getRiskDataAddress());
        tags = Tags(oldAppManager.getTagsDataAddress());
        pauseRules = PauseRules(oldAppManager.getPauseRulesDataAddress());
        DataModule(address(accessLevels)).confirmOwner();
        DataModule(address(riskScores)).confirmOwner();
        DataModule(address(tags)).confirmOwner();
        DataModule(address(pauseRules)).confirmOwner();
        // Disabling this finding, it is a false positive. A reentrancy lock modifier has been
        // applied to this function
        // slither-disable-next-line reentrancy-events
        emit AD1467_DataContractsMigrated(address(this));
    }

    /**
     * @dev Part of the two step process to set a new Data Provider within a Protocol AppManager. Final confirmation called by new provider
     * @param _providerType the type of data provider
     */
    function confirmNewDataProvider(IDataEnum.ProviderType _providerType) external {
        if (_providerType == IDataEnum.ProviderType.TAG) {
            if (newTagsProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (_msgSender() != newTagsProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            tags = ITags(newTagsProviderAddress);
            emit AD1467_TagProviderSet(newTagsProviderAddress);
            delete newTagsProviderAddress;
        } else if (_providerType == IDataEnum.ProviderType.RISK_SCORE) {
            if (newRiskScoresProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (_msgSender() != newRiskScoresProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            riskScores = IRiskScores(newRiskScoresProviderAddress);
            emit AD1467_RiskProviderSet(newRiskScoresProviderAddress);
            delete newRiskScoresProviderAddress;
        } else if (_providerType == IDataEnum.ProviderType.ACCESS_LEVEL) {
            if (newAccessLevelsProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (_msgSender() != newAccessLevelsProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            accessLevels = IAccessLevels(newAccessLevelsProviderAddress);
            emit AD1467_AccessLevelProviderSet(newAccessLevelsProviderAddress);
            delete newAccessLevelsProviderAddress;
        } else if (_providerType == IDataEnum.ProviderType.PAUSE_RULE) {
            if (newPauseRulesProviderAddress == address(0)) revert NoProposalHasBeenMade();
            if (_msgSender() != newPauseRulesProviderAddress) revert ConfirmerDoesNotMatchProposedAddress();
            pauseRules = IPauseRules(newPauseRulesProviderAddress);
            emit AD1467_PauseRuleProviderSet(newPauseRulesProviderAddress);
            delete newPauseRulesProviderAddress;
        }
    }
}
