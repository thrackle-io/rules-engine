// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/protocol/economic/ruleProcessor/RuleProcessorDiamondImports.sol";

/**
 * @title NFT Rule Processor Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Facet in charge of the logic to check non-fungible token rules compliance
 * @notice Implements NFT Rule checks
 */
contract ERC721RuleProcessorFacet is IERC721Errors, IRuleProcessorErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for bytes32[];


    /**
     * @dev This function receives data needed to check token min hold time rule. This a simple rule and thus is not stored in the rule storage diamond.
     * @param _holdHours minimum number of hours the asset must be held
     * @param _ownershipTs beginning of hold period
     */
    function checkTokenMinHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view {
        if (_ownershipTs > 0) {
            // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
            // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
            // slither-disable-next-line timestamp
            if ((block.timestamp - _ownershipTs) < _holdHours * 1 hours) {
                revert UnderHoldPeriod();
            }
        }
    }
}
