# ApplicationERC721
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/example/ERC721/ApplicationERC721WhitelistMint.sol)

**Inherits:**
[ProtocolERC721](/src/token/ERC721/ProtocolERC721.sol/contract.ProtocolERC721.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation of the protocol ERC721 where minting is open only to whitelisted address,
and they have a certain amount of availbale mints.


## State Variables
### _tokenIdCounter

```solidity
Counters.Counter private _tokenIdCounter;
```


### mintsAvailable

```solidity
mapping(address => uint8) public mintsAvailable;
```


### mintsAllowed

```solidity
uint8 mintsAllowed;
```


## Functions
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    string memory _baseUri,
    uint8 _mintsAllowed
) ProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri);
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
function addAddressToWhitelist(address _address) external appAdministratorOrOwnerOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address to enjoy the free mints|


### updateMintsAmount

this variable will affect directly the amount of free mints granted to an address through "addAddressToWhitelist"

*update the value of "mintsAllowed"*


```solidity
function updateMintsAmount(uint8 _mintsAllowed) external appAdministratorOrOwnerOnly(appManagerAddress);
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

