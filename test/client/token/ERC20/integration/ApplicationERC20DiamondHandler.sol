// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

/**
 * @title Application Coin Handler Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests the ApplicationERC20 Handler. This handler is deployed specifically for its implementation
 *      contains all the rule checks for the particular ERC20.
 * @notice It simulates the input from a token contract
 */
contract ApplicationERC20HandlerTest is TestCommonFoundry {


    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(superAdmin);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * ATTO);
        vm.warp(Blocktime);
        switchToAppAdministrator();

    }

    function testERC20_handlerDiamond() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(rich_user, 100000);
        assertEq(applicationCoin.balanceOf(rich_user), 100000);
        applicationCoin.transfer(user1, 1000);
        assertEq(applicationCoin.balanceOf(user1), 1000);

        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(10);
        uint256[] memory max = createUint256Array(1000);
        uint16[] memory empty;
        // add the actual rule
        switchToRuleAdmin();
        console.log("address(ruleProcessor)",address(ruleProcessor));
        console.log("address(handlerDiamond)",address(handlerDiamond));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        //update ruleId in coin rule handler
        //create the default actions array
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.SELL;
        TaggedRuleFacet(address(handlerDiamond)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToAppAdministrator();
    }

}