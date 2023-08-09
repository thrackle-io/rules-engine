// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Protocol Events Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library for all events in the Protocol module for the protocol. Each contract in the Protocol module should inherit this library for emitting events.
 * @notice Protocol Module Events Library
 */

interface IAppLevelEvents {
    ///AppManager
    event HandlerConnected(address indexed handlerAddress, address indexed appManager); 
    event RoleCheck(string contractName, string functionName, address checkedAddress, bytes32 checkedRole);
    event AppManagerDeployed(address indexed deployedAddress);
    event AppManagerDeployedForUpgrade(address indexed deployedAddress);
    event AppManagerUpgrade(address indexed deployedAddress, address replacedAddress);
    event RemoveFromRegistry(string contractName, address contractAddress);
    event RiskAdmin(address indexed admin, bool indexed add);
    event AccessTierAdmin(address indexed admin, bool indexed add);
    event AppAdministrator(address indexed admin, bool indexed add); 
    ///Accounts
    event AccountAdded(address indexed account, uint256 date);
    event AccountRemoved(address indexed account, uint256 date);
    ///GeneralTags
    event GeneralTag(address indexed _address, bytes32 indexed _tag, bool indexed add); 
    event TagAlreadyApplied(address indexed _address);
    ///AccessLevels
    event AccessLevelAdded(address indexed _address, uint8 indexed _level, uint256 date);
    event AccessLevelRemoved(address indexed _address, uint256 date);
    ///PauseRules
    event PauseRuleEvent(uint256 indexed pauseStart, uint256 indexed pauseStop, bool indexed add);
    ///RiskScores
    event RiskScoreAdded(address indexed _address, uint8 _score, uint256 date);
    event RiskScoreRemoved(address indexed _address, uint256 date);
}

/**
 * @title Application Handler Events Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library for all events in the Protocol module for the protocol. Each contract in the Protocol module should inherit this library for emitting events.
 * @notice Protocol Module Events Library
 */

interface IApplicationHandlerEvents {
    event ApplicationHandlerDeployed(address indexed deployedAddress, address indexed appManager);
    // Rule applied
    event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);
}

/**
 *@title Rule Storage Diamond Events Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library for all events in the Rule Processor Module for the protocol. Each contract in the access module should inherit this library for emitting events.
 * @notice Rule Processor Module Events Library
 */
interface IRuleStorageDiamondEvents {
    ///RuleStorageDiamond
    event RuleStorageDiamondDeployed(address indexed econRuleDiamond);
}

/**
 * @title Economic Events Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library for all events in the Rule Processor Module for the protocol. Each contract in the access module should inherit this library for emitting events.
 * @notice Rule Processor Module Events Library
 */

interface IEconomicEvents {
    /// Generic Rule Creation Event
    event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags);
    ///TokenRuleRouterProxy
    event newHandler(address indexed Handler);
}

/**
 * @title Tokem Handler Events Interface
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library for all protocol Handler Events. Each contract in the access module should inherit this library for emitting events.
 * @notice Handler Events Library
 */
interface ITokenHandlerEvents {
    ///Handler
    event HandlerDeployed(address indexed applicationHandler, address indexed appManager);
    event HandlerDeployedForUpgrade(address indexed applicationHandler, address indexed appManager);
    /// Rule applied
    event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId);
    event ApplicationHandlerSimpleApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint256 indexed param1);

    /// Rule deactivated
    event ApplicationHandlerDeactivated(bytes32 indexed ruleType, address indexed handlerAddress);
    /// Rule activated
    event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress);
}

interface IOracleEvents{
    event AllowedAddress(address indexed addr);
    event NotAllowedAddress(address indexed addr);
    event AllowListOracleDeployed();
     event SanctionedAddress(address indexed addr);
    event NonSanctionedAddress(address indexed addr);
    event SanctionedListOracleDeployed();
    event OracleListChanged(bool indexed add, address[] addresses); // new event
}


/**
 * @title Application Events
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This library for all events for the Application ecosystems. Each Contract should inherit this library for emitting events.
 * @notice Application Events Library
 */

interface IApplicationEvents {
    /// Application Handler
    event HandlerConnected(address indexed handlerAddress, address indexed assetAddress); // ...in favor of this one since regular deploy and upgrade now looks the same?
    ///ProtocolERC20
    event NewTokenDeployed(address indexed applicationCoin, address indexed appManagerAddress);
    ///ProtocolERC721 & ERC721A
    event NewNFTDeployed(address indexed applicationNFT, address indexed appManagerAddress);
    ///ERC20Staking & ERC20AutoMintStaking
    event ERC20StakingDeployed(address indexed stakingAddress);
    event NewStake(address indexed staker, uint256 indexed staked, uint256 stakingPeriodInSeconds, uint256 indexed stakingSince);
    event RewardsClaimed(address indexed staker, uint256 indexed staked, uint256 rewards, uint256 indexed stakingSince, uint256 date);
    event StakeWithdrawal(address indexed staker, uint256 indexed amount, uint256 date);
    ///ERC721Staking & ERC721 AutoMintStaking
    event ERC721StakingDeployed(address indexed stakingAddress);
    event NewStakeERC721(address indexed staker, uint256 indexed tokenId, uint256 stakingPeriodInSeconds, uint256 indexed stakingSince);
    event RewardsClaimedERC721(address indexed staker, uint256 indexed tokenId, uint256 rewards, uint256 indexed stakingSince, uint256 date);
    event StakeWithdrawalERC721(address indexed staker, uint256 indexed tokenId, uint256 date);
    event NewStakingAddress(address indexed newStakingAddress);
    ///AMM
    event AMMDeployed(address indexed ammAddress);
    event Swap(address indexed tokenIn, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(address token0, address token1, uint256 amount0, uint256 amount1);
    event RemoveLiquidity(address token, uint256 amount);
    ///ERC20Pricing
    event TokenPrice(address indexed token, uint256 indexed price);
    ///NFTPricing
    event SingleTokenPrice(address indexed collection, uint256 indexed tokenID, uint256 indexed price);
    event CollectionPrice(address indexed collection, uint256 indexed price);
    ///Fees
    event FeeType(bytes32 indexed tag, bool indexed add, uint256 minBalance, uint256 maxBalance, int256 feePercentage, address targetAccount);
}

interface IERC20StakingEvents {

    event NewStake(address indexed staker, uint256 indexed staked, uint256 stakingPeriodInSeconds, uint256 indexed stakingSince);
    event RewardsClaimed(address indexed staker, uint256 indexed staked, uint256 rewards, uint256 indexed stakingSince, uint256 date);
    event StakeWithdrawal(address indexed staker, uint256 indexed amount, uint256 date);
    event ERC20StakingFixedDeployed(address indexed appManagerAddress, address indexed stakingToken,address indexed rewardToken,bool autoMinting);
    }

interface IERC721StakingEvents {
    event NewStake(address indexed staker, uint256 indexed tokenId, uint256 stakingPeriodInSeconds, uint256 indexed stakingSince);
    event RewardsClaimed(address indexed staker, uint256 indexed tokenId, uint256 rewards, uint256 indexed stakingSince, uint256 date);
    event StakeWithdrawal(address indexed staker, uint256 indexed tokenId, uint256 date);
    event NewStakingAddress(address indexed newStakingAddress);
    event ERC721StakingFixedDeployed(address indexed appManagerAddress,address[] indexed stakingTokens,address indexed rewardToken, bool autoMinting);
}
