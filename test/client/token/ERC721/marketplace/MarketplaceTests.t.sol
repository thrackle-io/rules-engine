// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/client/token/TokenUtils.sol";
import "test/client/token/ERC721/util/NftMarketplace.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";
import "test/util/TestArrays.sol";
import "forge-std/Test.sol";


import {ActionTypes} from "src/common/ActionEnum.sol";
import "src/common/IErrors.sol";

/**
 * @title MarketplaceTests
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is to test rule functionality with the operator style marketplace.
 */
contract MarketplaceTestsErc20SellsNftBuys is TokenUtils, ERC721Util {
    NftMarketplace public marketplace;
    uint constant buyPrice = 100_000_000_000;
    uint constant NFT_ID_1 = 0;
    uint constant NFT_ID_2 = 1;

    // made as an attempt to get around a stack too deep error in the testing
    struct MaxTradeSizeTest {
        bytes32 tag;
        uint240 maxTradeSize;
        uint16 period;
        uint32 ruleId;
        ActionTypes[] actionTypes;
        address handler;
        bytes expectedError;
    }

    function setUp() public {
        marketplace = new NftMarketplace();
        setUpProcotolAndCreateERC721MinLegacyAndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(user1, buyPrice + 1);
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
        vm.startPrank(user1, user1);
        console.log("Part 1");
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
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
        vm.startPrank(user1, user1);
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
        vm.startPrank(user1, user1);
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
        applicationAppManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        console.log("Part 4");
        vm.startPrank(user1, user1);
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

    function getRuleForMaxTradeSize(uint8 i) internal returns (MaxTradeSizeTest memory) {
        bytes32 justBuyTag = "JUSTBUY";
        bytes32 justSellTag = "JUSTSELL";
        bytes32 buyAndSellTag = "BUYANDSELL";
        uint240 maxTradeSizeERC20 = uint240(buyPrice - 1);
        uint240 maxTradeSizeERC721 = uint240(1);
        uint16 period = 2;
        ActionTypes[] memory justBuy = createActionTypeArray(ActionTypes.BUY);
        ActionTypes[] memory justSell = createActionTypeArray(ActionTypes.SELL);
        ActionTypes[] memory buyAndSell = createActionTypeArray(ActionTypes.BUY, ActionTypes.SELL);


        if (i == 0) {
            uint32 justSellRuleIdERC20 = createAccountMaxTradeSizeRule(justSellTag, maxTradeSizeERC20, period);
            return MaxTradeSizeTest({
                tag: justSellTag,
                maxTradeSize: maxTradeSizeERC20,
                period: period,
                ruleId: justSellRuleIdERC20,
                actionTypes: justSell,
                handler: address(applicationCoinHandler),
                expectedError: abi.encodeWithSelector(
                    TransferFailed.selector, 
                    address(applicationCoin), 
                    ITagRuleErrors.OverMaxSize.selector
                )
            });

        } else if (i == 1) {
            uint32 justBuyRuleIdERC20 = createAccountMaxTradeSizeRule(justBuyTag, maxTradeSizeERC20, period);
            return MaxTradeSizeTest({
                tag: justBuyTag,
                maxTradeSize: maxTradeSizeERC20,
                period: period,
                ruleId: justBuyRuleIdERC20,
                actionTypes: justBuy,
                handler: address(applicationCoinHandler),
                expectedError: bytes("")
            });
        } else if (i == 2) {
            uint32 justBuyRuleIdERC721 = createAccountMaxTradeSizeRule(justBuyTag, maxTradeSizeERC721, period);
            return MaxTradeSizeTest({
                tag: justBuyTag,
                maxTradeSize: maxTradeSizeERC721,
                period: period,
                ruleId: justBuyRuleIdERC721,
                actionTypes: justBuy,
                handler: address(applicationNFTHandlerv2),
                expectedError: abi.encodeWithSelector(
                    TransferFailed.selector, 
                    address(applicationNFTv2), 
                    ITagRuleErrors.OverMaxSize.selector
                )
            });
        } else if (i == 3) {
            uint32 justSellRuleIdERC721 = createAccountMaxTradeSizeRule(justSellTag, maxTradeSizeERC721, period);
            return MaxTradeSizeTest({
                tag: justSellTag,
                maxTradeSize: maxTradeSizeERC721,
                period: period,
                ruleId: justSellRuleIdERC721,
                actionTypes: justSell,
                handler: address(applicationNFTHandlerv2),
                expectedError: bytes("")
            });
        } else if (i == 4) {
            uint32 buyAndSellRuleIdERC20 = createAccountMaxTradeSizeRule(buyAndSellTag, maxTradeSizeERC20, period);
            return MaxTradeSizeTest({
                tag: buyAndSellTag,
                maxTradeSize: maxTradeSizeERC20,
                period: period,
                ruleId: buyAndSellRuleIdERC20,
                actionTypes: buyAndSell,
                handler: address(applicationCoinHandler),
                expectedError: abi.encodeWithSelector(
                    TransferFailed.selector, 
                    address(applicationCoin), 
                    ITagRuleErrors.OverMaxSize.selector
                )
            });
        } else if (i == 5) {
            uint32 buyAndSellRuleIdERC721 = createAccountMaxTradeSizeRule(buyAndSellTag, maxTradeSizeERC721, period);
            return MaxTradeSizeTest({
                tag: buyAndSellTag,
                maxTradeSize: maxTradeSizeERC721,
                period: period,
                ruleId: buyAndSellRuleIdERC721,
                actionTypes: buyAndSell,
                handler: address(applicationNFTHandlerv2),
                expectedError: abi.encodeWithSelector(
                    TransferFailed.selector, 
                    address(applicationNFTv2), 
                    ITagRuleErrors.OverMaxSize.selector
                )
            });
        } else {
            revert("Invalid i");
        }
        
    }

    function test_accountMaxTradeSize_inOperatorMarketplace() public endWithStopPrank() {
        vm.warp(Blocktime);
        switchToAppAdministrator();
        applicationNFTv2.safeMint(user2); // give them a 2nd NFT
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTv2.approve(address(marketplace), NFT_ID_2);
        marketplace.listItem(address(applicationNFTv2), NFT_ID_2, address(applicationCoin), 1);
        vm.stopPrank();
        uint snapshotId = vm.snapshot();

        for (uint8 i = 0; i < 6; i++) {
            console.log("i: ", i);
            MaxTradeSizeTest memory test = getRuleForMaxTradeSize(i);
            setAccountMaxTradeSizeRule(test.handler, test.actionTypes, test.ruleId);
            switchToAppAdministrator();
            applicationAppManager.addTag(user1, test.tag);
            applicationAppManager.addTag(user2, test.tag);
            vm.stopPrank();

            vm.startPrank(user1, user1);
            //marketplace.buyItem(address(applicationNFTv2), NFT_ID_2); // need to buy atleast 1 first to trigger the bad outcome
            if (test.expectedError.length > 0) {
                vm.expectRevert(
                    test.expectedError
                );
            }
            marketplace.buyItem(address(applicationNFTv2), 0);
            vm.revertTo(snapshotId);
        }
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
        marketplace.updateListing(address(applicationNFTv2), NFT_ID_1, buyPrice * 10 + 1);
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
        applicationNFTv2.safeMint(user2);
        applicationAppManager.addTag(user1, "ERC721_NOMIN_SOLIDMAX");
        applicationAppManager.addTag(user2, "ERC721_SOLIDMIN_SOLIDMAX");
        vm.stopPrank();

        vm.startPrank(user2);
        applicationNFTv2.approve(address(marketplace), NFT_ID_2);
        marketplace.updateListing(address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        marketplace.listItem(address(applicationNFTv2), NFT_ID_2, address(applicationCoin), buyPrice / 2);
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
        uint256 ERC20TotalSupply = applicationCoin.totalSupply();
        uint256 ERC721TotalSupply = applicationNFTv2.totalSupply();
        uint64 startTime = uint64(block.timestamp); 
        
        uint snapshotId = vm.snapshot();

        switchToRuleAdmin();
        uint32 ruleId = createTokenMaxBuySellVolumeRule(tokenPercentage, period, ERC20TotalSupply, startTime);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actionTypes, ruleId);
        setTokenMaxBuySellVolumeRule(address(applicationNFTHandlerv2), actionTypes, ruleId);

        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.OverMaxVolume.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        vm.stopPrank();

        vm.revertTo(snapshotId);

        switchToRuleAdmin();
        ruleId = createTokenMaxBuySellVolumeRule(tokenPercentage, period, ERC721TotalSupply, startTime);
        setTokenMaxBuySellVolumeRule(address(applicationNFTHandlerv2), actionTypes, ruleId);

        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.OverMaxVolume.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        vm.stopPrank();

        vm.revertTo(snapshotId);

        switchToRuleAdmin();
        ruleId = createTokenMaxBuySellVolumeRule(tokenPercentage, period, ERC20TotalSupply, startTime);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actionTypes, ruleId);

        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.OverMaxVolume.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        vm.stopPrank();

    }

    function test_inOperatorMarketplace_AccountApproveDenyOracleRules_ApproveAndDenyOracle() public endWithStopPrank() {
        // create oracle rule and set users to approve list 
        switchToRuleAdmin();
        // ERC20 Approve Oracle 
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        // ERC721 Approve Oracle 
        uint32 newRuleId = createAccountApproveDenyOracleRule(0);

        uint snapshot = vm.snapshot();

        // test 1 - Test Buy side of ERC20 Transaction fails if buyer is not approved 
        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        // test 2 - Test Sell side of ERC20 Transaction fails if seller is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        oracleApproved.addToApprovedList(goodBoys);
        
        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        // test 3 - Test Buy side of ERC721 Transaction fails if buyer is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user1));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);

        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        // test 4 - Test Sell side of ERC20 Transaction fails if buyer is not approved 

        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user2));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);

        vm.stopPrank();
        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        // all passing 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);
        // Both oracle rules active 
        // users approved and no users denied 
        vm.startPrank(user1, user1);
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
    }

    function test_inOperatorMarketplace_AccountApproveDenyOracleRules_DenyAndApproveOracle() public endWithStopPrank() {
        // create oracle rule and set users to approve list 
        switchToRuleAdmin();
        // ERC20 Deny Oracle 
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        switchToAppAdministrator();
        // ERC721 Approve Oracle 
        uint32 newRuleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);

        uint snapshot = vm.snapshot();

        // test 1 - Test Buy side of ERC20 Transaction fails if buyer is not approved 
        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        // test 2 - Test Sell side of ERC20 Transaction fails if seller is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        oracleApproved.addToApprovedList(goodBoys);
        
        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        // test 3 - Test Buy side of ERC721 Transaction fails if buyer is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user1));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);

        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        // test 4 - Test Sell side of ERC20 Transaction fails if buyer is not approved 

        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user2));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);

        vm.stopPrank();
        vm.startPrank(user1, user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);

        // all passing 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);


        // Both oracle rules active 
        // users approved and no users denied 
        vm.startPrank(user1, user1);
        marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
    }

}

contract MarketplaceTestsErc20BuysNftSells is TokenUtils, ERC721Util {
    NftMarketplace public marketplace;
    uint constant buyPrice = 100_000_000_000;
    uint constant NFT_ID_1 = 0;
    uint constant NFT_ID_2 = 1;

    // made as an attempt to get around a stack too deep error in the testing
    struct MaxTradeSizeTest {
        bytes32 tag;
        uint240 maxTradeSize;
        uint16 period;
        uint32 ruleId;
        ActionTypes[] actionTypes;
        address handler;
        bytes expectedError;
    }

    function setUp() public {
        marketplace = new NftMarketplace();
        setUpProcotolAndCreateERC721MinLegacyAndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(user1, buyPrice + 10_000_000);
        applicationNFTv2.safeMint(user2);
        vm.stopPrank();

        vm.startPrank(user2);
        applicationNFTv2.approve(address(marketplace), NFT_ID_1);
        marketplace.listItem(address(applicationNFTv2), NFT_ID_1, address(applicationCoin), buyPrice);
        vm.stopPrank();

        vm.startPrank(user1);
        applicationCoin.approve(address(marketplace), buyPrice);
        marketplace.createOffer(address(applicationNFTv2), NFT_ID_1, buyPrice);
        vm.stopPrank();
        // from here all you should have to do is call sellItem with user2 and it should pass
    }

    function test_accountMaxTxValueByRiskScore_inOperatorMarketplace_Sell() public endWithStopPrank() {
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

        // test that sell fails
        setAccountMaxTxValueByRiskRuleSingleAction(ActionTypes.SELL, ruleId);

        vm.startPrank(user2, user2);
        console.log("Part 1");
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IRiskErrors.OverMaxTxValueByRiskScore.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        vm.stopPrank();

        vm.revertTo(snapshot);
        // // test that sell fails
        setAccountMaxTxValueByRiskRuleSingleAction(ActionTypes.BUY, ruleId);
        console.log(applicationHandler.isAccountMaxTxValueByRiskScoreActive(ActionTypes.BUY));
        vm.startPrank(user2, user2);
        console.log("Part 2");
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IRiskErrors.OverMaxTxValueByRiskScore.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
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

        vm.startPrank(user2, user2);
        vm.expectEmit(address(marketplace));
        emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice);
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);

    }

    function test_MaxBuySellVolume_inOperatorMarketplace_Sell() public endWithStopPrank() {
        vm.warp(Blocktime + 2);
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.SELL;
        actionTypes[1] = ActionTypes.BUY;
        uint16 tokenPercentage = 10;
        uint16 period = 24;
        uint256 totalSupply = applicationCoin.totalSupply();
        uint64 startTime = uint64(block.timestamp);  
        
        switchToRuleAdmin();
        uint32 ruleId = createTokenMaxBuySellVolumeRule(tokenPercentage, period, totalSupply, startTime);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actionTypes, ruleId);
        setTokenMaxBuySellVolumeRule(address(applicationNFTHandlerv2), actionTypes, ruleId);

        vm.prank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), // ensure erc20 rule is being checked inside transaction
                IERC20Errors.OverMaxVolume.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);

        // create new rule params so that rules is triggered on nft transfer 
        tokenPercentage = 5000; // 50% of supply for erc721 rule 
        vm.warp(Blocktime + 48); // warp to new period 
        switchToRuleAdmin();
        TradingRuleFacet(address(applicationCoinHandler)).activateTokenMaxBuySellVolume(actionTypes, false); /// deactivate ERC20Rule
        ruleId = createTokenMaxBuySellVolumeRule(tokenPercentage, period, applicationNFTv2.totalSupply(), startTime);
        setTokenMaxBuySellVolumeRule(address(applicationNFTHandlerv2), actionTypes, ruleId);
    
        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), // ensure that the NFT rule is being checked inside transaction 
                IERC20Errors.OverMaxVolume.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);

    }

    function test_inOperatorMarketplace_AccountApproveDenyOracleRules_ApproveAndDenyOracle_Sell() public endWithStopPrank() {
        // create oracle rule and set users to approve list 
        switchToRuleAdmin();
        // ERC20 Approve Oracle 
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        // ERC721 Approve Oracle 
        uint32 newRuleId = createAccountApproveDenyOracleRule(0);

        uint snapshot = vm.snapshot();

        // test 1 - Test Buy side of ERC20 Transaction fails if buyer is not approved 
        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);

        // test 2 - Test Sell side of ERC20 Transaction fails if seller is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        
        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        // test 3 - Test Buy side of ERC721 Transaction fails if buyer is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user2));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);

        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        // test 4 - Test Sell side of ERC20 Transaction fails if buyer is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user1));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);

        vm.stopPrank();
        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        // all passing 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);
        // Both oracle rules active 
        // users approved and no users denied 
        vm.startPrank(user2, user2);
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
    }

    function test_inOperatorMarketplace_AccountApproveDenyOracleRules_DenyAndApproveOracle_Sell() public endWithStopPrank() {
        // create oracle rule and set users to approve list 
        switchToRuleAdmin();
        // ERC20 Deny Oracle 
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        switchToAppAdministrator();
        // ERC721 Approve Oracle 
        uint32 newRuleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandlerv2), newRuleId);
        uint snapshot = vm.snapshot();
        // test 1 - Test Buy side of ERC20 Transaction fails if buyer is not approved 
        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        // test 2 - Test Sell side of ERC20 Transaction fails if seller is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        
        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationNFTv2), 
                IERC20Errors.AddressNotApproved.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        // test 3 - Test Buy side of ERC721 Transaction fails if buyer is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user2));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);

        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        // test 4 - Test Sell side of ERC20 Transaction fails if buyer is not approved 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        badBoys.push(address(user2));
        oracleDenied.addToDeniedList(badBoys);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);

        vm.stopPrank();
        vm.startPrank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                IERC20Errors.AddressIsDenied.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
        // all passing 
        vm.revertTo(snapshot);
        switchToAppAdministrator();
        goodBoys.push(address(user1));
        goodBoys.push(address(user2));
        oracleApproved.addToApprovedList(goodBoys);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        // Both oracle rules active 
        // users approved and no users denied 
        vm.startPrank(user2, user2);
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);
    }

    function test_accountMinMaxTokenBalance_inOperatorMarketplace_Sell() public endWithStopPrank() {
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

        vm.prank(user2, user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                ITagRuleErrors.UnderMinBalance.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);

        vm.revertTo(snapshotId);

        console.log("Part 2: Apply Max to ERC20");
        switchToAppAdministrator();
        applicationCoin.mint(user1, buyPrice * 10 + 1);
        applicationAppManager.addTag(user2, "ERC20_SOLIDMIN_NOMAX");
        applicationAppManager.addTag(user1, "ERC20_SOLIDMIN_SOLIDMAX");
        vm.stopPrank();

        vm.startPrank(user2, user2);
        marketplace.updateListing(address(applicationNFTv2), NFT_ID_1, buyPrice * 10 + 1);
        applicationCoin.approve(address(marketplace), buyPrice * 10 + 1);

        vm.expectRevert(
            abi.encodeWithSelector(
                TransferFailed.selector, 
                address(applicationCoin), 
                ITagRuleErrors.OverMaxBalance.selector
            )
        );
        marketplace.sellItem(address(applicationNFTv2), NFT_ID_1);

        // TODO Uncomment and refactor for sell 

        // vm.stopPrank();

        // vm.revertTo(snapshotId);

        // console.log("Part 3: Apply min/max to ERC721");

        // switchToAppAdministrator();
        // applicationNFTv2.safeMint(user2);
        // applicationAppManager.addTag(user1, "ERC721_NOMIN_SOLIDMAX");
        // applicationAppManager.addTag(user2, "ERC721_SOLIDMIN_SOLIDMAX");
        // vm.stopPrank();

        // vm.startPrank(user2);
        // applicationNFTv2.approve(address(marketplace), NFT_ID_2);
        // marketplace.updateListing(address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        // marketplace.listItem(address(applicationNFTv2), NFT_ID_2, address(applicationCoin), buyPrice / 2);
        // vm.stopPrank();

        // uint snapshotId2 = vm.snapshot();
        // // expect the first buy to go through, fail on the second due to max balance
        // vm.startPrank(user1);
        // vm.expectEmit(address(marketplace));
        // emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        // marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);  
        // vm.expectRevert(
        //     abi.encodeWithSelector(
        //         TransferFailed.selector, 
        //         address(applicationNFTv2), 
        //         ITagRuleErrors.OverMaxBalance.selector
        //     )
        // );
        // marketplace.buyItem(address(applicationNFTv2), NFT_ID_2);

        // TODO Uncomment and refactor for sell 

        // vm.stopPrank();

        // console.log("Part 4: Max of ERC721 testing");
        // vm.revertTo(snapshotId2);
        // // now test that the min is being followed
        // switchToAppAdministrator();
        // applicationAppManager.removeTag(user1, "ERC721_NOMIN_SOLIDMAX");
        // applicationAppManager.addTag(user2, "ERC721_SOLIDMIN_SOLIDMAX");
        // vm.stopPrank();

        // vm.startPrank(user1);
        // vm.expectEmit(address(marketplace));
        // emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        // marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
        // vm.expectRevert(
        //     abi.encodeWithSelector(
        //         TransferFailed.selector, 
        //         address(applicationNFTv2), 
        //         ITagRuleErrors.UnderMinBalance.selector
        //     )
        // );
        // marketplace.buyItem(address(applicationNFTv2), NFT_ID_2);

        // TODO Uncomment and refactor for sell 
        
        // vm.stopPrank();

        // vm.revertTo(snapshotId);

        // console.log("Part 5"); // test that it's still allowed to go through happy path

        // switchToAppAdministrator();
        // applicationAppManager.addTag(user1, "ERC721_NOMIN_SOLIDMAX");
        // applicationAppManager.addTag(user2, "ERC20_SOLIDMIN_SOLIDMAX");
        // vm.stopPrank();

        // vm.prank(user2);
        // marketplace.updateListing(address(applicationNFTv2), NFT_ID_1, buyPrice / 2);

        // vm.prank(user1);
        // vm.expectEmit(address(marketplace));
        // emit NftMarketplace.ItemBought(user1, address(applicationNFTv2), NFT_ID_1, buyPrice / 2);
        // marketplace.buyItem(address(applicationNFTv2), NFT_ID_1);
    }
}