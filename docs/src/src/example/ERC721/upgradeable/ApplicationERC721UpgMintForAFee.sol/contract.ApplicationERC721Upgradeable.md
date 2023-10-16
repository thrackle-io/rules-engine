# ApplicationERC721Upgradeable
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/108c58e2bb8e5c2e5062cebb48a41dcaadcbfcd8/src/example/ERC721/upgradeable/ApplicationERC721UpgMintForAFee.sol)

**Inherits:**
[ProtocolERC721U](/src/token/ProtocolERC721U.sol/contract.ProtocolERC721U.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

*This is an example implementation for an ERC721 token which can be minted in exchange of an amount (fee) of native tokens (ETH, MATIC, etc.).
During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract.
Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U must be performed.*


## State Variables
### _tokenIdCounter

```solidity
CountersUpgradeable.Counter private _tokenIdCounter;
```


### mintPrice
Mint Fee


```solidity
uint256 public mintPrice;
```


### proposedTreasury
Treasury Address


```solidity
address private proposedTreasury;
```


### treasury

```solidity
address payable private treasury;
```


### reservedStorage
the length of this array must be shrunk by the same amount of new variables added in an upgrade. This is to keep track of the remaining
storage slots available for variables in future upgrades and avoid storage collisions.

*these storage slots are saved for future upgrades. Please be aware of common constraints for upgradeable contracts regarding storage slots,
like maintaining the order of the variables to avoid mislabeling of storage slots, and to keep some reserved slots to avoid storage collisions.*


```solidity
uint256[47] reservedStorage;
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
    uint256 _mintPrice
) external appAdministratorOnly(_appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_baseUri`|`string`|URI for the base token|
|`_mintPrice`|`uint256`|price for minting the NFTs in WEIs|


### safeMint

This function assumes the mintPrice is in Chain Native Token and in WEI units

*Function mints a new token to caller at mintPrice with tokenId incremented by 1 from previous minted token.*


```solidity
function safeMint(address to) public payable override whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|


### setMintPrice

*Function to set the mint price amount in chain native token (WEIs)*


```solidity
function setMintPrice(uint256 _mintPrice) external appAdministratorOnly(appManagerAddress);
```

### proposeTreasuryAddress

*Function to propose the Treasury address for Mint Fees to be sent upon withdrawal*


```solidity
function proposeTreasuryAddress(address payable _treasury) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasury`|`address payable`|address of the treasury for mint fees to be sent upon withdrawal.|


### confirmTreasuryAddress


```solidity
function confirmTreasuryAddress() external;
```

### withdrawAmount

*Function to withdraw a specific amount from this contract to treasury address.*


```solidity
function withdrawAmount(uint256 _amount) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|the amount to withdraw (WEIs)|


### withdrawAll

*Function to withdraw all fees collected to treasury address.*


```solidity
function withdrawAll() external appAdministratorOnly(appManagerAddress);
```

### getTreasuryAddress

*gets value of treasury*


```solidity
function getTreasuryAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address of trasury|


### getProposedTreasuryAddress

*gets value of proposedTreasury*


```solidity
function getProposedTreasuryAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address of proposedTreasury|


### receive

Receive function for contract to receive chain native tokens in unordinary ways


```solidity
receive() external payable;
```

### fallback

function to handle wrong data sent to this contract


```solidity
fallback() external payable;
```

## Errors
### MintFeeNotReached
errors


```solidity
error MintFeeNotReached();
```

### PriceNotSet

```solidity
error PriceNotSet();
```

### CannotWithdrawZero

```solidity
error CannotWithdrawZero();
```

### TreasuryAddressCannotBeTokenContract

```solidity
error TreasuryAddressCannotBeTokenContract();
```

### TreasuryAddressNotSet

```solidity
error TreasuryAddressNotSet();
```

### FunctionDoesNotExist

```solidity
error FunctionDoesNotExist();
```

### NotEnoughBalance

```solidity
error NotEnoughBalance();
```

### ZeroValueNotPermited

```solidity
error ZeroValueNotPermited();
```

### NotProposedTreasury

```solidity
error NotProposedTreasury(address proposedTreasury);
```

### TrasferFailed

```solidity
error TrasferFailed(bytes reason);
```

