// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

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

    /**
     * @dev Constructor that sets the app manager address used for permissions. This is required for upgrades.
     * @param _dataModuleAppManagerAddress address of the owning app manager
     */
    constructor(address _dataModuleAppManagerAddress) DataModule(dataModuleAppManagerAddress) {
        dataModuleAppManagerAddress = _dataModuleAppManagerAddress;
        _transferOwnership(dataModuleAppManagerAddress);
    }

    /**
     * @dev Add the risk score to the account. Restricted to the owner
     * @param _address address of the account
     * @param _score risk score (0-100)
     */
    function addScore(address _address, uint8 _score) public virtual onlyOwner {
        if (_score > 100) revert riskScoreOutOfRange(_score);
        scores[_address] = _score;
        emit RiskScoreAdded(_address, _score, block.timestamp);
    }

    /**
     * @dev  Add the Risk Score to each address in array. Restricted to Risk Admins.
     * @param _accounts address array upon which to apply the Risk Score
     * @param _score Risk Score(0-100)
     */
    function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external virtual onlyOwner {
        if (_score > 100) revert riskScoreOutOfRange(_score);
        for (uint256 i; i < _accounts.length; ) {
            scores[_accounts[i]] = _score;
            emit RiskScoreAdded(_accounts[i], _score, block.timestamp);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Remove the risk score for the account. Restricted to the owner
     * @param _account address of the account
     */
    function removeScore(address _account) external virtual onlyOwner {
        delete scores[_account];
        emit RiskScoreRemoved(_account, block.timestamp);
    }

    /**
     * @dev Get the risk score for the account. Restricted to the owner
     * @param _account address of the account
     */
    function getRiskScore(address _account) external view virtual onlyOwner returns (uint8) {
        return scores[_account];
    }
}
