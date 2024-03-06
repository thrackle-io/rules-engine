// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Context.sol";
import {IPermissionModifierErrors} from "src/common/IErrors.sol";

abstract contract RBACModifiersCommonImports is IPermissionModifierErrors, Context{}