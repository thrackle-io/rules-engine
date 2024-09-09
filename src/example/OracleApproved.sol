// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/access/Ownable.sol";
import {IOracleEvents} from "src/common/IEvents.sol";

/**
 * @title Example On-chain Approve-List Oracle
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example on-chain oracle that maintains an approve list.
 * @dev This is intended to be a model only. It stores the approve list internally and returns bool true if address is in list.
 */
contract OracleApproved is Ownable, IOracleEvents {
    mapping(address => bool) private approvedAddresses;


    /**
     * @dev Constructor that only serves the purpose of notifying the indexer of its creation via event
     */
    constructor() {
        emit AD1467_ApproveListOracleDeployed();
    }

    /**
     * @dev Return the contract name
     * @return name the name of the contract
     */
    function name() external pure returns (string memory) {
        return "Example approve oracle(Approved List)";
    }

    /**
     * @dev Add addresses to the approve list. Restricted to owner.
     * @param newApproves the addresses to add
     */
    function addToApprovedList(address[] memory newApproves) public onlyOwner {        
        for (uint256 i = 0; i < newApproves.length; i++) {
            approvedAddresses[newApproves[i]] = true;
        }
        emit AD1467_OracleListChanged(true, newApproves);
    }

    /**
     * @dev Add single address to the approve list. Restricted to owner.
     * @param newApprove the addresses to add
     */
    function addAddressToApprovedList(address newApprove) public onlyOwner {
        approvedAddresses[newApprove] = true;
        address[] memory addresses = new address[](1);
        addresses[0] =  newApprove;
        emit AD1467_OracleListChanged(true,addresses);
    }

    /**
     * @dev Remove addresses from the approve list. Restricted to owner.
     * @param removeApproves the addresses to remove
     */
    function removeFromAprovededList(address[] memory removeApproves) public onlyOwner {
        for (uint256 i = 0; i < removeApproves.length; i++) {
            approvedAddresses[removeApproves[i]] = false;
        }
        emit AD1467_OracleListChanged(false, removeApproves);
    }

    /**
     * @dev Check to see if address is in approved list
     * @param addr the address to check
     * @return approved returns true if in the approved list, false if not.
     */
    function isApproved(address addr) public view returns (bool) {
        return approvedAddresses[addr];
    }

    /**
     * @dev Check to see if address is in approved list. Also emits events based on the results
     * @param addr the address to check
     * @return approved returns true if in the approved list, false if not.
     */
    function isApprovedVerbose(address addr) public returns (bool) {
        bool isAddressApproved = isApproved(addr);
        emit AD1467_ApprovedAddress(addr, isAddressApproved);
        return isAddressApproved;
    }
}
