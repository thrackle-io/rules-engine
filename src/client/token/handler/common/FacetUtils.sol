// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {HandlerDiamondLib, HandlerDiamondStorage} from "../diamond/HandlerDiamondLib.sol";

contract FacetUtils{

    function callAnotherFacet(bytes4 _functionSelector, bytes memory _callData) internal returns(bool success, bytes memory res){
        HandlerDiamondStorage storage ds = HandlerDiamondLib.s();
        address facet = ds.facetAddressAndSelectorPosition[_functionSelector].facetAddress;
        (success, res) = address(facet).delegatecall(_callData);
    }

}