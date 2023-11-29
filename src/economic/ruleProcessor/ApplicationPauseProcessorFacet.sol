// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";
import "../../data/PauseRule.sol";
import "../../application/IAppManager.sol";

/**
 * @title Application Pause Processor Facet
 * @notice Contains logic for checking specific action against pause rules. (part of diamond structure)
 * @dev Standard EIP2565 Facet with storage defined in its imported library
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ApplicationPauseProcessorFacet is ERC173, IPauseRuleErrors {
    /**
     * @dev This function checks if action passes according to application pause rules. Checks for all pause windows set for this token.
     * @param _dataServer address of the appManager contract
     * @return success true if passes, false if not passes
     */
    function checkPauseRules(address _dataServer) external view returns (bool) {
        // Get Pause rules
        PauseRule[] memory pauseRules = IAppManager(_dataServer).getPauseRules();
        // Loop through the pause blocks and see if current time falls in one
        for (uint256 i; i < pauseRules.length; ) {
            PauseRule memory rule = pauseRules[i];
            if (block.timestamp >= rule.pauseStart && block.timestamp < rule.pauseStop) {
                revert ApplicationPaused(rule.pauseStart, rule.pauseStop);
            }
            unchecked {
                ++i;
            }
        }

        return true;
    }
}
