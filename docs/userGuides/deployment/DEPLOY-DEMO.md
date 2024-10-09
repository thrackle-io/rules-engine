# Deployment of the Demo 

[![Project Version][version-image]][version-url]

A demo script is provided that sets up the protocol, several protocol supported assets, rules, and admins. This demo can be deployed to a local anvil or any EVM compatible chain including testnets and mainnet.

## Included In The Demo

1. Full Protocol Deployment
   1. RulesProcessor and all facets
2. Dr. Frankenstein's Lab Application Deployment including:
   1. AppManager
      1. ApplicationHandler
   2. Frankenstein Coin (ApplicationERC20)
      1. Connected Token Handler (HandlerDiamond)
   3. Dracula Coin (ApplicationERC20)
      1. Connected Token Handler (HandlerDiamond)
   4. Wolfman NFT (ApplicationERC721AdminOrOwnerMint)
      1. Connected Token Handler (HandlerDiamond)
   5. NFT Pricing Contract (ApplicationERC721Pricing)
   6. ERC20 Pricing Contract (ApplicationERC20Pricing)
   7. Approve List Oracle (OracleApproved)
   8. Deny List Oracle (OracleDenied)
3. Mint 1 billion Frankenstein coins
4. Set the price of Wolfman NFT's to $1 USD
5. Add Application Administrator role to the provided address
6. Add Rule Administrator role to the provided address
7. Add provided address to the oracle approve list
8. Use provided address to create an `Account Min/Max Token Balance Rule`
9. Apply the 'Account Min/Max Token Balance Rule' to Frankenstein Coin P2P_TRANSFER actions
10. Generate terminal export commands for ease of use


## Prerequisites

[foundry](https://book.getfoundry.sh/getting-started/installation), pull the code, and then run in the root of the project's directory:

`foundryup --version $(awk '$1~/^[^#]/' script/foundryScripts/foundry.lock)` 

_Note: `awk` in the above command is used to ignore comments in `foundry.lock`_

`pip3 install -r requirements.txt`

` brew install jq`

## Local Demo Requirements

1. Address and private key from the Anvil addresses

## Testnet Demo Requirements

1. Application Administrator Address and private key(This should be controlled by the deployer and funded)
2. Rule Administrator Address and private key(This should be controlled by the deployer and funded)
3. RPC url for the target testnet
4. Chain ID for the target testnet
5. Gas Price Setting for the target testnet(This is to aid successful deployment and prevent timeouts)
6. User1 Address(This should be controlled by the deployer and funded)
7. User2 Address(This should be controlled by the deployer and funded)
8. Protocol Deployment Owner Address and private key(This should be controlled by the deployer and funded)
9. `Optional` Rule Processor Address(only required if `Protocal Already Deployed` is set to `y`)

## Running DemoSetup.sh

1. Open a terminal in the project root directory
2. Run the following command in the terminal
   ```
   sh script/demo/DemoSetup.sh
   ```
3. Enter the data prompted by the script

## Testing

1. Copy the generated export statements to your terminal and run them. NOTE: They can be copy/pasted and run in one large chunk. Example:

```
    export ETH_RPC_URL=http://127.0.0.1:8545
    export RULE_PROCESSOR_DIAMOND=0x18693c9efb90c7a00f80d58ca0aa78fb0514dd81
    export APPLICATION_APP_MANAGER=0x09256f4f4caf376509eb5a4d91827da28358cc0c
    export APP_ADMIN_1_KEY=0xaf6f94772436a29ab6a7cbd448a016f20d43f17044c23af8548e4b740816c955
    export APP_ADMIN_1=0x7E97c19CA80Ba38D64c8C2e047694a11459C23bB
    export USER_1=0x90bF80a1fC7976C899F10f5617ff1D2CaB2d7B1e
    export USER_2=0xd2C79D2d7d7A71B04aA1025d5BF104008Cb7ff6e
    export APPLICATION_ERC20_1=0xff95b0f9e7868c0c8b785eeca646287c890200ca
    export APPLICATION_ERC20_1_HANDLER=0x85a0826585ca53c98aed848d38f157b748a08aa2
    export APPLICATION_ERC721_1=0x235c540193b3163ad07022d69cf0ef8052ae14b1
    export APPLICATION_ERC721_1_HANDLER=0xc306b7c859b8f2f94b4f3a73c4ba822ba291bfb1
```

2. Transfer 100 Frankenstein coins to User 1

```
    cast send $APPLICATION_ERC20_1 "transfer(address,uint256)" $USER_1 100 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1
```

3. Check User 1 Frankenstein coin Balance

```
    cast call $APPLICATION_ERC20_1 "balanceOf(address)(uint256)" $USER_1 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1 
```

4. Attempt to Transfer Over Max Balance - THIS WILL VIOLATE THE RULE AND FAIL

```	
    cast send $APPLICATION_ERC20_1 "transfer(address,uint256)" $USER_1 1 --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1
```

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-2.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/forte-rules-engine
