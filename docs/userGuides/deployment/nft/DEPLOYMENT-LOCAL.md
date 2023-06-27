# Foundry Local Deployment
[![Project Version][version-image]][version-url]

---

**Please note that all addresses and private keys are simply examples and should not be used for your deployment**

**Commands are configured for zsh terminal**

1. Ensure that [Foundry][foundry-url] is installed and functioning properly
2. Install eth-abi
   ````
   pip install eth-abi
   ````
3. Pull the repository
   1. Clone the [repository][repository-url]
   ````
   git clone [repository-url]
   ````
4. Start Anvil
   ````
   anvil
   ````
5. Deploy the [Protocol][deployProtocolLocal-url]. 
6. Deploy [AppManager][deployAppManager-url]
7. Deploy [Protocol Supported NFT][deployProtocolSupportedNft-url]
8. Deploy [Pricing Module][deployPricingModule-url] (Optional)
9.  Create [Application Rules][createAppRules-url] (Optional)    
10. Create [NFT Specific Rules][createNftRules-url] (Optional)    
11. Set [External Access Tier Provider][externalAccessTierProvider-url] (Optional)
12. [Set NFT Prices][settingNftPrice-url] (Optional)
    

<!-- These are the body links -->
[foundry-url]: https://book.getfoundry.sh/getting-started/installation
[repository-url]: https://github.com/thrackle-io/Tron
[deployProtocolLocal-url]: ../DEPLOY-PROTOCOL.md
[deployAppManager-url]: ../DEPLOY-APPMANAGER.md
[deployNftHandler-url]: ./DEPLOY-NFTHANDLER.md
[deployPricingModule-url]: ../DEPLOY-PRICING.md
[createAppRules-url]: ../CREATE-APP-RULES.md
[createNftRules-url]: ../CREATE-NFT-RULES.md
[externalAccessTierProvider-url]: ../../accessTier/EXTERNAL-ACCESS-TIER-PROVIDER.md
[deployProtocolSupportedNft-url]: ./DEPLOY-NFT.md
[settingNftPrice-url]: ./NFT-PRICING.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron