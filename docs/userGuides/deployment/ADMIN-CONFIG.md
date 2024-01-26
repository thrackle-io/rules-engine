# Administrator Configuration
[![Project Version][version-image]][version-url]

---

1. Call the addAppAdministrator function on the AppManager using the super admin account that deployed the AppManager. It accepts one parameter: the address of the desired appAdministrtor, e.g. (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)
   ````
   cast send $APPLICATION_APP_MANAGER "addAppAdministrator(address)()" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $SUPER_ADMIN --rpc-url $ETH_RPC_URL
   ````

2. Repeat for all addresses that may need appAdmin privileges ([see admin accounts][admin-roles]).

3. Repeat previous step for all other [admin roles][admin-roles], but this time using any of the addresses' private key with appAdmin roles granted in the previous step.


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron

<!-- These are the body links -->
[admin-roles]: ../permissions/ADMIN-ROLES.md 