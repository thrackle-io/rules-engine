// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC173} from "src/diamond/implementations/ERC173/ERC173.sol";
import {ApplicationPauseProcessorLib} from "./ApplicationPauseProcessorLib.sol";

/**
 * @title Application Pause Processor Facet
 * @notice Contains logic for checking specific action against pause rules. (part of diamond structure)
 * @dev Standard EIP2565 Facet with storage defined in its imported library
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ApplicationPauseProcessorFacet is ERC173 {
    /**
     * @dev This function checks if action passes according to application pause rules
     * @param _dataServer address of the appManager contract
     * @return success true if passes, false if not passes
     */
    function checkPauseRules(address _dataServer) external view returns (bool) {
        return ApplicationPauseProcessorLib.checkPauseRules(_dataServer);
    }
}
