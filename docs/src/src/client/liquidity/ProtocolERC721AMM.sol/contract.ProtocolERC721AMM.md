# ProtocolERC721AMM
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/ProtocolERC721AMM.sol)

**Inherits:**
[AppAdministratorOnly](/src/protocol/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), IERC721Receiver, [IApplicationEvents](/src/common/IEvents.sol/interface.IApplicationEvents.md), [AMMCalculatorErrors](/src/common/IErrors.sol/interface.AMMCalculatorErrors.md), [AMMErrors](/src/common/IErrors.sol/interface.AMMErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This is the base contract for all protocol AMMs.

*The only thing to recognize is that calculations are all done in an external calculation contract*


## State Variables
### PCT_MULTIPLIER

```solidity
uint256 constant PCT_MULTIPLIER = 10_000;
```


### ERC20Token
The fungible token


```solidity
IERC20 public immutable ERC20Token;
```


### ERC721Token
the non-fungible token


```solidity
IERC721 public immutable ERC721Token;
```


### appManagerAddress

```solidity
address public appManagerAddress;
```


### treasuryAddress

```solidity
address treasuryAddress;
```


### calculatorAddress

```solidity
address public calculatorAddress;
```


### calculator

```solidity
IProtocolAMMCalculator calculator;
```


### handler

```solidity
IProtocolAMMHandler handler;
```


## Functions
### constructor

*Must provide the addresses for both tokens that will provide liquidity*


```solidity
constructor(address _ERC20Token, address _ERC721Token, address _appManagerAddress, address _calculatorAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ERC20Token`|`address`|valid ERC20 address|
|`_ERC721Token`|`address`|valid ERC721 address|
|`_appManagerAddress`|`address`|valid address of the corresponding app manager|
|`_calculatorAddress`|`address`|valid address of the corresponding calculator for the AMM|


### swap

Set the calculator and create the variable for it.

*This is the primary function of this contract. It allows for
the swapping of one token for the other.*

*arguments for checkRuleStorages: balanceFrom is ERC20Token balance of _msgSender(), balanceTo is  ERC721Token balance of _msgSender().*


```solidity
function swap(address _tokenIn, uint256 _amountIn, uint256 _tokenId) external returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenIn`|`address`|address identifying the token coming into AMM|
|`_amountIn`|`uint256`|amount of the token being swapped|
|`_tokenId`|`uint256`|the NFT Id to swap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|amount of the other token coming out of the AMM|


### _swap0For1

validatation block
swap

This is considered a "PURCHASE" as the user is trading fungible tokens in exchange for NFTs (buying NFTs)

*This performs the swap from ERC20Token to ERC721*


```solidity
function _swap0For1(uint256 _amountIn, uint256 _tokenId) private returns (uint256 _amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amountIn`|`uint256`|amount of ERC20Token being swapped for 1 NFT|
|`_tokenId`|`uint256`|the NFT Id to swap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amountOut`|`uint256`|amount of ERC721Token coming out of the pool|


### _swap1For0

we make sure we have the nft
only 1 NFT per swap is allowed
we get price, fees and validate _amountIn
perform transfers

This is considered a "SELL" as the user is providing NFT in exchange for fungible tokens

*This performs the swap from  ERC721Token to ERC20s*


```solidity
function _swap1For0(uint256 _amountIn, uint256 _tokenId) private returns (uint256 _amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amountIn`|`uint256`|amount of NFTs. In this case it should always be 1.|
|`_tokenId`|`uint256`|the NFT Id to swap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amountOut`|`uint256`|amount of ERC20 tokens coming out of the pool|


### addLiquidityERC20

we make sure the user has the nft
only 1 NFT per swap is allowed
we get price and fees
transfer the ERC20Token amount to the swapper

*This function allows contributions to the liquidity pool*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function addLiquidityERC20(uint256 _amountERC20) external appAdministratorOnly(appManagerAddress) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amountERC20`|`uint256`|The amount of ERC20Token being added|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### addLiquidityERC721

transfer funds from sender to the AMM. All the checks for available funds
and approval are done in the ERC20

*This function allows contributions to the liquidity pool*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function addLiquidityERC721(uint256 _tokenId) external appAdministratorOnly(appManagerAddress) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|The Id of the ERC721Token being added. Liquidity can be added one by one.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### addLiquidityERC721InBatch

transfer funds from sender to the AMM. All the checks for available funds

*This function allows contributions to the liquidity pool*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function addLiquidityERC721InBatch(uint256[] memory _tokenIds)
    external
    appAdministratorOnly(appManagerAddress)
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenIds`|`uint256[]`|The Ids of the ERC721Tokens being added. This allows to add NFT liquidity in batch.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### removeERC20

transfer NFTs from sender to the AMM

*This function allows owners to remove ERC20Token liquidity*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function removeERC20(uint256 _amount) external appAdministratorOnly(appManagerAddress) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|The amount of ERC20Token being removed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### removeERC721

transfer the tokens to the remover

*This function allows owners to remove  ERC721Token liquidity*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function removeERC721(uint256 _tokenId) external appAdministratorOnly(appManagerAddress) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|The Id of the NFT being removed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success pass/fail|


### setAppManagerAddress

we make sure we have the nft
transfer the tokens to the remover

*sets the app manager address*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|The address of a valid appManager|


### setCalculatorAddress

*sets the calculator address*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setCalculatorAddress(address _calculatorAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_calculatorAddress`|`address`|The address of a valid AMMCalculator|


### _setCalculatorAddress

*sets the calculator address. It is only meant to be used at instantiation of contract*


```solidity
function _setCalculatorAddress(address _calculatorAddress) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_calculatorAddress`|`address`|The address of a valid AMMCalculator|


### setTreasuryAddress

*This function sets the treasury address*


```solidity
function setTreasuryAddress(address _treasury) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasury`|`address`|address for the treasury|


### onERC721Received

the receiver function specified in ERC721


```solidity
function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data)
    external
    pure
    returns (bytes4);
```

### getBuyPrice

this function won't change the state of the calculator.

*public function to get the price for buying an NFT.*


```solidity
function getBuyPrice() public view returns (uint256 price, uint256 fees);
```

### _calculateBuyPrice

*internal function to get the price for buying an NFT and also changing the state of the calculator*


```solidity
function _calculateBuyPrice() internal returns (uint256 price, uint256 fees);
```

### getSellPrice

this function won't change the state of the calculator.

*internal function to get the price for selling an NFT.*


```solidity
function getSellPrice() public view returns (uint256 price, uint256 fees);
```

### _calculateSellPrice

*internal function to get the price for selling an NFT and also changing the state of the calculator*


```solidity
function _calculateSellPrice() internal returns (uint256 price, uint256 fees);
```

### _calculateBuyFeesFromPct

*internal function to calculate the fees in a purchase by getting its price and fee percentage*


```solidity
function _calculateBuyFeesFromPct(uint256 price, uint256 feesPct) internal pure returns (uint256 fees);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|the price for the NFT|
|`feesPct`|`uint256`|the percentage of fees to pay in a purchase|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`fees`|`uint256`|to be paid at such price and at such percentage|


### getTreasuryAddress

*This function gets the treasury address*


```solidity
function getTreasuryAddress() external view appAdministratorOnly(appManagerAddress) returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_treasury address for the treasury|


### connectHandlerToAMM

*Connects the AMM with its handler*


```solidity
function connectHandlerToAMM(address _handlerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_handlerAddress`|`address`|of the rule processor|


### getHandlerAddress

*returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


### _checkRules


```solidity
function _checkRules(uint256 _amountIn, uint256 _amountOut, ActionTypes act) private;
```

### getERC20Reserves

*gets ERC20 reserves in the pool*


```solidity
function getERC20Reserves() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|reserves of the ERC20|


### getERC721Reserves

*gets ERC721 reserves in the pool*


```solidity
function getERC721Reserves() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|reserves of the ERC721|


### _transferBuy

*carries out the "BUY" swap*


```solidity
function _transferBuy(uint256 _amount, uint256 _tokenId) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|amount of ERC20s being paid to the AMM|
|`_tokenId`|`uint256`|the NFT Id being sold|


### _transferSell

*carries out the "SELL" swap*


```solidity
function _transferSell(uint256 _amount, uint256 _tokenId) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|amount of ERC20s being paid to the user|
|`_tokenId`|`uint256`|the NFT Id being added to the AMM|


### _sendERC20WithConfirmation

*transfers ERC20s and makes sure the transfer happened successfully*


```solidity
function _sendERC20WithConfirmation(address _from, address _to, uint256 _amount) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the sender|
|`_to`|`address`|address of the recepient|
|`_amount`|`uint256`|the amount of tokens changing hands|


### _sendERC721WithConfirmation

change to low level call later
change to low level call later

*transfers an ERC721 and makes sure the transfer happened successfully*


```solidity
function _sendERC721WithConfirmation(address _from, address _to, uint256 _tokenId) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the sender|
|`_to`|`address`|address of the recepient|
|`_tokenId`|`uint256`|the NFT being transferred|


### _checkNFTOwnership

*reverts if an NFT is not owned by the aleged owner*


```solidity
function _checkNFTOwnership(address _owner, uint256 _tokenId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|address of the aleged owner|
|`_tokenId`|`uint256`|the NFT the _owner claims to own|


### howMuchToBuyAllBack

TODO


```solidity
function howMuchToBuyAllBack() public pure returns (uint256 budget);
```

