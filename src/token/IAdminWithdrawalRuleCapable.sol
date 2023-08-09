// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

/**
 * @title Admin Withdrawal Capable
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This interface provides the ABI for any asset handler capable of implementing the admin withdrawal rule
 */

abstract contract IAdminWithdrawalRuleCapable {
    error AdminWithdrawalRuleisActive();

    /**
     * @dev This function is used by the app manager to determine if the AdminWithdrawal rule is active
     * @return Success equals true if all checks pass
     */
    function isAdminWithdrawalActiveAndApplicable() external virtual returns (bool);
}
