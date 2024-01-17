# Account Purchase Rule

## Purpose

The Account Purchase Rule is an account based measure which restricts an account’s ability to purchase more of a token. This may be put in place to restrict large transactions from occurring against suspected malicious accounts or other accounts of interest. The amount of purchases allowed depends on the account's tags. Different accounts may get different purchase restrictions depending on their tags.

## Applies To:

- [x] ERC20
- [x] ERC721
- [ ] AMM

## Scope 

This rule works at the token level. It must be activated and configured for each token in the corresponding token handler.

## Data Structure

As this is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. An account-purchase-controller "sub-rule" is specified by 2 variables:

- **Purchase Amounts** (uint192): The maximum amount of tokens that may be purchased during the *purchase period*. 
- **Purchase Periods** (uint16): The length of each time period for which the rule will apply, in hours.


```c
/// ******** Account Purchase Rules ********
     struct PurchaseRule {
        uint256 purchaseAmount; /// token units
        uint16 purchasePeriod; /// hours        
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

Additionally, each one of these data structures will be under a tag (bytes32) and the:

tag -> sub-rule.

 ```c
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.PurchaseRule)) 
```

And the starting Timestamp for the rule will be global for all tags:

- **Starting Timestamp** (uint64): The Unix timestamp of the date when the *period* starts counting.
 
```c

        mapping(uint32 => uint64) startTimes;///Time the rule is applied
```

###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

The collection of these tagged sub-rules plus the startingTime composes an account-purchase-controller rule.

```c
    /// ******** Account Purchase Rules ********
    struct PurchaseRuleS {
        /// ruleIndex => userType => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.PurchaseRule)) purchaseRulesPerUser;
        mapping(uint32 => uint64) startTimes;///Time the rule is applied
        uint32 purchaseRulesIndex; /// increments every time someone adds a rule
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
2. The token handler decides if the transfer is a Purchase (user perspective). Only if it is, it continues with the next steps.
3. The account is passed to the protocol with all the tags it has registered to its address in the application manager.
4. The processor receives these tags along with the ID of the account-purchase-controller rule set in the token handler. 
5. The processor retrieves the sub-rule associated with each tag.
6. The processor evaluates whether the rule is active based on the `starting timestamp`. If it is not active, the rule aborts the next steps, and returns zero as the accrued cumulative purchases value.
7. The processor evaluates whether the current time is within a new period.
   -If it is a new period, the processor sets the cumulative purchases to the current purchase amount.
   -If it is not a new period, the processor adds the current purchase amount to the accrued purchase amount for the rule period. 
8. The processor checks if the cumulative purchases amount is greater than the `purchase amount` defined in the rule. If true, the transaction reverts.
9. Steps 4 and 5 are repeated for each of the account's tags. In the case where multiple tags apply, the most restrictive is applied.
10. Returns the cumulative purchases amount.

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)]**

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkPurchaseLimit*

## Evaluation Exceptions 
This rule doesn't apply when:
- An approved Trading-Rule Whitelisted address is in the *to* side of the transaction.
- rulebypasser account is in the *from* or *to* side of the transaction.

Additionally, in the case of the ERC20, this rule doesn't apply also when registered treasury address is in the *to* side of the transaction.

### Revert Message

The rule processor reverts with the following error if the rule check fails: 

```
error TxnInFreezeWindow();
```

The selector for this error is `0xa7fb7b4b`.

## Create Function

Adding an account-purchase-controller rule is done through the function:

```c
function addPurchaseRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _purchaseAmounts,
        uint16[] calldata _purchasePeriods,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_accountTypes** (bytes32[]): Array of applicable general tags.
- **_purchaseAmounts** (uint192[]): Array of purchase amounts corresponding to each tag.
- **_purchasePeriod** (uint16[]): Array of purchase periods corresponding to each tag. 
- **_startTime** (uint64): Array of Unix timestamps for the *_purchasePeriod* to start counting that applies to each tag.


### Parameter Optionality:
none

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- All input array lengths must be equal and not empty.
- `_appManagerAddr` Must not be the zero address.
- `_accountTypes` No blank tags.
- `_purchaseAmounts` 0 not allowed.
- `_purchasePeriod` 0 not allowed.
- `_startTime` 0 not allowed. Must be a valid timestamp no more than 1 year into the future.



###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getPurchaseRule(uint32 _index, bytes32 _accountType) public view returns (TaggedRules.PurchaseRule memory, uint64 startTime);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalPurchaseRule() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkPurchaseLimit(uint32 ruleId, uint256 purchasedWithinPeriod, uint256 amount, bytes32[] calldata toTags, uint64 lastUpdateTime) external view returns (uint256);
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setPurchaseLimitRuleId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activatePurchaseLimitRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isPurchaseLimitActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getPurchaseLimitRuleId(ActionTypes _action) external view returns (uint32);
        ```
## Return Data

This rule returns the value:
1. **Total Purchases by Account Within Period** (uint64): the updated value for the total purchased for the account during the period. 

```c
uint256 cumulativeTotal;
```

*see [Token Handler](../../../src/client/token/ProtocolHandlerCommon.sol)*

## Data Recorded

This rule requires recording of the following information in the asset handler:

- **Total Purchases by Account Within Period** (uint256): the updated value for the total purchased by account during the period. 
- **Last Purchase Time** (uint64): the Unix timestamp of the last update in the Last-Transfer-Time variable

```c
mapping(address => uint256) purchasedWithinPeriod;
mapping(address => uint64) lastPurchaseTime;
```

*see [Token Handler](../../../src/client/token/ProtocolHandlerCommon.sol)*

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "PURCHASE_LIMIT".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "PURCHASE_LIMIT".
        - action: the protocol action the rule is being applied to.
        - ruleId: the index of the rule created in the protocol by rule type.

- **event ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action)** 
    - Emitted when: An Account Purchase Controller rule has been activated in an asset handler:
    - Parameters:
        - ruleType: "PURCHASE_LIMIT".
        - action: the protocol action for which the rule is being activated.

## Dependencies

- **Tags**: This rule relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.