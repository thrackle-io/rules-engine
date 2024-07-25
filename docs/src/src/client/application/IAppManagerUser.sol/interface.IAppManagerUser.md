# IAppManagerUser
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/268b521956cf89a918ed12522e8182d2df0cd3b2/src/client/application/IAppManagerUser.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Interface for app manager user functions.

*This interface is implemented by all contracts that use AppManager. It provides the common function for setting up a new link to an AppManager*


## Functions
### confirmAppManagerAddress

*This function confirms a new appManagerAddress that was put in storage. It can only be confirmed by the proposed address*


```solidity
function confirmAppManagerAddress() external;
```

