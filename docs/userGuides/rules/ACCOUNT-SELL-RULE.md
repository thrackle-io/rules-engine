# Account Sell Rule

## Purpose

The Account Sell Rule is an account based measure which restricts an account’s ability to sell a token. This may be put in place to restrict large transactions from occurring against suspected malicious accounts or other accounts of interest. The amount of sales allowed depends on the account's tags. Different accounts may get different sale restrictions depending on their tags.

## Applies To:

- [ ] ERC20
- [ ] ERC721
- [x] AMM

## Scope 

This rule works at the AMM level. It must be activated and configured for each desired AMM in the corresponding AMM handler. This rule will not be applied at the token level and will only be checked through the AMM swap function. 

## Data Structure

As this is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. An account-sell-controller "sub-rule" is specified by 3 variables:

- **Sell Amounts** (uint192): The maximum amount of tokens that may be sold during the *sell period*. 
- **Sell Periods** (uint16): The length of each time period for which the rule will apply, in hours.
- **Starting Timestamp** (uint64): The timestamp of the date when the *period* starts counting.


```c
/// ******** Account Sell Rules ********
    struct SellRule {
        uint256 sellAmount; /// token units
        uint16 sellPeriod; /// hours
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

Additionally, each one of these data structures will be under a tag (bytes32):

 tag -> sub-rule.

 ```c
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.SellRule)) 
```
###### *see [IRuleProcessor](../../../src/protocol/economic/ruleProcessor/IRuleProcessor.sol)*

The collection of these tagged sub-rules composes an account-sell-controller rule.

```c
    /// ******** Account Sell Rules ********
    struct SellRuleS {
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.SellRule)) sellRulesPerUser;
        uint64 startTime; /// Time the rule is created
        uint32 sellRulesIndex; /// increments every time someone adds a rule
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

1. The account being evaluated passes to the protocol all the tags it has registered to its address in the application manager.
2. The processor receives these tags along with the ID of the account-sell-controller rule set in the token handler. 
3. The processor then tries to retrieve the sub-rule associated with each tag.
4. The processor evaluates whether each sub-rule's period is active (if the current time is within `period` from the `starting timestamp`). If it is not within the period, it sets the cumulative sales to the current sale amount. If it is within the period, the processor adds the current sale amount to the accrued sale amount for the rule period.   
5. The processor then checks if the cumulative sales amount is greater than the `sell amount` defined in the rule. If true, the transaction reverts. 
6. Steps 4 and 5 are repeated for each of the account's tags.
7. Return the cumulative sales amount.

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkSellLimit*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. 

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error TemporarySellRestriction();
```

The selector for this error is `0xc11d5f20`.

## Create Function

Adding an account-sell-controller rule is done through the function:

```c
function addSellRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint192[] calldata _sellAmounts,
        uint16[] calldata _sellPeriod,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_accountTypes** (bytes32[]): Array of applicable general tags.
- **_sellAmounts** (uint192[]): Array of sell amounts corresponding to each tag.
- **_sellPeriod** (uint16[]): Array of sell periods corresponding to each tag. 
- **_startTime** (uint64): Unix timestamp for the *_sellPeriod* to start counting. It applies to each tag.


### Parameter Optionality:
none

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- All input array lengths must be equal and not empty.
- `_appManagerAddr` Must not be the zero address.
- `_accountTypes` No blank tags.
- `_sellAmounts` 0 not allowed.
- `_startTime` 0 not allowed. Must be less than 1 year into the future.



###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getSellRuleByIndex(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.SellRule memory, uint64 startTime);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalSellRule() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkSellLimit(uint32 ruleId, uint256 salesWithinPeriod, uint256 amount, bytes32[] calldata fromTags, uint64 lastUpdateTime) external view returns (uint256);
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setSellLimitRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateSellLimitRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isSellLimitActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getSellLimitRuleId() external view returns (uint32);
        ```
## Return Data

This rule returns the value:
1. **Total Sales by Account Within Period** (uint64): the updated value for the total sold for the account during the period. 

```c
uint64 salesWithinPeriod;
```

*see [AMMHandler](../../../src/client/liquidity/ProtocolAMMHandler.sol)*

## Data Recorded

This rule requires recording of the following information in the asset handler:

- **Total Sales by Account Within Period** (uint256): the updated value for the total sold by account during the period. 
- **Previous Sell Time** (uint64): the Unix timestamp of the last update in the Last-Transfer-Time variable

```c
mapping(address => uint256) salesWithinPeriod;
mapping(address => uint64) lastSellTime;
```

*see [AMMHandler](../../../src/client/liquidity/ProtocolAMMHandler.sol)*

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "SELL_LIMIT".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "SELL_LIMIT".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the index of the rule created in the protocol by rule type.

- **event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)** emitted when an Account Sell Controller rule has been activated in an asset handler:
    - ruleType: "SELL_LIMIT".
    - handlerAddress: the address of the asset handler where the rule has been activated.

## Dependencies

- **Tags**: This rules relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.