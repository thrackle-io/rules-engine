# ACCESS LEVELS CONTRACTS

## Purpose

The purpose of access levels is to provide a tiered approach to user verification and/or categorization before a user can receive certain assets and privileges in an application. Access levels may be defined using built-in protocol functionality or an external provider:

- [Protocol Access Level](./PROTOCOL-ACCESS-LEVEL-STRUCTURE.md).
- [External Access Level](./EXTERNAL-ACCESS-LEVEL-PROVIDER.md).

Access levels are used with the following rules:

- [Maximum Account Value By Access Level Rule](../rules/ACCOUNT-MAX-VALUE-BY-ACCESS-LEVEL.md).
- [Withdrawal Limit By Access Level](../rules/ACCOUNT-MAX-VALUE-OUT-BY-ACCESS-LEVEL.md).
- [Account Deny For No Access Level](../rules/ACCOUNT-DENY-FOR-NO-ACCESS-LEVEL.md).

## Quick Start

Deploy the protocol and your application manager using the [deployment guide](../deployment/README.md). Before you start be sure that you have also registered a [rule admin](../permissions/ADMIN-ROLES.md#rule-admin) and assumed that the `$RULE_ADMIN` private key is equivalent to `$RULE_ADMIN_KEY` in the following example.

For example, we can set a rule for the user to only be able to withdraw 1000 USDC from their account once they've reached access level 1 using the [Withdrawal Limit By Access Level](../rules/ACCOUNT-MAX-VALUE-OUT-BY-ACCESS-LEVEL.md) rule. In order to set this up we first will call the function `addAccountMaxValueOutByAccessLevel(address,uint48[])` on the protocol address using our ruleAdministrator account with the address in the function signature being the address of the application manager and the array of uints being [0, 10000000, 10000000, 10000000, 10000000]. 

```
cast send --rpc-url $ETH_RPC_URL --private-key $RULE_ADMIN_KEY $RULE_PROCESSOR_DIAMOND --method "addAccountMaxValueOutByAccessLevel(address,uint48[])" $APPLICATION_APP_MANAGER "[0, 10000000, 10000000, 10000000, 10000000]"
```

The number is slightly larger to account for the 4 decimal places of the USDC token and repeated so that we account for all levels available when crafting an access level. This will return a uint32 which is the ID of the rule. Because cast doesn't wrangle the calls well, we're going to have to take the tx id and parse for the event logs. Take note of the receipt that was generated from the last command and be mindful of the `to` and the `blockNumber` fields:

```
cast logs --from-block $blockNumber --address $to
```

The output should look something like this:

```
- address: 0xC9a43158891282A2B1475592D5719c001986Aaec
  blockHash: 0xaac11668303e28d24789511b0753ef16a58a9afdf06c2de2d07320758b274c61
  blockNumber: 60
  data: 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000
  logIndex: 0
  removed: false
  topics: [
        0xc8c31d1b3fae743175dd37c3ed86aca4d193c9fcd5732cc172fbd4e9bc170e8a
        0x4143435f4d41585f56414c55455f4f55545f4143434553535f4c4556454c0000
        0x0000000000000000000000000000000000000000000000000000000000000000
  ]
  transactionHash: 0xb561d85b097c3e67a3b4eff1b44f93b9b7e8f744f4ba390bdf2d4c6d0e88848b
  transactionIndex: 0
```

The topics field is where you are going to want to pay attention to as this contains the variable you want. In our particular case above because this is a fresh deployment on a local machine, we are taking the 0th position in the rules list. Therefore our `ruleId` is 0 and we can pass that along to our application manager. It should be noted that if you were to run this in a smart contract script, you would just need to take the return value generated from `addAccountMaxValueOutByAccessLevel`. Once we have this ruleId, we can add it to our access level using the `setAccountMaxValueOutByAccessLevelId(uint32 _ruleId)` function on the application handler.

```
cast send --rpc-url $RPC_URL --private-key $RULE_ADMIN_KEY $APP_HANDLER_ADDR --method "setAccountMaxValueOutByAccessLevelId(uint32 _ruleId)" $RULE_ID
```

Once you have that set up, it's time to start setting up your access levels.

```
cast send --rpc-url $RPC_URL --private-key $RULE_ADMIN_KEY $APP_MANAGER_ADDRESS --method "addAccessLevel(address,uint256)" $USER_ADDRESS 1
```

The above command will add the user in $USER_ADDRESS to the access level 1. This user now has an elevated status above other users and can move assets more freely in your setup than a user with an access level of 0. 