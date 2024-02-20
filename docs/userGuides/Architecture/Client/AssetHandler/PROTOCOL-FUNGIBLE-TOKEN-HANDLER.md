# Fungible Token Handler Diamond 

## Purpose 

The Protocol Fungible Token Handler Diamond is the asset handler used for Protocol supported ERC20 tokens. This Handler will utilize the ERC20 Rule facets to facilitate in economic rule checks with the rule Processor diamond and App Manager. 

## Unique Facets 
#### ERC20HandlerMainFacet
This facet contains functions that are necessary for rule facilitation on a protocol supported ERC20 token. The first function is the initializer function.

```c
function initialize(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress) external onlyOwner
```
This function can only be called once and stores parameters that are used throughout the facets. 


The next function in this facet is the check all rules function: 
```c
function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, address _sender, uint256 _amount) external onlyOwner returns (bool)
```
This function is the entry point for the token to facilitate checks to all rules set to active.  


#### ERC20TaggedRuleFacet
This facet contains the function to check all tag based and trading rules that are set to active for the token. 

```c
function checkTaggedAndTradingRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) external
```

#### ERC20NonTaggedRuleFacet
This facet contains the function to check all tag based rules that are set to active for the token.

```c
function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external
```

#### FeesFacet
This facet contains the functions to check and maintain the status of fees for the token. These functions are: 

```c
function setFeeActivation(bool on_off) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager)
```

```c
 function isFeeActive() external view returns (bool)
```

## Events 

- **event FeeActivationSet(bool on_off)**: 
    - Emitted when: the Asset Handler has a fee status change.
    - Parameters:
        - on_off: Activation status for fees 

- **event DiamondCut(_diamondCut, init, data)**: 
    - Emitted when: the Asset Handler Diamond has been upgraded.
    - Parameters:
        - _diamondCut: Facets Array
        - init: Address of the contract or facet to execute "data"
        - data: A function call, including function selector and arguments calldata is executed with delegatecall on "init"

## Upgrading
- The new facet that is to be added to the diamond should first be deployed to the network the Asset Handler Diamond is deployed to. 

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