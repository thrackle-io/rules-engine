// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title Example On-chain Allow-List Oracle
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example on-chain oracle that maintains an allow list.
 * @dev This is intended to be a model only. It stores the allow list internally and returns bool true if address is in list.
 */
contract OracleAllowed is Ownable {
    mapping(address => bool) private allowedAddresses;

    event AllowedAddress(address indexed addr);
    event AllowedAddressesAdded(address[] addrs);
    event AllowedAddressAdded(address addrs);
    event AllowedAddressesRemoved(address[] addrs);
    event NotAllowedAddress(address indexed addr);

    /**
     * @dev Return the contract name
     * @return name the name of the contract
     */
    function name() external pure returns (string memory) {
        return "Example allow oracle(Allow List)";
    }

    /**
     * @dev Add addresses to the allow list. Restricted to owner.
     * @param newAllows the addresses to add
     */
    function addToAllowList(address[] memory newAllows) public onlyOwner {
        for (uint256 i = 0; i < newAllows.length; i++) {
            allowedAddresses[newAllows[i]] = true;
        }
        emit AllowedAddressesAdded(newAllows);
    }

    /**
     * @dev Add single address to the allow list. Restricted to owner.
     * @param newAllow the addresses to add
     */
    function addAddressToAllowList(address newAllow) public onlyOwner {
        allowedAddresses[newAllow] = true;
        emit AllowedAddressAdded(newAllow);
    }

    /**
     * @dev Remove addresses from the allow list. Restricted to owner.
     * @param removeAllows the addresses to remove
     */
    function removeFromAllowedList(address[] memory removeAllows) public onlyOwner {
        for (uint256 i = 0; i < removeAllows.length; i++) {
            allowedAddresses[removeAllows[i]] = false;
        }
        emit AllowedAddressesRemoved(removeAllows);
    }

    /**
     * @dev Check to see if address is in allowed list
     * @param addr the address to check
     * @return allowed returns true if in the allowed list, false if not.
     */
    function isAllowed(address addr) public view returns (bool) {
        return allowedAddresses[addr] == true;
    }

    /**
     * @dev Check to see if address is in allowed list. Also emits events based on the results
     * @param addr the address to check
     * @return allowed returns true if in the allowed list, false if not.
     */
    function isAllowedVerbose(address addr) public returns (bool) {
        if (isAllowed(addr)) {
            emit AllowedAddress(addr);
            return true;
        } else {
            emit NotAllowedAddress(addr);
            return false;
        }
    }
}
