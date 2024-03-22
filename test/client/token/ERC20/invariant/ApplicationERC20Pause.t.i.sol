// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "src/client/application/data/IDataModule.sol";

/**
 * @title ApplicationERC20PauseInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC20 pause functionality.
 */
contract ApplicationERC20PauseInvariantTest is TestCommonFoundry {
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

// Transfers should not be possible during paused state
    function invariant_ERC20external_pausedTransfer() public {
        (, msgSender, ) = vm.readCallers();
        uint256 balance_sender = applicationCoin.balanceOf(address(this));
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        if(!(balance_sender > 0))return;
        uint256 transfer_amount = amount % (balance_sender + 1);

        switchToAppAdministrator();
        applicationCoin.pause();
        vm.startPrank(msgSender);
        bool r = applicationCoin.transfer(target, transfer_amount);
        assertFalse(r);
        assertEq(
            applicationCoin.balanceOf(address(this)),
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
        uint256 balance_sender = applicationCoin.balanceOf(msg.sender);
        uint256 balance_receiver = applicationCoin.balanceOf(target);
        uint256 allowance = applicationCoin.allowance(msg.sender, address(this));
        if(!(balance_sender > 0 && allowance > balance_sender))return;
        uint256 transfer_amount = amount % (balance_sender + 1);

        switchToAppAdministrator();
        applicationCoin.pause();
        vm.startPrank(msgSender);

        bool r = applicationCoin.transferFrom(msg.sender, target, transfer_amount);
        assertFalse(r);
        assertEq(
            applicationCoin.balanceOf(msg.sender),
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