// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ActionTypes} from "src/common/ActionEnum.sol";

/**
 * @title Protocol Events Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library is for all events in the Protocol. Each contract should inherit thier specific library for emitting events.
 * @notice Protocol Module Events Library
 */


/**
 * @dev The library for all events in the Application module for the protocol.
 * @notice Appliction Module Events Library
 */
interface IAppLevelEvents {
    ///AppManager
    event AD1467_AppManagerDeployed(address indexed superAndAppAdmin, string indexed appName);
    event AD1467_AppManagerDeployedForUpgrade(address indexed superAndAppAdmin, string indexed appName);
    event AD1467_AppManagerDataUpgradeProposed(address indexed deployedAddress, address replacedAddress);
    event AD1467_DataContractsMigrated(address indexed ownerAddress);
    event AD1467_RemoveFromRegistry(string contractName, address contractAddress);
    event AD1467_RuleAdmin(address indexed admin, bool indexed add);
    event AD1467_RiskAdmin(address indexed admin, bool indexed add);
    event AD1467_AccessLevelAdmin(address indexed admin, bool indexed add);
    event AD1467_AppAdministrator(address indexed admin, bool indexed add); 
    event AD1467_SuperAdministrator(address indexed admin, bool indexed add);
    event AD1467_RuleBypassAccount(address indexed bypassAccount, bool indexed add);
    event AD1467_AppNameChanged(string indexed appName);  
    ///Registrations
    event AD1467_TokenRegistered(string indexed _token, address indexed _address);
    event AD1467_TokenNameUpdated(string indexed _token, address indexed _address);
    event AD1467_AMMRegistered(address indexed _address);
    event AD1467_TreasuryRegistered(address indexed _address);
    event AD1467_TradingRuleAddressAllowlist(address indexed _address, bool indexed isApproved);
    ///Accounts
    event AD1467_AccountProviderSet(address indexed _address);
    event AD1467_AccountAdded(address indexed account);
    event AD1467_AccountRemoved(address indexed account);
    ///Tags
    event AD1467_TagProviderSet(address indexed _address);
    event AD1467_Tag(address indexed _address, bytes32 indexed _tag, bool indexed add);
    event AD1467_TagAlreadyApplied(address indexed _address);
    ///AccessLevels
    event AD1467_AccessLevelProviderSet(address indexed _address);
    event AD1467_AccessLevelAdded(address indexed _address, uint8 indexed _level);
    event AD1467_AccessLevelRemoved(address indexed _address);
    ///PauseRules
    event AD1467_PauseRuleProviderSet(address indexed _address);
    event AD1467_PauseRuleEvent(uint256 indexed pauseStart, uint256 indexed pauseStop, bool indexed add);
    ///RiskScores
    event AD1467_RiskProviderSet(address indexed _address);
    event AD1467_RiskScoreAdded(address indexed _address, uint8 _score);
    event AD1467_RiskScoreRemoved(address indexed _address);
}

interface IAppManagerAddressSet{
    event AD1467_AppManagerAddressSet(address indexed _address);
}

/**
 * @dev The library for all events for the Oracle contracts for the protocol.
 * @notice Oracle Events Library
 */
interface IOracleEvents{
    event AD1467_ApprovedAddress(address indexed addr);
    event AD1467_NotApprovedAddress(address indexed addr);
    event AD1467_ApproveListOracleDeployed();
    event AD1467_DeniedAddress(address indexed addr);
    event AD1467_NonDeniedAddress(address indexed addr);
    event AD1467_DeniedListOracleDeployed();
    event AD1467_OracleListChanged(bool indexed add, address[] addresses); // new event
}


/**
 * @dev This library is for all events in the Application Handler module for the protocol.
 * @notice Application Handler Events Library
 */

interface IApplicationHandlerEvents {
    event AD1467_ApplicationHandlerDeployed(address indexed appManager);
    // Rule applied
    event AD1467_ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);
    /// Pricing
    event AD1467_ERC721PricingAddressSet(address indexed _address);
    event AD1467_ERC20PricingAddressSet(address indexed _address);
}

/**
 * @dev This library is for all events in the Common Application Handler for the protocol. Each contract in the Protocol module should inherit this library for emitting events.
 * @notice Common Application Handler Events Library
 */
interface ICommonApplicationHandlerEvents {
    /// Rule deactivated
    event AD1467_ApplicationHandlerDeactivated(bytes32 indexed ruleType);
    /// Rule activated
    event AD1467_ApplicationHandlerActivated(bytes32 indexed ruleType);
    //// Rule Bypassed Via Rule Bypass Account 
    event AD1467_RulesBypassedViaRuleBypassAccount(address indexed ruleBypassAccount, address indexed appManager);
}

/**
 *@title Rule Storage Diamond Events Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library for all events in the Rule Processor Module for the protocol. Each contract in the access module should inherit this library for emitting events.
 * @notice Rule Processor Module Events Library
 */
interface IRuleProcessorDiamondEvents {
    /// Initial deploy of the Rule Processor Diamond
    event AD1467_RuleProcessorDiamondDeployed();
}

/**
 * @dev This library is for all events in the Economic Module for the protocol.
 * @notice Economic Module Events Library
 */
interface IEconomicEvents {
    /// Generic Rule Creation Event
    event AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags);
}

/**
 * @dev This library is for all events in the Handler Diamond.
 * @notice Diamond Handler Events Library
 */
interface IHandlerDiamondEvents {
    event AD1467_HandlerDeployed();
}

/**
 * @dev This library is for all Token Handler Events.
 * @notice Token Handler Events Library
 */
interface ITokenHandlerEvents is IAppManagerAddressSet{
    /// Rule applied
    event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes indexed action, uint32 indexed ruleId);
    event AD1467_ApplicationHandlerActionAppliedFull(bytes32 indexed ruleType, ActionTypes[] indexed actions, uint32[] indexed ruleIds);
    event AD1467_ApplicationHandlerSimpleActionApplied(bytes32 indexed ruleType, ActionTypes action, uint256 indexed param1);
    event AD1467_ApplicationHandlerSimpleActionAppliedFull(bytes32 indexed ruleType, ActionTypes[] action, uint32[] indexed param1);
    /// Rule deactivated
    event AD1467_ApplicationHandlerActionDeactivated(bytes32 indexed ruleType, ActionTypes action);
    /// Rule activated
    event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action);
    /// NFT Valuation Limit Updated
    event AD1467_NFTValuationLimitUpdated(uint256 indexed nftValuationLimit);
    event AD1467_AppManagerAddressProposed(address indexed _address);
    /// Fees
    event AD1467_FeeActivationSet(bool indexed _activation);
    /// Configuration
    event AD1467_ERC721AddressSet(address indexed _address);
}

/**
 * @dev This library for all events for the Application ecosystems.
 * @notice Application Events Library
 */

interface IApplicationEvents is IAppManagerAddressSet{
    /// Application Handler
    event AD1467_HandlerConnected(address indexed handlerAddress, address indexed assetAddress); 
    ///ProtocolERC20
    event AD1467_NewTokenDeployed(address indexed appManagerAddress);
    ///ProtocolERC721 & ERC721A
    event AD1467_NewNFTDeployed(address indexed appManagerAddress);
    ///ERC20Pricing
    event AD1467_TokenPrice(address indexed token, uint256 indexed price);
    ///NFTPricing
    event AD1467_SingleTokenPrice(address indexed collection, uint256 indexed tokenID, uint256 indexed price);
    event AD1467_CollectionPrice(address indexed collection, uint256 indexed price);
    ///Fees
    event AD1467_FeeType(bytes32 indexed tag, bool indexed add, uint256 minBalance, uint256 maxBalance, int256 feePercentage, address targetAccount);
}
