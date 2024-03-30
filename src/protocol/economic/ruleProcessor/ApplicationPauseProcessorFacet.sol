// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./RuleProcessorDiamondImports.sol";
import "src/client/application/data/PauseRule.sol";
import "src/client/application/IAppManager.sol";

/**
 * @title Application Pause Processor Facet
 * @notice Contains logic for checking specific action against pause rules.
 * @dev Standard EIP2565 Facet with storage defined in its imported library
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ApplicationPauseProcessorFacet is ERC173, IPauseRuleErrors {
    /**
     * @dev This function checks if action passes according to application pause rules. Checks for all pause windows set for this token.
     * @param _appManagerAddress address of the appManager contract
     * @return success true if passes, false if not passes
     */
    function checkPauseRules(address _appManagerAddress) external view returns (bool) {
        PauseRule[] memory pauseRules = IAppManager(_appManagerAddress).getPauseRules();
        for (uint256 i; i < pauseRules.length; ++i) {
            PauseRule memory rule = pauseRules[i];
            // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
            // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
            // slither-disable-next-line timestamp
            if (block.timestamp >= rule.pauseStart && block.timestamp < rule.pauseStop) {
                revert ApplicationPaused(rule.pauseStart, rule.pauseStop);
            }
        }

        return true;
    }
}
