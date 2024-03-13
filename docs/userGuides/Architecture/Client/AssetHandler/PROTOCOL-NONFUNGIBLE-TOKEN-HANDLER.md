# NonFungible Token Handler Diamond 

## Purpose 

The Protocol NonFungible Token Handler Diamond is the asset handler used for Protocol supported ERC721 tokens. This Handler will utilize the ERC721 Rule facets to facilitate in economic rule checks with the rule Processor diamond and App Manager. 

## Unique Facets
#### ERC721HandlerMainFacet
This facet contains functions that are necessary for rule facilitation on a protocol supported ERC721 token. The first function is the initializer function.

```c
function initialize(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress) external onlyOwner
├── when the caller is not the owner
│ └── it should revert
└── when the caller is the owner
    └── when the function has not been called previously 
        ├── when ruleProcessorProxyAddress or appManagerAddress or assetAddress is the zero address
        │ └── it should revert
        └── when the ruleProcessorProxyAddress or appManagerAddress or assetAddress is not the zero address 
            ├── it should set the ruleProcessorProxyAddress state variable
            ├── it should set the appManagerAddress state variable
            ├── it should set the assetAddress state variable
            ├── it should set the assetAddress state variable
            └── it should set the initialized state variable to true 
```
This function can only be called once and stores parameters that are used throughout the facets. 


The next function in this facet is the check all rules function: 
```c
function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to,  address _sender, uint256 _tokenId) external onlyOwner returns (bool)
├── when the caller is not the owner
│ └── it should revert
└── when the caller is the owner
    └── it should call the application manager and check application level rules 
        └── when application level rules are active 
        │ └── it should validate application level rules through the application manager 
        ├── it should call the rule processor diamond and validate the transaction 
        └── when the rule processor diamond returns true 
          └── it should succeed
```
This function is the entry point for the token to facilitate checks to all rules set to active.  


#### ERC721TaggedRuleFacet
This facet contains the function to check all tag based and trading rules that are set to active for the token. 

```c
function checkTaggedAndTradingRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) external
```

#### ERC721NonTaggedRuleFacet
This facet contains the function to check all tag based rules that are set to active for the token.

```c
function checkNonTaggedRules(ActionTypes action, address _from, address _to, uint256 _amount, uint256 _tokenId) external
```

## Events 

- **event DiamondCut(_diamondCut, init, data)**: 
    - Emitted when: the Asset Handler Diamond has been upgraded.
    - Parameters:
        - _diamondCut: Facets Array
        - init: Address of the contract or facet to execute "data"
        - data: A function call, including function selector and arguments calldata is executed with delegatecall on "init"

## Upgrading
- The new facet that is to be added to the diamond should first be deployed to the same network the Asset Handler Diamond is deployed to. 

- The new facet address and function selectors are used as parameters for the DiamondCut function. 

- Once the new facet is deployed and the function selectors are known, call diamondCut on the Asset Handler Diamond contract. This is the address of the [Asset Handler Proxy](./PROTOCOL-ASSET-HANDLER-DIAMOND.md). 

```c
function diamondCut(FacetCut[] memory _diamondCut, address init, bytes memory data) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; ) {
            bytes4[] memory functionSelectors = _diamondCut[facetIndex].functionSelectors;
            address facetAddress = _diamondCut[facetIndex].facetAddress;

            if (functionSelectors.length == 0) {
                revert NoSelectorsProvidedForFacetForCut(facetAddress);
            }

            FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == FacetCutAction.Add) {
                addFunctions(facetAddress, functionSelectors);
            } else if (action == FacetCutAction.Replace) {
                replaceFunctions(facetAddress, functionSelectors);
            } else if (action == FacetCutAction.Remove) {
                removeFunctions(facetAddress, functionSelectors);
            } else {
                revert IncorrectFacetCutAction(uint8(action));
            }
            unchecked {
                ++facetIndex;
            }
        }
        emit DiamondCut(_diamondCut, init, data);
        initializeDiamondCut(init, data);
    }
```
- Any attempt to remove an immutable function from the diamond will revert. 

- Adding functions that already exist within the diamond will revert with an error "Cannot add function that already exists". 

- The diamondCut function will add the new selectors to storage and are then able to be called through the proxy address.

<!-- TODO: Update section with Facet Upgrade script steps  -->