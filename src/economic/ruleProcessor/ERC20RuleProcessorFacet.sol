// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RuleProcessorDiamondLib as Diamond, RuleDataStorage} from "./RuleProcessorDiamondLib.sol";
import {RuleDataFacet} from "../ruleStorage/RuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "../ruleStorage/RuleDataInterfaces.sol";
import "../ruleStorage/RuleCodeData.sol";
import "./IOracle.sol";

/**
 * @title ERC20 Handler Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check token rules compliance
 * @notice Implements Token Fee Rules on Accounts.
 */
contract ERC20RuleProcessorFacet {
    error BelowMinTransfer();
    error AddressIsRestricted();
    error AddressNotOnAllowedList();
    error OracleTypeInvalid();
    error RuleDoesNotExist();

    /**
     * @dev Check if transaction passes minTransfer rule.
     * @param _ruleId Rule Identifier for rule arguments
     * @param amountToTransfer total number of tokens to be transferred
     */
    function checkMinTransferPasses(uint32 _ruleId, uint256 amountToTransfer) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);

        if (data.getTotalMinimumTransferRules() != 0) {
            try data.getMinimumTransferRule(_ruleId) returns (uint min) {
                if (min > amountToTransfer) revert BelowMinTransfer();
            } catch {
                revert RuleDoesNotExist();
            }
        }
    }

    /**
     * @dev This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param _address user address to be checked
     */
    function checkOraclePasses(uint32 _ruleId, address _address) external view {
        RuleDataFacet data = RuleDataFacet(Diamond.ruleDataStorage().rules);

        if (data.getTotalOracleRules() != 0) {
            try data.getOracleRule(_ruleId) returns (NonTaggedRules.OracleRule memory oracleRule) {
                uint256 oType = oracleRule.oracleType;
                address oracleAddress = oracleRule.oracleAddress;
                /// White List type
                if (oType == uint(ORACLE_TYPE.ALLOWED_LIST)) {
                    if (!IOracle(oracleAddress).isAllowed(_address)) {
                        revert AddressNotOnAllowedList();
                    }

                    /// Black List type
                } else if (oType == uint(ORACLE_TYPE.RESTRICTED_LIST)) {
                    if (IOracle(oracleAddress).isRestricted(_address)) {
                        revert AddressIsRestricted();
                    }
                    /// Invalid oracle type
                } else {
                    revert OracleTypeInvalid();
                }
            } catch {
                revert RuleDoesNotExist();
            }
        }
    }
}
