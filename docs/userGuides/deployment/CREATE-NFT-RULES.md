# NFT Rule Creation
[![Project Version][version-image]][version-url]

---

1.  Ensure the [environment variable][environment-url] is set correctly.
2.  Create a token specific rule:
    -  Get the rule creation function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the Rule Storage Diamond sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the Rule Storage Diamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. 
        -  This will return a ruleId, please take note of this value.
3.  Apply the token specific rule to the application
    -  Get the rule application function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the ERC721Handler created in previous steps.
4.  Repeat for each desired token specific rule

### Example using NFT Transfer Control Rule
1.  Ensure the [environment variable][environment-url] is set correctly.
2.  Create a token specific rule:
    -  Get the rule creation function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the Rule Storage Diamond sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the Rule Storage Diamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. NOTE: Metadata tags must be sent in as bytes32. This can be done with any [keccak converter][keccak-url]. For instance, a tag named "TransferRestriction1" would be sent as: _0x44628a3708ec20e64749d41fc781a34a888977eaf5b82cfa61d0dbccb8665903_ 
        ````
        cast send 0x59b670e9fA9D0A427751Af201D676719a970857b "addNFTTransferCounterRule(address,bytes32[],uint8[])(uint256)" --rpc-url  $ETH_RPC_URL 0x0116686E2291dbd5e317F47faDBFb43B599786Ef \[0x44628a3708ec20e64749d41fc781a34a888977eaf5b82cfa61d0dbccb8665903] \[2] --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc 
        ````

        -  This function will return a ruleId, please take note of this value. It can be found in the _logs_ section of the output as the second value in the topics section. It will be the last digits so in the example, _0000_(0 is a valid rule id) is the ruleId:
            ````
            logs                    [{"address":"0x59b670e9fa9d0a427751af201d676719a970857b","topics":["0x0cc5ec27eaf8acfcfb3123c711cd141f2914380495f9d58c7cbfe5c44bfd5b4e","0x0000000000000000000000000000000000000000000000000000000000000000","0x2702176aef9ea802f11f79f52f4272fdabd0acfdd18fd1bb20466064c90361c6"],"data":"0x000000000000000000000000000000000000000000000000000000006446b336","blockHash":"0x42551b1c37b94e2eec95893d04605b35974afc1a6ed0396d7aa76e4645c82528","blockNumber":"0x25","transactionHash":"0x918fd7efbeba207daa246f25f0d68beda25a762d6403ac146209ae17b2dcda2b","transactionIndex":"0x0","logIndex":"0x0","transactionLogIndex":"0x0","removed":false}]
            ````
3.  Apply the token specific rule to the NFT
    -  Get the rule application function from the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] and invoke it on the NFTHandler created in previous steps.
        ````
        cast send 0x82e01223d51Eb87e16A03E24687EDF0F294da6f1 "setTradeControlRuleId(uint32)" 0 --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc  --rpc-url  $ETH_RPC_URL 
        ````
<!-- These are the body links -->
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md
[tokenSpecificRuleDirectory-url]: ../rules/TOKEN-RULE-DIRECTORY.md
[environment-url]: ./SET-ENVIRONMENT.md
[keccak-url]: https://keccak-256.4tools.net


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron