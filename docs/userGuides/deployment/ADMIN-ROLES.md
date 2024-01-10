# APP ADMINISTRATOR ROLES 
[![Project Version][version-image]][version-url]

The super admin account is set during the [deployment][deployAppManager-url] of the AppManager in the constructor. Ensure you use it when creating App Admins. App Admins are used to create all other [admin roles][createAdminRole-url]. 

---
1. Super Admin: Super admin is set at construction of the App Manager(the deploying address of the AppManager). This role has the highest level of permissions and can grant/revoke the app admin role. Functions with the modifier onlyRole(SUPER_ADMIN_ROLE) can only be called by this role. **There can only be one super admin in an application**, and the only way to grant another account the super-admin role is by using the function `proposeNewSuperAdmin` in which case current super admin would effectively renounce to the super admin role and all of its privilages to grant it to the new address. The new address has to confirm the acceptance of the super-admin role for the process to take effect, otherwise the old super admin will remain in the role.
   
2. App Admin: App admin is set at contruction and can be granted only by the super admin at any time. App Admins do not have the ability to create/revoke other App Admins. This role can grant permissions to the access tier, risk and rule admin roles as well as rule bypass accounts. This role also has control over setting addresses for provider contracts, registering/deregistering asset contracts and setting upgraded handler addresses. Functions with the modifier onlyRole(APP_ADMIN_ROLE) can only be called by this role. 
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

6. There is a transitionary role called "proposed super Admin". There can only be one address member of this role, and it can only be added by the super admin role when invoking `proposeNewSuperAdmin`. Once the proposed account confirms the role by invoking `confirmSuperAdmin`, the new super Admin will renounce to the proposed-super-Admin role. 

7. Rule Bypass Account: Rule Bypass Account is set at construction and can be granted only by the app admin at any time. This role is exempt from all economic rules except for the Admin Withdrawal rule. This role cannot be revoked or renounce their role while this rule is active. Functions with the modifier onlyRole(RULE_BYPASS_ACCOUNT) can only be called by this role. 
    ````
    cast send $APPLICATION_APP_MANAGER "addRuleBypassAccount(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ````

## Role Hashes

Roles can be identified by their Keccak256 hash in the logs.

| Role | Keccak256 hash |
| - | - |
| APP_ADMIN_ROLE | 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60 |
| ACCESS_TIER_ADMIN_ROLE | 0x31f80d5aea029b856920c9e867db87c5fae0f51b2923773b55e653791d4c12c0 |
| RISK_ADMIN_ROLE | 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f |
| RULE_ADMIN_ROLE | 0x5ff038c4899bb7fbbc7cf40ef4accece5ebd324c2da5ab7db2c3b81e845e2a7a |
| SUPER_ADMIN_ROLE | 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689 |
| PROPOSED_SUPER_ADMIN_ROLE | 0x16c600d7bfbb199b1bbbaaec72d225e1b669f7d0c812d7cafcf00672fb42b30d |
| RULE_BYPASS_ACCOUNT | 0x5cb9147a971eae9c63c04beb424326d7db091a71473987979b49bb1e189f3457 |





<!-- These are the body links -->
[createAdminRole-url]: ../permissions/ADMIN-CONFIG.md
[deployAppManager-url]: ./DEPLOY-APPMANAGER.md 

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron