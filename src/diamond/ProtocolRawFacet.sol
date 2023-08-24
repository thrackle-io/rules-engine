// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC165Facet} from "diamond-std/implementations/ERC165/ERC165Facet.sol";

import {ERC173Facet} from "diamond-std/implementations/ERC173/ERC173Facet.sol";

/**
 * @title ProtocolNativeFacet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev The code for this comes from Nick Mudge's sample contracts. The only reason this is here is so that the deploy scripts can
 * still use Foundry's vm.getCode operation to pull the function selectors for the facets.
 */
contract ProtocolRawFacet is ERC165Facet, ERC173Facet {

}
