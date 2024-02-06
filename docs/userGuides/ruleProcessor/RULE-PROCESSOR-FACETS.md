# Protocol Rule Processor Diamond Facets 

## Purpose

The Rule Processor Diamond Facets are where rule adding and rule check functions are stored in the protocol. Storage facets store the add rule functions for each [rule type](../rules/RULE-GUIDE.md). Processor facets store the rule check functions and are called by an application's handler contracts. Facets can be added or removed by the diamond to allow for upgrades to functionality of the diamond. Application contracts never call the facets directly and will only ever interact with the [Rule Processor Proxy](./RULE-PROCESSOR-DIAMOND.md).

#### *[see facet list](./RULE-PROCESSOR-FACET-LIST.md)*


## Upgrading
- The new facet that is to be added to the diamond should first be deployed to the network the Rule Processor Diamond is deployed too. 

- The new facet address and function selectors are used as parameters for the DiamondCut function. 

- Once the new facet is deployed and the function selectors are known, call diamondCut on the Rule Processor Diamond contract. This is the address of the [Rule Processor Proxy](./RULE-PROCESSOR-DIAMOND.md). 

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

## Events 

- **event DiamondCut(_diamondCut, init, data)**: 
    - Emitted when: the Rule Processor Diamond has been upgraded.
    - Parameters:
        - _diamondCut: Facets Array
        - init: Address of the contract or facet to execute "data"
        - data: A function call, including function selector and arguments calldata is executed with delegatecall on "init"
