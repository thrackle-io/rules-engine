// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import {IApplicationEvents} from "src/common/IEvents.sol";
import {IZeroAddressError, IProtocolERC20Errors} from "src/common/IErrors.sol";
import "../ProtocolTokenCommon.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import "../handler/diamond/FeesFacet.sol";

/**
 * @title ERC20 Base Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC20s
 * @dev The only thing to recognize is that flash minting is added but not allowed...yet
 */
contract ProtocolERC20 is ERC20, ERC165, ERC20Burnable, ERC20FlashMint, Pausable, ProtocolTokenCommon, IProtocolERC20Errors {
    // address of the Handler
    IProtocolTokenHandler handler;

    /// Max supply should only be set once. Zero means infinite supply.
    uint256 MAX_SUPPLY;

    /**
     * @dev Constructor sets name and symbol for the ERC20 token and makes connections to the protocol.
     * @param _name name of token
     * @param _symbol abreviated name for token (i.e. THRK)
     * @param _appManagerAddress address of app manager contract
     * _upgradeMode is also passed to Handler contract to deploy a new data contract with the handler.
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress) ERC20(_name, _symbol) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);

        emit NewTokenDeployed(address(this), _appManagerAddress);
    }

    /**
     * @dev pauses the contract. Only whenPaused modified functions will work once called.
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function pause() public virtual appAdministratorOnly(appManagerAddress) {
        _pause();
    }

    /**
     * @dev Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function unpause() public virtual appAdministratorOnly(appManagerAddress) {
        _unpause();
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param amount number of tokens to be transferred
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {
        /// Rule Processor Module Check
        require(handler.checkAllRules(balanceOf(from), balanceOf(to), from, to, _msgSender(), amount));
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC20).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This is overridden from {IERC20-transfer}. It handles all fees/discounts and then uses ERC20 _transfer to do the actual transfers
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        // if transfer fees/discounts are defined then process them first
        if (FeesFacet(address(handler)).isFeeActive()) {
            address[] memory targetAccounts;
            int24[] memory feePercentages;
            uint256 fees;
            (targetAccounts, feePercentages) = handler.getApplicableFees(owner, balanceOf(owner));
            for (uint i; i < feePercentages.length; ) {
                if (feePercentages[i] > 0) {
                    // trim the fee and send it to the target treasury account
                    _transfer(owner, targetAccounts[i], (amount * uint24(feePercentages[i])) / 10000);
                    // accumulate all fees
                    fees += (amount * uint24(feePercentages[i])) / 10000;
                }
                unchecked {
                    ++i;
                }
            }
            // subtract the total fees from main transfer amount
            amount -= fees;
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
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        // if transfer fees/discounts are defined then process them first
        if (handler.isFeeActive()) {
            address[] memory targetAccounts;
            int24[] memory feePercentages;
            uint256 fees;
            (targetAccounts, feePercentages) = handler.getApplicableFees(from, balanceOf(from));
            for (uint i; i < feePercentages.length; ) {
                if (feePercentages[i] > 0) {
                    // trim the fee and send it to the target treasury account
                    uint fee = (amount * uint24(feePercentages[i])) / 10000;
                    if (fee > 0) {
                        _transfer(from, targetAccounts[i], fee);
                        // accumulate all fees
                        fees += fee;
                    }
                }
                unchecked {
                    ++i;
                }
            }
            // subtract the total fees from main transfer amount
            amount -= fees;
        }
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Function mints new tokens. AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param to recipient address
     * @param amount number of tokens to mint
     */
    function mint(address to, uint256 amount) public virtual {
        ///check that the address calling mint is authorized(appAdminstrator, AMM or Staking Contract)
        if (!appManager.isAppAdministrator(msg.sender) && !appManager.isRegisteredAMM(msg.sender)) {
            revert CallerNotAuthorizedToMint();
        }
        if (MAX_SUPPLY > 0 && totalSupply() + amount > MAX_SUPPLY) {
            revert ExceedingMaxSupply();
        }
        _mint(to, amount);
    }

    /**
     * @dev This function is overridden here as a guarantee that flashloans are not allowed. This is done in case they are enabled at a later time.
     * @param receiver loan recipient.
     * @param token address of token calling function
     * @param amount number of tokens
     * @param data arbitrary data structure for user params
     */
    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data) public pure virtual override returns (bool) {
        /// These are simply to get rid of the compiler warnings.
        receiver = receiver;
        token = token;
        amount = amount;
        data = data;
        revert("Flashloans not allowed at this time");
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _handlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _handlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_handlerAddress == address(0)) revert ZeroAddress();
        handler = IProtocolTokenHandler(_handlerAddress);
        emit HandlerConnected(_handlerAddress, address(this));
    }

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override returns (address) {
        return address(handler);
    }
}
