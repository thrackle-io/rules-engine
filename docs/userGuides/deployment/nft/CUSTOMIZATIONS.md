# Customization Options
[![Project Version][version-image]][version-url]

---

### Rule Modification 
To modify an applied rule, simply create the new rule with the desired settings and apply it. 
1. Application Rules:  
   1. Create [Application Rules][createAppRules-url]
2. Token Specific Rules: 
   1. Create [Token Specific Rules][createNftRules-url] 

### Rule Deactivation
To deactivate an applied rule, invoke the activation function and send it a parameter of false. This deactivates the rule, but it can be reactivated at any time. 
1. Application Rules
   1. Consult the [Application Rule Directory][appRuleDirectory-url] for the activation function name and invoke it on the AppManager created during deployment.
      1. This examples uses _Max Transaction Size Per Period By Risk Score_: 
         ````
         cast send 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575 "activateMaxTxSizePerPeriodByRiskRule(bool)" false --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc  --rpc-url  $ETH_RPC_URL 
         ````
2. Token Specific Rules
   1. Consult the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] for the activation function name and invoke it on the Token Application Handler created during deployment.
      1. This example uses _Transaction Restriction By Risk_: 
         ````
         cast send 0x82e01223d51Eb87e16A03E24687EDF0F294da6f1 "activateTransactionLimitByRiskRule(bool)" false --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc  --rpc-url  $ETH_RPC_URL 
         ````


### Activating a Deactivated Rule
To activate a deactivated rule, invoke the activation function and send it a parameter of true. This activates the rule.  
1. Application Rules
   1. Consult the [Application Rule Directory][appRuleDirectory-url] for the activation function name and invoke it on the AppManager created during deployment. 
      1. This examples uses _Max Transaction Size Per Period By Risk Score_: 
         ````
         cast send 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575 "activateMaxTxSizePerPeriodByRiskRule(bool)" true --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc  --rpc-url  $ETH_RPC_URL 
         ````
2. Token Specific Rules
   1. Consult the [Token Specific Rule Directory][tokenSpecificRuleDirectory-url] for the activation function name and invoke it on the TokenApplicationHandler created during deployment.
      1. This example uses _Transaction Restriction By Risk_: 
         ````
         cast send 0x82e01223d51Eb87e16A03E24687EDF0F294da6f1 "activateTransactionLimitByRiskRule(bool)" true --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --from 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc  --rpc-url  $ETH_RPC_URL 
         ````

### NFT Functionality
Protocol supported NFT's implement OpenZeppelin ERC721Burnable, ERC721URIStorage, ERC721Enumerable, and Pausable. These interfaces may be utilized in application NFT's. 

Additional logic may be added to the constructor, but it MUST still invoke the ProtocolERC721 constructor

<!-- These are the body links -->
[createAppRules-url]: ../CREATE-APP-RULES.md
[createNftRules-url]: ../CREATE-NFT-RULES.md
[appRuleDirectory-url]: ../../rules/APP-RULE-DIRECTORY.md
[tokenSpecificRuleDirectory-url]: ../../rules/TOKEN-RULE-DIRECTORY.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron