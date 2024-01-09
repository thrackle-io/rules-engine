// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "src/protocol/economic/ruleProcessor/RuleCodeData.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "src/client/application/IAppManager.sol";
import "src/common/IProtocolERC721Pricing.sol";
import "src/common/IProtocolERC20Pricing.sol";
import "src/protocol/economic/AppAdministratorOrOwnerOnly.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import "src/client/application/IAppManagerUser.sol";
import "./IAdminWithdrawalRuleCapable.sol";
import "./IProtocolTokenHandler.sol";
import "src/client/token/IAdminWithdrawalRuleCapable.sol";
import {IAssetHandlerErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";

/**
 * @title Protocol Handler Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 */

abstract contract ProtocolHandlerCommon is 
    IAppManagerUser, 
    IProtocolTokenHandler, 
    IOwnershipErrors, 
    IZeroAddressError, 
    ITokenHandlerEvents, 
    ICommonApplicationHandlerEvents, 
    IAssetHandlerErrors, 
    AppAdministratorOnly, 
    RuleAdministratorOnly, 
    AppAdministratorOrOwnerOnly
{
    string private constant VERSION="1.1.0";
    address private newAppManagerAddress;
    address public appManagerAddress;
    IRuleProcessor ruleProcessor;
    IAppManager appManager;
    // Pricing Module interfaces
    IProtocolERC20Pricing erc20Pricer;
    IProtocolERC721Pricing nftPricer;
    address public erc20PricingAddress;
    address public nftPricingAddress;
    bytes32 ERC20_PRICER;

    /// RuleIds
    uint32 internal purchaseLimitRuleId;
    uint32 internal sellLimitRuleId;
    uint32 internal purchasePercentageRuleId;
    uint32 internal sellPercentageRuleId;

    /// on-off switches for rules
    bool internal purchaseLimitRuleActive;
    bool internal sellLimitRuleActive;
    bool internal purchasePercentageRuleActive;
    bool internal sellPercentageRuleActive;

    /// purchase/sell data
    uint64 public previousPurchaseTime;
    uint64 public previousSellTime;
    uint256 internal totalPurchasedWithinPeriod; /// total number of tokens purchased in period
    uint256 internal totalSoldWithinPeriod; /// total number of tokens purchased in period
    /// Mapping lastUpdateTime for most recent previous tranaction through Protocol
    mapping(address => uint64) lastPurchaseTime;
    mapping(address => uint256) purchasedWithinPeriod;
    mapping(address => uint256) salesWithinPeriod;
    mapping(address => uint64) lastSellTime;

     /// token level accumulators
    uint256 internal transferVolume;
    uint64 internal lastTransferTs;
    uint64 internal lastSupplyUpdateTime;
    int256 internal volumeTotalForPeriod;
    uint256 internal totalSupplyForPeriod;


    /**
     * @dev This function consolidates all the trading rules.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param fromTags tags of the from account
     * @param toTags tags of the from account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function _checkTradingRules(
        address _from, 
        address _to, 
        bytes32[] memory fromTags, 
        bytes32[] memory toTags, 
        uint256 _amount, 
        ActionTypes action
    )
    internal
    {
        if(action == ActionTypes.PURCHASE){
            if (purchaseLimitRuleActive) {
                purchasedWithinPeriod[_to] = ruleProcessor.checkPurchaseLimit(
                    purchaseLimitRuleId,
                    purchasedWithinPeriod[_to],
                    _amount,
                    toTags,
                    lastPurchaseTime[_to]
                );
                lastPurchaseTime[_to] = uint64(block.timestamp);
            }
            if(purchasePercentageRuleActive){
                totalPurchasedWithinPeriod = ruleProcessor.checkPurchasePercentagePasses(
                    purchasePercentageRuleId, 
                    IERC20(msg.sender).totalSupply(), 
                    _amount, 
                    previousPurchaseTime, 
                    totalPurchasedWithinPeriod
                );
                previousPurchaseTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }else{
            if ( sellLimitRuleActive) {
                salesWithinPeriod[_from] = ruleProcessor.checkSellLimit(
                    sellLimitRuleId, 
                    salesWithinPeriod[_from], 
                    _amount, 
                    fromTags, 
                    lastSellTime[_from]
                );
                lastSellTime[_from] = uint64(block.timestamp);
            }
            if(sellPercentageRuleActive){
                totalSoldWithinPeriod = ruleProcessor.checkSellPercentagePasses(
                    sellPercentageRuleId,  
                    IERC20(msg.sender).totalSupply(), 
                    _amount, 
                    previousSellTime, 
                    totalSoldWithinPeriod
                );
                previousSellTime = uint64(block.timestamp); /// update with new blockTime if rule check is successful
            }
        }
    }


    /**
     * @dev Set the PurchaseLimitRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setPurchaseLimitRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        purchaseLimitRuleId = _ruleId;
        purchaseLimitRuleActive = true;
        emit ApplicationHandlerApplied(PURCHASE_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePurchaseLimitRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        purchaseLimitRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(PURCHASE_LIMIT, address(this));
        } else {
            emit ApplicationHandlerDeactivated(PURCHASE_LIMIT, address(this));
        }
    }

    /**
     * @dev Retrieve the Purchase Limit rule id
     * @return purchaseLimitRuleId
     */
    function getPurchaseLimitRuleId() external view returns (uint32) {
        return purchaseLimitRuleId;
    }

    /**
     * @dev Tells you if the Purchase Limit Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isPurchaseLimitActive() external view returns (bool) {
        return purchaseLimitRuleActive;
    }

    /**
     * @dev Set the SellLimitRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setSellLimitRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        sellLimitRuleId = _ruleId;
        sellLimitRuleActive = true;
        emit ApplicationHandlerApplied(SELL_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateSellLimitRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        sellLimitRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SELL_LIMIT, address(this));
        } else {
            emit ApplicationHandlerDeactivated(SELL_LIMIT, address(this));
        }
    }

    /**
     * @dev Retrieve the Purchase Limit rule id
     * @return oracleRuleId
     */
    function getSellLimitRuleId() external view returns (uint32) {
        return sellLimitRuleId;
    }

    /**
     * @dev Tells you if the Purchase Limit Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isSellLimitActive() external view returns (bool) {
        return sellLimitRuleActive;
    }

    /**
     * @dev Get the block timestamp of the last purchase for account.
     * @return LastPurchaseTime for account
     */
    function getLastPurchaseTime(address account) external view ruleAdministratorOnly(appManagerAddress) returns (uint256) {
        return lastPurchaseTime[account];
    }

    /**
     * @dev Get the block timestamp of the last Sell for account.
     * @return LastSellTime for account
     */
    function getLastSellTime(address account) external view returns (uint256) {
        return lastSellTime[account];
    }

    /**
     * @dev Get the cumulative total of the purchases for account in purchase period.
     * @return purchasedWithinPeriod for account
     */
    function getPurchasedWithinPeriod(address account) external view returns (uint256) {
        return purchasedWithinPeriod[account];
    }

    /**
     * @dev Get the cumulative total of the Sales for account during sell period.
     * @return salesWithinPeriod for account
     */
    function getSalesWithinPeriod(address account) external view  returns (uint256) {
        return salesWithinPeriod[account];
    }

    /**
     * @dev Set the purchasePercentageRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setPurchasePercentageRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        purchasePercentageRuleId = _ruleId;
        purchasePercentageRuleActive = true;
        emit ApplicationHandlerApplied(PURCHASE_PERCENTAGE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activatePurchasePercentageRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        purchasePercentageRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(PURCHASE_PERCENTAGE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(PURCHASE_PERCENTAGE, address(this));
        }
    }

    /**
     * @dev Retrieve the Purchase Percentage Rule Id
     * @return purchasePercentageRuleId
     */
    function getPurchasePercentageRuleId() external view returns (uint32) {
        return purchasePercentageRuleId;
    }

    /**
     * @dev Tells you if the Purchase Percentage Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isPurchasePercentageRuleActive() external view returns (bool) {
        return purchasePercentageRuleActive;
    }

    /**
     * @dev Set the sellPercentageRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setSellPercentageRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        sellPercentageRuleId = _ruleId;
        sellPercentageRuleActive = true;
        emit ApplicationHandlerApplied(SELL_PERCENTAGE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateSellPercentageRuleIdRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        sellPercentageRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SELL_PERCENTAGE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(SELL_PERCENTAGE, address(this));
        }
    }

    /**
     * @dev Retrieve the Purchase Percentage Rule Id
     * @return purchasePercentageRuleId
     */
    function getSellPercentageRuleId() external view returns (uint32) {
        return sellPercentageRuleId;
    }

    /**
     * @dev Tells you if the Purchase Percentage Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isSellPercentageRuleActive() external view returns (bool) {
        return sellPercentageRuleActive;
    }

    /**
     * @dev this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process
     * @param _newAppManagerAddress the new address being proposed
     */
    function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_newAppManagerAddress == address(0)) revert ZeroAddress();
        newAppManagerAddress = _newAppManagerAddress;
        emit AppManagerAddressProposed(_newAppManagerAddress);
    }

    /**
     * @dev this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        if (newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        appManagerAddress = newAppManagerAddress;
        appManager = IAppManager(appManagerAddress);
        delete newAppManagerAddress;
        emit AppManagerAddressSet(appManagerAddress);
    }

    /**
     * @dev sets the address of the nft pricing contract and loads the contract.
     * @param _address Nft Pricing Contract address.
     */
    function setNFTPricingAddress(address _address) external appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_address == address(0)) revert ZeroAddress();
        nftPricingAddress = _address;
        nftPricer = IProtocolERC721Pricing(_address);
        emit ERC721PricingAddressSet(_address);
    }

    /**
     * @dev sets the address of the erc20 pricing contract and loads the contract.
     * @param _address ERC20 Pricing Contract address.
     */
    function setERC20PricingAddress(address _address) external appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_address == address(0)) revert ZeroAddress();
        erc20PricingAddress = _address;
        erc20Pricer = IProtocolERC20Pricing(_address);
        emit ERC20PricingAddressSet(_address);
    }

    /**
     * @dev Get the account's balance in dollars. It uses the registered tokens in the app manager.
     * @notice This gets the account's balance in dollars.
     * @param _account address to get the balance for
     * @return totalValuation of the account in dollars
     */
    function getAccTotalValuation(address _account, uint256 _nftValuationLimit) public view returns (uint256 totalValuation) {
        address[] memory tokenList = appManager.getTokenList();
        uint256 tokenAmount;
        /// check if _account is zero address. If zero address we return a valuation of zero to allow for burning tokens when rules that need valuations are active.
        if (_account == address(0)) {
            return totalValuation;
        } else {
            /// Loop through all Nfts and ERC20s and add values to balance for account valuation
            for (uint256 i; i < tokenList.length; ) {
                /// First check to see if user owns the asset
                tokenAmount = (IToken(tokenList[i]).balanceOf(_account));
                if (tokenAmount > 0) {
                    try IERC165(tokenList[i]).supportsInterface(0x80ac58cd) returns (bool isERC721) {
                        if (isERC721 && tokenAmount >= _nftValuationLimit) totalValuation += _getNFTCollectionValue(tokenList[i], tokenAmount);
                        else if (isERC721 && tokenAmount < _nftValuationLimit) totalValuation += _getNFTValuePerCollection(tokenList[i], _account, tokenAmount);
                        else {
                            uint8 decimals = ERC20(tokenList[i]).decimals();
                            totalValuation += (_getERC20Price(tokenList[i]) * (tokenAmount)) / (10 ** decimals);
                        }
                    } catch {
                        uint8 decimals = ERC20(tokenList[i]).decimals();
                        totalValuation += (_getERC20Price(tokenList[i]) * (tokenAmount)) / (10 ** decimals);
                    }
                }
                unchecked {
                    ++i;
                }
            }
        }
    }

    /**
     * @dev Get the value for a specific ERC20. This is done by interacting with the pricing module
     * @notice This gets the token's value in dollars.
     * @param _tokenAddress the address of the token
     * @return price the price of 1 in dollars
     */
    function _getERC20Price(address _tokenAddress) internal view returns (uint256) {
        if (erc20PricingAddress != address(0)) {
            return erc20Pricer.getTokenPrice(_tokenAddress);
        } else {
            revert PricingModuleNotConfigured(erc20PricingAddress, nftPricingAddress);
        }
    }

    /**
     * @dev Get the value for a specific ERC721. This is done by interacting with the pricing module
     * @notice This gets the token's value in dollars.
     * @param _tokenAddress the address of the token
     * @param _account of the token holder
     * @param _tokenAmount amount of NFTs from _tokenAddress contract
     * @return totalValueInThisContract in whole USD
     */
    function _getNFTValuePerCollection(address _tokenAddress, address _account, uint256 _tokenAmount) internal view returns (uint256 totalValueInThisContract) {
        if (nftPricingAddress != address(0)) {
            for (uint i; i < _tokenAmount; ) {
                totalValueInThisContract += nftPricer.getNFTPrice(_tokenAddress, IERC721Enumerable(_tokenAddress).tokenOfOwnerByIndex(_account, i));
                unchecked {
                    ++i;
                }
            }
        } else {
            revert PricingModuleNotConfigured(erc20PricingAddress, nftPricingAddress);
        }
    }

    /**
     * @dev Get the total value for all tokens held by wallet for specific collection. This is done by interacting with the pricing module
     * @notice This function gets the total token value in dollars of all tokens owned in each collection by address.
     * @param _tokenAddress the address of the token
     * @param _tokenAmount amount of NFTs from _tokenAddress contract
     * @return totalValueInThisContract total valuation of tokens by collection in whole USD
     */
    function _getNFTCollectionValue(address _tokenAddress, uint256 _tokenAmount) private view returns (uint256 totalValueInThisContract) {
        if (nftPricingAddress != address(0)) {
            totalValueInThisContract = _tokenAmount * uint256(nftPricer.getNFTCollectionPrice(_tokenAddress));
        } else {
            revert PricingModuleNotConfigured(erc20PricingAddress, nftPricingAddress);
        }
    }


    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev checks the appManager to determine if an address is an AMM or not
     * @param _address the address to check if is an AMM
     * @return true if the _address is an AMM
     */
    function _isAMM(address _address) internal view returns (bool){
        return appManager.isRegisteredAMM(_address);
    }

    /**
     * @dev determines if a transfer is a pure P2P transfer or a trade such as Buying or Selling
     * @param _from the address where the tokens are being moved from
     * @param _to the address where the tokens are going to
     * @param _sender the address triggering the transaction
     * @return action intended in the transfer
     */
    function determineTransferAction(address _from, address _to, address _sender) internal view returns (ActionTypes action){
        action = ActionTypes.TRADE;
        if(!(_sender == _from || address(0) == _from || address(0) == _to)){
            action = ActionTypes.SELL;
        }else if(isContract(_from))
            action = ActionTypes.PURCHASE;
    }
    

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}

interface IToken {
    function balanceOf(address owner) external view returns (uint256 balance);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);
}
