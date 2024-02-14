// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";
import {FeeRuleDataFacet} from "./FeeRuleDataFacet.sol";


/**
 * @title Fee Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check fee rule compliance
 * @notice Implements Token Fee Rules on Accounts.
 */
contract FeeRuleProcessorFacet is IRuleProcessorErrors, IInputErrors {
    using RuleProcessorCommonLib for uint32;

    /**
     * @dev Assess the fee associated with the AMM Fee Rule
     * @param _ruleId Rule Identifier for rule arguments
     * @param _collateralizedTokenAmount total number of collateralized tokens to be swapped(this could be the "token in" or "token out" as the fees are always * assessed from the collateralized token)
     */
    function assessAMMFee(uint32 _ruleId, uint256 _collateralizedTokenAmount) external view returns (uint256) {
        Fee.AMMFeeRule memory feeRule = getAMMFeeRule(_ruleId);
        if (feeRule.feePercentage > 0) {
            return (_collateralizedTokenAmount * feeRule.feePercentage) / 10000;
        }
        return 0;
    }

    /**
     * @dev Function get AMM Fee Rule by index
     * @param _index Position of rule in storage
     * @return AMMFeeRule at index
     */
    function getAMMFeeRule(uint32 _index) public view returns (Fee.AMMFeeRule memory) {
        _index.checkRuleExistence(getTotalAMMFeeRules());
        RuleS.AMMFeeRuleS storage data = Storage.ammFeeRuleStorage();
        return data.ammFeeRules[_index];
    }

    /**
     * @dev Function get total AMM Fee rules
     * @return total ammFeeRules array length
     */
    function getTotalAMMFeeRules() public view returns (uint32) {
        RuleS.AMMFeeRuleS storage data = Storage.ammFeeRuleStorage();
        return data.ammFeeRuleIndex;
    }
}
