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

    struct Request{
        uint256 balance;
        uint256 tokenId;
        address tokenAddress;
        address holder;
        Status status; 
    }

    address public oracleOrigin;
    uint128 public requestId;
    uint256 public gasDeposit;
    /// tokenAddress => tokenId => status
    mapping (address => mapping(uint256 => Status)) public statusPerNFT;
    /// requestId => Request
    mapping (uint128 => Request) public requestById;
    /// tokenAddress => tokenId => RequestId
    mapping (address => mapping(uint256 => uint128)) public tokenToRequestId;

    error NotAuthorized();
    error NotEnoughDeposit(uint256 minDeposit);
    error TrasferFailed(bytes reason);
    error FunctionDoesNotExist();
    error OracleOriginNotSet();
    error CannotWithdrawZero();
    error NotEnoughBalance();
    error CheckAlreadyPlaced();

    modifier onlyOracle(){
        if(_msgSender() != oracleOrigin) revert NotAuthorized();
        _;
    }

    event StatusRequest(uint128 indexed requestID, address indexed holder, address indexed tokenAddress, uint256 tokenId);
    event RequestCompleted(uint128 indexed requestID, bool indexed status);

    constructor(address _oracleOrigin, uint256 _gasDeposit) payable {
            oracleOrigin = _oracleOrigin;
            gasDeposit = _gasDeposit;
    }

    function startSoftStaking(address _holder, address _tokenAddress, uint256 _tokenId) external payable {
        if (msg.value < gasDeposit) revert NotEnoughDeposit(gasDeposit);
        if(statusPerNFT[_tokenAddress][_tokenId] != Status.NOT_STAKED) revert CheckAlreadyPlaced();

        uint128 _requestId = requestId;
        tokenToRequestId[_tokenAddress][_tokenId] = _requestId;
        statusPerNFT[_tokenAddress][_tokenId] = Status.PENDING;
        Request memory _req = Request(msg.value, _tokenId, _tokenAddress, _holder, Status.PENDING);
        requestById[_requestId] = _req;

        emit StatusRequest(_requestId, _holder, _tokenAddress, _tokenId);
        ++requestId;
    }


    function updateSoftStakingStatus(uint128 _requestId, bool isStaked, uint256 gasUsed) external onlyOracle{
        Request memory _req = requestById[_requestId];
        uint256 balance = _req.balance;
        // oracle should always check this before sending tx to avoid a malicious attack
        if(balance < gasUsed) revert NotEnoughDeposit(gasUsed);
        balance -= gasUsed;
        statusPerNFT[_req.tokenAddress][_req.tokenId] = isStaked ? Status.STAKED : Status.NOT_STAKED;
        /// reentrancy prevention
        delete _req.balance;
        (bool sent, bytes memory data) = payable(_req.holder).call{value: balance}("");
        if(!sent) revert TrasferFailed(data);
        
    }

    function claimStake(address _holder, address _tokenAddress, uint256 _tokenId) external {
        uint128 _requestId = tokenToRequestId[_tokenAddress][_tokenId];
        Request memory _req = requestById[_requestId];
        if(_holder != _req.holder) revert NotAuthorized();
        delete statusPerNFT[_req.tokenAddress][_req.tokenId];
        delete tokenToRequestId[_req.tokenAddress][_req.tokenId];
        delete requestById[_requestId];
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