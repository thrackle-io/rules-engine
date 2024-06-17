// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/client/token/TokenUtils.sol";
import "test/client/token/ERC721/util/NftMarketplace.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";
import "test/util/TestArrays.sol";
import "forge-std/Test.sol";


import {ActionTypes} from "src/common/ActionEnum.sol";
import "src/common/IErrors.sol";

/**
 * @title MarketplaceTests
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is to test rule functionality with the operator style marketplace.
 */
contract MarketplaceTests is TokenUtils, ERC721Util {
    NftMarketplace public marketplace;
    uint constant buyPrice = 100_000_000_000;
    uint constant NFT_ID_1 = 0;
    uint constant NFT_ID_2 = 1;


    function setUp() public {
        marketplace = new NftMarketplace();
        setUpProcotolAndCreateERC721MinLegacyAndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(user1, buyPrice);
        applicationNFTv2.safeMint(user2);
        vm.stopPrank();

        vm.startPrank(user1);
        applicationCoin.approve(address(marketplace), buyPrice);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTv2.approve(address(marketplace), NFT_ID_1);
        marketplace.listItem(address(applicationNFTv2), NFT_ID_1, address(applicationCoin), buyPrice);
        vm.stopPrank();
    }

    function test_accountDenyForNoAccessLevel_inOperatorMarketplace() public endWithStopPrank() {
        // create rule for buy only
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.BUY;
        actionTypes[1] = ActionTypes.NONE;
        createAccountDenyForNoAccessLevelRuleFull(actionTypes);
        
        uint snapshot = vm.snapshot();
        vm.prank(user1);
        console.log("Part 1");
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IAccessLevelErrors.NotAllowedForAccessLevel.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        vm.revertTo(snapshot);

        // create rule for sell only
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        actionTypes[0] = ActionTypes.SELL;
        createAccountDenyForNoAccessLevelRuleFull(actionTypes);

        console.log("Part 2");
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IAccessLevelErrors.NotAllowedForAccessLevel.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        vm.revertTo(snapshot);
        // create rule for buy and sell
        actionTypes[1] = ActionTypes.BUY;
        createAccountDenyForNoAccessLevelRuleFull(actionTypes);

        console.log("Part 3");
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IAccessLevelErrors.NotAllowedForAccessLevel.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        // give them access level
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.stopPrank();
        console.log("Part 4");
        vm.prank(user1);
        vm.expectEmit(address(marketplace));
        emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), 0, buyPrice);
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
    }

    function test_accountMaxTxValueByRiskScore_inOperatorMarketplace() public endWithStopPrank() {
        uint8[] memory riskScores = new uint8[](2);
        riskScores[0] = 25;
        riskScores[1] = 50;
        uint48[] memory txLimits = new uint48[](2);
        txLimits[0] = uint48(buyPrice);
        txLimits[1] = uint48(99);
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, txLimits);

        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 10 * (10 ** 26)); //setting at $1
        erc721Pricer.setNFTCollectionPrice(address(applicationNFTv2), buyPrice * (10 ** 26)); //setting at $1,000,000,000
        vm.stopPrank();

        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[1]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        vm.stopPrank();
        
        uint snapshot = vm.snapshot();

        // test that buy fails
        setAccountMaxTxValueByRiskRuleSingleAction(ActionTypes.BUY, ruleId);

        vm.startPrank(user1, user1);
        console.log("Part 1");
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IRiskErrors.OverMaxTxValueByRiskScore.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        vm.stopPrank();

        vm.revertTo(snapshot);
        // // test that sell fails
        setAccountMaxTxValueByRiskRuleSingleAction(ActionTypes.SELL, ruleId);
        console.log(applicationHandler.isAccountMaxTxValueByRiskScoreActive(ActionTypes.SELL));
        vm.startPrank(user1, user1);
        console.log("Part 2");
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IRiskErrors.OverMaxTxValueByRiskScore.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        vm.stopPrank();

        vm.revertTo(snapshot);

        // test that rules on and activated but within proper risk score this works
        console.log("Part 3");

        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 10 * (10 ** 18)); //setting at $1
        erc721Pricer.setNFTCollectionPrice(address(applicationNFTv2), buyPrice * (10 ** 18)); //setting at $1,000,000,000
        vm.stopPrank();

        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.SELL;
        actionTypes[1] = ActionTypes.BUY;
        uint32[] memory ruleIds = new uint32[](2);
        ruleIds[0] = ruleId;
        ruleIds[1] = ruleId;
        setAccountMaxTxValueByRiskRuleFull(actionTypes, ruleIds);

        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[0]);
        vm.stopPrank();

        vm.prank(user1);
        vm.expectEmit(address(marketplace));
        emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice);
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

    }

    function test_accountMaxTradeSize_inOperatorMarketplace() public endWithStopPrank() {
        bytes32 justBuyTag = "JUSTBUY";
        bytes32 justSellTag = "JUSTSELL";
        bytes32 buyAndSellTag = "BUYANDSELL";
        uint240 maxTradeSizeERC20 = uint240(buyPrice);
        uint240 maxTradeSizeERC721 = uint240(1);
        uint16 period = 1;
        
        ActionTypes[] memory justBuy = createActionTypeArray(ActionTypes.BUY);
        ActionTypes[] memory justSell = createActionTypeArray(ActionTypes.SELL);
        ActionTypes[] memory buyAndSell = createActionTypeArray(ActionTypes.BUY, ActionTypes.SELL);

        uint32 justBuyRuleIdERC20 = createAccountMaxTradeSizeRule(justBuyTag, maxTradeSizeERC20, period);
        uint32 justBuyRuleIdERC721 = createAccountMaxTradeSizeRule(justBuyTag, maxTradeSizeERC721, period);
        uint32 justSellRuleIdERC20 = createAccountMaxTradeSizeRule(justSellTag, maxTradeSizeERC20, period);
        uint32 justSellRuleIdERC721 = createAccountMaxTradeSizeRule(justSellTag, maxTradeSizeERC721, period);
        uint32 buyAndSellRuleIdERC20 = createAccountMaxTradeSizeRule(buyAndSellTag, maxTradeSizeERC20, period);
        uint32 buyAndSellRuleIdERC721 = createAccountMaxTradeSizeRule(buyAndSellTag, maxTradeSizeERC721, period);

        uint snapshotId = vm.snapshot();
        // setAccountMaxTradeSizeRule(address(applicationCoinHandler), justBuy, justBuyRuleIdERC20);
        // setAccountMaxTradeSizeRule(address(applicationNFTHandler), justBuy, ruleId);

        // test that just buy fails on ERC20

        // test that just buy fails on ERC721

        // test that just sell fails on ERC20

        // test that just sell fails on ERC721

        // test that buy and sell fails on ERC20

        // test that buy and sell fails on ERC721
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                ITagRuleErrors.OverMaxSize.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), 0);

    }

    function test_accountMinMaxTokenBalance_inOperatorMarketplace() public endWithStopPrank() {
        bytes32[] memory accsERC20 = createBytes32Array("ERC20_SOLIDMIN_SOLIDMAX", "ERC20_SOLIDMIN_NOMAX");
        bytes32[] memory accsERC721 = createBytes32Array("ERC721_NOMIN_SOLIDMAX", "ERC721_SOLIDMIN_SOLIDMAX");
        uint256[] memory minAmountsERC20 = createUint256Array(buyPrice, 250_000);
        uint256[] memory minAmountsERC721 = createUint256Array(0, 1);
        uint256[] memory maxAmountsERC20 = createUint256Array(buyPrice * 10, type(uint256).max);
        uint256[] memory maxAmountsERC721 = createUint256Array(1, 3);

        switchToRuleAdmin();
        uint32 ruleIdERC20 = createAccountMinMaxTokenBalanceRule(accsERC20, minAmountsERC20, maxAmountsERC20);
        uint32 ruleIdERC721 = createAccountMinMaxTokenBalanceRule(accsERC721, minAmountsERC721, maxAmountsERC721);

        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleIdERC20);
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandlerv2), ruleIdERC721);
        vm.warp(Blocktime + 15);

        uint snapshotId = vm.snapshot();

        console.log("Part 1: Apply Min to ERC20");
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "ERC20_SOLIDMIN_SOLIDMAX");
        applicationAppManager.addTag(user2, "NOMIN_NOMAX");
        vm.stopPrank();

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                ITagRuleErrors.UnderMinBalance.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        vm.revertTo(snapshotId);

        console.log("Part 2: Apply Max to ERC20");
        switchToAppAdministrator();
        applicationCoin.mint(user1, buyPrice * 10 + 1);
        applicationAppManager.addTag(user1, "ERC20_SOLIDMIN_NOMAX");
        applicationAppManager.addTag(user2, "ERC20_SOLIDMIN_SOLIDMAX");
        vm.stopPrank();

        vm.startPrank(user2);
        marketplace.updateListing(address(applicationNFTv2), 0, buyPrice * 10 + 1);
        vm.stopPrank();
        
        vm.startPrank(user1);
        applicationCoin.approve(address(marketplace), buyPrice * 10 + 1);

        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                ITagRuleErrors.OverMaxBalance.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        vm.stopPrank();

        vm.revertTo(snapshotId);

        console.log("Part 3: Apply min/max to ERC721");

        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "ERC721_NOMIN_SOLIDMAX");
        applicationAppManager.addTag(user2, "ERC721_SOLIDMIN_SOLIDMAX");
        applicationNFTv2.safeMint(user2);
        vm.stopPrank();

        vm.startPrank(user2);
        applicationNFTv2.approve(address(marketplace), 1);
        marketplace.updateListing(address(applicationNFTv2), 0, buyPrice / 2);
        marketplace.listItem(address(applicationNFTv2), 1, address(applicationCoin), buyPrice / 2);
        vm.stopPrank();

        uint snapshotId2 = vm.snapshot();
        // expect the first buy to go through, fail on the second due to max balance
        vm.startPrank(user1);
        vm.expectEmit(address(marketplace));
        emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);  
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                ITagRuleErrors.OverMaxBalance.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_2);
        vm.stopPrank();

        console.log("Part 4: Max of ERC721 testing");
        vm.revertTo(snapshotId2);
        // now test that the min is being followed
        switchToAppAdministrator();
        applicationAppManager.removeTag(user1, "ERC721_NOMIN_SOLIDMAX");
        applicationAppManager.addTag(user2, "ERC721_SOLIDMIN_SOLIDMAX");
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectEmit(address(marketplace));
        emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                ITagRuleErrors.UnderMinBalance.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_2);
        vm.stopPrank();

        vm.revertTo(snapshotId);

        console.log("Part 5"); // test that it's still allowed to go through happy path

        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "ERC721_NOMIN_SOLIDMAX");
        applicationAppManager.addTag(user2, "ERC20_SOLIDMIN_SOLIDMAX");
        vm.stopPrank();

        vm.prank(user2);
        marketplace.updateListing(address(applicationNFTv2), NFT_ID_1, buyPrice / 2);

        vm.prank(user1);
        vm.expectEmit(address(marketplace));
        emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
    }

    function test_MaxBuySellVolume_inOperatorMarketplace() public endWithStopPrank() {
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.SELL;
        actionTypes[1] = ActionTypes.BUY;
        uint16 tokenPercentage = 10;
        uint16 period = 2;
        uint256 totalSupply = applicationCoin.totalSupply();
        uint64 startTime = uint64(block.timestamp); 
        
        switchToRuleAdmin();
        uint32 ruleId = createTokenMaxBuySellVolumeRule(tokenPercentage, period, totalSupply, startTime);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actionTypes, ruleId);
        setTokenMaxBuySellVolumeRule(address(applicationNFTHandler), actionTypes, ruleId);


        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                ITagRuleErrors.UnderMinBalance.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

    }

}