// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "src/protocol/economic/RuleAdministratorOnly.sol";
import "src/client/application/IAppManager.sol";
import "src/client/token/handler/ruleContracts/Fees.sol";

contract FeesFacet is RuleAdministratorOnly, Fees {
    

    /**
     * @dev Turn fees on/off
     * @param on_off value for fee status
     */
    function setFeeActivation(bool on_off) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager) {
        lib.feeStorage().feeActive = on_off;
        emit AD1467_FeeActivationSet(on_off);
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeActive fee activation status
     */
    function isFeeActive() external view returns (bool) {
        return lib.feeStorage().feeActive;
    }

}