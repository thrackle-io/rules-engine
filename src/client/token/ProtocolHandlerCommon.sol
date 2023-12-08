// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IAssetHandlerErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
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

/**
 * @title Protocol Handler Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 */

abstract contract ProtocolHandlerCommon is IAppManagerUser, IOwnershipErrors, IZeroAddressError, ITokenHandlerEvents, ICommonApplicationHandlerEvents, IAssetHandlerErrors, AppAdministratorOrOwnerOnly {
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
