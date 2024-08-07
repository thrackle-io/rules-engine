# Deployment Guide

This is a step-by-step guide to protocol and protocol supported application deployments. This guide is broken down into modules to make it easier to follow and is listed in the proper deployment order. Please review overall [documentation](../README.md) and deployment information prior to running individual deployment scripts. A [demo](./DEPLOY-DEMO.md) has also been provided which deploys the protocol and a fully configured example application.

1. Deploy the protocol if it doesn't exist yet. Go to [Deploy Protocol](DEPLOY-PROTOCOL.md).
2. Then, deploy your Application Manager. Go to [Deploy Application Manager](DEPLOY-APPMANAGER.md).
3. Optionally, setup the pricing module for your application. Go to [Deploy Pricing](../pricing/DEPLOY-PRICING.md).
4. Now you can start deploying your application tokens. Go to [Deploy Token Handlers](./DEPLOY-TOKEN-HANDLERS.md) and [Deploy Tokens](./DEPLOY-TOKENS.md).
5. Once you have your application and your tokens deployed, you can start creating and applying rules to your application and tokens. Go to [Create App Rules](../rules/CREATE-APP-RULES.md) and [Create NFT Rules](CREATE-NFT-RULES.md).
6. (Optional) To see what's available in deployment of the scripts, see [Deployment scripts index](./DEPLOYMENT-SCRIPTS.md).

Your application is ready to roll!


NOTE: 
When integrating the protocol as a library in your repo, there are certain configuration requirements that must be followed for compilation. The following four contract imports must be configured as: 
```
import {AppManager} from "aquifi-rules-v1/client/application/AppManager.sol";
import "aquifi-rules-v1/client/application/ProtocolApplicationHandler.sol";
```

```
import "aquifi-rules-v1/client/token/handler/diamond/HandlerDiamond.sol";
import {RuleProcessorDiamond} from "aquifi-rules-v1/protocol/economic/ruleProcessor/ruleProcessorDiamond.sol";
```

When importing these contracts in the pairs above into the src directory of your repo it is essential that you follow this inheritance structure to ensure there are no compiler issues. 