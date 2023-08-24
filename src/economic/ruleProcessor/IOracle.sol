// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Sanction and Permission Oracle Interface
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This stores the function signature for external oracles
 * @dev Both "allow list" and "restrict list" oracles will use this interface
 */
interface IOracle {
    /**
     * @dev This function checks to see if the address is on the oracle's sanction list. This is the RESTRICTED_LIST type.
     * @param _address Account address to check
     * @return sanctioned returns true if sanctioned, false if not
     */
    function isRestricted(address _address) external view returns (bool);

    /**
     * @dev This function checks to see if the address is on the oracle's allowed list. This is the ALLOWED_LIST type.
     * @param _address Account address to check
     * @return sanctioned returns true if allowed, false if not
     */
    function isAllowed(address _address) external view returns (bool);
}
