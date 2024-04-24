// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./DataModule.sol";
import "./IRiskScores.sol";

/**
 * @title Risk Scores Data Contract
 * @notice Data contract to store risk scores for user accounts
 * @dev This contract stores and serves risk scores via an internal mapping
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract RiskScores is IRiskScores, DataModule {
    mapping(address => uint8) public scores;
    uint8 constant MAX_RISK = 100;

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     * @param _dataModuleAppManagerAddress address of the owning app manager
     */
    constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress) {
        _transferOwnership(_dataModuleAppManagerAddress);
    }

    /**
     * @dev Add the risk score to the account. Restricted to the owner
     * @param _address address of the account
     * @param _score risk score (0-100)
     */
    function addScore(address _address, uint8 _score) public virtual onlyOwner {
        if (_score > MAX_RISK) revert riskScoreOutOfRange(_score);
        if (_address == address(0)) revert ZeroAddress();
        scores[_address] = _score;
        emit AD1467_RiskScoreAdded(_address, _score);
    }

    /**
     * @dev  Add the Risk Score at index to Account at index in array. Restricted to Risk Admins.
     * @param _accounts address array upon which to apply the Risk Score
     * @param _scores Risk Score array (0-100)
     */
    function addMultipleRiskScores(address[] memory _accounts, uint8[] memory _scores) external onlyOwner {
        if (_scores.length != _accounts.length) revert InputArraysMustHaveSameLength();
        for (uint256 i; i < _accounts.length; ++i) {
            addScore(_accounts[i], _scores[i]);
        }
    }

    /**
     * @dev  Add the Risk Score to each address in array. Restricted to Risk Admins.
     * @param _accounts address array upon which to apply the Risk Score
     * @param _score Risk Score(0-100)
     */
    function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external virtual onlyOwner {
        if (_score > MAX_RISK) revert riskScoreOutOfRange(_score);
        for (uint256 i; i < _accounts.length; ++i) {
            if (_accounts[i] == address(0)) revert ZeroAddress();
            addScore(_accounts[i], _score);
        }
    }

    /**
     * @dev Remove the risk score for the account. Restricted to the owner
     * @param _account address of the account
     */
    function removeScore(address _account) external virtual onlyOwner {
        delete scores[_account];
        emit AD1467_RiskScoreRemoved(_account);
    }

    /**
     * @dev Get the risk score for the account. Restricted to the owner
     * @param _account address of the account
     */
    function getRiskScore(address _account) external view virtual returns (uint8) {
        return scores[_account];
    }
}
