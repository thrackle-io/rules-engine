# ApplicationAdminRolesScript
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/example/script/Application_Deploy_07_ApplicationAdminRoles.s.sol)

**Inherits:**
Script

This Script sets the admin roles for Application.
Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
Deploy Scripts:
forge script src/example/script/Application_Deploy_01_AppManger.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
forge script src/example/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
forge script src/example/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
forge script src/example/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
forge script src/example/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
forge script src/example/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
forge script src/example/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
<<<OPTIONAL>>>
forge script src/example/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv

*This Script sets the admin roles for Application.*


## State Variables
### privateKey

```solidity
uint256 privateKey;
```


### ownerAddress

```solidity
address ownerAddress;
```


## Functions
### setUp


```solidity
function setUp() public;
```

### run


```solidity
function run() public;
```

