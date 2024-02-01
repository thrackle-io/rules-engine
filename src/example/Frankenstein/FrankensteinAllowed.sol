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
contract FrankensteinAllowed is Ownable, IOracleEvents {
    mapping(address => bool) private approvedAddresses;


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
        return "Example approve oracle(Approved List)";
    }

    /**
     * @dev Add addresses to the allow list. Restricted to owner.
     * @param newAllows the addresses to add
     */
    function addToApprovedList(address[] memory newAllows) public onlyOwner {
        for (uint256 i = 0; i < newAllows.length; i++) {
            approvedAddresses[newAllows[i]] = true;
        }
        emit OracleListChanged(true, newAllows);
    }

    /**
     * @dev Add single address to the allow list. Restricted to owner.
     * @param newAllow the addresses to add
     */
    function addAddressToApprovedList(address newAllow) public onlyOwner {
        approvedAddresses[newAllow] = true;
        address[] memory addresses = new address[](1);
        addresses[0] =  newAllow;
        emit OracleListChanged(true,addresses);
    }

    /**
     * @dev Remove addresses from the allow list. Restricted to owner.
     * @param removeAllows the addresses to remove
     */
    function removeFromAprovededList(address[] memory removeAllows) public onlyOwner {
        for (uint256 i = 0; i < removeAllows.length; i++) {
            approvedAddresses[removeAllows[i]] = false;
        }
        emit OracleListChanged(false, removeAllows);
    }

    /**
     * @dev Check to see if address is in allowed list
     * @param addr the address to check
     * @return allowed returns true if in the allowed list, false if not.
     */
    function isApproved(address addr) public view returns (bool) {
        return approvedAddresses[addr];
    }

    /**
     * @dev Check to see if address is in allowed list. Also emits events based on the results
     * @param addr the address to check
     * @return allowed returns true if in the allowed list, false if not.
     */
    function isApprovedVerbose(address addr) public returns (bool) {
        if (isApproved(addr)) {
            emit AllowedAddress(addr);
            return true;
        } else {
            emit NotAllowedAddress(addr);
            return false;
        }
    }
}
