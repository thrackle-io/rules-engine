// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../application/IAppManager.sol";
import "../liquidity/IProtocolAMMHandler.sol";
import "../economic/AppAdministratorOnly.sol";
import "./IProtocolAMMCalculator.sol";
import "../../src/liquidity/IProtocolAMMHandler.sol";
import {IApplicationEvents} from "../interfaces/IEvents.sol";
import { AMMCalculatorErrors, AMMErrors, IZeroAddressError } from "../interfaces/IErrors.sol";

/**
 * @title ProtocolERC721AMM Base Contract
 * @notice This is the base contract for all protocol AMMs. 
 * @dev The only thing to recognize is that calculations are all done in an external calculation contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolERC721AMM is AppAdministratorOnly, IERC721Receiver, IApplicationEvents,  AMMCalculatorErrors, AMMErrors, IZeroAddressError {
    
    uint256 constant PCT_MULTIPLIER = 10_000;
    /// The fungible token
    IERC20 public immutable ERC20Token;
    /// the non-fungible token
    IERC721 public immutable ERC721Token;

    address public appManagerAddress;
    // Address that will accrue fees
    address treasuryAddress;
    address public calculatorAddress;
    IProtocolAMMCalculator calculator;
    IProtocolAMMHandler handler;

    /**
     * @dev Must provide the addresses for both tokens that will provide liquidity
     * @param _ERC20Token valid ERC20 address
     * @param _ERC721Token valid ERC721 address
     * @param _appManagerAddress valid address of the corresponding app manager
     * @param _calculatorAddress valid address of the corresponding calculator for the AMM
     */
    constructor(address _ERC20Token, address _ERC721Token, address _appManagerAddress, address _calculatorAddress) {
        if(_ERC20Token == address(0) || _ERC721Token == address(0)) revert ZeroAddress();
        if(!_isERC721Enumerable(_ERC721Token)) revert NotEnumerable();
        ERC20Token = IERC20(_ERC20Token);
        ERC721Token = IERC721(_ERC721Token);
        
        appManagerAddress = _appManagerAddress;
        /// Set the calculator and create the variable for it.
        _setCalculatorAddress(_calculatorAddress);
        emit AMMDeployed(address(this));
    }

    /**
     * @dev This is the primary function of this contract. It allows for
     *      the swapping of one token for the other.
     * @dev arguments for checkRuleStorages: balanceFrom is ERC20Token balance of _msgSender(), balanceTo is  ERC721Token balance of _msgSender().
     * @param _tokenIn address identifying the token coming into AMM
     * @param _amountIn amount of the token being swapped
     * @param _tokenId the NFT Id to swap
     * @return amountOut amount of the other token coming out of the AMM
     */
    function swap(address _tokenIn, uint256 _amountIn, uint256 _tokenId) external returns (uint256 amountOut) {
        /// validatation block
        if (!(_tokenIn == address(ERC20Token) || _tokenIn == address (ERC721Token))) revert TokenInvalid(_tokenIn);
        if (_amountIn == 0) revert AmountsAreZero();
        /// swap
        if (_tokenIn == address(ERC20Token)) return _swap0For1(_amountIn, _tokenId);
        else return _swap1For0(_amountIn, _tokenId);
        
    }

    /**
     * @dev This performs the swap from ERC20Token to ERC721
     * @notice This is considered a "PURCHASE" as the user is trading fungible tokens in exchange for NFTs (buying NFTs)
     * @param _amountIn amount of ERC20Token being swapped for unknown amount of token1
     * @param _tokenId the NFT Id to swap
     * @return _amountOut amount of ERC721Token coming out of the pool
     */
    function _swap0For1(uint256 _amountIn, uint256 _tokenId) private returns (uint256 _amountOut) {

        /// we make sure we have the nft
        _checkNFTOwnership(address(this),_tokenId);
        
        /// only 1 NFT per swap is allowed
        _amountOut = 1;
        /// we get price, fees and validate _amountIn
        (uint256 price, uint256 fees) = _calculateBuyPrice();
        uint256 pricePlusFees =  price + fees;
        if(pricePlusFees > _amountIn) revert NotEnoughTokensForSwap(_amountIn, pricePlusFees);
        else _amountIn = price;
        
        ///Check Rules(it's ok for this to be after the swap...it will revert on rule violation)
        _checkRules(_amountOut, _amountIn, ActionTypes.PURCHASE);

        /// perform transfers
        _transferBuy(pricePlusFees, _tokenId);
        _sendERC20WithConfirmation(address(this), treasuryAddress, fees);
        emit Swap(address(ERC20Token), _amountIn, _amountOut);
    }

    /**
     * @dev This performs the swap from  ERC721Token to ERC20s
     * @notice This is considered a "SELL" as the user is providing NFT in exchange for fungible tokens
     * @param _amountIn amount of ERC20Token to pay for the NFT with _tokenId and the possible fees
     * @param _tokenId the NFT Id to swap
     * @return _amountOut amount of ERC20 tokens coming out of the pool
     */
    function _swap1For0(uint256 _amountIn, uint256 _tokenId) private returns (uint256 _amountOut) {

        /// we make sure the user has the nft
        _checkNFTOwnership(_msgSender(),_tokenId);

        /// only 1 NFT per swap is allowed
        if(_amountIn > 1) _amountIn = 1;
        /// we get price and fees
        (uint256 price, uint256 fees) =  _calculateSellPrice();
        _amountOut = price;

        ///Check Rules
        _checkRules(_amountIn, _amountOut, ActionTypes.SELL);

        /// transfer the ERC20Token amount to the swapper
        _transferSell(_amountOut - fees, _tokenId);
        _sendERC20WithConfirmation(address(this), treasuryAddress, fees);
        emit Swap(address (ERC721Token), _amountIn, _amountOut);
    }

    /**
     * @dev This function allows contributions to the liquidity pool
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _amountERC20 The amount of ERC20Token being added
     * @return success pass/fail
     */
    function addLiquidityERC20(uint256 _amountERC20) external appAdministratorOnly(appManagerAddress) returns (bool) {
        if(_amountERC20 == 0) revert ZeroValueNotPermited();

        /// transfer funds from sender to the AMM. All the checks for available funds
        /// and approval are done in the ERC20
        _sendERC20WithConfirmation(_msgSender(), address(this), _amountERC20);
        
        emit AddLiquidity(address(ERC20Token), address (ERC721Token), _amountERC20, 0);
        return true;
    }

    /**
     * @dev This function allows contributions to the liquidity pool
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _tokenId The Id of the ERC721Token being added. Liquidity can be added one by one.
     * @return success pass/fail
     */
    function addLiquidityERC721( uint256 _tokenId) external appAdministratorOnly(appManagerAddress) returns (bool) {

        /// transfer funds from sender to the AMM. All the checks for available funds
        _sendERC721WithConfirmation(_msgSender(), address(this), _tokenId);
        emit AddLiquidity(address(ERC20Token), address (ERC721Token), 0, _tokenId);
        return true;
    }

    /**
     * @dev This function allows contributions to the liquidity pool
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _tokenIds The Ids of the ERC721Tokens being added. This allows to add NFT liquidity in batch.
     * @return success pass/fail
     */
    function addLiquidityERC721InBatch( uint256[] memory _tokenIds) external appAdministratorOnly(appManagerAddress) returns (bool) {
        /// transfer NFTs from sender to the AMM
        for(uint i; i < _tokenIds.length;){
            _sendERC721WithConfirmation(_msgSender(), address(this), _tokenIds[i]);
            emit AddLiquidity(address(ERC20Token), address (ERC721Token), 0, _tokenIds[i]);
            unchecked{
                ++i;
            }
        }
        return true;
    }

    /**
     * @dev This function allows owners to remove ERC20Token liquidity
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _amount The amount of ERC20Token being removed
     * @return success pass/fail
     */

    function removeERC20(uint256 _amount) external appAdministratorOnly(appManagerAddress) returns (bool) {
        if (_amount == 0) revert AmountsAreZero();
        /// transfer the tokens to the remover
        _sendERC20WithConfirmation(address(this), _msgSender(), _amount);
        emit RemoveLiquidity(address(ERC20Token), _amount);
        return true;
    }

    /**
     * @dev This function allows owners to remove  ERC721Token liquidity
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _tokenId The Id of the NFT being removed
     * @return success pass/fail
     */
    function removeERC721(uint256 _tokenId) external appAdministratorOnly(appManagerAddress) returns (bool) {
        /// we make sure we have the nft
        _checkNFTOwnership(address(this), _tokenId);
        /// transfer the tokens to the remover
        _sendERC721WithConfirmation(address(this), _msgSender(), _tokenId);
        emit RemoveLiquidity(address (ERC721Token), _tokenId);
        return true;
    }

    /**
     * @dev sets the app manager address
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _appManagerAddress The address of a valid appManager
     */
    function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress) {
        require(_appManagerAddress != address(0), "Address cannot be default address");
        appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev sets the calculator address
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     * @param _calculatorAddress The address of a valid AMMCalculator
     */
    function setCalculatorAddress(address _calculatorAddress) external appAdministratorOnly(appManagerAddress) {
        _setCalculatorAddress(_calculatorAddress);
    }

    /**
     * @dev sets the calculator address. It is only meant to be used at instantiation of contract
     * @param _calculatorAddress The address of a valid AMMCalculator
     */
    function _setCalculatorAddress(address _calculatorAddress) private {
        require(_calculatorAddress != address(0), "Address cannot be default address");
        calculatorAddress = _calculatorAddress;
        calculator = IProtocolAMMCalculator(calculatorAddress);
    }

    /**
     * @dev This function sets the treasury address
     * @param _treasury address for the treasury
     */
    function setTreasuryAddress(address _treasury) external appAdministratorOnly(appManagerAddress) {
        treasuryAddress = _treasury;
    }

    /** 
    * the receiver function specified in ERC721
    */
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external pure returns (bytes4){
        _operator;
        _from;
        _tokenId;
        _data;
        return this.onERC721Received.selector;
    }

    /**
    * @dev public function to get the price for buying an NFT
    */
    function getBuyPrice() public view returns(uint256 price, uint256 fees){
        price = calculator.simulateSwap(0, 0, 0, 1);
        uint256 feesPct = handler.assessFees (ERC20Token.balanceOf(_msgSender()), ERC20Token.balanceOf( address(this)), _msgSender(), address(this), PCT_MULTIPLIER , ActionTypes.PURCHASE);
        fees = (price * PCT_MULTIPLIER) / (PCT_MULTIPLIER - feesPct ) - price; /// old version = (feesPct * price) / PCT_MULTIPLIER ;
    }

    /**
    * @dev internal function to get the price for buying an NFT and also changing the state of the calculator
    */
    function _calculateBuyPrice() internal returns(uint256 price, uint256 fees){
        price = calculator.calculateSwap(0, 0, 0, 1);
        uint256 feesPct = handler.assessFees (ERC20Token.balanceOf(_msgSender()), ERC20Token.balanceOf( address(this)), _msgSender(), address(this), PCT_MULTIPLIER , ActionTypes.PURCHASE);
        fees = (price * PCT_MULTIPLIER) / (PCT_MULTIPLIER - feesPct ) - price; /// old version = (feesPct * price) / PCT_MULTIPLIER ;
    }

    /**
    * @dev internal function to get the price for selling an NFT
    */
    function getSellPrice() public view returns(uint256 price, uint256 fees){
        price = calculator.simulateSwap(0, 0, 1, 0);
        fees = handler.assessFees(ERC20Token.balanceOf(address(this)), ERC20Token.balanceOf(_msgSender()), address(this), _msgSender(), price, ActionTypes.SELL);
    }

    /**
    * @dev internal function to get the price for selling an NFT and also changing the state of the calculator
    */
    function _calculateSellPrice() internal returns(uint256 price, uint256 fees){
        price = calculator.calculateSwap(0, 0, 1, 0);
        fees = handler.assessFees(ERC20Token.balanceOf(address(this)), ERC20Token.balanceOf(_msgSender()), address(this), _msgSender(), price, ActionTypes.SELL);
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
     * @dev returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return address(handler);
    }

    function _checkRules(uint256 _amountIn, uint256 _amountOut, ActionTypes act) private {
        handler.checkAllRules(
                ERC20Token.balanceOf(_msgSender()),
                ERC721Token.balanceOf(_msgSender()),
                _msgSender(),
                address(this),
                _amountIn,
                _amountOut,
                address(ERC721Token),
                act
            );
    }

    /** 
    * @dev gets ERC20 reserves in the pool
    * @return reserves of the ERC20 
    */
    function getERC20Reserves() external view returns(uint256 reserves){
        reserves = ERC20Token.balanceOf(address(this));
    }

    /** 
    * @dev gets ERC721 reserves in the pool
    * @return reserves of the ERC721 
    */
    function getERC721Reserves() external view returns(uint256 reserves){
        reserves = ERC721Token.balanceOf(address(this));
    }

    /** 
    * @dev assesses if an ERC721 token is enumerable 
    * @param _ERC721Token address of the token
    * @return true if the token is enumerable
    */
    function _isERC721Enumerable(address _ERC721Token) internal view returns(bool){
        return IERC165(_ERC721Token).supportsInterface(type(IERC721Enumerable).interfaceId);
    }

    /** 
    * @dev carries out the "BUY" swap 
    * @param _amount amount of ERC20s being paid to the AMM
    * @param _tokenId the NFT Id being sold
    */
    function _transferBuy(uint256 _amount, uint256 _tokenId) private {
        _sendERC20WithConfirmation(_msgSender(), address(this), _amount);
        _sendERC721WithConfirmation(address(this), _msgSender(), _tokenId);
    }

    /** 
    * @dev carries out the "SELL" swap 
    * @param _amount amount of ERC20s being paid to the user
    * @param _tokenId the NFT Id being added to the AMM
    */
    function _transferSell(uint256 _amount, uint256 _tokenId) private {
        _sendERC20WithConfirmation(address(this), _msgSender(), _amount);
        _sendERC721WithConfirmation(_msgSender(), address(this), _tokenId);
    }

    /** 
    * @dev transfers ERC20s and makes sure the transfer happened successfully
    * @param _from address of the sender
    * @param _to address of the recepient
    * @param _amount the amount of tokens changing hands
    */
    function _sendERC20WithConfirmation(address _from, address _to, uint256 _amount) private {
        if (_from == address(this)){
            if (!ERC20Token.transfer(_to, _amount)) revert TransferFailed(); /// change to low level call later
        }else{
            if (!ERC20Token.transferFrom(_from, _to, _amount)) revert TransferFailed(); /// change to low level call later
        }
       
    }

    /** 
    * @dev transfers an ERC721 and makes sure the transfer happened successfully
    * @param _from address of the sender
    * @param _to address of the recepient
    * @param _tokenId the NFT being transferred
    */
    function _sendERC721WithConfirmation(address _from, address _to, uint256 _tokenId) private {
        ERC721Token.safeTransferFrom(_from, _to, _tokenId);
        if (ERC721Token.ownerOf(_tokenId) != _to) revert TransferFailed();
    }

    /** 
    * @dev reverts if an NFT is not owned by the aleged owner
    * @param _owner address of the aleged owner
    * @param _tokenId the NFT the _owner claims to own
    */
    function _checkNFTOwnership(address _owner, uint256 _tokenId) internal view {
        if(ERC721Token.ownerOf(_tokenId) != _owner) revert NotTheOwnerOfNFT(_tokenId);
    }

    function howMuchToBuyAllBack() pure public returns(uint256 budget){
        //call integral in the calculator

    }


}
