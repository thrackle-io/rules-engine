# Application Rules
[![Project Version][version-image]][version-url]

---

## Application Rule Implementation Overview
1.  Ensure the [environment variables][environment-url] are set correctly.
2.  Create an application rule:
    -  Get the rule creation function from the [Application Rule Directory][appRuleDirectory-url] and invoke it on the RuleProcssorDiamond, sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the RuleProcssorDiamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. 
       -  This function will return a ruleId, please take note of this value.
3.  Apply the application rule to the application
    -  Get the rule application function from the rule directory and invoke it on the Application Handler created in previous steps.
4.  Repeat for each desired application rule

## Example using Balance by Access Level Rule
1.  Create an application rule:
    -  Get the _Balance by Access Level Rule_ creation function from the [Application Rule Directory][appRuleDirectory-url] and invoke it on the RuleProcssorDiamond, sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the RuleProcssorDiamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. 
        ````
        cast send $RULE_STORAGE_DIAMOND "addAccessLevelBalanceRule(address,uint48[])(uint256)" $APPLICATION_APP_MANAGER \[0,10,100,1000,100000] --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1
        ````
        -  This function will return a ruleId, please take note of this value. It can be found in the _logs_ section of the output as the second value in the topics section. It will be the last digits so in the example, _00002_ is the ruleId:
            ````
            logs                    [{"address":"0x59b670e9fa9d0a427751af201d676719a970857b","topics":["0xec056b9c458ed605f3ee203934a18f53f3e77a445df9391d1a27714e768ee121","0x0000000000000000000000000000000000000000000000000000000000000002","0x15f03dd9ceacb82e23807f5bd2f3d03abada7618f21e6222f38058a940e56ba0"],"data":"0x000000000000000000000000000000000000000000000000000000006446aeff","blockHash":"0x5dd332896a9db8bc0e74e5d095bbf1b0aa2a53e068cffc77d5761d95e15069a9","blockNumber":"0x16","transactionHash":"0x763eb5e6ee7712804fd5ca4b7c467f7f71f2fd7543237676ee5ac1a6bea3daf6","transactionIndex":"0x0","logIndex":"0x0","transactionLogIndex":"0x0","removed":false}]
            ````

2.  Apply the application rule to the application
    -  Get the rule application function from the rule directory and invoke it on the ApplicationHandler created in previous steps.
        ````
        cast send $APPLICATION_APP_MANAGER "setAccountBalanceByAccessTierRuleId(uint32)" 00002  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1
        ````



<!-- These are the body links -->
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md
[appRuleDirectory-url]: ../rules/APP-RULE-DIRECTORY.md
[environment-url]: ./SET-ENVIRONMENT.md


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron