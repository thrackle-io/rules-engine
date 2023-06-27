// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "diamond-std/core/DiamondCut/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "diamond-std/core/DiamondLoupe/DiamondLoupeFacet.sol";

/**
 * @title ProtocolNativeFacet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev The code for this comes from Nick Mudge's sample contracts. The only reason this is here is so that the deploy scripts can
 * still use Foundry's vm.getCode operation to pull the function selectors for the facets.
 */
contract ProtocolNativeFacet is DiamondCutFacet, DiamondLoupeFacet {

}
