// SPDX-License-Identifier: UNLICENSED

//Objective:
//Anyone can send Ethers
//Only owner can withdraw
//Anyone can check wallet balance

pragma solidity >=0.7.0 <0.9.0;

struct UserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;
    bytes callData;
    bytes32 accountGasLimits;
    uint256 preVerificationGas;
    bytes32 gasFees;
    bytes paymasterAndData;
    bytes signature;
}

interface IEntryPoint {
    /**
     * Execute a batch of UserOperations.
     * no signature aggregator is used.
     * if any account requires an aggregator (that is, it returned an aggregator when
     * performing simulateValidation), then handleAggregatedOps() must be used instead.
     * @param ops the operations to execute
     * @param beneficiary the address to receive the fees
     */
    function handleOps(UserOperation[] calldata ops, address payable beneficiary) external;
}

contract SCAWallet{


    //Define owner as state variable
    address payable public owner;

    IEntryPoint _entrypoint;

    //The one ho calls the contract for the first time is the owner 
    constructor() {
        owner = payable(msg.sender);
        _entrypoint = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789); // put in standard address
    }
    

    function entryPoint() public view virtual returns (IEntryPoint) {
        return _entrypoint;
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds) external view verifyOwner returns (uint256) {
        userOp;
        userOpHash;
        missingAccountFunds;
        return 0; // for testing purposes we're going to assume this reverts
    }

    // function to call another contract, this is purely for testing purposes
    function callContract(address target, uint256 value, bytes memory data) external verifyOwner() {
        (bool success, bytes memory result) = target.call{value : value}(data); // Call the contract with the provided address, value, and function data
        if (!success) { // Check if the call was unsuccessful
            assembly { // Use assembly to revert with the error message from the failed call
                revert(add(result, 32), mload(result))
            }
        }
    }

    //Payable function returns nothing (setter function only takes ethers as an argument and stores ethers inside the smart contract)
    //Since we need ethers to store inside of our wallet (smart contract) 
    function getEthToWallet() payable external{}
    //We could also use
    //receive() payable external{}

    //Verify Owner or Not
    modifier verifyOwner() {
        require(msg.sender==owner || msg.sender == address(entryPoint()),"Only restricted to Wallet Owner or entrypoint");
        _;
    }

    //Transfer the amount from caller's account to this wallet (smart contract)
    function withdraw(uint _amount) external verifyOwner{
        payable(msg.sender).transfer(_amount);
    }

    //To know the wallet balance
    function getWalletBalance() external view returns (uint){
        return address(this).balance;
    }

    //To know the owner balance
    function getOwnerBalance() external view returns (uint){
        return address(owner).balance;
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external pure returns (bytes4) {
            _operator;
            _from;
            _tokenId;
            _data;
            return this.onERC721Received.selector;
    }

}

contract SCAWalletZeroDevStyle {

    address public entrypoint;
    //Define owner as state variable
    address payable public owner;

    function getWalletBalance() external view returns (uint){
        return address(this).balance;
    }

        //Verify Owner or Not
    modifier verifyOwner() {
        require(msg.sender==owner || msg.sender == address(entrypoint),"Only restricted to Wallet Owner or entrypoint");
        _;
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds) external view verifyOwner returns (uint256) {
        userOp;
        userOpHash;
        missingAccountFunds;
        return 0; // for testing purposes we're going to assume this reverts
    }

    //The one ho calls the contract for the first time is the owner 
    constructor() {
        owner = payable(msg.sender);
        entrypoint = address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789); // put in standard address
    }
    
}

contract SCAWalletSafeStyle {

    address public immutable SUPPORTED_ENTRYPOINT;
    //Define owner as state variable
    address payable public owner;

    function getWalletBalance() external view returns (uint){
        return address(this).balance;
    }

        //Verify Owner or Not
    modifier verifyOwner() {
        require(msg.sender==owner || msg.sender == address(SUPPORTED_ENTRYPOINT),"Only restricted to Wallet Owner or entrypoint");
        _;
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds) external view verifyOwner returns (uint256) {
        userOp;
        userOpHash;
        missingAccountFunds;
        return 0; // for testing purposes we're going to assume this reverts
    }

    //The one ho calls the contract for the first time is the owner 
    constructor() {
        owner = payable(msg.sender);
        SUPPORTED_ENTRYPOINT = address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789); // put in standard address
    }
    
}