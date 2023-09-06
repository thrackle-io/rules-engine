# APP ADMINISTRATOR ROLES 
[![Project Version][version-image]][version-url]

The super admin account is set during the [deployment][deployAppManager-url] of the AppManager in the constructor. Ensure you use it when creating App Admins. App Admins are used to create all other [admin roles][createAdminRole-url]. 

---
1. Super Admin: Super admin is set at construction of the App Manager(the deploying address of the AppManager). This role has the highest level of permissions and can grant/revoke the app admin role. Functions with the modifier onlyRole(SUPER_ADMIN_ROLE) can only be called by this role. It is recommended that this role be strictly managed.
   
2. App Admin: App admin is set at contruction and can be granted only by the super admin at any time. App Admins do not have the ability to create/revoke other App Admins. This role can grant permissions to the access tier, risk and rule admin roles. This role also has control over setting addresses for provider contracts, registering/deregistering asset contracts and setting upgraded handler addresses. Functions with the modifier onlyRole(APP_ADMIN_ROLE) can only be called by this role. 
    ````
    cast send $APPLICATION_APP_MANAGER "addAppAdministrator(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ````

3. Risk Admin: Risk admin is set at construction and can be granted only by the app admin at any time. This role sets the risk level for addresses within the application app manager. Functions with the modifier onlyRole(RISK_ADMIN_ROLE) can only be called by this role.
    ````
    cast send $APPLICATION_APP_MANAGER "addRiskAdmin(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ````

4. Access Tier: Access tier is set at construction and can be granted only by the app admin at any time. This role sets the access level for addresses within the application app manager. Functions with the modifier onlyRole(ACCESS_TIER_ADMIN_ROLE) can only be called by this role.
    ````
    cast send $APPLICATION_APP_MANAGER "addAccessTier(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ````

5. Rule Admin: Rule admin is set at construction and can be granted only by the app admin at any time. This role can activate and deactivate economic rules within the handler contracts. Functions with the modifier onlyRuleAdministrator() can only be called by this role. 
    ````
    cast send $APPLICATION_APP_MANAGER "addRuleAdministrator(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ````



<!-- These are the body links -->
[createAdminRole-url]: ../permissions/ADMIN-CONFIG.md
[deployAppManager-url]: ./DEPLOY-APPMANAGER.md 

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron