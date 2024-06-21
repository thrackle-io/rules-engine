// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ApplicationERC20Common.t.i.sol";

/**
 * @title ApplicationERC20MintBurnInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC20 mint/burn functionality.
 */
contract ApplicationERC20MintBurnInvariantTest is ApplicationERC20Common {
    function setUp() public {
        prepERC20AndEnvironment();
    }

    // Burn should update user balance and total supply
    function invariant_ERC20external_burn() public {
        uint256 balance_sender = applicationCoin.balanceOf(USER1);
        uint256 supply = applicationCoin.totalSupply();
        if (!(balance_sender > 0)) return;
        uint256 burn_amount = amount % (balance_sender + 1);

        vm.startPrank(USER1, USER1);
        applicationCoin.burn(burn_amount);
        assertEq(applicationCoin.balanceOf(USER1), balance_sender - burn_amount);
        assertEq(applicationCoin.totalSupply(), supply - burn_amount);
    }

    // Burn should update user balance and total supply when burnFrom is called twice
    function invariant_ERC20external_burnFrom() public {
        uint256 balance_sender = applicationCoin.balanceOf(USER1);
        uint256 allowance = applicationCoin.allowance(USER1, USER2);
        if (!(balance_sender > 0 && allowance > balance_sender)) return;
        uint256 supply = applicationCoin.totalSupply();
        uint256 burn_amount = amount % (balance_sender + 1);
        vm.startPrank(USER2);
        applicationCoin.burnFrom(USER1, burn_amount);
        assertEq(applicationCoin.balanceOf(USER1), balance_sender - burn_amount);
        assertEq(applicationCoin.totalSupply(), supply - burn_amount);
    }

    // burnFrom should update allowance
    function invariant_ERC20external_burnFromUpdateAllowance() public {
        uint256 balance_sender = applicationCoin.balanceOf(USER1);
        uint256 current_allowance = applicationCoin.allowance(USER1, address(this));
        if (!(balance_sender > 0 && current_allowance > balance_sender)) return;
        uint256 burn_amount = amount % (balance_sender + 1);

        applicationCoin.burnFrom(USER1, burn_amount);

        // Some implementations take an allowance of 2**256-1 as infinite, and therefore don't update
        if (current_allowance != type(uint256).max) {
            assertEq(applicationCoin.allowance(USER1, address(this)), current_allowance - burn_amount);
        }
    }
}
