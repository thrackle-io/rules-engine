// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title Application NFT Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an example for how to implement the ProtocolERC721Handler. All ERC721 rules are set up through this contract
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */
import "../token/ProtocolERC721Handler.sol";

contract ApplicationERC721Handler is ProtocolERC721Handler {

    enum OracleAction{ START_STAKING, CHECK_STATUS, CLAIM_STAKING}

    /// RuleIds for implemented tagged rules of the ERC721
    uint32 private statusOracleRuleId;
    /// on-off switches for rules
    bool private statusOracleRuleActive;

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _ruleProcessorProxyAddress Address of Token Rule Router Proxy
     * @param _appManagerAddress Address of App Manager
     * @param _assetAddress Address of the controlling address
     * @param _upgradeMode specifies whether this is a fresh Handler or an upgrade replacement.
     */
    constructor(
        address _ruleProcessorProxyAddress,
        address _appManagerAddress,
        address _assetAddress,
        bool _upgradeMode
    ) ProtocolERC721Handler(_ruleProcessorProxyAddress, _appManagerAddress, _assetAddress, _upgradeMode) {}


    function startSoftStaking(address holder, address tokenAddress, uint256 tokenId) external onlyOwner {
        if (statusOracleRuleActive) ruleProcessor.checkStatusOraclePasses(oracleRuleId, holder, tokenAddress, tokenId, OracleAction.START_STAKING);
    }

    function checkStakingStatus(address holder, address tokenAddress, uint256 tokenId) external onlyOwner {
        if (statusOracleRuleActive) ruleProcessor.checkOraclePasses(oracleRuleId, holder, tokenAddress, tokenId,  OracleAction.CHECK_STATUS);
    }

    function claimStaking(address holder, address tokenAddress, uint256 tokenId) external onlyOwner {
        if (statusOracleRuleActive) ruleProcessor.checkOraclePasses(oracleRuleId, holder, tokenAddress, tokenId,  OracleAction.CLAIM_STAKING);
    } 

    /**
     * @dev Set the minMaxBalanceRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setStatusOracleRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateStatusOracle(_ruleId);
        statusOracleRuleId = _ruleId;
        statusOracleRuleActive = true;
        emit ApplicationHandlerApplied(STATUS_ORACLE, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateStatusOracleRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        statusOracleRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(STATUS_ORACLE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(STATUS_ORACLE, address(this));
        }
    }

    /**
     * Get the minMaxBalanceRuleId.
     * @return minMaxBalance rule id.
     */
    function getStatusOracleRuleId() external view returns (uint32) {
        return statusOracleRuleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isStatusOracleActive() external view returns (bool) {
        return statusOracleRuleActive;
    }
}
