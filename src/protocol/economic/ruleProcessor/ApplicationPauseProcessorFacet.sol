// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

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
