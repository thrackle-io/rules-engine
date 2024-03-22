// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "src/client/application/data/IDataModule.sol";

/**
 * @title ApplicationERC20MintBurnInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC20 mint/burn functionality.
 */
contract ApplicationERC20MintBurnInvariantTest is TestCommonFoundry {
    address msgSender;
    uint256 value;
    uint256 amount;
    address target;
    address USER1;
    address USER2;
    address USER3;
    
    function setUp() public {
        setUpProtocolAndAppManagerAndTokensWithERC721HandlerDiamond();
        switchToAppAdministrator();
        address[] memory addressList = getUniqueAddresses(block.timestamp % ADDRESSES.length, 4);
        amount = block.timestamp;
        USER1 = addressList[0];
        USER2 = addressList[1];
        USER3 = addressList[2];
        target = addressList[3];

        applicationCoin.mint(USER1, 10 * ATTO);
        applicationCoin.mint(USER2, 10 * ATTO);
        applicationCoin.mint(USER3, 10 * ATTO);
        vm.stopPrank();
        targetSender(USER1);
        targetSender(USER2);
        targetSender(USER3);
        targetSender(appAdministrator);
        targetSender(target);
        targetContract(address(applicationCoin));
    }

    // Burn should update user balance and total supply
    function invariant_ERC20external_burn() public {
        if (applicationCoin.paused())return;
        uint256 balance_sender = applicationCoin.balanceOf(address(this));
        uint256 supply = applicationCoin.totalSupply();
        if(!(balance_sender > 0))return;
        uint256 burn_amount = amount % (balance_sender + 1);

        applicationCoin.burn(burn_amount);
        assertEq(
            applicationCoin.balanceOf(address(this)),
            balance_sender - burn_amount
        );
        assertEq(
            applicationCoin.totalSupply(),
            supply - burn_amount
        );
    }

    // Burn should update user balance and total supply
    function invariant_ERC20external_burnFrom() public {
        if (applicationCoin.paused())return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 allowance = applicationCoin.allowance(msg.sender, address(this));
        if(!(balance_sender > 0 && allowance > balance_sender))return;
        uint256 supply = applicationCoin.totalSupply();
        uint256 burn_amount = amount % (balance_sender + 1);

        applicationCoin.burnFrom(msg.sender, burn_amount);
        assertEq(
            applicationCoin.balanceOf(msg.sender),
            balance_sender - burn_amount
        );
        assertEq(
            applicationCoin.totalSupply(),
            supply - burn_amount
        );
    }

    // burnFrom should update allowance
    function invariant_ERC20external_burnFromUpdateAllowance() public {
        if (applicationCoin.paused())return;
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 current_allowance = applicationCoin.allowance(msg.sender, address(this));
        if(!(balance_sender > 0 && current_allowance > balance_sender))return;
        uint256 burn_amount = amount % (balance_sender + 1);

        applicationCoin.burnFrom(msg.sender, burn_amount);

        // Some implementations take an allowance of 2**256-1 as infinite, and therefore don't update
        if (current_allowance != type(uint256).max) {
            assertEq(
                applicationCoin.allowance(msg.sender, address(this)),
                current_allowance - burn_amount
            );
        }
    }

}