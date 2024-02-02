// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Approved and Denied Oracle Interface
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This stores the function signature for external oracles
 * @dev Both "approve list" and "deny list" oracles will use this interface
 */
interface IOracle {
    /**
     * @dev This function checks to see if the address is on the oracle's denied list. This is the DENIED_LIST type.
     * @param _address Account address to check
     * @return denied returns true if denied, false if not
     */
    function isDenied(address _address) external view returns (bool);

    /**
     * @dev This function checks to see if the address is on the oracle's approved list. This is the APPROVED_LIST type.
     * @param _address Account address to check
     * @return denied returns true if approved, false if not
     */
    function isApproved(address _address) external view returns (bool);
}
