// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

enum  Status{
        NOT_STAKED, 
        STAKED, 
        PENDING 
     }

contract SoftStakingOracle is Context, Ownable{

    address public oracleOrigin;
    uint128 public requestId;
    uint256 public gasDeposit;
    mapping (address => uint8) public statusPerAddress;
    mapping (uint128 => address) public requestIdToAddress;
    mapping (uint128 => uint256) public requestIdToBalance;

    error NotAuthorized();
    error NotEnoughDeposit(uint256 minDeposit);
    error TrasferFailed(bytes reason);
    error FunctionDoesNotExist();
    error OracleOriginNotSet();
    error CannotWithdrawZero();
    error NotEnoughBalance();

    modifier onlyOracle(){
        if(_msgSender() != oracleOrigin) revert NotAuthorized();
        _;
    }

    event StatusRequest(uint128 indexed requestID, address indexed _address);
    event RequestCompleted(uint128 indexed requestID, address indexed _address, bool indexed status);

    constructor(address _oracleOrigin, uint256 _gasDeposit) payable {
            oracleOrigin = _oracleOrigin;
            gasDeposit = _gasDeposit;
    }

      
    function requestStatusCheck(address _address) external payable returns(uint8){
        if (msg.value < gasDeposit) revert NotEnoughDeposit(gasDeposit);
        uint128 _requestId = requestId;
        requestIdToBalance[_requestId] = msg.value;
        uint8 status = statusPerAddress[_address];
        if(status == 0){
            requestIdToAddress[_requestId] = _address;
            emit StatusRequest(_requestId, _address);
            ++requestId;
            statusPerAddress[_address] = uint8(Status.PENDING);
            return uint8(Status.PENDING);
        }
        else {
            (bool sent, bytes memory data) = payable(_address).call{value: msg.value}("");
            if(!sent) revert TrasferFailed(data);
            return status;
        }
    }

    function updateState(uint128 _requestId, bool isStaked, uint256 gasUsed) external onlyOracle{
        uint256 balance = requestIdToBalance[_requestId];
        // oracle should always check this before sending tx to avoid a malicious attack
        if(balance < gasUsed) revert NotEnoughDeposit(gasUsed);
        balance -= gasUsed;
        address _address = requestIdToAddress[_requestId];
        statusPerAddress[_address] = isStaked ? uint8(Status.STAKED ) : uint8(Status.NOT_STAKED);
        (bool sent, bytes memory data) = payable(_address).call{value: balance}("");
        if(!sent) revert TrasferFailed(data);
    }

    function requestStatusUpdate(address _address) external payable {
        if (msg.value < gasDeposit) revert NotEnoughDeposit(gasDeposit);
        uint128 _requestId = requestId;
        requestIdToBalance[_requestId] = msg.value;
        requestIdToAddress[_requestId] = _address;
        emit StatusRequest(_requestId, _address);
        ++requestId;
        statusPerAddress[_address] = uint8(Status.PENDING);
    }

    function updateGasDeposit(uint256 newGasDeposit) external onlyOwner{
        gasDeposit = newGasDeposit;
    }

    function updateOracleOrigin(address newOracleOrigin) external onlyOwner{
        oracleOrigin = newOracleOrigin;
    }

    /**
     * @dev Function to withdraw a specific amount from this contract to oracleOrigin address.
     * @param _amount the amount to withdraw (WEIs)
     */
    function withdrawAmount(uint256 _amount) external onlyOwner(){
        if (oracleOrigin == address(0x00)) revert OracleOriginNotSet();
        if(_amount == 0) revert CannotWithdrawZero();
        if(_amount > address(this).balance) revert NotEnoughBalance();
        (bool sent, bytes memory data) = oracleOrigin.call{value: _amount}("");
        if(!sent) revert TrasferFailed(data);  
    }

    /**
     * @dev Function to withdraw all fees collected to oracleOrigin address.
     */
    function withdrawAll() external onlyOwner() {
        if (oracleOrigin == address(0x00)) revert OracleOriginNotSet();
        uint balance = address(this).balance;
        if(balance == 0) revert CannotWithdrawZero();
        (bool sent, bytes memory data) = oracleOrigin.call{value: balance}("");
        if(!sent) revert TrasferFailed(data);
    }

     /// Receive function for contract to receive chain native tokens in unordinary ways
    receive() external payable {}

    /// function to handle wrong data sent to this contract
    fallback() external payable {
        revert FunctionDoesNotExist();
    }
}