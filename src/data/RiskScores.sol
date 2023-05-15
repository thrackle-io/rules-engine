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
     */
    constructor() {
        dataModuleAppManagerAddress = owner();
    }

    /**
     * @dev Add the risk score to the account. Restricted to the owner
     * @param _address address of the account
     * @param _score risk score (0-100)
     */
    function addScore(address _address, uint8 _score) public onlyOwner {
        scores[_address] = _score;
        emit RiskScoreAdded(_address, _score, block.timestamp);
    }

    /**
     * @dev Remove the risk score for the account. Restricted to the owner
     * @param _account address of the account
     */
    function removeScore(address _account) external onlyOwner {
        delete scores[_account];
        emit RiskScoreRemoved(_account, block.timestamp);
    }

    /**
     * @dev Get the risk score for the account. Restricted to the owner
     * @param _account address of the account
     */
    function getRiskScore(address _account) external view onlyOwner returns (uint8) {
        return scores[_account];
    }
}
