# Adding A New Token Level Rule To The Rule Processor Diamond

## Purpose

There are several updates that need to take place in order to add a new token level rule. In this document we'll be covering the steps required to update the protocol rule processor diamond including: updating the code for the appropriate facets and upgrading the diamond. This document will walk through the process step by step. (We will be using an existing rule, Token Minimum Transaction Size, as our example) 

## Creating The Rule

### Updating Diamond Storage

The first step is to update the diamond storage to account for the new rule. We'll need to update [RuleStoragePositionLib](../../../../../src/protocol/economic/ruleProcessor/RuleStoragePositionLib.sol). For our example we would first add the following constant to the top of the contract to define the storage position for our Token Minimum Transaction Size rule:

```c
bytes32 constant TOKEN_MIN_TX_SIZE_POSITION = bytes32(uint256(keccak256("token-min-tx-size")) - 1);
```

Next we'll want to define the storage structure for our rule. For our example we would add the following struct to [IRuleStorage](../../../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol):

```c
    struct TokenMinTxSizeS {
        mapping(uint32 => INonTaggedRules.TokenMinTxSize) tokenMinTxSizeRules;
        uint32 tokenMinTxSizeIndex;
    }
```

Finally we'll want to add a function to retrieve the storage for our rule to RuleStoragePositionLib.sol. For our example we would add the following function:

```c
    function tokenMinTxSizePosition() internal pure returns (IRuleStorage.TokenMinTxSizeS storage ds) {
        bytes32 position = TOKEN_MIN_TX_SIZE_POSITION;
        assembly {
            ds.slot := position
        }
    }
```

### Facet Updates

The next step is to update the [RuleDataFacet](../../../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol) contract to include a function that can be used to create an instance of our new rule and register it with the diamond. For our example we would add the following function:

```c
    function addTokenMinTxSize(address _appManagerAddr, uint256 _minSize) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_minSize == 0) revert ZeroValueNotPermited();
        RuleS.TokenMinTxSizeS storage data = Storage.tokenMinTxSizePosition();
        NonTaggedRules.TokenMinTxSize memory rule = NonTaggedRules.TokenMinTxSize(_minSize);
        uint32 ruleId = data.tokenMinTxSizeIndex;
        data.tokenMinTxSizeRules[ruleId] = rule;
        emit ProtocolRuleCreated(TOKEN_MIN_TX_SIZE, ruleId, new bytes32[](0));
        ++data.tokenMinTxSizeIndex;
        return ruleId;
    }
```

### Upgrading Existing Diamonds

Once the above changes have been made to add the new rule, in order to make the rule available we will need to upgrade the existing diamond instance. Step by step instructions on this upgrade are provided in [RULE-PROCESSOR-DIAMOND-UPGRADE.md](../../../Architecture/Protocol/RULE-PROCESSOR-DIAMOND-UPGRADE.md) 