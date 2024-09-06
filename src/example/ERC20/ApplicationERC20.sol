// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "src/client/token/IProtocolToken.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import {IZeroAddressError} from "src/common/IErrors.sol";
import {ITokenEvents, IApplicationEvents} from "src/common/IEvents.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "src/client/token/handler/diamond/FeesFacet.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _tokenAdmin are set in constructor
 */
contract ApplicationERC20 is ERC20, ERC20Burnable, AccessControl, IProtocolToken, IZeroAddressError, ReentrancyGuard, ITokenEvents, IApplicationEvents {

    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    address private handlerAddress;

    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol Symbol of the token
     * @param _tokenAdmin Token Admin address
     */
     // slither-disable-next-line shadowing-local
    constructor(string memory _name, string memory _symbol, address _tokenAdmin) ERC20(_name, _symbol) {
        _grantRole(TOKEN_ADMIN_ROLE, _tokenAdmin);
        _setRoleAdmin(TOKEN_ADMIN_ROLE, TOKEN_ADMIN_ROLE);
    }

    /**
     * @dev Function mints new tokens. 
     * @param to recipient address
     * @param amount number of tokens to mint
     */
    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }

/// TRANSFER FUNCTION GROUP START
     /**
     * @dev This is overridden from {IERC20-transfer}. It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    // Disabling this finding, it is a false positive. A reentrancy lock modifier has been
    // applied to this function
    // slither-disable-start reentrancy-events
    // slither-disable-start reentrancy-no-eth
    function transfer(address to, uint256 amount) public virtual override nonReentrant returns (bool) {
        address owner = _msgSender();
        // if transfer fees/discounts are defined then process them first
        if (handlerAddress != address(0)) {
            if (FeesFacet(handlerAddress).isFeeActive()) {
                // return the adjusted amount after fees
                amount = _handleFees(owner, amount);
            }
        }
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev This is overridden from {IERC20-transferFrom}. It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public override nonReentrant returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        // if transfer fees/discounts are defined then process them first
        if (handlerAddress != address(0)) {
            if (FeesFacet(handlerAddress).isFeeActive()) {
                // return the adjusted amount after fees
                amount = _handleFees(from, amount);
            }
        }
        _transfer(from, to, amount);
        return true;
    }
    // slither-disable-end reentrancy-events
    // slither-disable-end reentrancy-no-eth
    /**
     * @dev This transfers all the P2P transfer fees to the individual fee sinks
     * @param from sender address
     * @param amount number of tokens being transferred
     */
    function _handleFees(address from, uint256 amount) internal returns (uint256) {
        address[] memory targetAccounts;
        int24[] memory feePercentages;
        uint256 fees = 0;
        (targetAccounts, feePercentages) = FeesFacet(handlerAddress).getApplicableFees(from, balanceOf(from));
        for (uint i; i < feePercentages.length; ++i) {
            if (feePercentages[i] > 0) {
                // trim the fee and send it to the target fee sink account
                uint fee = (amount * uint24(feePercentages[i])) / 10000;
                if (fee > 0) {
                    _transfer(from, targetAccounts[i], fee);
                    emit AD1467_FeeCollected(targetAccounts[i], fee);
                    // accumulate all fees
                    fees += fee;
                }
            }
        }
        // subtract the total fees from main transfer amount
        return amount -= fees;
    }
/// TRANSFER FUNCTION GROUP END

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param amount number of tokens to be transferred
     */
    // slither-disable-next-line calls-loop
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        /// Rule Processor Module Check
        if (handlerAddress != address(0)) require(IProtocolTokenHandler(handlerAddress).checkAllRules(balanceOf(from), balanceOf(to), from, to, _msgSender(), amount));
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @notice This function does not check for zero address. Zero address is a valid address for this function's purpose.
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
     // slither-disable-next-line missing-zero-check
    function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE) {
        handlerAddress = _deployedHandlerAddress;
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }

}
