# NFTValuationLimit
[Git Source](https://github.com/thrackle-io/tron/blob/d5d71b820b889f2fefe2639a8f5979e5f09110ed/src/client/token/handler/ruleContracts/NFTValuationLimit.sol)

**Inherits:**
[ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett @bfcoursewool

*Setters and getters for the rule in the handler. Meant to be inherited by a handler
facet to easily support the rule.*


## Functions
### setNFTValuationLimit

*Set the NFT Valuation limit that will check collection price vs looping through each tokenId in collections*


```solidity
function setNFTValuationLimit(uint16 _newNFTValuationLimit)
    public
    appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newNFTValuationLimit`|`uint16`|set the number of NFTs in a wallet that will check for collection price vs individual token prices|


### getNFTValuationLimit

*Get the nftValuationLimit*


```solidity
function getNFTValuationLimit() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|nftValautionLimit number of NFTs in a wallet that will check for collection price vs individual token prices|


