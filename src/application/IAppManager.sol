// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../economic/ruleProcessor/ActionEnum.sol";
import "../data/IDataModule.sol";
import "../data/IPauseRules.sol";
import {IAppManagerErrors, IPermissionModifierErrors, IInputErrors, IZeroAddressError, IOwnershipErrors} from "../interfaces/IErrors.sol";

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
     * @dev This function is where the access tier role is actually checked
     * @param account address to be checked
     * @return success true if ACCESS_TIER_ADMIN_ROLE, false if not
     */
    function isAccessTier(address account) external view returns (bool);

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
     * @dev Get the address of the access levelprovider
     * @return accessLevelProvider Address of the access levelprovider
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
     * @dev This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions
     * @param _AMMAddress Address for the AMM to be registered
     */
    function registerAMM(address _AMMAddress) external;

    /**
     * @dev This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions
     * @param _AMMAddress Address for the AMM
     */
    function isRegisteredAMM(address _AMMAddress) external view returns (bool);

    /**
     * @dev This function allows the devs to deregister an AMM contract address.
     * @param _AMMAddress The address of the AMM to be de-registered
     */
    function deRegisterAMM(address _AMMAddress) external;

    /**
     * @dev This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions
     * @param _treasuryAddress Address for the treasury
     */
    function isTreasury(address _treasuryAddress) external view returns (bool);

    /**
     * @dev Jump through to the gobal rules to see if the requested action is valid.
     * @param _action Action to be checked
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _usdBalanceTo recepient address current total application valuation in USD with 18 decimals of precision
     * @param _usdAmountTransferring valuation of the token being transferred in USD with 18 decimals of precision
     */
    function checkApplicationRules(ActionTypes _action, address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) external;

    /**
     * @dev checks if any of the balance prerequisite rules are active
     * @return true if one or more rules are active
     */
    function requireValuations() external returns (bool);

    /**
     * @dev Part of the two step process to set a new Data Provider within a Protocol AppManager. Final confirmation called by new provider
     * @param _providerType the type of data provider
     */
    function confirmNewDataProvider(IDataModule.ProviderType _providerType) external;
}
