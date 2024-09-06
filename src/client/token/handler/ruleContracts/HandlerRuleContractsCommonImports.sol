// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {Rule} from "src/client/token/handler/common/DataStructures.sol";
import {ActionTypes} from "src/common/ActionEnum.sol";
import {StorageLib as lib} from "src/client/token/handler/diamond/StorageLib.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import "src/protocol/economic/ruleProcessor/RuleCodeData.sol";
import "src/client/token/handler/diamond/RuleStorage.sol";
import "src/client/common/ActionTypesArray.sol";

abstract contract HandlerRuleContractsCommonImports {}
