// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "src/client/token/handler/common/HandlerUtils.sol";

/**
 * @title Application Token Handler Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests the ApplicationERC20 Handler. This handler is deployed specifically for its implementation
 *      contains all the rule checks for the particular ERC20.
 * @notice It simulates the input from a token contract
 */
contract ApplicationERC20HandlerTest is Test, HandlerUtils {
   
    function testERC20_ApplicationERC20Actions_DetermineTransferAction() public {
        address from;
        address to;
        address sender;
        address user1 = address(1);
        address user2 = address(2);

        // mint
        sender = user1;
        to = user1;
        from = address(0);
        assertEq(uint8(ActionTypes.MINT), uint8(determineTransferAction(from, to, sender)));

        // burn
        sender = user1;
        to = address(0);
        from = user1;
        assertEq(uint8(ActionTypes.BURN), uint8(determineTransferAction(from, to, sender)));

        // p2p transfer
        sender = user2;
        to = user1;
        from = user2;
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction(from, to, sender)));

        // purchase
        sender = address(this);
        to = user1;
        from = address(this);
        assertEq(uint8(ActionTypes.BUY), uint8(determineTransferAction(from, to, sender)));

        // sale
        sender = user2;
        to = user1;
        from = user1;
        assertEq(uint8(ActionTypes.SELL), uint8(determineTransferAction(from, to, sender)));
    }
}
