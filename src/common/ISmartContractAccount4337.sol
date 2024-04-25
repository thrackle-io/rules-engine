// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

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

interface ISmartContractAccount4337 {
    function entryPoint() external view returns (address);

    function SUPPORTED_ENTRYPOINT() external view returns (address); // handle GNOSIS Safe

    function entrypoint() external view returns (address); // handles zerodev

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds) external returns (uint256 validationData);
}