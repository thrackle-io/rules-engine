# APP ADMINISTRATOR ROLES 
[![Project Version][version-image]][version-url]

The super admin account is set during the [deployment][deployAppManager-url] of the AppManager in the constructor. Ensure you use it when creating App Admins. App Admins are used to create all other [admin roles][createAdminRole-url]. 

---

## SUPER ADMIN

### Overview
Super admin is set at construction of the App Manager(the deploying address of the AppManager). This role is the highest in the hierarchy of roles and can grant/revoke the app admin role. Functions with the modifier onlyRole(SUPER_ADMIN_ROLE) can only be called by this role. **There can only be one super admin in an application**, and the only way to grant another account the super-admin role is by using the function `proposeNewSuperAdmin` in which case current super admin would effectively renounce the super admin role and all of its privilages to grant it to the new address. The new address has to confirm the acceptance of the super-admin role for the process to take effect, otherwise the old super admin will remain in the role.

### Proposed Super Admin
There is a transitionary role called "proposed super Admin". There can only be one address member of this role, and it can only be added by the super admin role when invoking `proposeNewSuperAdmin`. Once the proposed account confirms the role by invoking `confirmSuperAdmin`, the new super Admin will renounce to the proposed-super-Admin role. 

### Capabilities
* The Super Administrator is the initial approver/creator of the application ecosystem.

* The Super Administrator may approve/add subsequent Application Administrators.
* The Super Administrator may NOT renounce it’s role except via the Proposed Super Admin process described above. There must be at least one Super Administrator at all times.

### Role Hash
Roles can be identified by their Keccak256 hash in the logs.

#### Super Admin
````
Keccak256: 0x7613a25ecc738585a232ad50a301178f12b3ba8887d13e138b523c4269c47689
````
#### Proposed Super Admin
````
Keccak256: 0x16c600d7bfbb199b1bbbaaec72d225e1b669f7d0c812d7cafcf00672fb42b30d
````

### Recommendations
It is strongly recommended that the Super Administrator is a multi-signature account.

---

## APP ADMIN

### Overview
App admin is set at contruction and can be granted only by the super admin at any time. App Admins do not have the ability to create/revoke other App Admins. This role can grant permissions to the access tier, risk and rule admin roles as well as rule bypass accounts. This role also has control over setting addresses for provider contracts, registering/deregistering asset contracts and setting upgraded handler addresses. Functions with the modifier onlyRole(APP_ADMIN_ROLE) can only be called by this role. 

### Add Command
The following is an example of the command used to add an app admin:
````
cast send $APPLICATION_APP_MANAGER "addAppAdministrator(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities 
* Application Administrators may add/remove Rule Administrators
* Application Administrators may add/remove Risk Administrators.
* Application Administrators may add/remove Access Tier Administrators.
* Application Administrators may add/remove Rule Bypass Accounts.
* Application Administrators may add/edit/remove player account metadata such as tags (not including risk/access tier levels).
* Application Administrators may renounce their role.
* Application Administrators may register/deregister asset contracts.
* Application Administrators may set upgraded hnadler addresses.
   
### Role Hash
````
Keccak256: 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60
````

---

## RISK ADMIN

### Overview
Risk admin can be granted at any time by the app admin. This role sets the risk level for addresses within the application app manager. Functions with the modifier onlyRole(RISK_ADMIN_ROLE) can only be called by this role.

### Add Command
The following is an example of the command used to add an risk admin:
````
cast send $APPLICATION_APP_MANAGER "addRiskAdmin(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Risk Administrators may alter player risk levels.
* Risk Administrators may not alter any rule configurations to include risk related rules.
* Risk Administrators may renounce their role.

### Role Hash
````
Keccak256: 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f
````


---

## ACCESS TIER ADMIN

### Overview
Access tier can be granted at any time by the app admin. This role sets the access level for addresses within the application app manager. Functions with the modifier onlyRole(ACCESS_TIER_ADMIN_ROLE) can only be called by this role.

### Add Command
The following is an example of the command used to add an access tier admin:
````
cast send $APPLICATION_APP_MANAGER "addAccessTier(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Access Tier Administrators may alter player access tier levels.
* Access Tier Administrators may not alter any rule configurations to include risk related rules.
* Access Tier Administrators may renounce their role.

### Role Hash
````
Keccak256: 0x31f80d5aea029b856920c9e867db87c5fae0f51b2923773b55e653791d4c12c0
````

---

## RULE ADMIN

### Overview
Rule admin can be granted at any time by the app admin. This role can activate and deactivate economic rules within the handler contracts. Functions with the modifier onlyRuleAdministrator() can only be called by this role. 

### Add Command
The following is an example of the command used to add an rule admin:
````
cast send $APPLICATION_APP_MANAGER "addRuleAdministrator(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities 
* Rule Administrators may create rules.
* Rule Administrators may enable/disable rules.
* Rule Administrators may configure/edit rules.
* Rule Administrators may renounce their role.

### Role Hash
````
Keccak256: 0x5ff038c4899bb7fbbc7cf40ef4accece5ebd324c2da5ab7db2c3b81e845e2a7a
````

---

## RULE BYPASS ACCOUNT
Rule Bypass Account can be granted at any time by the app admin. This role is exempt from all economic rules except for the Admin Withdrawal rule. This role cannot be revoked or renounce their role while this rule is active. Functions with the modifier onlyRole(RULE_BYPASS_ACCOUNT) can only be called by this role. 

### Add Command
The following is an example of the command used to add an rule bypass account:
````
cast send $APPLICATION_APP_MANAGER "addRuleBypassAccount(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Rule Bypass Accounts are exempt from all economic rules except for the Admin Withdrawal Rule.
* Rule Bypass Accounts may not alter any rule configurations to include risk related rules.
* Rule Bypass Accounts may not renounce their role.

### Role Hash
````
Keccak256: 0x5cb9147a971eae9c63c04beb424326d7db091a71473987979b49bb1e189f3457
````

<!-- These are the body links -->
[createAdminRole-url]: ../permissions/ADMIN-CONFIG.md
[deployAppManager-url]: ./DEPLOY-APPMANAGER.md 

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron