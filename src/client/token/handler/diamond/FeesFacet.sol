// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/protocol/economic/RuleAdministratorOnly.sol";
import "../../../application/IAppManager.sol";
import "../ruleContracts/Fees.sol";

contract FeesFacet is RuleAdministratorOnly, Fees {
    

    /**
     * @dev Turn fees on/off
     * @param on_off value for fee status
     */
    function setFeeActivation(bool on_off) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.feeStorage().feeActive = on_off;
        emit FeeActivationSet(on_off);
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeActive fee activation status
     */
    function isFeeActive() external view returns (bool) {
        return lib.feeStorage().feeActive;
    }

}