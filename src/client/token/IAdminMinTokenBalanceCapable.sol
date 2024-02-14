// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title Admin Min Token Balance Capable
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This interface provides the ABI for any asset handler capable of implementing the Admin Min Token Balance rule
 */

abstract contract IAdminMinTokenBalanceCapable {

    /**
     * @dev This function is used by the app manager to determine if the Admin Min Token Balance rule is active for any of the actions
     * @return Success equals true if all checks pass
     */
    function isAdminMinTokenBalanceActiveAndApplicable() external virtual returns (bool);
}
