# Global Rules
[![Project Version][version-image]][version-url]

---

## Global Rule Implementation Overview
1.  Ensure the [environment variable][environment-url] is set correctly.
2.  Create a global rule:
    1.  Get the rule creation function from the [Global Rule Directory][globalRuleDirectory-url] and invoke it on the Rule Storage Diamond, sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the Rule Storage Diamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. 
        1.  This function will return a ruleId, please take note of this value.
3.  Apply the global rule to the application
    1.  Get the rule application function from the rule directory and invoke it on the Application Handler created in previous steps.
4.  Repeat for each desired global rule

## Example using Balance by KYC Level Rule
1.  Create a global rule:
    1.  Get the _Balance by Access Level Rule_ creation function from the [Global Rule Directory][globalRuleDirectory-url] and invoke it on the Rule Storage Diamond, sending in the required parameters. NOTE: Each rule requires a different parameter set. For local deployments, the Rule Storage Diamond address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url]. 
        ````
        cast send 0x59b670e9fA9D0A427751Af201D676719a970857b "addAccessBalanceRule(address,uint48[])(uint256)" 0x0116686E2291dbd5e317F47faDBFb43B599786Ef \[0,10,100,1000,100000] --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc --rpc-url $ETH_RPC_URL
        ````

        1.  This function will return a ruleId, please take note of this value. It can be found in the _logs_ section of the output as the second value in the topics section. It will be the last digits so in the example, _00002_ is the ruleId:
            ````
            logs                    [{"address":"0x59b670e9fa9d0a427751af201d676719a970857b","topics":["0xec056b9c458ed605f3ee203934a18f53f3e77a445df9391d1a27714e768ee121","0x0000000000000000000000000000000000000000000000000000000000000002","0x15f03dd9ceacb82e23807f5bd2f3d03abada7618f21e6222f38058a940e56ba0"],"data":"0x000000000000000000000000000000000000000000000000000000006446aeff","blockHash":"0x5dd332896a9db8bc0e74e5d095bbf1b0aa2a53e068cffc77d5761d95e15069a9","blockNumber":"0x16","transactionHash":"0x763eb5e6ee7712804fd5ca4b7c467f7f71f2fd7543237676ee5ac1a6bea3daf6","transactionIndex":"0x0","logIndex":"0x0","transactionLogIndex":"0x0","removed":false}]
            ````

2.  Apply the global rule to the application
    1.  Get the rule application function from the rule directory and invoke it on the Application Handler created in previous steps.
        ````
        cast send 0x0116686E2291dbd5e317F47faDBFb43B599786Ef "setAccountBalanceByKYCRuleId(uint32)" 00002  --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc --rpc-url $ETH_RPC_URL
        ````



<!-- These are the body links -->
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md
[globalRuleDirectory-url]: ../rules/GLOBALRULEDIRECTORY.md
[environment-url]: ./SET-ENVIRONMENT.md


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron