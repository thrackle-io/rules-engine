# ApplicationERC721
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/example/ERC721/ApplicationERC721MintForAFee.sol)

**Inherits:**
[ProtocolERC721](/src/token/ERC721/ProtocolERC721.sol/contract.ProtocolERC721.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation of the protocol ERC721 where minting is open to anybody willing to pay for the NFT.


## State Variables
### _tokenIdCounter

```solidity
Counters.Counter private _tokenIdCounter;
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


## Functions
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    string memory _baseUri,
    uint256 _price
) ProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of NFT|
|`_symbol`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_baseUri`|`string`|URI for the base token|
|`_price`|`uint256`|minting price in WEIs|


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

