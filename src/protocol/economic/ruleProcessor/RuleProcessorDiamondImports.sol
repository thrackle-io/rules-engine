// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "src/protocol/economic/ruleProcessor/RuleProcessorCommonLib.sol";
import "src/common/IErrors.sol";
import "src/protocol/economic/ruleProcessor/RuleCodeData.sol";
import {ERC173} from "diamond-std/implementations/ERC173/ERC173.sol";
import {RuleProcessorDiamondLib as processorDiamond, RuleDataStorage} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol";
import {RuleStoragePositionLib as Storage} from "src/protocol/economic/ruleProcessor/RuleStoragePositionLib.sol";
import {IRuleStorage as RuleS} from "src/protocol/economic/ruleProcessor/IRuleStorage.sol";
import {IApplicationRules as ApplicationRuleStorage, INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules, IFeeRules as Fee} from "src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol";
import {IEconomicEvents} from "src/common/IEvents.sol";



/**
 * @title Rule Processor Diamond Import Abstract Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This abstract contract exists to centralize the imports needed across the Rule Processor Facets.
 * @notice This contract should be used by all facet contracts in the rule processor module. 
 * import "./RuleProcessorDiamondImports.sol";
 */

abstract contract RuleProcessorDiamondImports {}
