// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";


/**
 * @title ApplicationERC20Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the common module for ERC20 invariant tests..
 */
abstract contract ApplicationERC20Common is TestCommonFoundry {
    address msgSender;
    uint256 value;
    uint256 amount;
    address target;
    address USER1;
    address USER2;
    address USER3;
    
    function prepERC20AndEnvironment() public {
        setUpProtocolAndAppManagerAndTokensWithERC721HandlerDiamond();
        switchToAppAdministrator();
        (USER1, USER2, USER3, target) = _get4RandomAddresses(uint8(block.timestamp % ADDRESSES.length));
        amount = block.timestamp;
        applicationCoin.mint(USER1, 10 * ATTO);
        applicationCoin.mint(USER2, 10 * ATTO);
        applicationCoin.mint(USER3, 10 * ATTO);
        vm.stopPrank();
        targetSender(USER1);
        targetSender(USER2);
        targetSender(USER3);
        targetSender(target);
        targetContract(address(applicationCoin));
    }
}