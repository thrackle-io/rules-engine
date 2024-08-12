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
7. [Token Admin](#token-admin).
8. [Proxy Admin](#proxy-admin).

## SUPER ADMIN

### Overview
Super admin is set at construction of the AppManager(the root address argument of the AppManager constructor). This role is the highest in the hierarchy of roles and can grant/revoke the app admin role. Functions with the modifier onlyRole(SUPER_ADMIN_ROLE) can only be called by this role. **There can only be one super admin in an application**, and the only way to grant another account the super-admin role is by using the function `proposeNewSuperAdmin` in which case, the current super admin would effectively renounce the super admin role and all of its privileges to grant it to the new address. The new address has to confirm the acceptance of the super-admin role for the process to take effect, otherwise the old super admin will remain in the role. This two step process is used to ensure there is always a super admin role assigned.

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
    export SUPER_ADMIN_PRIVATE_KEY=<super admin privkey>
    ```

- For the production phase, it is strongly recommended that the Super Administrator is a multi-signature wallet where the approved signers don't have admin privileges and their private keys are stored in hardware wallets.

---

## APP ADMIN

### Overview
The `APP_ADMIN_ROLE` can be granted only by the super admin at any time. App Admins do not have the ability to create/revoke other App Admins. This role can grant permissions to the access level, risk and rule admin roles as well as treasury accounts. This role also has control over setting addresses for provider contracts, registering/deregistering asset contracts and setting upgraded handler addresses. Functions with the modifier onlyRole(APP_ADMIN_ROLE) can only be called by this role. 

### Add Command
The following is an example of the command used to add an app admin by the super admin. Replace `DESIRED_APP_ADMIN_ADDRESS` in the following cast command with the address that is being granted the role of AppAdmin:
````
cast send $APPLICATION_APP_MANAGER "addAppAdministrator(address)" DESIRED_APP_ADMIN_ADDRESS --private-key $SUPER_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
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

### Revoke Command
The following is an example of the command used to revoke an app admin by the super admin. Replace `APP_ADMIN_ADDRESS_TO_BE_REVOKED` with the address of a current app admin that is no longer desired to have the `APP_ADMIN_ROLE`. The bytes32 argument here is the keccak256 hash of the `APP_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "revokeRole(bytes32,address)" 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60 APP_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $SUPER_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Renounce Command
The following is an example of the command used to renounce the `APP_ADMIN_ROLE` from the caller of this command. Replace `APP_ADMIN_ADDRESS_TO_BE_RENOUNCED` with the address associated with the private key used to sign this transaction. The bytes32 argument here is the keccak256 hash of the `APP_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "renounceRole(bytes32,address)" 0x371a0078bf8859908953848339bea5f1d5775487f6c2f50fd279fcc2cafd8c60 APP_ADMIN_ADDRESS_TO_BE_RENOUNCED --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Recommendations
- It is recommended to have as few app admins as possible in the application since these have great indirect privileges. One app admin is the optimal amount.

- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.

- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export APP_ADMIN_PRIVATE_KEY=<app admin privkey>
    ```

---

## RISK ADMIN

### Overview
Risk admin can be granted at any time by the app admin. This role sets the risk level for addresses within the application app manager. Functions with the modifier onlyRole(RISK_ADMIN_ROLE) can only be called by this role.

### Add Command
The following is an example of the command used to add a risk admin by the app admin. Replace `DESIRED_RISK_ADMIN_ADDRESS` in the following cast command with the address that is being granted the `RISK_ADMIN_ROLE`:
````
cast send $APPLICATION_APP_MANAGER "addRiskAdmin(address)" DESIRED_RISK_ADMIN_ADDRESS  --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Risk Administrators may alter user risk levels.
* Risk Administrators may not alter any rule configurations to include risk related rules.
* Risk Administrators may renounce their role.

### Role Hash
````
Keccak256: 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f
````

### Revoke Command
The following is an example of the command used to revoke a risk admin by an app admin. Replace `RISK_ADMIN_ADDRESS_TO_BE_REVOKED` with the address of a current risk admin that is no longer desired to have the `RISK_ADMIN_ROLE`. The bytes32 argument here is the keccak256 hash of the `RISK_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "revokeRole(bytes32,address)" 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f RISK_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Renounce Command
The following is an example of the command used to renounce the `RISK_ADMIN_ROLE` from the caller of this command. Replace `RISK_ADMIN_ADDRESS_TO_BE_REVOKED` with the address associated with the private key used to sign this transaction. The bytes32 argument here is the keccak256 hash of the `RISK_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "renounceRole(bytes32,address)" 0x870ee5500b98ca09b5fcd7de4a95293916740021c92172d268dad85baec3c85f RISK_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $RISK_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export RISK_ADMIN_PRIVATE_KEY=<risk admin privkey>
    ```


---

## ACCESS LEVEL ADMIN

### Overview
Access level admin can be granted at any time by the app admin. This role sets the access level for addresses within the application app manager. Functions with the modifier onlyRole(ACCESS_LEVEL_ADMIN_ROLE) can only be called by this role.

### Add Command
The following is an example of the command used to add an access level admin by the app admin. Replace `DESIRED_ACCESS_LEVEL_ADMIN_ADDRESS` in the following cast command with the address that is being granted the `ACCESS_LEVEL_ADMIN_ROLE`:
````
cast send $APPLICATION_APP_MANAGER "addAccessLevelAdmin(address)" DESIRED_ACCESS_LEVEL_ADMIN_ADDRESS --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Access Level Administrators may alter user access levels.
* Access Level Administrators may not alter any rule configurations to include risk related rules.
* Access Level Administrators may renounce their role.

### Role Hash
````
Keccak256: 0x2104bd22bc71f1a868806c22aa1905dad25555696bbf4456c5b464b8d55f7335
````

### Revoke Command
The following is an example of the command used to revoke an access level admin by an app admin. Replace `ACCESS_LEVEL_ADMIN_ADDRESS_TO_BE_REVOKED` with the address of a current access level admin that is no longer desired to have the `ACCESS_LEVEL_ADMIN_ROLE`. The bytes32 argument here is the keccak256 hash of the `ACCESS_LEVEL_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "revokeRole(bytes32,address)" 0x2104bd22bc71f1a868806c22aa1905dad25555696bbf4456c5b464b8d55f7335 ACCESS_LEVEL_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Renounce Command
The following is an example of the command used to renounce the `ACCESS_LEVEL_ADMIN_ROLE` from the caller of this command. Replace `ACCESS_LEVEL_ADMIN_ADDRESS_TO_BE_REVOKED` with the address associated with the private key used to sign this transaction. The bytes32 argument here is the keccak256 hash of the `ACCESS_LEVEL_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "renounceRole(bytes32,address)" 0x2104bd22bc71f1a868806c22aa1905dad25555696bbf4456c5b464b8d55f7335 ACCESS_LEVEL_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $ACCESS_LEVEL_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export ACCESS_LEVEL_ADMIN_PRIVATE_KEY=<access level admin privkey>
    ```

---

## RULE ADMIN

### Overview
Rule admin can be granted at any time by the app admin. This role can activate and deactivate economic rules within the handler contracts. Functions with the modifier onlyRole(RULE_ADMIN_ROLE) can only be called by this role. 

### Add Command
The following is an example of the command used to add a rule admin by the app admin. Replace `DESIRED_RULE_ADMIN_ADDRESS` in the following cast command with the address that is being granted the `RULE_ADMIN_ROLE`:
````
cast send $APPLICATION_APP_MANAGER "addRuleAdministrator(address)" DESIRED_RULE_ADMIN_ADDRESS --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
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

### Revoke Command
The following is an example of the command used to revoke a rule admin by an app admin. Replace `RULE_ADMIN_ADDRESS_TO_BE_REVOKED` with the address of a current rule admin that is no longer desired to have the `RULE_ADMIN_ROLE`. The bytes32 argument here is the keccak256 hash of the `RULE_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "revokeRole(bytes32,address)" 0x5ff038c4899bb7fbbc7cf40ef4accece5ebd324c2da5ab7db2c3b81e845e2a7a RULE_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Renounce Command
The following is an example of the command used to renounce the `RULE_ADMIN_ROLE` from the caller of this command. Replace `RULE_ADMIN_ADDRESS_TO_BE_REVOKED` with the address associated with the private key used to sign this transaction. The bytes32 argument here is the keccak256 hash of the `RULE_ADMIN_ROLE`.
````
cast send $APPLICATION_APP_MANAGER "renounceRole(bytes32,address)" 0x5ff038c4899bb7fbbc7cf40ef4accece5ebd324c2da5ab7db2c3b81e845e2a7a RULE_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $RULE_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other admin roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export RULE_ADMIN_PRIVATE_KEY=<rule admin privkey>
    ```


---

## TREASURY ACCOUNT
Treasury Account can be granted at any time by the app admin. This role is exempt from all economic rules. Any transactions involving a treasury account will bypass rule checks for all parties involved. Functions with the modifier onlyRole(TREASURY_ACCOUNT) can only be called by this role.

### Add Command
The following is an example of the command used to add a Treasury Account by the app admin. Replace `DESIRED_TREASURY_ACCOUNT_ADDRESS` in the following cast command with the address that is being granted the `TREASURY_ACCOUNT` role:
````
cast send $APPLICATION_APP_MANAGER "addTreasuryAccount(address)" DESIRED_TREASURY_ACCOUNT_ADDRESS --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Treasury Accounts are exempt from all economic rules.
* Treasury Accounts may not alter any rule configurations to include risk related rules.

### Role Hash
````
Keccak256: 0x6ec7f14f5bb307db04b8741f0dfa1605098831d97aae193f99400b1357d4bb95
````

### Revoke Command
The following is an example of the command used to revoke a treasury account by an app admin. Replace `TREASURY_ACCOUNT_ADDRESS_TO_BE_REVOKED` with the address of a current treasury account that is no longer desired to have the `TREASURY_ACCOUNT` role. The bytes32 argument here is the keccak256 hash of the `TREASURY_ACCOUNT` role.
````
cast send $APPLICATION_APP_MANAGER "revokeRole(bytes32,address)" 0x6ec7f14f5bb307db04b8741f0dfa1605098831d97aae193f99400b1357d4bb95 TREASURY_ACCOUNT_ADDRESS_TO_BE_REVOKED --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Renounce Command
The following is an example of the command used to renounce the `TREASURY_ACCOUNT` role from the caller of this command. Replace `TREASURY_ACCOUNT_ADDRESS_TO_BE_REVOKED` with the address associated with the private key used to sign this transaction. The bytes32 argument here is the keccak256 hash of the `TREASURY_ACCOUNT` role.
````
cast send $APPLICATION_APP_MANAGER "renounceRole(bytes32,address)" 0x6ec7f14f5bb307db04b8741f0dfa1605098831d97aae193f99400b1357d4bb95 TREASURY_ACCOUNT_ADDRESS_TO_BE_REVOKED --private-key $TREASURY_ACCOUNT_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export TREASURY_ACCOUNT_PRIVATE_KEY=<treasury account privkey>
    ```

---

## Token Admin
The Token Admin role is granted during construction of the ApplicationERC20 and ApplicaitionERC721 contracts. Token Admin can be granted at any time by a current Token Admin. This role can connect a handler to the token. Functions with the modifier onlyRole(TOKEN_ADMIN_ROLE) can be called by this role.

### Add Command
The following is an example of the command used to add a Token Admin by a current Token Admin. Replace `APPLICATION_TOKEN_ADDRESS` with the token address. Replace `DESIRED_TOKEN_ADMIN_ADDRESS` in the following command with the address that is being granted the `TOKEN_ADMIN_ROLE`:
````
cast send APPLICATION_TOKEN_ADDRESS "grantRole(bytes32,address)" 0x9e262e26e9d5bf97da5c389e15529a31bb2b13d89967a4f6eab01792567d5fd6 DESIRED_TOKEN_ADMIN_ADDRESS --private-key $TOKEN_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Token admins can connect a handler to the token.
* Token admins can set the baseURI and mint tokens on ApplicationERC721 contracts.
* Token admins can grant or revoke the `TOKEN_ADMIN_ROLE`.

### Role Hash
````
Keccak256: 0x9e262e26e9d5bf97da5c389e15529a31bb2b13d89967a4f6eab01792567d5fd6
````

### Revoke Command
The following is an example of the command used to revoke a Token Admin by a current Token Admin. Replace `APPLICATION_TOKEN_ADDRESS` with the token address. Replace `TOKEN_ADMIN_ADDRESS_TO_BE_REVOKED` with the address of a current Token Admin that is no longer desired to have the `TOKEN_ADMIN_ROLE`. The bytes32 argument here is the keccak256 hash of the `TOKEN_ADMIN_ROLE`:
````
cast send APPLICATION_TOKEN_ADDRESS "revokeRole(bytes32,address)" 0x9e262e26e9d5bf97da5c389e15529a31bb2b13d89967a4f6eab01792567d5fd6 TOKEN_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $TOKEN_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Renounce Command
The following is an example of the command used to renounce the `TOKEN_ADMIN_ROLE` from the caller of this command. Replace `APPLICATION_TOKEN_ADDRESS` with the token address. Replace `TOKEN_ADMIN_ADDRESS_TO_BE_REVOKED` with the address asoociated with the private key used to sign this transaction. The bytes32 argument here is the keccak256 hash of the `TOKEN_ADMIN_ROLE`:
````
cast send APPLICATION_TOKEN_ADDRESS "renounceRole(bytes32,address)" 0x9e262e26e9d5bf97da5c389e15529a31bb2b13d89967a4f6eab01792567d5fd6 TOKEN_ADMIN_ADDRESS_TO_BE_REVOKED --private-key $TOKEN_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export TOKEN_ADMIN_PRIVATE_KEY=<token admin privkey>
    ```

---

## Proxy Admin
The proxy admin role is granted during construction of the ApplicationERC20UProxy and ApplicationERC721UProxy contracts. The proxy admin is provided by the OpenZeppelin ERC1967Upgrade contract. It is different than AccessControl roles and doesn't have a role hash. Instead, it is stored at a specific slot in the proxy contract storage. There can only be one proxy admin at a time. Functions with the modifier ifAdmin can be called by this role.

### Change Command
The following is an example of the command used to change the proxy admin by the current proxy admin. Replace `APPLICATION_PROXY_ADDRESS` with the proxy contract address. Replace `NEW_PROXY_ADMIN` with the address of the new proxy admin.
````
cast send APPLICATION_PROXY_ADDRESS "changeAdmin(address)" NEW_PROXY_ADMIN --private-key $APPLICATION_PROXY_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
````

### Capabilities
* Proxy admins can change the current proxy admin.
* Proxy admins can upgrade the implementaition contract.

### Role Slot
````
_ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
````

### Recommendations
- It is recommended to have a dedicated account for this role that doesn't have any other roles in the application.
- To ensure this guide can be followed during the development phase, it is recommended to export the private key for this admin as an environment variable (you might want to follow other practices in production for security reasons):

    ```
    export APPLICATION_PROXY_ADMIN_PRIVATE_KEY=<proxy admin privkey>
    ```


<!-- These are the body links -->
[createAdminRole-url]: ./ADMIN-CONFIG.md
[deployAppManager-url]: ../deployment/DEPLOY-APPMANAGER.md 

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.3.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/aquifi-rules-v1