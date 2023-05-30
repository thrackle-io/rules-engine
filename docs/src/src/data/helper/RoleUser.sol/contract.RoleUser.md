# RoleUser
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/data/helper/RoleUser.sol)

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


