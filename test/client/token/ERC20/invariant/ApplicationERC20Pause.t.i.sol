// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ApplicationERC20Common.t.i.sol";

/**
 * @title ApplicationERC20PauseInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC20 pause functionality.
 */
contract ApplicationERC20PauseInvariantTest is ApplicationERC20Common {
   function setUp() public {
        prepERC20AndEnvironment();
    }

// Transfers should not be possible during paused state
    function invariant_ERC20external_pausedTransfer() public {
        (, msgSender, ) = vm.readCallers();
        uint256 balance_sender = applicationCoin.balanceOf(USER1);
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        if(!(balance_sender > 0))return;
        uint256 transfer_amount = amount % (balance_sender + 1);

        switchToAppAdministrator();
        applicationCoin.pause();
        vm.startPrank(USER1);
        vm.expectRevert("Pausable: paused");
        bool r = applicationCoin.transfer(target, transfer_amount);
        assertFalse(r);
        assertEq(
            applicationCoin.balanceOf(USER1),
            balance_sender
        );
        assertEq(
            applicationCoin.balanceOf(target),
            balance_receiver
        );
        switchToAppAdministrator();
        applicationCoin.unpause();
    }

    // Transfers should not be possible during paused state
    function invariant_ERC20external_pausedTransferFrom() public {
        uint256 balance_sender = applicationCoin.balanceOf(USER1);
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        uint256 allowance = applicationCoin.allowance(USER1, address(this));
        if(!(balance_sender > 0 && allowance > balance_sender))return;
        uint256 transfer_amount = amount % (balance_sender + 1);

        switchToAppAdministrator();
        applicationCoin.pause();
        vm.startPrank(USER1);
        vm.expectRevert("Pausable: paused");
        bool r = applicationCoin.transferFrom(USER1, target, transfer_amount);
        assertFalse(r);
        assertEq(
            applicationCoin.balanceOf(USER1),
            balance_sender
        );
        assertEq(
            applicationCoin.balanceOf(target),
            balance_receiver
        );

        switchToAppAdministrator();
        applicationCoin.unpause();
    }

}