# APP ADMINISTRATOR ROLES 
[![Project Version][version-image]][version-url]

The super admin account is set during the [deployment][deployAppManager-url] of the AppManager in the constructor. Ensure you use it when creating App Admins. App Admins are used to create all other [admin roles][createAdminRole-url]. 

---

## Index

1. [Super Admin](#super-admin).
2. [App Admin](#app-admin).
3. [Risk Admin](#risk-admin).
4. [Access Level Admin](#access-level-admin).
5. [Rule Admin](#rule-admin).
6. [Treasury Account](#treasury-account).

## SUPER ADMIN

### Overview
Super admin is set at construction of the App Manager(the deploying address of the AppManager). This role is the highest in the hierarchy of roles and can grant/revoke the app admin role. Functions with the modifier onlyRole(SUPER_ADMIN_ROLE) can only be called by this role. **There can only be one super admin in an application**, and the only way to grant another account the super-admin role is by using the function `proposeNewSuperAdmin` in which case current super admin would effectively renounce the super admin role and all of its privileges to grant it to the new address. The new address has to confirm the acceptance of the super-admin role for the process to take effect, otherwise the old super admin will remain in the role.

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

- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export SUPER_ADMIN_KEY=<super admin privkey>
    ```

- For the production phase, it is strongly recommended that the Super Administrator is a multi-signature wallet where the approved signers don't have admin privileges and their private keys are stored in hardware wallets.

---

## APP ADMIN

### Overview
App admin can be granted only by the super admin at any time. App Admins do not have the ability to create/revoke other App Admins. This role can grant permissions to the access level, risk and rule admin roles as well as treasury accounts. This role also has control over setting addresses for provider contracts, registering/deregistering asset contracts and setting upgraded handler addresses. Functions with the modifier onlyRole(APP_ADMIN_ROLE) can only be called by this role. 

### Add Command
The following is an example of the command used to add an app admin:
````
cast send $APPLICATION_APP_MANAGER "addAppAdministrator(address)" $APP_ADMIN --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities 
* Application Administrators may add/remove Rule Administrators
* Application Administrators may add/remove Risk Administrators.
* Application Administrators may add/remove Access Level Administrators.
* Application Administrators may add/remove Treasury Accounts.
* Application Administrators may add/edit/remove account metadata such as tags (not including risk/access levels).
* Application Administrators may renounce their role.
* Application Administrators may register/deregister asset contracts.
* Application Administrators may set upgraded handler addresses.
   
### Role Hash
````
Keccak256: 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60
````

### Recommendations
- It is recommended to have as little app admins as possible in the application since these have great indirect privileges. One app admin is the optimal amount.

- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.

- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export APP_ADMIN_PRIVATE_KEY=<app admin privkey>
    ```

---

---

## RISK ADMIN

### Overview
Risk admin can be granted at any time by the app admin. This role sets the risk level for addresses within the application app manager. Functions with the modifier onlyRole(RISK_ADMIN_ROLE) can only be called by this role.

### Add Command
The following is an example of the command used to add an risk admin:
````
cast send $APPLICATION_APP_MANAGER "addRiskAdmin(address)" $RISK_ADMIN  --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Risk Administrators may alter player risk levels.
* Risk Administrators may not alter any rule configurations to include risk related rules.
* Risk Administrators may renounce their role.

### Role Hash
````
Keccak256: 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export RISK_ADMIN_KEY=<risk admin privkey>
    ```


---

## ACCESS LEVEL ADMIN

### Overview
Access level admin can be granted at any time by the app admin. This role sets the access level for addresses within the application app manager. Functions with the modifier onlyRole(ACCESS_LEVEL_ADMIN_ROLE) can only be called by this role.

### Add Command
The following is an example of the command used to add an access level admin:
````
cast send $APPLICATION_APP_MANAGER "addAccessLevel(address)" $ACCESS_LEVEL_ADMIN --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Access Level Administrators may alter player access levels.
* Access Level Administrators may not alter any rule configurations to include risk related rules.
* Access Level Administrators may renounce their role.

### Role Hash
````
Keccak256: 0x31f80d5aea029b856920c9e867db87c5fae0f51b2923773b55e653791d4c12c0
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export ACCESS_LEVEL_ADMIN_KEY=<access level admin privkey>
    ```

---

## RULE ADMIN

### Overview
Rule admin can be granted at any time by the app admin. This role can activate and deactivate economic rules within the handler contracts. Functions with the modifier onlyRuleAdministrator() can only be called by this role. 

### Add Command
The following is an example of the command used to add an rule admin:
````
cast send $APPLICATION_APP_MANAGER "addRuleAdministrator(address)" $RULE_ADMIN --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
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

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export RULE_ADMIN_KEY=<rule admin privkey>
    ```


---

## TREASURY ACCOUNT
Treasury Account can be granted at any time by the app admin. This role is exempt from all economic rules except for the Admin Withdrawal rule. This role cannot be revoked or renounce their role while this rule is active. Functions with the modifier onlyRole(TREASURY_ACCOUNT) can only be called by this role. 

### Add Command
The following is an example of the command used to add an treasury account:
````
cast send $APPLICATION_APP_MANAGER "addTreasuryAccount(address)" $APP_ADMIN --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Treasury Accounts are exempt from all economic rules except for the Admin Withdrawal Rule.
* Treasury Accounts may not alter any rule configurations to include risk related rules.
* Treasury Accounts may not renounce their role.

### Role Hash
````
Keccak256: 0x5cb9147a971eae9c63c04beb424326d7db091a71473987979b49bb1e189f3457
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other roles in the application.

<!-- These are the body links -->
[createAdminRole-url]: ./ADMIN-CONFIG.md
[deployAppManager-url]: ../deployment/DEPLOY-APPMANAGER.md 

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron