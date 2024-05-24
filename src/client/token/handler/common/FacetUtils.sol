// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {HandlerDiamondLib, HandlerDiamondStorage} from "src/client/token/handler/diamond/HandlerDiamondLib.sol";

contract FacetUtils{

    function callAnotherFacet(bytes4 _functionSelector, bytes memory _callData) internal returns(bool success, bytes memory res){
        HandlerDiamondStorage storage ds = HandlerDiamondLib.s();
        address facet = ds.facetAddressAndSelectorPosition[_functionSelector].facetAddress;
        (success, res) = address(facet).delegatecall(_callData);
        if (!success) assembly {revert(add(res,0x20),mload(res))}
    }

}