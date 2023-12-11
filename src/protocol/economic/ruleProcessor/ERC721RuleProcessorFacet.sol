// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";

/**
 * @title NFT Rule Processor Facet Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev facet in charge of the logic to check non-fungible token rules compliance
 * @notice Implements NFT Rule checks for rules
 */
contract ERC721RuleProcessorFacet is IERC721Errors, IRuleProcessorErrors, IMaxTagLimitError {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for bytes32[];


    /**
     * @dev This function receives data needed to check Minimum hold time rule. This a simple rule and thus is not stored in the rule storage diamond.
     * @param _holdHours minimum number of hours the asset must be held
     * @param _ownershipTs beginning of hold period
     */
    function checkNFTHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view {
        if (_ownershipTs > 0) {
            if ((block.timestamp - _ownershipTs) < _holdHours * 1 hours) {
                revert MinimumHoldTimePeriodNotReached();
            }
        }
    }
}
