# Tags Guide
[![Project Version][version-image]][version-url]
--- 

## Tag Information Documentation: 

The protocol uses tags to assess fees and facilitate rule checks for addresses. Tags are applied to addresses via an addTag function in the app manager by application administators. Tags are stored as bytes32 in a mapping inside the tags data contract. A maximum of 10 tags may be applied to each address. Their purpose is to be for application of rulesets to specific groups of individuals that may be too narrow to be encompassed in an access level. 

The tag data contract is deployed with and owned by the application manager contract. In the event of an upgrade the data contract can be migrated through a two step migration process. [App administrators](../permissions/ADMIN-ROLES.md) are the only ones who can migrate the data contracts to a new app manager contract. To understand the structure of tags at a far more indepth level please check [here](./PROTOCOL-TAGS-STRUCTURE.md). If you would like an overview of all the tags available, there is a list located [here](./TAGGED-RULES.md).

## Quick start

Lets begin a quick example of using tags. First, it is assumed that you have already [deployed the protocol locally](../deployment/DEPLOY-PROTOCOL.md), have an [application manager set up](../deployment/DEPLOY-APPMANAGER.md) as well as a [rule admin in place](../permissions/ADMIN-ROLES.md#rule-admin) and have deployed a token with an appropriate token handler contract address handy. If not, please set those variables up now.

For our example we're going to do a simple minimum/maximum token balance to be held by an account over a specified number of hours. If you'd like to dive deeper at any point, we recommend you read more [here](../rules/ACCOUNT-MIN-MAX-TOKEN-BALANCE.md). Lets begin by saying that for all users with the tag "A" we want to be able to demand that they have a minimum balance of 20 and a maximum balance of 100 for a time frame of 3 hours. We would pass in the parameters to the function:
```addAccountMinMaxTokenBalance(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _min,
        uint256[] calldata _max,
        uint16[] calldata _periods,
        uint64 _startTime)
```

such that _appManagerAddr is `$APPLICATION_APP_MANAGER`, _accountTypes is `[0x4100000000000000000000000000000000000000000000000000000000000000]` which contains the hex input for 'A' with zeros appended, _min is `[20]`, _max is `[100]`, _periods is `[3]` for the number of hours required and _startTime is the current unix timestamp for when the checks should start, which due to the way the contracts are constructed, we can use the number 0 to get. The final call to this would look something like:

```
 cast send $RULE_PROCESSOR_DIAMOND --private-key $RULE_ADMIN_KEY "addAccountMinMaxTokenBalance(address,bytes32[],uint256[],uint256[],uint16[],uint64)" $APPLICATION_APP_MANAGER "[0x4100000000000000000000000000000000000000000000000000000000000000]" "[20]" "[100]" "[3]" 0
```

Once this is cleared, we need to get the index of the rule that was just created. If you're using cast or a client side sdk for interaction, you'll want to pull this from the logs on the signature `AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)` and search for the ruleId. Here's an example of how that would look using cast:

```cast logs --from-block $BLOCK_IN_TX --address $RULE_PROCESSOR_DIAMOND```
 
From the output, search for the third argument in the topics to get the ruleId in a bytes format. If you're using a smart contract to deploy the code, simply take the returned uint32 from the call to the function as this is the `ruleId`. Once you have the ruleId, it's time to add it to the application. Call the function on your token handler `setAccountMinMaxTokenBalanceId(uint8[],uint32)` where the uint8 array is an array of enum selections from the [action types](../rules/ACTION-TYPES.md) and the uint32 is the ruleId. For our purposes we're going to add all of the action types into our transaction send.

```
 cast send $APPLICATION_ERC20_HANDLER_ADDRESS --private-key $RULE_ADMIN_KEY "addAccountMinMaxTokenBalance(address,bytes32[],uint256[],uint256[],uint16[],uint64)" $APPLICATION_ERC20_HANDLER_ADDRESS "[0,1,2,3,4,5]" $RULEID
 ```

 Finally, we activate the rule using `activateAccountMinMaxTokenBalance(uint8[],bool)` and can begin tagging accounts:

 ```
 cast send $APPLICATION_ERC20_HANDLER_ADDRESS --private-key $RULE_ADMIN_KEY "activateAccountMinMaxTokenBalance(uint8[],bool)" "[0,1,2,3,4,5]" true
 ```

And can now call `addTag(address _account,bytes32 _tag)` with the App admin on the application manager to tag an account. 

 ```
 cast send $APPLICATION_APP_MANAGER --private-key $APP_ADMIN_PRIVATE_KEY "addTag(address,bytes32)" 0x... 0x4100000000000000000000000000000000000000000000000000000000000000
 ```
<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.3.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-engine