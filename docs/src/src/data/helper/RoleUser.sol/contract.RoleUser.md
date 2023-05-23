# RoleUser
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/data/helper/RoleUser.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract stores permission roles

*This is intended to be inherited by role users.*


## State Variables
### USER_ROLE

```solidity
bytes32 public constant USER_ROLE = keccak256("USER");
```


### APP_ADMIN_ROLE

```solidity
bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
```


### ACCESS_TIER_ADMIN_ROLE

```solidity
bytes32 public constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
```


### RISK_ADMIN_ROLE

```solidity
bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
```


