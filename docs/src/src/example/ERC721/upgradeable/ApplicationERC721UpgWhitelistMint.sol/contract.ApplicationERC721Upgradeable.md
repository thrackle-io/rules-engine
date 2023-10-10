# ApplicationERC721Upgradeable
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/example/ERC721/upgradeable/ApplicationERC721UpgWhitelistMint.sol)

**Inherits:**
[ProtocolERC721U](/src/token/ProtocolERC721U.sol/contract.ProtocolERC721U.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

*This is an example implementation that App Devs should use.
During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
must be performed*


## State Variables
### _tokenIdCounter

```solidity
CountersUpgradeable.Counter private _tokenIdCounter;
```


### mintsAvailable

```solidity
mapping(address => uint8) public mintsAvailable;
```


### mintsAllowed

```solidity
uint8 mintsAllowed;
```


### reservedStorage
the length of this array must be shrunk by the same amount of new variables added in an upgrade. This is to keep track of the remaining
storage slots available for variables in future upgrades and avoid storage collisions.

*these storage slots are saved for future upgrades. Please be aware of common constraints for upgradeable contracts regarding storage slots,
like maintaining the order of the variables to avoid mislabeling of storage slots, and to keep some reserved slots to avoid storage collisions.*


```solidity
uint256[48] reservedStorage;
```


## Functions
### initialize

*Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
function initialize(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    string memory _baseUri,
    uint8 _mintsAllowed
) external appAdministratorOnly(_appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_baseUri`|`string`|URI for the base token|
|`_mintsAllowed`|`uint8`|the amount of mints per whitelisted address|


### safeMint

*Function mints a new token to anybody in the whitelist, and updates the amount of mints available for the address.*


```solidity
function safeMint(address to) public payable override whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|


### addAddressToWhitelist

the amount of free mints granted to this address is limited and it will be equal to "mintsAllowed"

*add an address to the whitelist*


```solidity
function addAddressToWhitelist(address _address) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address to enjoy the free mints|


### updateMintsAmount

this variable will affect directly the amount of free mints granted to an address through "addAddressToWhitelist"

*update the value of "mintsAllowed"*


```solidity
function updateMintsAmount(uint8 _mintsAllowed) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_mintsAllowed`|`uint8`|uint8 that represents the amount of free mints granted through "addAddressToWhitelist" from now on|


## Errors
### NoMintsAvailable

```solidity
error NoMintsAvailable();
```

