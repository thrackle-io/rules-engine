# Administrator Configuration
[![Project Version][version-image]][version-url]

---

An application relies on many [administrator roles][admin-roles] to work properly. Different configuration tasks need different administrator roles. The following section explains how to set all the admin roles:

1. Call the addAppAdministrator function on the AppManager using the **Super Admin** account that deployed the AppManager. It accepts one parameter: the address of the desired appAdministrtor, e.g. (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266):

      ````
      cast send $APPLICATION_APP_MANAGER "addAppAdministrator(address)()" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $SUPER_ADMIN_KEY --rpc-url $ETH_RPC_URL
      ````

2. Repeat for all addresses that may need appAdmin privileges ([see admin accounts][admin-roles]).

3. Repeat previous steps for all addresses that may need any other [admin roles][admin-roles] (ruleAdmin, riskAdmin, accessTierAdmin, ruleBypass account) through the respective function in the appManager. This time, you can sign the transactions with any of the addresses that were granted the appAdmin role in the previous steps since it is only addresses with appAdmin privileges that can grant these other admin roles.


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron

<!-- These are the body links -->
[admin-roles]: ./ADMIN-ROLES.md 