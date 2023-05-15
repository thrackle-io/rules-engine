// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Contract for storing permission roles
 * @notice This contract stores permission roles
 * @dev This is intended to be inherited by role users.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract RoleUser {
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
}
