// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/application/IAppManager.sol";
import {ApplicationRuleProcessorDiamondLib as actionDiamond, ApplicationRuleDataStorage} from "./ApplicationRuleProcessorDiamondLib.sol";
import {TaggedRuleDataFacet} from "src/economic/ruleStorage/TaggedRuleDataFacet.sol";

/**
 * @title Application Pause Processor Facet Lib Contract
 * @notice Contains logic for checking specific action against pause rules. (part of diamond structure)
 * @dev Standard EIP2565 Facet Lib contract with storage defined internally
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
struct PauseRuleProcessorStorage {
    uint256 v1;
}

library ApplicationPauseProcessorLib {
    error ApplicationPaused(uint started, uint ends);
    bytes32 constant PAUSE_PROCESSOR_STORAGE_POSITION = keccak256("pause-processor.storage");
    using ApplicationRuleProcessorDiamondLib for uint256;

    /**
     * @dev This function returns the storage struct for reading and writing.
     * @return storageStruct actual storage for the facet
     */
    function s() internal pure returns (PauseRuleProcessorStorage storage storageStruct) {
        bytes32 position = PAUSE_PROCESSOR_STORAGE_POSITION;
        assembly {
            storageStruct.slot := position
        }
    }

    /**
     * @dev This function checks if action passes according to application pause rules. Checks for all pause windows set for this token.
     * @param _dataServer address of the appManager contract
     * @return success true if passes, false if not passes
     */
    function checkPauseRules(address _dataServer) internal view returns (bool) {
        // Get Pause rules
        PauseRule[] memory pauseRules = IAppManager(_dataServer).getPauseRules();
        // Loop through the pause blocks and see if current time falls in one
        for (uint256 i = 0; i < pauseRules.length; ) {
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
