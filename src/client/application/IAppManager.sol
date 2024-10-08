// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {ActionTypes} from "src/common/ActionEnum.sol";
import "src/client/application/data/PauseRule.sol";
import "src/client/token/HandlerTypeEnum.sol";
import "src/client/application/data/IDataEnum.sol";
import {IAppManagerErrors, IPermissionModifierErrors, IInputErrors, IZeroAddressError, IOwnershipErrors} from "src/common/IErrors.sol";

/**
 * @title App Manager Inquiry Interface
 * @dev This interface is a lightweight counterpart to AppManager. It should be used by calling contracts that only need inquiry actions
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice Interface for app manager server functions.
 */
interface IAppManager is IAppManagerErrors, IPermissionModifierErrors, IInputErrors, IZeroAddressError, IOwnershipErrors {
    /**
     * @dev This function is where the super admin role is actually checked
     * @param account address to be checked
     * @return success true if admin, false if not
     */
    function isSuperAdmin(address account) external view returns (bool);

    /**
     * @dev This function is where the app administrator role is actually checked
     * @param account address to be checked
     * @return success true if app administrator, false if not
     */
    function isAppAdministrator(address account) external view returns (bool);

    /**
     * @dev This function is where the rule administrator role is actually checked
     * @param account address to be checked
     * @return success true if rule administrator, false if not
     */
    function isRuleAdministrator(address account) external view returns (bool);

    /**
     * @dev This function is where the rTreasury account role is actually checked
     * @param account address to be checked
     * @return success true if TREASURY_ACCOUNT, false if not
     */
    function isTreasuryAccount(address account) external view returns (bool);

    /**
     * @dev This function is where the access level admin role is actually checked
     * @param account address to be checked
     * @return success true if ACCESS_LEVEL_ADMIN_ROLE, false if not
     */
    function isAccessLevelAdmin(address account) external view returns (bool);

    /**
     * @dev This function is where the risk admin role is actually checked
     * @param account address to be checked
     * @return success true if RISK_ADMIN_ROLE, false if not
     */
    function isRiskAdmin(address account) external view returns (bool);

    /**
     * @dev Get all the tags for the address
     * @param _address Address to retrieve the tags
     * @return tags Array of all tags for the account
     */
    function getAllTags(address _address) external view returns (bytes32[] memory);

    /**
     * @dev Get the AccessLevel Score for the specified account
     * @param _account address of the user
     * @return
     */
    function getAccessLevel(address _account) external view returns (uint8);

    /**
     * @dev Get the Risk Score for an account.
     * @param _account address upon which the risk score was set
     * @return score risk score(0-100)
     */
    function getRiskScore(address _account) external view returns (uint8);

    /**
     * @dev Get all pause rules for the token
     * @return PauseRule An array of all the pause rules
     */
    function getPauseRules() external view returns (PauseRule[] memory);

    /**
     * @dev Check to see if an account has a specific general tag
     * @param _account Address to check
     * @param _tag Tag to be checked for
     * @return success true if account has the tag, false if it does not
     */
    function hasTag(address _account, bytes32 _tag) external view returns (bool);

    /**
     * @dev Get the address of the access level provider
     * @return accessLevelProvider Address of the access level provider
     */
    function getAccessLevelProvider() external view returns (address);

    /**
     * @dev This function allows the devs to register their token contract addresses. This keeps everything in sync and will aid with the token factory
     * @param _tokenId The token id(may be NFT or ERC20)
     * @param _tokenAddress Address corresponding to the tokenId
     */
    function registerToken(string calldata _tokenId, address _tokenAddress) external;

    /**
     * @dev This function allows the devs to deregister a token contract address. This keeps everything in sync and will aid with the token factory
     * @param _tokenId The token id(may be NFT or ERC20)
     */
    function deregisterToken(string calldata _tokenId) external;

    /**
     * @dev Return a the token list for calculation purposes
     * @return tokenList list of all tokens registered
     */
    function getTokenList() external view returns (address[] memory);

    /**
     * @dev This function gets token identification string.
     * @param _tokenAddress the address of the contract of the token to query
     * @return the identification string.
     */
    function getTokenID(address _tokenAddress) external view returns (string memory);

    /**
     * @dev manage the allowlist for trading-rule bypasser accounts
     * @param _address account in the list to manage
     * @param isApproved set to true to indicate that _address can bypass trading rules.
     */
    function approveAddressToTradingRuleAllowlist(address _address, bool isApproved) external;

    /**
     * @dev tells if an address can bypass trading rules
     * @param _address the address to check for
     * @return true if the address can bypass trading rules, or false otherwise.
     */
    function isTradingRuleBypasser(address _address) external view returns (bool);

    /**
     * @dev Jump through to the gobal rules to see if the requested action is valid.
     * @param _tokenAddress address of the token calling the rule check 
     * @param _sender address of the calling account passed through from the token
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount amount of tokens to be transferred 
     * @param _nftValuationLimit number of tokenID's per collection before checking collection price vs individual token price
     * @param _tokenId tokenId of the NFT token 
     * @param _action Action to be checked
     * @param _handlerType type of handler calling checkApplicationRules function 
     */
    function checkApplicationRules(address _tokenAddress, address _sender, address _from, address _to, uint256 _amount, uint16 _nftValuationLimit, uint256 _tokenId, ActionTypes _action, HandlerTypes _handlerType) external;


    /**
     * @dev Part of the two step process to set a new Data Provider within a Protocol AppManager. Final confirmation called by new provider
     * @param _providerType the type of data provider
     */
    function confirmNewDataProvider(IDataEnum.ProviderType _providerType) external;
}
