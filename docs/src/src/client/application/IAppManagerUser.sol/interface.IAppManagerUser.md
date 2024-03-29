# IAppManagerUser
[Git Source](https://github.com/thrackle-io/tron/blob/28055da058876a0a8138d3f9a19aa587a0c30e2b/src/client/application/IAppManagerUser.sol)

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

