// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../application/IAppManager.sol";
import "../liquidity/IProtocolAMMHandler.sol";
import "../economic/AppAdministratorOnly.sol";
import "./IProtocolAMMCalculator.sol";
import "../../src/liquidity/IProtocolAMMHandler.sol";
import {IApplicationEvents} from "../interfaces/IEvents.sol";
import { AMMCalculatorErrors, AMMErrors, IZeroAddressError } from "../interfaces/IErrors.sol";

/**
 * @title ProtocolAMM Base Contract
 * @notice This is the base contract for all protocol AMMs. Token 0 is the application native token. Token 1 is the chain native token (ETH, MATIC, ETC).
 * @dev The only thing to recognize is that calculations are all done in an external calculation contract
 * TODO add action types purchase and sell to buy/sell functions, test purchaseWithinPeriod on buy functions.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMM is AppAdministratorOnly, IApplicationEvents,  AMMCalculatorErrors, AMMErrors, IZeroAddressError {
    
    /// Application Token
    IERC20 public immutable token0;
    /// Collateralized Token
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    address public appManagerAddress;
    // Address that will accrue fees
    address treasuryAddress;
    address public calculatorAddress;
    IProtocolAMMCalculator calculator;
    IProtocolAMMHandler handler;

    /**
     * @dev Must provide the addresses for both tokens that will provide liquidity
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _appManagerAddress valid address of the corresponding app manager
     * @param _calculatorAddress valid address of the corresponding calculator for the AMM
     */
    constructor(address _token0, address _token1, address _appManagerAddress, address _calculatorAddress) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        appManagerAddress = _appManagerAddress;
        /// Set the calculator and create the variable for it.
        _setCalculatorAddress(_calculatorAddress);
        emit AMMDeployed(address(this));
    }

    /**
     * @dev update the reserve balances
     * @param _reserve0 amount of token0 in contract
     * @param _reserve1 amount of token1 in contract
     */
    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    /**
     * @dev This is the primary function of this contract. It allows for
     *      the swapping of one token for the other.
     * @dev arguments for checkRuleStorages: balanceFrom is token0 balance of msg.sender, balanceTo is token1 balance of msg.sender.
     * @param _tokenIn address identifying the token coming into AMM
     * @param _amountIn amount of the token being swapped
     * @return amountOut amount of the other token coming out of the AMM
     */
    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        if (!(_tokenIn == address(token0) || _tokenIn == address(token1))) {
            revert TokenInvalid(_tokenIn);
        }
        if (_amountIn == 0) {
            revert AmountsAreZero();
        }

        if (_tokenIn == address(token0)) {
            return _swap0For1(_amountIn);
        } else {
            return _swap1For0(_amountIn);
        }
    }

    /**
     * @dev This performs the swap from token0 to token1
     * @notice This is considered a "SELL" as the user is trading application native token 0 and receiving the chain native token 1
     * @param _amountIn amount of token0 being swapped for unknown amount of token1
     * @return _amountOut amount of token1 coming out of the pool
     */
    function _swap0For1(uint256 _amountIn) private returns (uint256 _amountOut) {
        /// Calculate how much token they get in return
        _amountOut = calculator.calculateSwap(reserve0, reserve1, _amountIn, 0);
        ///Check Rules(it's ok for this to be after the swap...it will revert on rule violation)
        require(
            handler.checkAllRules(
                token0.balanceOf(msg.sender),
                token1.balanceOf(msg.sender),
                msg.sender,
                address(this),
                _amountIn,
                _amountOut,
                address(token0),
                ActionTypes.SELL
            )
        );

        /// update the reserves with the proper amounts(adding to token0, subtracting from token1)
        _update(reserve0 += _amountIn, reserve1 - _amountOut);
        /// Assess fees. All fees are always taken out of the collateralized token(token1)
        uint256 fees = handler.assessFees(token0.balanceOf(msg.sender), token1.balanceOf(msg.sender), msg.sender, address(this), _amountOut, ActionTypes.SELL);
        /// subtract fees from collateralized token
        _amountOut -= fees;
        /// add fees to treasury
        if (!token1.transfer(treasuryAddress, fees)) revert TransferFailed();
        /// perform swap transfers
        if (!token0.transferFrom(msg.sender, address(this), _amountIn)) revert TransferFailed();
        if (!token1.transfer(msg.sender, _amountOut)) revert TransferFailed();
        emit Swap(address(token0), _amountIn, _amountOut);
    }

    /**
     * @dev This performs the swap from token1 to token0
     * @notice This is considered a "Purchase" as the user is trading chain native token 1 and receiving the application native token
     * @param _amountIn amount of token0 being swapped for unknown amount of token1
     * @return _amountOut amount of token1 coming out of the pool
     */
    function _swap1For0(uint256 _amountIn) private returns (uint256 _amountOut) {
        /// Assess fees. All fees are always taken out of the collateralized token(token1)
        uint256 fees = handler.assessFees(token1.balanceOf(msg.sender), token0.balanceOf(msg.sender), msg.sender, address(this), _amountIn, ActionTypes.PURCHASE);
        /// subtract fees from collateralized token
        _amountIn -= fees;
        /// add fees to treasury
        if (!token1.transfer(treasuryAddress, fees)) revert TransferFailed();
        /// Calculate how much token they get in return
        _amountOut = calculator.calculateSwap(reserve0, reserve1, 0, _amountIn);
        ///Check Rules
        require(
            handler.checkAllRules(
                token0.balanceOf(msg.sender),
                token1.balanceOf(msg.sender),
                msg.sender,
                address(this),
                _amountIn,
                _amountOut,
                address(token0),
                ActionTypes.PURCHASE
            )
        );

        /// update the reserves with the proper amounts(subtracting from token0, adding to token1)
        _update(reserve0 - _amountOut, reserve1 += _amountIn);
        /// transfer the token0 amount to the swapper
        if (!token1.transferFrom(msg.sender, address(this), _amountIn)) revert TransferFailed();
        if (!token0.transfer(msg.sender, _amountOut)) revert TransferFailed();
        emit Swap(address(token1), _amountIn, _amountOut);
    }

    /**
     * @dev This function allows contributions to the liquidity pool
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _amount0 The amount of token0 being added
     * @param _amount1 The amount of token1 being added
     * @return success pass/fail
     */
    function addLiquidity(uint256 _amount0, uint256 _amount1) external appAdministratorOnly(appManagerAddress) returns (bool) {
        require(_amount0 > 0 || _amount1 > 0, "No tokens contributed");

        _update(reserve0 + _amount0, reserve1 + _amount1);
        /// transfer funds from sender to the AMM. All the checks for available funds
        /// and approval are done in the ERC20
        if (_amount0 > 0) {
            if (!token0.transferFrom(msg.sender, address(this), _amount0)) revert TransferFailed();
        }
        if (_amount1 > 0) {
            if (!token1.transferFrom(msg.sender, address(this), _amount1)) revert TransferFailed();
        }
        emit AddLiquidity(address(token0), address(token1), _amount0, _amount1);
        return true;
    }

    /**
     * @dev This function allows owners to remove token0 liquidity
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _amount The amount of token0 being removed
     * @return success pass/fail
     */
    function removeToken0(uint256 _amount) external appAdministratorOnly(appManagerAddress) returns (bool) {
        if (_amount == 0) {
            revert AmountsAreZero();
        }
        if (_amount > reserve0) {
            revert AmountExceedsBalance(_amount);
        }
        /// update the reserve balances
        _update(reserve0 - _amount, reserve1);
        /// transfer the tokens to the remover
        if (!token0.transfer(msg.sender, _amount)) revert TransferFailed();
        emit RemoveLiquidity(address(token0), _amount);
        return true;
    }

    /**
     * @dev This function allows owners to remove token1 liquidity
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _amount The amount of token1 being removed
     * @return success pass/fail
     */
    function removeToken1(uint256 _amount) external appAdministratorOnly(appManagerAddress) returns (bool) {
        if (_amount == 0) {
            revert AmountsAreZero();
        }
        if (_amount > reserve0) {
            revert AmountExceedsBalance(_amount);
        }
        /// update the reserve balances
        _update(reserve0, reserve1 - _amount);
        /// transfer the tokens to the remover
        if (!token1.transfer(msg.sender, _amount)) revert TransferFailed();
        emit RemoveLiquidity(address(token1), _amount);
        return true;
    }

    /**
     * @dev This function allows owners to set the app manager address
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _appManagerAddress The address of a valid appManager
     */
    function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress) {
        require(_appManagerAddress != address(0), "Address cannot be default address");
        appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev This function allows owners to set the calculator address
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _calculatorAddress The address of a valid AMMCalculator
     */
    function setCalculatorAddress(address _calculatorAddress) external appAdministratorOnly(appManagerAddress) {
        _setCalculatorAddress(_calculatorAddress);
    }

    /**
     * @dev This function allows owners to set the calculator address. It is only meant to be used at instantiation of contract
     * @param _calculatorAddress The address of a valid AMMCalculator
     */
    function _setCalculatorAddress(address _calculatorAddress) private {
        require(_calculatorAddress != address(0), "Address cannot be default address");
        calculatorAddress = _calculatorAddress;
        calculator = IProtocolAMMCalculator(calculatorAddress);
    }

    /**
     * @dev This function returns reserve0
     */
    function getReserve0() external view returns (uint256) {
        return reserve0;
    }

    /**
     * @dev This function returns reserve1
     */
    function getReserve1() external view returns (uint256) {
        return reserve1;
    }

    /**
     * @dev This function sets the treasury address
     * @param _treasury address for the treasury
     */
    function setTreasuryAddress(address _treasury) external appAdministratorOnly(appManagerAddress) {
        treasuryAddress = _treasury;
    }

    /**
     * @dev This function gets the treasury address
     * @return _treasury address for the treasury
     */
    function getTreasuryAddress() external view appAdministratorOnly(appManagerAddress) returns (address) {
        return treasuryAddress;
    }

    /**
     * @dev Connects the AMM with its handler
     * @param _handlerAddress of the rule processor
     */
    function connectHandlerToAMM(address _handlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_handlerAddress == address(0)) revert ZeroAddress();
        handler = IProtocolAMMHandler(_handlerAddress);
        emit HandlerConnected(_handlerAddress, address(this));
    }

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return address(handler);
    }
}
