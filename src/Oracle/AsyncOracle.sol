// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

enum  Status{
        NOT_CHECKED,
        DENIED, 
        APPROVED, 
        PENDING 
     }

contract AsyncOracle is Context, Ownable{

    struct Request{
        uint256 balance;
        address tokenAddress;
        address account;
    }

    address public oracleOrigin;
    uint128 public requestId;
    uint256 public minGasDeposit;
    /// account => status
    mapping (address => Status) private statusPerAccount;
    /// requestId => Request
    mapping (uint128 => Request) public requestById;
    /// account => RequestId
    mapping (address =>  uint128) private accountToRequestId;

    error NotAuthorized();
    error NotEnoughDeposit(uint256 minDeposit);
    error TransferFailed(bytes reason);
    error FunctionDoesNotExist();
    error OracleOriginNotSet();
    error CannotWithdrawZero();
    error NotEnoughBalance();
    error CheckAlreadyPlaced();

    modifier onlyOracle(){
        if(_msgSender() != oracleOrigin) revert NotAuthorized();
        _;
    }

    event StatusRequest(uint128 indexed requestID, address indexed account, address indexed tokenAddress);
    event RequestCompleted(uint128 indexed requestID, bool indexed isApproved);

    constructor(address _oracleOrigin, uint256 _minGasDeposit) payable {
            oracleOrigin = _oracleOrigin;
            minGasDeposit = _minGasDeposit;
    }

    function requestStatus(address account, address tokenAddress) external payable returns(uint8 _status, uint128 _requestId){
        // if oracle doesn't have a state for the account (NOT_CHECKED), it starts a check
        if(statusPerAccount[account] == Status.NOT_CHECKED){
            // it will first see if the account sent enough funds for the offchain check
            if (msg.value < minGasDeposit) revert NotEnoughDeposit(minGasDeposit);
            // then we store the requestId locally to avoid expensive read from storage
            _requestId = requestId;
            // we write to storage the relevant data
            accountToRequestId[account] = _requestId;
            statusPerAccount[account] = Status.PENDING;
            Request memory _req = Request(msg.value, tokenAddress, account);
            requestById[_requestId] = _req;
            // we notify the offchain part of the oracle to do the check
            emit StatusRequest(_requestId, account, tokenAddress);
            // we update the requestId
            ++requestId;
            // finally we return the status which should be PENDING in this case
            _status = _getStatusPerAccount(account);
        }else{
            // if not, it will return the state and will return any funds sent
            _status = _getStatusPerAccount(account);
            if (msg.value > 0){
                (bool sent, bytes memory data) = payable(account).call{value: msg.value}("");
                if(!sent) revert TransferFailed(data);
            }
        }
    }

    function _getStatusPerAccount(address account) internal view returns(uint8 _status){
        unchecked{
            _status = uint8(statusPerAccount[account]) - 1;
        }
    }

    function completeRequest(uint128 _requestId, bool isApproved, uint256 gasUsed) external onlyOracle{
        Request memory _req = requestById[_requestId];
        uint256 balance = _req.balance;
        /// oracle should always check this before sending tx to avoid a malicious attack
        if(balance < gasUsed) revert NotEnoughDeposit(gasUsed);
        balance -= gasUsed;
        statusPerAccount[_req.account] = isApproved ? Status.APPROVED : Status.DENIED;
        /// reentrancy prevention
        delete _req.balance;
        /// return any excess of gas funds
        if(balance >0){
            /// WARNING:
            /// A malicious receiver contract might have a gas consumer function in the receive or fallback function
            /// which could eat more gas than anticipated. A full test on the offchain side of the oracle must be
            /// conducted to see if it is capable of forseeing these possible attacks, or we might need to limit the
            /// amount of gas available to transfer the ETH by either setting a manual gas limit in the "call" function,
            /// or by using either "send" or "transfer" instead of "call" although this might limit the transfers to
            /// only EOAs or very simple receiving contracts.
            (bool sent, bytes memory data) = payable(_req.account).call{value: balance}("");
            if(!sent) revert TransferFailed(data); 
        }
        
        emit RequestCompleted(_requestId, isApproved);
    }

    function updateGasDeposit(uint256 newGasDeposit) external onlyOwner{
        minGasDeposit = newGasDeposit;
    }

    function updateOracleOrigin(address newOracleOrigin) external onlyOwner{
        oracleOrigin = newOracleOrigin;
    }

    /**
     * @dev Function to withdraw a specific amount from this contract to oracleOrigin address.
     * @param _amount the amount to withdraw (WEIs)
     */
    function withdrawAmount(uint256 _amount) external onlyOwner {
        if (oracleOrigin == address(0x00)) revert OracleOriginNotSet();
        if(_amount == 0) revert CannotWithdrawZero();
        if(_amount > address(this).balance) revert NotEnoughBalance();
        (bool sent, bytes memory data) = oracleOrigin.call{value: _amount}("");
        if(!sent) revert TransferFailed(data);  
    }

    /**
     * @dev Function to withdraw all fees collected to oracleOrigin address.
     */
    function withdrawAll() external onlyOwner {
        if (oracleOrigin == address(0x00)) revert OracleOriginNotSet();
        uint balance = address(this).balance;
        if(balance == 0) revert CannotWithdrawZero();
        (bool sent, bytes memory data) = oracleOrigin.call{value: balance}("");
        if(!sent) revert TransferFailed(data);
    }

     /// Receive function for contract to receive chain native tokens in unordinary ways
    receive() external payable {}

    /// function to handle wrong data sent to this contract
    fallback() external payable {
        revert FunctionDoesNotExist();
    }
}