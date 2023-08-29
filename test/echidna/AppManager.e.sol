// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/application/AppManager.sol";

contract TestAppManager is AppManager {
    constructor() AppManager(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, "TestApp", false) {}
}
