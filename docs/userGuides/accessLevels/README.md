# ACCESS LEVELS CONTRACTS

## Purpose

The purpose of access levels is to provide a tiered approach to user verification and/or categorization before a user can receive certain assets and privileges in an application. Access levels may be defined using built-in protocol functionality or an external provider:

- [Protocol Access Level](./PROTOCOL-ACCESS-LEVEL-STRUCTURE.md).
- [External Access Level](./EXTERNAL-ACCESS-LEVEL-PROVIDER.md).

Access levels are used with the following rules:

- [Maximum Account Balance By Access Level Rule](../rules/ACCOUNT-MAX-BALANCE-BY-ACCESS-LEVEL.md).
- [Withdrawal Limit By Access Level](../rules/ACCOUNT-MAX-VALUE-OUT-BY-ACCESS-LEVEL.md).
- [Account Deny For No Access Level](../rules/ACCOUNT-DENY-FOR-NO-ACCESS-LEVEL.md).

## Quick Start

Deploy the protocol and your application manager using the [deployment guide](../deployment/README.md). Once you have that set up, it's time to start setting up your access levels.

```
cast send --rpc-url $RPC_URL --private-key $PRIVATE_KEY $APP_MANAGER_ADDRESS --method "addAccessLevel(address,uint256)" $USER_ADDRESS 1
```

The above command will add the user in $USER_ADDRESS to the access level 1. This user now has an elevated status above other users and can move assets more freely in your setup than a user with an access level of 0. For example, we can set a rule for the user to only be able to withdraw 1000 USDC from their account once they've reached access level 1 using the [Withdrawal Limit By Access Level](../rules/ACCOUNT-MAX-VALUE-OUT-BY-ACCESS-LEVEL.md) rule. 

We will call the function `addAccountMaxValueOutByAccessLevel(address,uint48[])` on the protocol address using our ruleAdministrator account with the address in the function signature being the address of the application manager and the array of uints being [0, 10000000, 10000000, 10000000, 10000000, 10000000]. 

```
cast send --rpc-url $RPC_URL --private-key $PRIVATE_KEY $PROTOCOL_ADDR --method "addAccountMaxValueOutByAccessLevel(address,uint48[])" $APP_MANAGER_ADDRESS "[0, 10000000, 10000000, 10000000, 10000000, 10000000]"
```

The number is slightly larger to account for the 4 decimal places of the USDC token and repeated so that we account for all levels available when crafting an access level. This will return a uint256 which is the ID of the rule. Once we have this ruleId, we can add it to our access level using the `setAccountMaxValueOutByAccessLevelId(uint32 _ruleId)` function on the application handler.

```
cast send --rpc-url $RPC_URL --private-key $PRIVATE_KEY $APP_HANDLER_ADDR --method "setAccountMaxValueOutByAccessLevelId(uint32 _ruleId)" $RULE_ID
```
