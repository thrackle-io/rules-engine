// SPDX-License-Identifier: GPL-3.0

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

//API struct used by getStakeInfo and simulateValidation
struct StakeInfo {
    uint256 stake;
    uint256 unstakeDelaySec;
}

interface IEntryPoint {
    /**
     * gas and return values during simulation
     * @param preOpGas the gas used for validation (including preValidationGas)
     * @param prefund the required prefund for this operation
     * @param sigFailed validateUserOp's (or paymaster's) signature check failed
     * @param validAfter - first timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param validUntil - last timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param paymasterContext returned by validatePaymasterUserOp (to be passed into postOp)
     */
    struct ReturnInfo {
        uint256 preOpGas;
        uint256 prefund;
        bool sigFailed;
        uint48 validAfter;
        uint48 validUntil;
        bytes paymasterContext;
    }

    /**
     * returned aggregated signature info.
     * the aggregator returned by the account, and its current stake.
     */
    struct AggregatorStakeInfo {
        address aggregator;
        StakeInfo stakeInfo;
    }


    /**
     * simulate full execution of a UserOperation (including both validation and target execution)
     * this method will always revert with "ExecutionResult".
     * it performs full validation of the UserOperation, but ignores signature error.
     * an optional target address is called after the userop succeeds, and its value is returned
     * (before the entire call is reverted)
     * Note that in order to collect the the success/failure of the target call, it must be executed
     * with trace enabled to track the emitted events.
     * @param op the UserOperation to simulate
     * @param target if nonzero, a target address to call after userop simulation. If called, the targetSuccess and targetResult
     *        are set to the return from that call.
     * @param targetCallData callData to pass to target address
     */
    function simulateHandleOp(UserOperation calldata op, address target, bytes calldata targetCallData) external;
}

contract SBAWallet{


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

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds) external returns (uint256 validationData) {
        userOp;
        userOpHash;
        missingAccountFunds;

        // assume true
        return 0;
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
    modifier verifyOwner{
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

contract SBAWalletZeroDevStyle {

    address public entrypoint;
    //Define owner as state variable
    address payable public owner;

    //The one ho calls the contract for the first time is the owner 
    constructor() {
        owner = payable(msg.sender);
        entrypoint = address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789); // put in standard address
    }
    
}

contract SBAWalletSafeStyle {

    address public immutable SUPPORTED_ENTRYPOINT;
    //Define owner as state variable
    address payable public owner;

    //The one ho calls the contract for the first time is the owner 
    constructor() {
        owner = payable(msg.sender);
        SUPPORTED_ENTRYPOINT = address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789); // put in standard address
    }
    
}