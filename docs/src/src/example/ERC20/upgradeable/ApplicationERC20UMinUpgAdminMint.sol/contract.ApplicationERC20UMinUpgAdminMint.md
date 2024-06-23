# ApplicationERC20UMinUpgAdminMint
[Git Source](https://github.com/thrackle-io/tron/blob/5b7fc1e99a9efe7cd4509a3bd8aa91769d651104/src/example/ERC20/upgradeable/ApplicationERC20UMinUpgAdminMint.sol)

**Inherits:**
[ApplicationERC20UMin](/src/example/ERC20/upgradeable/ApplicationERC20UMin.sol/contract.ApplicationERC20UMin.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

*This is an upgradeable example implementation of the protocol ERC721 where minting is only available for app administrators.
During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
must be performed*


## State Variables
### reservedStorage
the length of this array must be shrunk by the same amount of new variables added in an upgrade. This is to keep track of the remaining
storage slots available for variables in future upgrades and avoid storage collisions.

*These storage slots are saved for future upgrades. Please be aware of common constraints for upgradeable contracts regarding storage slots,
like maintaining the order of the variables to avoid mislabeling of storage slots, and to keep some reserved slots to avoid storage collisions.*


```solidity
uint256[50] reservedStorage;
```


