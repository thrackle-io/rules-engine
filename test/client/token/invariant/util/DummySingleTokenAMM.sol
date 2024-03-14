// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DummySingleTokenAMM {
    function buy(uint256 _amount, address token) public {
        IERC20(token).transfer(msg.sender, _amount);
    }

    function sell(uint256 _amount, address token) public {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
    }
}
