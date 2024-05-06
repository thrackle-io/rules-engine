# Protocol Asset Handler Diamond Structure 

## Purpose

The Protocol Asset Handler Diamond serves as the access point to the protocol for a protocol supported asset. The protocol supported asset stores the Handler Diamond proxy address and uses it to call the `check all rules function`. The Handler Diamond stores all asset level rule data, rule activation status', and connects the token to the App Manager for role based access control. 

Asset level rules are set by [Rule administrators](../../../permissions/ADMIN-ROLES.md). When setting a rule status in the Handler the protocol supplied rule id for each [Rule](../../../rules/README.md) and the [action type](../../../rules/ACTION-TYPES.md) are required for the `set-rule function`. The Handler Diamond stores each action type and rule together within the [Rule Storage Facet](./PROTOCOL-ASSET-HANDLER-DIAMOND-FACET-LIST.md). 

Each Protocol supported asset type (ERC20, ERC721, etc) will need one handler diamond deployed and connected to the asset. The Handler diamond architecture will remain the same for each asset type. The asset handler diamond will consist of a proxy contract, libraries, storage facets and unique facets for that type. The unique facets for the asset type are found here:
- [Protocol Fungible Handler](./PROTOCOL-FUNGIBLE-TOKEN-HANDLER.md) 
- [Protocol NonFungible Handler](./PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md) 

#### *[see diamond diagram](../../../images/ApplicationDeployment.png)*

### Diamond Pattern

The diamond pattern allows the handler to upgrade, add new features and improvements through the use of a proxy contract. New facet contracts can be deployed and connected to the diamond via a specialized function called diamondCut. New facets and functions allow the handler to grow while maintaining address immutability with the proxy contract. Calling contracts will only need to set the address of the diamond proxy at deployment, without having to worry about that address changing over time. The Handler Diamond follows ERC 2535 standards for storage and functions. 
#### *[ERC 2535: Diamond Proxies](https://eips.ethereum.org/EIPS/eip-2535)*


### Common Contracts 

Each asset handler diamond will inherit from the following contracts: 
- [HandlerBase.sol](../../../../../src/client/token/handler/ruleContracts/HandlerBase.sol)
- [HandlerUtils.sol](../../../../../src/client/token/handler/common/HandlerUtils.sol)
- [HandlerDiamondLib.sol](../../../../../src/client/token/handler/diamond/HandlerDiamondLib.sol) 
- [RuleStorage.sol](../../../../../src/client/token/handler/diamond/RuleStorage.sol)
- [StorageLib.sol](../../../../../src/client/token/handler/diamond/StorageLib.sol)
- [TradingRulesFacet.sol](../../../../../src/client/token/handler/diamond/TradingRuleFacet.sol)

#### Handler Base 
The Handler Base contract contains functions to propose and confirm a new App Manager address. 

##### Functions 

```c
function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOrOwnerOnly(lib.handlerBaseStorage().appManager)
```

```c
 function confirmAppManagerAddress() external
```


#### Handler Utils 
This contract holds utility functions for the handler diamond. The first is to determine the action type of the transaction. The second is to determine if an address in the transaction is a contract or externally owned account. 

##### Functions

```c
function determineTransferAction(address _from, address _to, address _sender) internal view returns (ActionTypes action)
```

```c
function isContract(address account) internal view returns (bool)
```

#### Handler Diamond Lib 
The Handler Diamond Lib follows ERC 2535 standards for storage and functions. 
###### *[ERC 2535: Diamond Proxies](https://eips.ethereum.org/EIPS/eip-2535)*

#### Rule Storage
This contract holds the storage structs for each rule able to be set at the asset level. 

#### Storage Lib 
This contract holds storage functions called when setting a rule in the handler diamond. 

#### TradingRulesFacet 
This contract contains the function to check all trading rules that are active in the handler diamond. 

##### Functions

```c
function checkTradingRules(address _from, address _to, bytes32[] memory fromTags, bytes32[] memory toTags, uint256 _amount, ActionTypes action)
```

## Events
- **event AD1467_HandlerDeployed()**: 
    - Emitted when: the Asset Handler is deployed.

### Upgrading 

Facets may be added, replaced or removed over time: 

- [Upgrade an Asset Handler](./PROTOCOL-ASSET-HANDLER-DIAMOND-UPGRADE.md)
- If an upgrade needs to be reverted, see [Revert a Diamond Upgrade](../../common/DIAMOND-UPGRADE-REVERSION.md).

### Token Type Handlers

- [Protocol Fungible Handler](./PROTOCOL-FUNGIBLE-TOKEN-HANDLER.md) 
- [Protocol NonFungible Handler](./PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md) 