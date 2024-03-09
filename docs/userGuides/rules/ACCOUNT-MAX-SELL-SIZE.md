# Account Max Sell Size

## Purpose

The Account Max Sell Size is an account based measure which restricts an account’s ability to sell a token. This may be put in place to restrict large transactions from occurring against suspected malicious accounts or other accounts of interest. The amount of sales allowed depends on the account's tags. Different accounts may get different sale restrictions depending on their tags.

## Applies To:

- [x] ERC20
- [x] ERC721
- [ ] AMM

## Applies To Actions:

- [ ] MINT
- [ ] BURN
- [ ] BUY
- [x] SELL
- [ ] TRANSFER(Peer to Peer)
  
## Scope 

This rule works at the token level. It must be activated and configured for each token in the corresponding token handler.

## Data Structure

As this is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. An account-max-sell-size "sub-rule" is specified by 2 variables:

- **Max Size** (uint256): The maximum amount of tokens that may be sold during the *sell period*. 
- **Period** (uint16): The length of each time period for which the rule will apply, in hours.


```c
/// ******** Account Max Sell Sizes ********
    struct AccountMaxSellSize {
        uint256 maxSize; /// token units
        uint16 period; /// hours
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

If a single blank `tag` is specified, the rule is applicable to all users.

Additionally, each one of these data structures will be under a tag (bytes32):

 tag -> sub-rule.

 ```c
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.AccountMaxSellSize)) 
```

And the starting Timestamp for the rule will be global for all tags:

- **Starting Timestamp** (uint64): The Unix timestamp of the date when the *period* starts counting.
 
```c

        mapping(uint32 => uint64) startTimes;///Time the rule is applied
```

###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

The collection of these tagged sub-rules plus the startTime composes an account-max-sell-size rule.

```c
    /// ******** Account Max Sell Sizes ********
    struct AccountMaxSellSizeS {
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.AccountMaxSellSize)) AccountMaxSellSizesRules;
        mapping(uint32 => uint64) startTimes;///Time the rule is applied
        uint32 AccountMaxSellSizesIndex; /// increments every time someone adds a rule
    }
```
###### *see [IRuleProcessor](../../../src/protocol/economic/ruleProcessor/IRuleProcessor.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. The token handler decides if the transfer is a Sell (user perspective). Only if it is, it continues with the next steps.
3. The account being evaluated passes to the protocol all the tags it has registered to its address in the application manager.
4. The processor receives these tags along with the ID of the account-max-sell-size rule set in the token handler. 
5. The processor then tries to retrieve the sub-rule associated with each tag.
6. The processor evaluates whether each sub-rule's period is active (if the current time is within `period` from the `starting timestamp`). If it is not within the period, it sets the cumulative sales to the current sale amount. If it is within the period, the processor adds the current sale amount to the accrued sale amount for the rule period.   
7. The processor then checks if the cumulative sales amount is greater than the `maxSize` defined in the rule. If true, the transaction reverts. 
8. Steps 4 and 5 are repeated for each of the account's tags.
9. Return the cumulative sales amount.

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkAccountMaxSellSize*

## Evaluation Exceptions 
This rule doesn't apply when:
- An approved Trading-Rule Whitelisted address is in the *from* side of the transaction.
- rulebypasser account is in the *from* or *to* side of the transaction.

Additionally, in the case of the ERC20, this rule doesn't apply also when registered treasury address is in the *to* side of the transaction. 

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error OverMaxSellSize();
```

The selector for this error is `0x91985774`.

## Create Function

Adding an account-max-sell-size rule is done through the function:

```c
function addAccountMaxSellSize(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint192[] calldata _maxSizes,
        uint16[] calldata _period,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_accountTypes** (bytes32[]): Array of applicable general tags.
- **_maxSizes** (uint192[]): Array of sell amounts corresponding to each tag.
- **_period** (uint16[]): Array of sell periods corresponding to each tag. 
- **_startTime** (uint64): Unix timestamp for the *_period* to start counting. It applies to each tag.


### Parameter Optionality:
none

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- All input array lengths must be equal and not empty.
- `_appManagerAddr` Must not be the zero address.
- `_accountTypes` `tag` can either be a single blank tag or a list of non blank `tag`s.
- `_maxSizes` 0 not allowed.
- `_startTime` 0 not allowed. Must be less than 1 year into the future.



###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getAccountMaxSellSizeByIndex(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.AccountMaxSellSize memory, uint64 startTime);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAccountMaxSellSize() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkAccountMaxSellSize(uint32 ruleId, uint256 salesInPeriod, uint256 amount, bytes32[] calldata fromTags, uint64 lastUpdateTime) external view returns (uint256);
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setAccountMaxSellSizeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activateAccountMaxSellSize(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isAccountMaxSellSizeActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getAccountMaxSellSizeId(ActionTypes _action) external view returns (uint32);
        ```
## Return Data

This rule returns the value:
1. **Total Sales by Account Within Period** (uint64): the updated value for the total sold for the account during the period. 

```c
uint64 salesInPeriod;
```

*see [Token Handler](../../../src/client/token/ProtocolHandlerCommon.sol)*

## Data Recorded

This rule requires recording of the following information in the asset handler:

- **Total Sales by Account Within Period** (uint256): the updated value for the total sold by account during the period. 
- **Previous Sell Time** (uint64): the Unix timestamp of the last update in the Last-Transfer-Time variable

```c
mapping(address => uint256) salesInPeriod;
mapping(address => uint64) lastSellTime;
```

*see [Token Handler](../../../src/client/token/ProtocolHandlerCommon.sol)*

## Events

- **event AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ACCOUNT_MAX_SELL_SIZE".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "ACCOUNT_MAX_SELL_SIZE".
        - action: the protocol action the rule is being applied to.
        - ruleId: the index of the rule created in the protocol by rule type.

- **event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action)** 
    - Emitted when: An Account Max Sell Size rule has been activated in an asset handler:
    - Parameters:
        - ruleType: "ACCOUNT_MAX_SELL_SIZE".
        - action: the protocol action for which the rule is being activated.

## Dependencies

- **Tags**: This rule relies on accounts having a matching [tag](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md) or the rule being configured with a blank [tag](../GLOSSARY.md).