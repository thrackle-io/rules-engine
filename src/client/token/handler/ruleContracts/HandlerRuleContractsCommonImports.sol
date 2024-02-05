// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Rule} from "../common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import {StorageLib as lib} from "../diamond/StorageLib.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import "../../../../protocol/economic/IRuleProcessor.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import "../../../../protocol/economic/ruleProcessor/RuleCodeData.sol";

abstract contract HandlerRuleContractsCommonImports{}