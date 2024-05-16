# External Access Level Provider
[![Project Version][version-image]][version-url]

An external access level provider may be utilized when you need to rely on controls and data passports provided by external systems. In order to switch to an external access level provider, the external provider contract must conform to the IAccessLevels interface or an adapter contract that conforms to the interface must be used. Once the external provider contract is deployed, the [AppManager](../../../src/client/application/AppManager.sol) must be pointed to the new provider.

## Required functions for the External Access Level Provider


```c
    function addLevel(address _address, uint8 _level) external;
    
    function getAccessLevel(address _account) external view returns (uint8);

    function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external;
```

The implementations for each of the above functions can be found in the [AccessLevels](../../../src/client/application/data/AccessLevels.sol) contract.

###### *see [IAccessLevels](../../../src/client/application/data/IAccessLevels.sol)*
###### *see [AccessLevels](../../../src/client/application/data/AccessLevels.sol)*


```c
    function proposeOwner(address _newOwner) external;

    function confirmOwner() external;

    function confirmDataProvider(ProviderType _providerType) external;
```

The implementations for each of the above functions can be found in the [DataModule](../../../src/client/application/data/DataModule.sol) contract.

###### *see [IDataModule](../../../src/client/application/data/IDataModule.sol)*
###### *see [DataModule](../../../src/client/application/data/DataModule.sol)*

## Process for switching to an external access level provider

The switching process consists of proposing and confirming the data provider. The first part of the 2 step process is to propose a new access level provider in the [AppManager](../../../src/client/application/AppManager.sol). Once the new provider address is proposed, then it is confirmed by invoking a confirmation function in the new provider that invokes the corresponding function in [AppManager](../../../src/client/application/AppManager.sol). The process is as follows:

- 1. Deploy the external Access Level Provider.
- 2. Call proposeAccessLevelsProvider in the [AppManager](../../../src/client/application/AppManager.sol).
    ```c
    function proposeAccessLevelsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE);
    ```
- 3. Call confirmDataProvider in the external access level provider contract with provider type = IDataModule.ProviderType.ACCESS_LEVEL:
    ```c
    function confirmDataProvider(ProviderType _providerType) external;
    ```
    
### Revert Messages

The confirmation will revert if the external access level contract address does not match the proposed access level provider: 

```
error ConfirmerDoesNotMatchProposedAddress();
```
The selector for this error is `0x41284967`.

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron