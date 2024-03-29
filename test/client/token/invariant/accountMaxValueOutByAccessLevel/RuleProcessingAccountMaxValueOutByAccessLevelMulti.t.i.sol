// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/invariant/util/RuleProcessingInvariantCommon.sol";
import {RuleProcessingAccountMaxValueOutByAccessLevelActor} from "./RuleProcessingAccountMaxValueOutByAccessLevelActor.sol";
import "./RuleProcessingAccountMaxValueOutByAccessLevelActorManager.sol";

/**
 * @title RuleProcessingAccountMaxValueOutByAccessLevelMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple managers with multiple actors. Each manager has its
 * own application and set of tokens which will be tested through their own set of actors. The same single rule is shared by all
 * the applications and tokens in this invariant test.
 */
contract RuleProcessingAccountMaxValueOutByAccessLevelMultiTest is RuleProcessingInvariantCommon {
    RuleProcessingAccountMaxValueOutByAccessLevelActorManager[] actorManagers;
    RuleProcessingAccountMaxValueOutByAccessLevelActor[][] actors;
    HandlerDiamond[] appHandlers;
    uint8 constant AMOUNT_ACTORS = 10;
    uint8 constant AMOUNT_MANAGERS = 4;

    function setUp() public {
        (DummySingleTokenAMM amm, ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) = prepareTradingRuleProcessingInvariant();
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueOutByAccessLevel(address(applicationAppManager), accountMaxValueOutByAccessLevel);
        for (uint j; j < AMOUNT_MANAGERS; j++) {
            switchToAppAdministrator();
            (ApplicationERC20 testCoin, HandlerDiamond testCoinHandler) = deployAndSetupERC20(string.concat("coin", vm.toString(j)), string.concat("C", vm.toString(j)));
            switchToAppAdministrator();
            erc20Pricer.setSingleTokenPrice(address(testCoin), 1 * ATTO); //setting at $1
            RuleProcessingAccountMaxValueOutByAccessLevelActor[] memory tempActors = new RuleProcessingAccountMaxValueOutByAccessLevelActor[](AMOUNT_ACTORS);
            // Load actors
            for (uint i; i < AMOUNT_ACTORS; i++) {
                RuleProcessingAccountMaxValueOutByAccessLevelActor actor = new RuleProcessingAccountMaxValueOutByAccessLevelActor(ruleProcessor);
                tempActors[i] = actor;
                switchToAppAdministrator();
                testCoin.mint(address(actor), 2_000 * ATTO);
                vm.startPrank(address(actor));
                testCoin.approve(address(amm), 2_000 * ATTO);
                switchToAccessLevelAdmin();
                applicationAppManager.addAccessLevel(address(actor), uint8(i / 2));
            }
            actors.push(tempActors);
            RuleProcessingAccountMaxValueOutByAccessLevelActorManager actorManager = new RuleProcessingAccountMaxValueOutByAccessLevelActorManager(tempActors, address(testCoin), address(amm));
            targetContract(address(actorManager));
            actorManagers.push(actorManager);
            testCoinHandler;
        }
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueOutByAccessLevelId(createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL), index);
    }

    /**
     * the cumulative USD value in all application assets taken out from the application economy can never exceed the maximum of the AccountMaxValueOutByAccessLevel
     * applied for the application and the access level of the account.
     */
    function invariant_amountOutCanNeverExceedMaximumOfAccessLevel() public view {
        for (uint j; j < actors.length; j++) {
            for (uint i; i < actors[j].length; i++) {
                uint256 totalOutInPeriodWeis = actors[j][i].totalOutInPeriod();
                console.log(totalOutInPeriodWeis);
                if (i / 2 < 1) assertLe(totalOutInPeriodWeis / (ATTO), accountMaxValueOutByAccessLevel[0]);
                else if (i / 2 < 2) assertLe(totalOutInPeriodWeis / (ATTO), accountMaxValueOutByAccessLevel[1]);
                else if (i / 2 < 3) assertLe(totalOutInPeriodWeis / (ATTO), accountMaxValueOutByAccessLevel[2]);
                else if (i / 2 < 4) assertLe(totalOutInPeriodWeis / (ATTO), accountMaxValueOutByAccessLevel[3]);
                else assertLe(totalOutInPeriodWeis / (ATTO), accountMaxValueOutByAccessLevel[4]);
            }
        }
    }
}
