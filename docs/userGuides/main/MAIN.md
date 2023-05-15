
# The Protocol
[![Project Version][version-image]][version-url]

> The protocol allows client applications to leverage controls in order to manage their assets and create an economic climate that suits their ecosystem. Transfer restrictions, access-tier-based rules, risk mitigations, and many other functionalities are available.
>
> All the rules are configurable and may be modified to suit the needs of each client. They can be activated/deactivated as needed. 

---
## Main

---
### Author

**Thrackle Inc.** 
* *Initial work* - [TheProtocolRepo][repository-url] (Repository space)
* *Released on* [Polygon Edge][chain-url] (chain)
* [Thrackle website][Thrackle-url]

---
## [Deployment Guides][deploymentGuide-url]

## [User Guide][userGuide-url]

## [Rule Guide][ruleGuide-url]

## [Glossary][glossary-url]

---

### Running the tests

Should we create some sort of deployment verification test scripts?

---

## Release History

* 0.1.1
    * Initial document creation

---
Tasks still to do
1. ERD address
2. Token Rule Router Address
3. Contract Registry Address
   1. 
4. Pricing module detail for custom pricing
   1. Come up with at least one custom pricing method
5. Token specific Rule list directory
   1.  List of all Token specific rules, what they do, and the following function signatures:
      1. creation function(ERD)
      2. application function(TokenHandler)
      3. activation/deactivation function
6. Global rule list directory
   1. List of all Global rules, what they do, and the following function signatures:
      1. creation function(ERD)
      2. application function(AppHandler)
      3. activation/deactivation function
7. Deployment Directory
   1. List of all protocol deployments and their prevailing addresses
   
<!-- These are the body links -->
[deploymentGuide-url]: ../deployment/DEPLOYMENTGUIDES.md
[userGuide-url]: ./USERGUIDE.md
[ruleGuide-url]: ../rules/RULEGUIDE.md
[glossary-url]: ./GLOSSARY.md


<!-- These are the header links -->
[header-url]: github-template.png
[header-link]: https://github.com/thrackle-io/Tron
[repository-url]: https://github.com/thrackle-io/Tron
[chain-url]: https://www.polygon.com/
[Thrackle-url]: https://www.thrackle.io
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
