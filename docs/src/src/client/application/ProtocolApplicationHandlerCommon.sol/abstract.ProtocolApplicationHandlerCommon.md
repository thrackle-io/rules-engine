# ProtocolApplicationHandlerCommon
[Git Source](https://github.com/thrackle-io/tron/blob/cbc87814d6bed0b3e71e8ab959486c532d05c771/src/client/application/ProtocolApplicationHandlerCommon.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220

This contract is the permissions contract

*This contains common functions for the protocol application handler*


## State Variables
### lastPossibleAction

```solidity
uint8 constant lastPossibleAction = 4;
```


## Functions
### validateRuleInputFull

The actions and ruleIds lists must be the same length and at least one action must be present

*Validate the full atomic rule setter function parameters*


```solidity
function validateRuleInputFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|list of applicable actions|
|`_ruleIds`|`uint32[]`|list of ruleIds for each action|


