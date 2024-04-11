# Adding A New Token Level Rule To The Handler Diamond

## Purpose

There are several updates that need to take place in order to add a new token level rule. In this document we'll be covering the steps required to update the assciated token asset diamond including: updating the code for the appropriate facets and upgrading the effected handler diamonds. This document will walk through the process step by step. (We will be using an existing rule, Token Minimum Transaction Size, as our example) 

## Creating The Rule

### Updating Diamond Storage

The first step is to update the diamond storage to account for the new rule. We'll need to update [StorageLib](../../../../../src/client/token/handler/StorageLib.sol). For our example we would first add the following constant to the top of the contract to define the storage position for our Token Minimum Transaction Size rule:

```c
bytes32 constant TOKEN_MIN_TX_SIZE_HANDLER_POSITION = bytes32(uint256(keccak256("token-min-tx-size-position")) - 1);
```

Next we'll want to define the storage structure for our rule. For our example we would add the following struct to [RuleStorage](../../../../../src/client/token/handler/ruleContracts/RuleStorage.sol):

```c
struct TokenMinTxSizeS{
    mapping(ActionTypes => Rule) tokenMinTxSize;
}
```

Finally we'll want to add a function to retrieve the storage for our rule to StorageLib.sol. For our example we would add the following function:

```c
    function tokenMinTxSizeStorage() internal pure returns (TokenMinTxSizeS storage ds);
```

### Facet Updates

The next step is to create the contract responsible for managing the rule. In `src/client/token/handler/ruleContracts` you will see a contract for each existing rule that implements the following four functions: setRuleName, activateRuleName, getRuleNameId, isRuleNameActive (RuleName being replaced by the name of the specific rule instace the file is handling). For our example we'll be looking at the `HandlerTokenMinTxSize.sol` contract which implements the following four functions: `setTokenMinTxSizeId`, `activateMinTransactionSizeRule`, `getTokenMinTxSizeId`, and `isTokenMinTxSizeActive`. 

The following function uses the ruleId we received when we created the instance of the rule to set the instance in the diamond and activate it for the list of passed in actions:

```c
    function setTokenMinTxSizeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```

The following function is used to activate/deactivate the instance of the rule that's already set in the diamond for the list of passed in actions:

```c
    function activateMinTransactionSizeRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```

The following function is used to retrieve the rule id for the Minimum Transaction Size Rule currently set on the diamond (for the specified action):

```c
    function getTokenMinTxSizeId(ActionTypes _action) external view returns (uint32);
```

The following function is used to check whether the rule is currently active for the given action:

```c 
    function isTokenMinTxSizeActive(ActionTypes _action) external view returns (bool);
```

The next step is to update the appropriate Rule Facet to include a check for our new rule. For our example we'll be updating the [ERC20NonTaggedRuleFacet](../../../../../src/client/token/handler/ERC20NonTaggedRuleFacet.sol). 

The facet must first be updated to implement the contract we just created:

```c
contract ERC20NonTaggedRuleFacet is HandlerTokenMinTxSize, ...
```

Then a check needs to be added to the `checkNonTaggedRules` function:

```c
    function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external {
        ...
        
        if (lib.tokenMinTxSizeStorage().tokenMinTxSize[action].active) 
            IRuleProcessor(handlerBaseStorage.ruleProcessor).checkTokenMinTxSize(lib.tokenMinTxSizeStorage().tokenMinTxSize[action].ruleId, _amount);
        
        ...
```

### Upgrading Existing Diamonds

Once the above changes have been made to add the new rule, in order to make the rule available we will need to upgrade the existing diamond instance. Step by step instructions on this upgrade are provided in [PROTOCOL-ASSET-HANDLER-DIAMOND-UPGRADE.md](../../../Architecture/Client/AssetHandler/PROTOCOL-ASSET-HANDLER-DIAMOND-UPGRADE.md) 