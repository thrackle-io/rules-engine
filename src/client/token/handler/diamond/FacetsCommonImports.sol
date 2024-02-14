// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {StorageLib as lib} from "../diamond/StorageLib.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import "../common/FacetUtils.sol";
import "../../../application/IAppManager.sol";
import "../ruleContracts/HandlerAccountMinMaxTokenBalance.sol";
import "./TradingRuleFacet.sol";

abstract contract FacetsCommonImports{}