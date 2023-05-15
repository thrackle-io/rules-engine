// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../src/helpers/OwnableUpgradeable.sol";
import "./ruleProcessor/nontagged/RuleProcessorDiamond.sol";
import "./ITokenRuleRouter.sol";
import "./ruleProcessor/nontagged/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "./ruleProcessor/tagged/ERC20TaggedRuleProcessorFacet.sol";
import {ERC721TaggedRuleProcessorFacet} from "./ruleProcessor/tagged/ERC721TaggedRuleProcessorFacet.sol";
import {ERC721RuleProcessorFacet} from "./ruleProcessor/nontagged/ERC721RuleProcessorFacet.sol";
import {FeeRuleProcessorFacet} from "./ruleProcessor/nontagged/FeeRuleProcessorFacet.sol";
import {RiskTaggedRuleProcessorFacet} from "./ruleProcessor/tagged/RiskTaggedRuleProcessorFacet.sol";
import {TaggedRuleProcessorDiamond} from "./ruleProcessor/tagged/TaggedRuleProcessorDiamond.sol";

/**
 * @title Token Rule Router Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is the Token Rule Router.
 * @notice All the rule checks are funneled through this contract. Specifically
 * through the checkAllRules() function. This function then relays the
 * the checks to the RuleProcessor diamond and the TaggedRuleProcessor diamond.
 * These diamonds then reroute the checks to the appropiate facets.
 */
contract TokenRuleRouter is Initializable, OwnableUpgradeable {
    RuleProcessorDiamond public tokenRuleProcessorDiamondContract;
    TaggedRuleProcessorDiamond public taggedRuleProcessorDiamond;

    /**
     * @dev Function acts as a constructor for upgradeable contracts pattern.
     */
    function initialize(address payable tokenRuleProcessorsAddress, address payable taggedRuleProcessorAddress) public initializer {
        __Ownable_init();
        tokenRuleProcessorDiamondContract = RuleProcessorDiamond(tokenRuleProcessorsAddress);
        taggedRuleProcessorDiamond = TaggedRuleProcessorDiamond(taggedRuleProcessorAddress);
    }

    /**
     * @dev Set the address of the Token Rules Diamond
     * @param tokenRuleProcessorsAddress is the address of the Rule Processors Diamond
     */
    function setRuleProcessorDiamondAddress(address payable tokenRuleProcessorsAddress) external onlyOwner {
        tokenRuleProcessorDiamondContract = RuleProcessorDiamond(tokenRuleProcessorsAddress);
    }

    /**
     * @dev Set the address of the Tagged Rules Diamond
     * @param taggedRuleProcessorAddress is the address of the Tagged Rules Diamond
     */
    function setTaggedRuleProcessorDiamondAddress(address payable taggedRuleProcessorAddress) external onlyOwner {
        taggedRuleProcessorDiamond = TaggedRuleProcessorDiamond(taggedRuleProcessorAddress);
    }

    /**
     * Functions added so far:
     * minTransfer
     * balanceLimits
     * oracle
     */

    /**
     * @dev Check the minimum/maximum rule. This rule ensures that both the to and from accounts do not
     * exceed the max balance or go below the min balance.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param amount total number of tokens to be transferred
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalancePasses(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, uint256 amount, bytes32[] calldata toTags, bytes32[] calldata fromTags) public view {
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).minAccountBalanceCheck(balanceFrom, fromTags, amount, ruleId);
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).maxAccountBalanceCheck(balanceTo, toTags, amount, ruleId);
    }

    /**
     * @dev Check the minimum/maximum rule through the AMM Swap
     * @param ruleIdToken0 Uint value of the ruleId storage pointer for applicable rule.
     * @param ruleIdToken1 Uint value of the ruleId storage pointer for applicable rule.
     * @param tokenBalance0 Token balance of the token being swapped
     * @param tokenBalance1 Token balance of the received token
     * @param amountIn total number of tokens to be swapped
     * @param amountOut total number of tokens to be received
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalancePassesAMM(
        uint32 ruleIdToken0,
        uint32 ruleIdToken1,
        uint256 tokenBalance0,
        uint256 tokenBalance1,
        uint256 amountIn,
        uint256 amountOut,
        bytes32[] calldata fromTags
    ) public view {
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).minAccountBalanceCheck(tokenBalance0, fromTags, amountOut, ruleIdToken0);
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).maxAccountBalanceCheck(tokenBalance1, fromTags, amountIn, ruleIdToken1);
    }

    /**
     * @dev Check the minimum transfer rule. This rule ensures accounts cannot transfer less than
     * the specified amount.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param amount total number of tokens to be transferred
     */
    function checkMinTransferPasses(uint32 ruleId, uint256 amount) public view {
        ERC20RuleProcessorFacet(address(tokenRuleProcessorDiamondContract)).checkMinTransferPasses(ruleId, amount);
    }

    /**
     * @dev Check the minMaxAccoutBalace rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param balanceTo Token balance of the recipient address
     * @param toTags tags applied via App Manager to recipient address
     * @param fromTags tags applied via App Manager to sender address
     */
    function checkMinMaxAccountBalanceERC721(uint32 ruleId, uint256 balanceFrom, uint256 balanceTo, bytes32[] calldata toTags, bytes32[] calldata fromTags) public view {
        ERC721TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).minAccountBalanceERC721(balanceFrom, fromTags, ruleId);
        ERC721TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).maxAccountBalanceERC721(balanceTo, toTags, ruleId);
    }

    /**
     * @dev Check the minMaxAccoutBalace rule for ERC721 tokens. This rule ensures accounts cannot drop below specified account balance.
     * @param ruleId Uint value of the ruleId storage pointer for applicable rule.
     * @param balanceFrom Token balance of the sender address
     * @param amount total number of tokens to be transferred
     * @param tokenId array of tokenIds
     */
    function checkMinAccountBalanceERC721(uint32 ruleId, uint256 balanceFrom, uint256 amount, bytes32[] calldata tokenId) public view {
        ERC721RuleProcessorFacet(address(tokenRuleProcessorDiamondContract)).minAccountBalanceERC721(balanceFrom, tokenId, amount, ruleId);
    }

    /**
     * @dev This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.
     * @param _ruleId Rule Id
     * @param _address user address to be checked
     */
    function checkOraclePasses(uint32 _ruleId, address _address) public view {
        ERC20RuleProcessorFacet(address(tokenRuleProcessorDiamondContract)).checkOraclePasses(_ruleId, _address);
    }

    /**
     * @dev This function receives a rule id, which it uses to get Purchase Rule details.
     * @param ruleId Rule identifier for rule arguments
     * @param purchasedWithinPeriod Number of tokens purchased within purchase Period
     * @param amount Number of tokens to be transferred
     * @param toTags Account tags applied to sender via App Manager
     * @param lastUpdateTime block.timestamp of most recent transaction from sender.
     */
    function checkPurchaseLimit(uint32 ruleId, uint256 purchasedWithinPeriod, uint256 amount, bytes32[] calldata toTags, uint64 lastUpdateTime) public view returns (uint256) {
        return ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).purchaseLimit(ruleId, purchasedWithinPeriod, amount, toTags, lastUpdateTime);
    }

    /**
     * @dev  This function receives a rule id, which it uses to get the Sell Rule details.
     * @param ruleId Rule identifier for rule arguments
     * @param amount Number of tokens to be transferred
     * @param fromTags Account tags applied to sender via App Manager
     * @param lastUpdateTime block.timestamp of most recent transaction from sender.
     */
    function checkSellLimit(uint32 ruleId, uint256 salesWithinPeriod, uint256 amount, bytes32[] calldata fromTags, uint256 lastUpdateTime) public view returns (uint256) {
        return ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).sellLimit(ruleId, salesWithinPeriod, amount, fromTags, lastUpdateTime);
    }

    /**
     * @dev This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.
     * @param ruleId Rule identifier for rule arguments
     * @param transfersWithinPeriod Number of transfers within the time period
     * @param nftTags NFT tags applied
     * @param lastTransferTime block.timestamp of most recent transaction from sender.
     */
    function checkNFTTransferCounter(uint32 ruleId, uint256 transfersWithinPeriod, bytes32[] calldata nftTags, uint64 lastTransferTime) public view returns (uint256) {
        return ERC721RuleProcessorFacet(address(tokenRuleProcessorDiamondContract)).checkNFTTransferCounter(ruleId, transfersWithinPeriod, nftTags, lastTransferTime);
    }

    /**
     * @dev Check Transaction Limit for Risk Score
     * @param _ruleId Rule Identifier for rule arguments
     * @param _riskScore the Risk Score of the account
     * @param _amountToTransfer total dollar amount to be transferred
     */
    function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) public view {
        RiskTaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).transactionLimitbyRiskScore(_ruleId, _riskScore, _amountToTransfer);
    }

    /**
     * @dev Assess the fee associated with the AMM Fee Rule
     * @param _ruleId Rule Identifier for rule arguments
     * @param _collateralizedTokenAmount total number of collateralized tokens to be swapped(this could be the "token in" or "token out" as the fees are always * assessed from the collateralized token)
     */
    function assessAMMFee(uint32 _ruleId, uint256 _collateralizedTokenAmount) external view returns (uint256) {
        return FeeRuleProcessorFacet(address(tokenRuleProcessorDiamondContract)).assessAMMFee(_ruleId, _collateralizedTokenAmount);
    }

    /**
     * @dev checks that an admin won't hold less tokens than promised until a certain date
     * @param _ruleId Rule identifier for rule arguments
     * @param _currentBalance of tokens held by the admin
     * @param _amountToTransfer Number of tokens to be transferred
     * @notice that the function will revert if the check finds a violation of the rule, but won't give anything
     * back if everything checks out.
     */
    function checkAdminWithdrawalRule(uint32 _ruleId, uint256 _currentBalance, uint256 _amountToTransfer) external view {
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).checkAdminWithdrawalRule(_ruleId, _currentBalance, _amountToTransfer);
    }

    /**
     * @dev Rule checks if the minimum balance by date rule will be violated. Tagged accounts must maintain a minimum balance throughout the period specified
     * @param ruleId Rule identifier for rule arguments
     * @param balance account's current balance
     * @param amount Number of tokens to be transferred from this account
     * @param toTags Account tags applied to sender via App Manager
     */
    function checkMinBalByDatePasses(uint32 ruleId, uint256 balance, uint256 amount, bytes32[] calldata toTags) external view {
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).checkMinBalByDatePasses(ruleId, balance, amount, toTags);
    }
}
