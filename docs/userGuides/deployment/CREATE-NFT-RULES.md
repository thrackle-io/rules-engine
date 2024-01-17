# NFT Rule Creation
[![Project Version][version-image]][version-url]

---

1.  Ensure the [environment variables][environment-url] are set correctly.
2.  Create a token specific rule:
    -  Get the rule creation function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the Rule Processor Diamond sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the Rule Processor Diamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. 
        -  This will return a ruleId, please take note of this value.
3.  Apply the token specific rule to the application
    -  Get the rule application function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the ERC721Handler created in previous steps.
4.  Repeat for each desired token specific rule

### Example using NFT Transfer Control Rule
1.  Ensure the [environment variables][environment-url] are set correctly.
2.  Create a token specific rule:
    -  Get the rule creation function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the Rule Processor Diamond sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the Rule Processor Diamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. NOTE: Metadata tags must be sent in as bytes32. This can be done with any [keccak converter][keccak-url]. For instance, a tag named "TransferRestriction1" would be sent as: _0x44628a3708ec20e64749d41fc781a34a888977eaf5b82cfa61d0dbccb8665903_. The final param of this rule is a unix timestamp of the rule starting time. 
        ````
        cast send $RULE_PROCESSOR_DIAMOND "addNFTTransferCounterRule(address,bytes32[],uint8[],uint64)(uint32)" $APPLICATION_APP_MANAGER \[0x44628a3708ec20e64749d41fc781a34a888977eaf5b82cfa61d0dbccb8665903] \[2] \1694033883 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1
        ````

        -  This function will return a ruleId, please take note of this value. It can be found in the _logs_ section of the output as the second value in the topics section. It will be the last digits so in the example, _0000_(0 is a valid rule id) is the ruleId:
            ````
            logs                    [{"address":"0x59b670e9fa9d0a427751af201d676719a970857b","topics":["0x0cc5ec27eaf8acfcfb3123c711cd141f2914380495f9d58c7cbfe5c44bfd5b4e","0x0000000000000000000000000000000000000000000000000000000000000000","0x2702176aef9ea802f11f79f52f4272fdabd0acfdd18fd1bb20466064c90361c6"],"data":"0x000000000000000000000000000000000000000000000000000000006446b336","blockHash":"0x42551b1c37b94e2eec95893d04605b35974afc1a6ed0396d7aa76e4645c82528","blockNumber":"0x25","transactionHash":"0x918fd7efbeba207daa246f25f0d68beda25a762d6403ac146209ae17b2dcda2b","transactionIndex":"0x0","logIndex":"0x0","transactionLogIndex":"0x0","removed":false}]
            ````
3.  Apply the token specific rule to the NFT
    -  Get the rule application function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the NFTHandler created in previous steps.
    -  Rules are applied against an array of Action Types (defined here [ActionEnum.sol](../../userGuides/rules/ACTION-TYPES.md)). For this example we're enabling the rule just for TRADE.
        ````
        cast send $APPLICATION_ERC721_HANDLER "setTradeCounterRuleId(uint8[], uint32)" [2] 0 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1
4. In order to apply this rule to specific accounts, each account must be tagged with the metadata tags set above.
        ````
<!-- These are the body links -->
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md
[tokenSpecificRuleDirectory-url]: ../rules/TOKEN-RULE-DIRECTORY.md
[environment-url]: ./SET-ENVIRONMENT.md
[keccak-url]: https://keccak-256.4tools.net


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron