// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import {IOracleEvents} from "src/common/IEvents.sol";

/**
 * @title Example On-chain Allow-List Oracle
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example on-chain oracle that maintains an allow list.
 * @dev This is intended to be a model only. It stores the allow list internally and returns bool true if address is in list.
 */
contract OracleAllowed is Ownable, IOracleEvents {
    mapping(address => bool) private allowedAddresses;


    /**
     * @dev Constructor that only serves the purpose of notifying the indexer of its creation via event
     */
    constructor() {
        emit AllowListOracleDeployed();
    }

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
        emit OracleListChanged(true, newAllows);
    }

    /**
     * @dev Add single address to the allow list. Restricted to owner.
     * @param newAllow the addresses to add
     */
    function addAddressToAllowList(address newAllow) public onlyOwner {
        allowedAddresses[newAllow] = true;
        address[] memory addresses;
        addresses[0] =  newAllow;
        emit OracleListChanged(true,addresses);
    }

    /**
     * @dev Remove addresses from the allow list. Restricted to owner.
     * @param removeAllows the addresses to remove
     */
    function removeFromAllowedList(address[] memory removeAllows) public onlyOwner {
        for (uint256 i = 0; i < removeAllows.length; i++) {
            allowedAddresses[removeAllows[i]] = false;
        }
        emit OracleListChanged(false, removeAllows);
    }

    /**
     * @dev Check to see if address is in allowed list
     * @param addr the address to check
     * @return allowed returns true if in the allowed list, false if not.
     */
    function isAllowed(address addr) public view returns (bool) {
        return allowedAddresses[addr];
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
