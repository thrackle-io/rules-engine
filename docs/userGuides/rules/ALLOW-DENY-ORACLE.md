# Allow Deny Oracle Rule

## Purpose

The purpose of the allow-deny-oracle rule is to check if the receiver address in the transaction is an allowed address or to check if the sender is restricted from performing the transaction. Addresses are added to the oracle lists by the owner of the oracle contract for any reason that the owner deems necessary. 

If an address is not on an allowed oracle list, they will be restricted from receiving application tokens. This rule can be used to restrict transfers to only specific contract addresses or wallets that are approved by the oracle owner. An example is NFT exchanges that support ERC2981 royalty payments. 

The deny list is designed as a tool to reduce the risk of malicious actors in the ecosystem. If an address is on the deny oracle list they are restricted from performing the transaction. Any address not on the deny list will pass this rule check.

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 

This rule works at both the token level and AMM level. It must be activated and configured for each desired token in the corresponding token handler or each desired AMM in the AMM Handler.

## Data Structure

An allow-deny-oracle rule is composed of 2 components:

- **Oracle Type** (uint8): The Type of Oracle (0 for denied, 1 for allowed).
- **Oracle Address** (address): The address of the allow Oracle contract. 

```c
/// ******** Oracle ********
struct OracleRule {
    uint8 oracleType; /// enum value --> 0 = restricted; 1 = allowed
    address oracleAddress;
}
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleProcessor/RuleDataInterfaces.sol)*

The allow-oracle rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
/// ******** Oracle ********
struct OracleRuleS {
    mapping(uint32 => INonTaggedRules.OracleRule) oracleRules;
    uint32 oracleRuleIndex;
}
```
###### *see [IRuleStorage](../../../src/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.

## Rule Evaluation

The rule will be evaluated with the following logic:

1. The processor will receive the ID of the allow-oracle rule set in the application handler. 
2. The processor will receive the address that is to be checked in the oracle.
3. The processor will determine the type of oracle based on the rule id. 
4. The processor will then call the oracle address to check if the address to be checked is on the oracle's list: 
- Allow list: check if the receiver address is an allowed address. If the address is not on the allowed list the transaction will revert. 
- Deny list: check if the sender is a denied address. If the address is restricted the transaction will revert. 

###### *see [ERC20RuleProcessorFacet](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkOraclePasses*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with one of the following errors if the rule check fails: 

```
error AddressNotOnAllowedList();
```

The selector for this error is `0x7304e213`.

```
error AddressIsRestricted();
```

The selector for this error is `0x6bdfffc0`.

## Create Function

Adding an allow-deny-oracle rule is done through the function:

```c
function addOracleRule(
    address _appManagerAddr, 
    uint8 _type, 
    address _oracleAddress
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/economic/ruleProcessor/RuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_oracleType** (uint8): The type of oracle for this rule (0 for denied, 1 for allowed).
- **_oracleAddress** (address): the address of the allow oracle.


### Parameter Optionality:

There is no parameter optionality for this rule. 

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_oracleAddress` is not the zero address. 
- `_type` is not greater than 1. 


###### *see [RuleDataFacet](../../../src/economic/ruleProcessor/RuleDataFacet.sol)*

## Other Functions:

- In Protocol [ERC20RuleProcessorFacet](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getOracleRule(
                    uint32 _index
                ) 
                external 
                view 
                returns 
                (NonTaggedRules.OracleRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalOracleRules() public view returns (uint32);
        ```
- In Protocol [ERC20RuleProcessorFacet](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkOraclePasses(
                    uint32 _ruleId, 
                    address _address
                    ) 
                    external 
                    view;
        ```
- in Application Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setOracleRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateOracleRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isOracleActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getOracleRuleId() external view returns (uint32);
        ```
## Return Data

This rule does not return any data.

## Data Recorded

This rule does not require any data to be recorded. 

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ORACLE".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "ORACLE".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the index of the rule created in the protocol by rule type.
        
- **event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)**:
    - Emitted when: rule has been activated in the asset handler.
    - Parameters:
        - ruleType: "ORACLE".
        - handlerAddress: the address of the asset handler where the rule has been activated.

## Dependencies

- This rule is dependant on a deployed oracle with either of the function signatures:

```c
function isRestricted(address _address) external view returns (bool)
```
```c
function isAllowed(address _address) external view returns (bool)
```