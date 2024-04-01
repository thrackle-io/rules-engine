// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ApplicationERC20Common.t.i.sol";

/**
 * @title ApplicationERC20BasicInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC20 general functionality.
 */
contract ApplicationERC20BasicInvariantTest is ApplicationERC20Common {
    function setUp() public {
        prepERC20AndEnvironment();
    }

    // User balance must not exceed total supply
    function invariant_ERC20external_userBalanceNotHigherThanSupply() public view {
        assertLe(applicationCoin.balanceOf(msg.sender), applicationCoin.totalSupply(), "User balance higher than total supply");
    }

    // Sum of users balance must not exceed total supply
    function invariant_ERC20external_userBalancesLessThanTotalSupply() public view {
        uint256 sumBalances = applicationCoin.balanceOf(address(this)) + applicationCoin.balanceOf(USER1) + applicationCoin.balanceOf(USER2) + applicationCoin.balanceOf(USER3);
        assertLe(sumBalances, applicationCoin.totalSupply(), "Sum of user balances are greater than total supply");
    }

    // Address zero should have zero balance
    function invariant_ERC20external_zeroAddressBalance() public view {
        assertEq(applicationCoin.balanceOf(address(0)), 0, "Address zero balance not equal to zero");
    }

    // Transfers to zero address should not be allowed
    function invariant_ERC20external_transferToZeroAddress() public {
        (, msgSender, ) = vm.readCallers();
        uint256 balance = applicationCoin.balanceOf(address(this));
        if (balance > 0) {
            vm.expectRevert("ERC20: transfer to the zero address");
            applicationCoin.transfer(address(0), balance);
        }
        assertEq(balance, applicationCoin.balanceOf((msgSender)));
    }

    // Transfers to zero address should not be allowed
    function invariant_ERC20external_transferFromToZeroAddress() public {
        if (applicationCoin.paused()) return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 allowance = applicationCoin.allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > 0)) return;
        uint256 maxValue = balance_sender >= allowance ? allowance : balance_sender;

        bool r = applicationCoin.transferFrom(msg.sender, address(0), value % (maxValue + 1));
        assertFalse(r);
    }

    // Self transfers should not break accounting
    function invariant_ERC20external_selfTransferFrom() public {
        if (applicationCoin.paused()) return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 allowance = applicationCoin.allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > 0)) return;
        uint256 maxValue = balance_sender >= allowance ? allowance : balance_sender;

        bool r = applicationCoin.transferFrom(msg.sender, msg.sender, value % (maxValue + 1));
        assertFalse(r);
        assertEq(balance_sender, applicationCoin.balanceOf(msg.sender));
    }

    // Self transfers should not break accounting
    function invariant_ERC20external_selfTransfer() public {
        if (applicationCoin.paused()) return;
        uint256 balance_sender = applicationCoin.balanceOf(address(this));
        if (!(balance_sender > 0)) return;

        bool r = applicationCoin.transfer(address(this), value % (balance_sender + 1));
        assertTrue(r);
        assertEq(balance_sender, applicationCoin.balanceOf(address(this)));
    }

    // Transfers for more than available balance should not be allowed
    function invariant_ERC20external_transferFromMoreThanBalance() public {
        if (applicationCoin.paused()) return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        uint256 allowance = applicationCoin.allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > balance_sender)) return;

        bool r = applicationCoin.transferFrom(msg.sender, target, balance_sender + 1);
        assertFalse(r);
        assertEq(applicationCoin.balanceOf(msg.sender), balance_sender);
        assertEq(applicationCoin.balanceOf(target), balance_receiver);
    }

    // Transfers for more than available balance should not be allowed
    function invariant_ERC20external_transferMoreThanBalance() public {
        if (applicationCoin.paused()) return;
        uint256 balance_sender = applicationCoin.balanceOf(address(this));
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        if (!(balance_sender > 0)) return;

        bool r = applicationCoin.transfer(target, balance_sender + 1);
        assertFalse(r);
        assertEq(applicationCoin.balanceOf(address(this)), balance_sender);
        assertEq(applicationCoin.balanceOf(target), balance_receiver);
    }

    // Zero amount transfers should not break accounting
    function invariant_ERC20external_transferZeroAmount() public {
        if (applicationCoin.paused()) return;
        uint256 balance_sender = applicationCoin.balanceOf(address(this));
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        if (!(balance_sender > 0)) return;

        bool r = applicationCoin.transfer(target, 0);
        assertTrue(r);
        assertEq(applicationCoin.balanceOf(address(this)), balance_sender);
        assertEq(applicationCoin.balanceOf(target), balance_receiver);
    }

    // Zero amount transfers should not break accounting
    function invariant_ERC20external_transferFromZeroAmount() public {
        if (applicationCoin.paused()) return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        uint256 allowance = applicationCoin.allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > 0)) return;

        bool r = applicationCoin.transferFrom(msg.sender, target, 0);
        assertTrue(r);
        assertEq(applicationCoin.balanceOf(msg.sender), balance_sender);
        assertEq(applicationCoin.balanceOf(target), balance_receiver);
    }

    // Transfers should update accounting correctly
    function invariant_ERC20external_transfer() public {
        if (applicationCoin.paused()) return;
        if (!(target != address(this))) return;
        uint256 balance_sender = applicationCoin.balanceOf(address(this));
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        if (!(balance_sender > 2)) return;
        uint256 transfer_value = (amount % balance_sender) + 1;

        bool r = applicationCoin.transfer(target, transfer_value);
        assertTrue(r);
        assertEq(applicationCoin.balanceOf(address(this)), balance_sender - transfer_value);
        assertEq(applicationCoin.balanceOf(target), balance_receiver + transfer_value);
    }

    // Transfers should update accounting correctly
    function invariant_ERC20external_transferFrom() public {
        if (!(target != address(this))) return;
        if (!(target != msg.sender)) return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        uint256 allowance = applicationCoin.allowance(msg.sender, address(this));
        if (!(balance_sender > 2 && allowance > balance_sender)) return;
        uint256 transfer_value = (amount % balance_sender) + 1;

        bool r = applicationCoin.transferFrom(msg.sender, target, transfer_value);
        assertTrue(r);
        assertEq(applicationCoin.balanceOf(msg.sender), balance_sender - transfer_value);
        assertEq(applicationCoin.balanceOf(target), balance_receiver + transfer_value);
    }

    // Approve should set correct allowances
    function invariant_ERC20external_setAllowance() public {
        if (applicationCoin.paused()) return;
        bool r = applicationCoin.approve(target, amount);
        assertTrue(r);
        assertEq(applicationCoin.allowance(address(this), target), amount);
    }

    // Approve should set correct allowances
    function invariant_ERC20external_setAllowanceTwice() public {
        if (applicationCoin.paused()) return;
        bool r = applicationCoin.approve(target, amount);
        assertTrue(r);
        assertEq(applicationCoin.allowance(address(this), target), amount);

        r = applicationCoin.approve(target, amount / 2);
        assertTrue(r);
        assertEq(applicationCoin.allowance(address(this), target), amount / 2);
    }

    // TransferFrom should decrease allowance
    function invariant_ERC20external_spendAllowanceAfterTransfer() public {
        if (applicationCoin.paused()) return;
        if (!(target != address(this) && target != address(0))) return;
        if (!(target != msg.sender)) return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 current_allowance = applicationCoin.allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && current_allowance > balance_sender)) return;
        uint256 transfer_value = (amount % balance_sender) + 1;

        bool r = applicationCoin.transferFrom(msg.sender, target, transfer_value);
        assertTrue(r);

        // Some implementations take an allowance of 2**256-1 as infinite, and therefore don't update
        if (current_allowance != type(uint256).max) {
            assertEq(applicationCoin.allowance(msg.sender, address(this)), current_allowance - transfer_value);
        }
    }
}
