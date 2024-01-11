// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "src/client/token/ProtocolHandlerCommon.sol";

/**
 * @title ProtocolAMMHandler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs rule checks related to the the AMM that implements it.
 * @notice Any rules may be updated by modifying this contract and redeploying.
 */

contract ProtocolAMMHandler is Ownable, ProtocolHandlerCommon {
    /// Mapping lastUpdateTime for most recent previous tranaction through Protocol
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) purchasedWithinPeriod;
    mapping(address => uint256) salesWithinPeriod;
    mapping(address => uint64) lastSellTime;

    address public ruleProcessorAddress;
    uint64 public previousPurchaseTime;
    uint64 public previousSellTime;
    uint256 private totalPurchasedWithinPeriod; /// total number of tokens purchased in period
    uint256 private totalSoldWithinPeriod; /// total number of tokens purchased in period

    IERC20 public token;

    /// Rule ID's
    uint32 private minTransferRuleId;
    uint32 private minMaxBalanceRuleIdToken0;
    uint32 private minMaxBalanceRuleIdToken1;
    uint32 private oracleRuleId;

    /// Rule Activation Bools
    bool private minTransferRuleActive;
    bool private oracleRuleActive;
    bool private minMaxBalanceRuleActive;

    /**
     * @dev Constructor sets the App Manager andToken Rule Router Address
     * @param _appManagerAddress Application App Manager Address
     * @param _ruleProcessorProxyAddress Rule Processor Address
     * @param _assetAddress address of the controlling asset
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _appManagerAddress, address _ruleProcessorProxyAddress,address _assetAddress, bool _upgradeMode) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        transferOwnership(_assetAddress);
        ruleProcessorAddress = _ruleProcessorProxyAddress;
        if (!_upgradeMode) {
            deployDataContract();
            emit HandlerDeployed(_appManagerAddress);
        } else {
            emit HandlerDeployed(_appManagerAddress);
        }
    }

    /**
     * @dev Function mirrors that of the checkRuleStorages. This is the rule check function to be called by the AMM.
     * @param token0BalanceFrom token balance of sender address
     * @param token1BalanceFrom token balance of sender address
     * @param _from sender address
     * @param _to recipient address
     * @param token_amount_0 number of tokens transferred
     * @param token_amount_1 number of tokens received
     * @return Success equals true if all checks pass
     */
    function checkAllRules(
        uint256 token0BalanceFrom,
        uint256 token1BalanceFrom,
        address _from,
        address _to,
        uint256 token_amount_0,
        uint256 token_amount_1,
        address _tokenAddress
    ) external onlyOwner returns (bool) {
        bool isFromBypassAccount = appManager.isRuleBypassAccount(_from);
        bool isToBypassAccount = appManager.isRuleBypassAccount(_to);
        // // All transfers to treasury account are allowed
        if (!appManager.isTreasury(_to)) {
            /// standard tagged and  rules do not apply when either to or from is an admin
            if (!isFromBypassAccount && !isToBypassAccount) {
            //appManager.checkApplicationRules( _to, _from, 0, 0, _action); /// WE DON'T WANT TO DOUBLE CHECK APP RULES. THIS IS DONE AT THE TOKEN LEVEL
            _checkTaggedRules(token0BalanceFrom, token1BalanceFrom, _from, _to, token_amount_0, token_amount_1);
            _checkNonTaggedRules(token0BalanceFrom, token1BalanceFrom, _from, _to, token_amount_0, token_amount_1, _tokenAddress);
            } else {
                emit RulesBypassedViaRuleBypassAccount(address(msg.sender), appManagerAddress);
            }
        }
        return true;
    }

    /**
     * @dev Rule tracks all purchases by account for purchase Period, the timestamp of the most recent purchase and purchases are within the purchase period.
     * @param _token0BalanceFrom token balance of sender address
     * @param _token1BalanceFrom token balance of sender address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _token_amount_0 number of tokens transferred
     * @param _token_amount_1 number of tokens received
     */
    function _checkTaggedRules(
        uint256 _token0BalanceFrom,
        uint256 _token1BalanceFrom,
        address _from,
        address _to,
        uint256 _token_amount_0,
        uint256 _token_amount_1
    ) internal {
        /// We get all tags for sender and recipient
        bytes32[] memory toTags = appManager.getAllTags(_to);
        bytes32[] memory fromTags = appManager.getAllTags(_from);
        address purchaseAccount = _to;
        address sellerAccount = _from;
        /// Pass in fromTags twice because AMM address will not have tags applied (AMM Address is address_to).
        if (minMaxBalanceRuleActive) {
            ///Token 0
            ruleProcessor.checkMinMaxAccountBalancePassesAMM(minMaxBalanceRuleIdToken0, minMaxBalanceRuleIdToken1, _token0BalanceFrom, _token1BalanceFrom, _token_amount_0, _token_amount_1, fromTags);
            ruleProcessor.checkMinMaxAccountBalancePassesAMM(minMaxBalanceRuleIdToken1, minMaxBalanceRuleIdToken0, _token1BalanceFrom, _token0BalanceFrom, _token_amount_1, _token_amount_0, fromTags);
        }
    }

    /**
     * @dev Rule tracks all sales by account for sell Period, the timestamp of the most recent sale and sales are within the sell period.
     * @param _token0BalanceFrom token balance of sender address
     * @param _token1BalanceFrom token balance of sender address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _token_amount_0 number of tokens transferred
     * @param _token_amount_1 number of tokens received
     */
    function _checkNonTaggedRules(
        uint256 _token0BalanceFrom,
        uint256 _token1BalanceFrom,
        address _from,
        address _to,
        uint256 _token_amount_0,
        uint256 _token_amount_1,
        address _tokenAddress
    ) internal {
        if (minTransferRuleActive) ruleProcessor.checkMinTransferPasses(minTransferRuleId, _token_amount_0);
        if (oracleRuleActive) ruleProcessor.checkOraclePasses(oracleRuleId, _from);
        ///silencing unused variable warnings
        _to;
        _token0BalanceFrom;
        _token1BalanceFrom;
        _token_amount_1;
    }

    /*********************************          Rule Setters and Getter            ********************************/

    /**
     *@dev this function gets the total supply of the address.
     *@param _token address of the token to call totalSupply() of.
     */
    function getTotalSupply(address _token) internal view returns (uint256) {
        return IERC20(_token).totalSupply();
    }

    /**
     * @dev Set the minTransferRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinTransferRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        minTransferRuleId = _ruleId;
        minTransferRuleActive = true;
        emit ApplicationHandlerApplied(MIN_TRANSFER, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransferRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minTransferRuleActive = _on;
    }

    /**
     * @dev Retrieve the minTransferRuleId
     * @return minTransferRuleId
     */
    function getMinTransferRuleId() external view returns (uint32) {
        return minTransferRuleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinTransferActive() external view returns (bool) {
        return minTransferRuleActive;
    }

    /**
     * @dev Set the minMaxBalanceRuleId for token 0. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleIdToken0(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleIdToken0 = _ruleId;
        minMaxBalanceRuleActive = true;
    }

    /**
     * @dev Set the minMaxBalanceRuleId for Token 1. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleIdToken1(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleIdToken1 = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleActive = _on;
    }

    /**
     * Get the minMaxBalanceRuleIdToken0.
     * @return minMaxBalance rule id for token 0.
     */
    function getMinMaxBalanceRuleIdToken0() external view returns (uint32) {
        return minMaxBalanceRuleIdToken0;
    }

    /**
     * Get the minMaxBalanceRuleId for token 1.
     * @return minMaxBalance rule id for token 1.
     */
    function getMinMaxBalanceRuleIdToken1() external view returns (uint32) {
        return minMaxBalanceRuleIdToken1;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinMaxBalanceActive() external view returns (bool) {
        return minMaxBalanceRuleActive;
    }

    /**
     * @dev Set the oracleRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setOracleRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        oracleRuleId = _ruleId;
        oracleRuleActive = true;
        emit ApplicationHandlerApplied(ORACLE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateOracleRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        oracleRuleActive = _on;
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return oracleRuleId
     */
    function getOracleRuleId() external view returns (uint32) {
        return oracleRuleId;
    }

    /**
     * @dev Tells you if the Oracle Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isOracleActive() external view returns (bool) {
        return oracleRuleActive;
    }


    /// -------------DATA CONTRACT DEPLOYMENT---------------
    /**
     * @dev Deploy all the child data contracts. Only called internally from the constructor.
     */
    function deployDataContract() private {
        fees = new Fees();
    }

    /**
     * @dev Getter for the fee rules data contract address
     * @return feesDataAddress
     */
    function getFeesDataAddress() external view returns (address) {
        return address(fees);
    }

    /**
     * @dev This function is used to propose the new owner for data contracts.
     * @param _newOwner address of the new AppManager
     */
    function proposeDataContractMigration(address _newOwner) external appAdministratorOrOwnerOnly(appManagerAddress) {
        fees.proposeOwner(_newOwner);
    }

    /**
     * @dev This function is used to confirm this contract as the new owner for data contracts.
     */
    function confirmDataContractMigration(address _oldHandlerAddress) external appAdministratorOrOwnerOnly(appManagerAddress) {
        ProtocolAMMHandler oldHandler = ProtocolAMMHandler(_oldHandlerAddress);
        fees = Fees(oldHandler.getFeesDataAddress());
        fees.confirmOwner();
    }
}
