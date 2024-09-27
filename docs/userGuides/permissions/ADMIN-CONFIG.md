# Administrator Configuration
[![Project Version][version-image]][version-url]

---

An application relies on many [administrator roles][admin-roles] to work properly. Different configuration tasks need different administrator roles. The protocol utilizes the AccessControlEnumerable contract provided by OpenZeppelin to grant and revoke roles. The following section explains how to set all the admin roles:

1. Call the addAppAdministrator function on the AppManager using the current **Super Admin** account. It accepts one parameter: the address of the desired appAdministrator. Replace `DESIRED_APP_ADMIN_ADDRESS` in the following cast command with the address that is being granted the role of AppAdmin.

      ````
      cast send $APPLICATION_APP_MANAGER "addAppAdministrator(address)" DESIRED_APP_ADMIN_ADDRESS --private-key $SUPER_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
      ````

      **_NOTE_**: If multiple appAdmins are desired, the use of `addMultipleAppAdministrator` can be used, but it is recommended to have as few App Admins as possible. It accepts an array of addresses: the addresses of the desired appAdministrators. Replace `DESIRED_APP_ADMIN_ADDRESS` in the following cast command with the addresses that are being granted the role of AppAdmin.

      ````
      cast send $APPLICATION_APP_MANAGER "addMultipleAppAdministrator(address[])" "[DESIRED_APP_ADMIN_ADDRESS,DESIRED_APP_ADMIN_ADDRESS,DESIRED_APP_ADMIN_ADDRESS]" --private-key $SUPER_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
      ````

2. Now that there are addresses granted the `APP_ADMIN_ROLE`, refer to [admin roles][admin-roles] to setup other desired admin roles (ruleAdmin, riskAdmin, accessTierAdmin, Treasury account) through the respective function in the appManager. This time, you can sign the transactions with any of the addresses that were granted the appAdmin role in the previous steps since it is only addresses with appAdmin privileges that can grant these other admin roles.


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-2.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/forte-rules-engine

<!-- These are the body links -->
[admin-roles]: ./ADMIN-ROLES.md 