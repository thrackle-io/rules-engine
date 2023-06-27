// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title Example On-chain Restrict-List Oracle
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example on-chain oracle that maintains a restricted list.
 * @dev This is intended to be a model only. It stores the allow list internally and returns bool true if address is in list.
 */
contract OracleRestricted is Ownable {
    constructor() {}

    mapping(address => bool) private sanctionedAddresses;

    event SanctionedAddress(address indexed addr);
    event NonSanctionedAddress(address indexed addr);
    event SanctionedAddressesAdded(address[] addrs);
    event SanctionedAddressAdded(address addrs);
    event SanctionedAddressesRemoved(address[] addrs);

    /**
     * @dev Return the contract name
     * @return name the name of the contract
     */
    function name() external pure returns (string memory) {
        return "Example sanctions oracle(Restricted List)";
    }

    /**
     * @dev Add addresses to the sanction list. Restricted to owner.
     * @param newSanctions the addresses to add
     */
    function addToSanctionsList(address[] memory newSanctions) public onlyOwner {
        for (uint256 i = 0; i < newSanctions.length; i++) {
            sanctionedAddresses[newSanctions[i]] = true;
        }
        emit SanctionedAddressesAdded(newSanctions);
    }

    /**
     * @dev Add single address to the allow list. Restricted to owner.
     * @param newSanction the addresses to add
     */
    function addAddressToSanctionsList(address newSanction) public onlyOwner {
        sanctionedAddresses[newSanction] = true;

        emit SanctionedAddressAdded(newSanction);
    }

    /**
     * @dev Remove addresses from the restricted list. Restricted to owner.
     * @param removeSanctions the addresses to remove
     */
    function removeFromSanctionsList(address[] memory removeSanctions) public onlyOwner {
        for (uint256 i = 0; i < removeSanctions.length; i++) {
            sanctionedAddresses[removeSanctions[i]] = false;
        }
        emit SanctionedAddressesRemoved(removeSanctions);
    }

    /**
     * @dev Check to see if address is in restricted list
     * @param addr the address to check
     * @return restricted returns true if in the restricted list, false if not.
     */
    function isRestricted(address addr) public view returns (bool) {
        return sanctionedAddresses[addr] == true;
    }

    /**
     * @dev Check to see if address is in restricted list. Also emits events based on the results
     * @param addr the address to check
     * @return restricted returns true if in the restricted list, false if not.
     */
    function isRestrictedVerbose(address addr) public returns (bool) {
        if (isRestricted(addr)) {
            emit SanctionedAddress(addr);
            return true;
        } else {
            emit NonSanctionedAddress(addr);
            return false;
        }
    }
}
