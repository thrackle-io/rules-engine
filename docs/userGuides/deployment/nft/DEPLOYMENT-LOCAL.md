# Foundry Local Deployment
[![Project Version][version-image]][version-url]

---

**Please note that all addresses and private keys are simply examples and should not be used for your deployment**

**Commands are configured for zsh terminal**

1. Ensure that [Foundry][foundry-url] is installed and functioning properly
2. Pull the repository
   1. Clone the [repository][repository-url]
   ````
   git clone [repository-url]
   ````

3. Start Anvil
   ````
   anvil
   ````
4. Deploy the [Protocol][deployProtocolLocal-url]. 
5. Deploy [AppManager][deployAppManager-url]
6. Deploy [NFTHandler][deployNftHandler-url]
7. Deploy [Pricing Module][deployPricingModule-url] (Optional)
8.  Create [Global Rules][createGlobalRules-url] (Optional)    
9.  Create [NFT Specific Rules][createNftRules-url] (Optional)    
10. Set [External KYC Provider][externalKYCProvider-url] (Optional)
11. Deploy [Protocol Supported NFT][deployProtocolSupportedNft-url]
12. [Set NFT Prices][settingNftPrice-url] (Optional)
    

<!-- These are the body links -->
[foundry-url]: https://book.getfoundry.sh/getting-started/installation
[deployProtocolLocal-url]: ../DEPLOY-PROTOCOL.md
[deployAppManager-url]: ../DEPLOY-APPMANAGER.md
[deployNftHandler-url]: ./DEPLOY-NFTHANDLER.md
[deployPricingModule-url]: ../DEPLOY-PRICING.md
[createGlobalRules-url]: ../CREATE-GLOBAL-RULES.md
[createNftRules-url]: ../CREATE-NFT-RULES.md
[externalKYCProvider-url]: ../../accessTier/EXTERNAL-ACCESS-TIER-PROVIDER.md
[deployProtocolSupportedNft-url]: ./DEPLOY-NFT.md
[settingNftPrice-url]: ./NFT-PRICING.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron