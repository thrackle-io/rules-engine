# TokenRuleRouter
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/TokenRuleRouter.sol)

**Inherits:**
[Initializable](/src/helpers/Initializable.sol/abstract.Initializable.md), [OwnableUpgradeable](/src/helpers/OwnableUpgradeable.sol/abstract.OwnableUpgradeable.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

All the rule checks are funneled through this contract. Specifically
through the checkAllRules() function. This function then relays the
the checks to the RuleProcessor diamond and the TaggedRuleProcessor diamond.
These diamonds then reroute the checks to the appropiate facets.

*This contract is the Token Rule Router.*


## State Variables
### tokenRuleProcessorDiamondContract

```solidity
RuleProcessorDiamond public tokenRuleProcessorDiamondContract;
```


### taggedRuleProcessorDiamond

```solidity
TaggedRuleProcessorDiamond public taggedRuleProcessorDiamond;
```


## Functions
### initialize

*Function acts as a constructor for upgradeable contracts pattern.*


```solidity
function initialize(address payable tokenRuleProcessorsAddress, address payable taggedRuleProcessorAddress)
    public
    initializer;
```

### setRuleProcessorDiamondAddress

*Set the address of the Token Rules Diamond*


```solidity
function setRuleProcessorDiamondAddress(address payable tokenRuleProcessorsAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenRuleProcessorsAddress`|`address payable`|is the address of the Rule Processors Diamond|


### setTaggedRuleProcessorDiamondAddress

*Set the address of the Tagged Rules Diamond*


```solidity
function setTaggedRuleProcessorDiamondAddress(address payable taggedRuleProcessorAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`taggedRuleProcessorAddress`|`address payable`|is the address of the Tagged Rules Diamond|


### checkMinMaxAccountBalancePasses

Functions added so far:
minTransfer
balanceLimits
oracle

*Check the minimum/maximum rule. This rule ensures that both the to and from accounts do not
exceed the max balance or go below the min balance.*


```solidity
function checkMinMaxAccountBalancePasses(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    uint256 amount,
    bytes32[] calldata toTags,
    bytes32[] calldata fromTags
) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`amount`|`uint256`|total number of tokens to be transferred|
|`toTags`|`bytes32[]`|tags applied via App Manager to recipient address|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### checkMinMaxAccountBalancePassesAMM

*Check the minimum/maximum rule through the AMM Swap*


```solidity
function checkMinMaxAccountBalancePassesAMM(
    uint32 ruleIdToken0,
    uint32 ruleIdToken1,
    uint256 tokenBalance0,
    uint256 tokenBalance1,
    uint256 amountIn,
    uint256 amountOut,
    bytes32[] calldata fromTags
) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleIdToken0`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`ruleIdToken1`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`tokenBalance0`|`uint256`|Token balance of the token being swapped|
|`tokenBalance1`|`uint256`|Token balance of the received token|
|`amountIn`|`uint256`|total number of tokens to be swapped|
|`amountOut`|`uint256`|total number of tokens to be received|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### checkMinTransferPasses

*Check the minimum transfer rule. This rule ensures accounts cannot transfer less than
the specified amount.*


```solidity
function checkMinTransferPasses(uint32 ruleId, uint256 amount) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`amount`|`uint256`|total number of tokens to be transferred|


### checkMinMaxAccountBalanceERC721

*Check the minMaxAccoutBalace rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.*


```solidity
function checkMinMaxAccountBalanceERC721(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    bytes32[] calldata toTags,
    bytes32[] calldata fromTags
) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`toTags`|`bytes32[]`|tags applied via App Manager to recipient address|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### checkMinAccountBalanceERC721

*Check the minMaxAccoutBalace rule for ERC721 tokens. This rule ensures accounts cannot drop below specified account balance.*


```solidity
function checkMinAccountBalanceERC721(uint32 ruleId, uint256 balanceFrom, uint256 amount, bytes32[] calldata tokenId)
    public
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`amount`|`uint256`|total number of tokens to be transferred|
|`tokenId`|`bytes32[]`|array of tokenIds|


### checkOraclePasses

*This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.*


```solidity
function checkOraclePasses(uint32 _ruleId, address _address) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id|
|`_address`|`address`|user address to be checked|


### checkPurchaseLimit

*This function receives a rule id, which it uses to get Purchase Rule details.*


```solidity
function checkPurchaseLimit(
    uint32 ruleId,
    uint256 purchasedWithinPeriod,
    uint256 amount,
    bytes32[] calldata toTags,
    uint64 lastUpdateTime
) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`purchasedWithinPeriod`|`uint256`|Number of tokens purchased within purchase Period|
|`amount`|`uint256`|Number of tokens to be transferred|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint64`|block.timestamp of most recent transaction from sender.|


### checkSellLimit

*This function receives a rule id, which it uses to get the Sell Rule details.*


```solidity
function checkSellLimit(
    uint32 ruleId,
    uint256 salesWithinPeriod,
    uint256 amount,
    bytes32[] calldata fromTags,
    uint256 lastUpdateTime
) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`salesWithinPeriod`|`uint256`||
|`amount`|`uint256`|Number of tokens to be transferred|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint256`|block.timestamp of most recent transaction from sender.|


### checkNFTTransferCounter

*This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.*


```solidity
function checkNFTTransferCounter(
    uint32 ruleId,
    uint256 transfersWithinPeriod,
    bytes32[] calldata nftTags,
    uint64 lastTransferTime
) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`transfersWithinPeriod`|`uint256`|Number of transfers within the time period|
|`nftTags`|`bytes32[]`|NFT tags applied|
|`lastTransferTime`|`uint64`|block.timestamp of most recent transaction from sender.|


### checkTransactionLimitByRiskScore

*Check Transaction Limit for Risk Score*


```solidity
function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_riskScore`|`uint8`|the Risk Score of the account|
|`_amountToTransfer`|`uint256`|total dollar amount to be transferred|


### assessAMMFee

*Assess the fee associated with the AMM Fee Rule*


```solidity
function assessAMMFee(uint32 _ruleId, uint256 _collateralizedTokenAmount) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_collateralizedTokenAmount`|`uint256`|total number of collateralized tokens to be swapped(this could be the "token in" or "token out" as the fees are always * assessed from the collateralized token)|


### checkAdminWithdrawalRule

that the function will revert if the check finds a violation of the rule, but won't give anything
back if everything checks out.

*checks that an admin won't hold less tokens than promised until a certain date*


```solidity
function checkAdminWithdrawalRule(uint32 _ruleId, uint256 _currentBalance, uint256 _amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule identifier for rule arguments|
|`_currentBalance`|`uint256`|of tokens held by the admin|
|`_amountToTransfer`|`uint256`|Number of tokens to be transferred|


### checkMinBalByDatePasses

*Rule checks if the minimum balance by date rule will be violated. Tagged accounts must maintain a minimum balance throughout the period specified*


```solidity
function checkMinBalByDatePasses(uint32 ruleId, uint256 balance, uint256 amount, bytes32[] calldata toTags)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`balance`|`uint256`|account's current balance|
|`amount`|`uint256`|Number of tokens to be transferred from this account|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|


