# External Access Tier Provider
[![Project Version][version-image]][version-url]

An external access tier provider may be utilized. In order to switch to an external access tier provider, the external provider contract must conform to the IAccessLevels interface or an adapter contract that conforms to the interface must be used. Once the external provider contract is deployed, the AppManager must be pointed to the new provider.

## Required functions for the External Access Tier Provider

###### *see [IAccessLevels](../../../src/client/application/data/IAccessLevels.sol)*

```c
    function addLevel(address _address, uint8 _level) external;
    
    function getAccessLevel(address _account) external view returns (uint8);

    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external;
```

The implementations for each of the above functions can be found in the AccessLevels contract.

###### *see [AccessLevels](../../../src/client/application/data/AccessLevels.sol)*

###### *see [IDataModule](../../../src/client/application/data/IDataModule.sol)*

```c
    function proposeOwner(address _newOwner) external;

    function confirmOwner() external;

    function confirmDataProvider(ProviderType _providerType) external;
```

The implementations for each of the above functions can be found in the DataModule contract.

###### *see [DataModule](../../../src/client/application/data/DataModule.sol)*

## Process for switching to an external access tier provider

The switching process consists of proposing and confirming the data provider. The first part of the 2 step process is to set a new access level provider. The new provider address is proposed and saved, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in AppManager.

- 1. Deploy the external Access Tier Provider
- 2. Call proposeAccessLevelsProvider in the AppManager.
    ```c
    function proposeAccessLevelsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE);
    ```
- 3. Call confirmDataProvider in the external access tier provider contract with provider type = IDataModule.ProviderType.ACCESS_LEVEL:
    ```c
    function confirmDataProvider(ProviderType _providerType) external;
    ```
    
### Revert Messages

The confirmation will revert if the external access tier contract address does not match the proposed access tier provider: 

```
error ConfirmerDoesNotMatchProposedAddress();
```
The selector for this error is `0x41284967`.

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron