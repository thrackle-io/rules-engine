// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";
import {ApplicationERC721 as MintForAFeeERC721} from "src/example/ERC721/not-upgradeable/ApplicationERC721MintForAFee.sol";
import {ApplicationERC721 as WhitelistMintERC721} from "src/example/ERC721/not-upgradeable/ApplicationERC721WhitelistMint.sol";
import {ApplicationERC721 as FreeForAllERC721} from "src/example/ERC721/not-upgradeable/ApplicationERC721FreeMint.sol";
import {ApplicationERC721HandlerMod} from "./helpers/ApplicationERC721HandlerMod.sol";
import {ApplicationERC721Upgradeable as MintForAFeeERC721Upgradeable} from "src/example/ERC721/upgradeable/ApplicationERC721UpgMintForAFee.sol";
import {ApplicationERC721Upgradeable as WhitelistMintERC721Upgradeable} from "src/example/ERC721/upgradeable/ApplicationERC721UpgWhitelistMint.sol";
import {ApplicationERC721Upgradeable as FreeForAllERC721Upgradeable} from "src/example/ERC721/upgradeable/ApplicationERC721UpgFreeMint.sol";
import {ApplicationERC721HandlerMod} from "./helpers/ApplicationERC721HandlerMod.sol";
import "../src/example/ERC721/upgradeable/ApplicationERC721UProxy.sol";
import "test/helpers/ApplicationERC721WithBatchMintBurn.sol";
import "test/helpers/TestCommon.sol";

interface NFT{
    function confirmTreasuryAddress() external;
}

contract FaultyDummyTreasury{

    error CannotReceive(uint256 weis);

    function acceptTreasuryRole(address nft) external {
        NFT(nft).confirmTreasuryAddress();
    }
    receive() payable external{
        revert CannotReceive(msg.value);
    }
}

contract DummyTreasury{

    uint256 public balance;

    function acceptTreasuryRole(address nft) external {
        NFT(nft).confirmTreasuryAddress();
    }

    receive() payable external {
        balance += msg.value;
    }
}

contract ApplicationERC721ExampleTest is TestCommon {
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC721HandlerMod newAssetHandler;
    MintForAFeeERC721 mintForAFeeNFT;
    WhitelistMintERC721 whitelistMintNFT;
    FreeForAllERC721 freeNFT;
    MintForAFeeERC721Upgradeable mintForAFeeNFTUpImplementation;
    WhitelistMintERC721Upgradeable whitelistMintNFTUpImplementation;
    FreeForAllERC721Upgradeable freeNFTUpImplementation;
    ApplicationERC721UProxy mintForAFeeNFTUp;
    ApplicationERC721UProxy whitelistMintNFTUp;
    ApplicationERC721UProxy freeNFTUp;
    ApplicationERC721Handler MintForAFeeNFTHandler;
    ApplicationERC721Handler WhitelistNFTHandler;
    ApplicationERC721Handler FreeForAllnNFTHandler;
    ApplicationERC721Handler MintForAFeeNFTHandlerUp;
    ApplicationERC721Handler WhitelistNFTHandlerUp;
    ApplicationERC721Handler FreeForAllnNFTHandlerUp;

    address rich_user = address(44);
    address proxyOwner = address(0xBABE666);
    address user1 = address(0xa1);
    address user2 = address(0xb2);
    address user3 = address(0xc3);
    address ac;
    address[] badBoys;
    address[] goodBoys;

    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(appAdministrator);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();

        /// create ERC721 examples
        mintForAFeeNFT = new MintForAFeeERC721("BlindSailers", "BSL", address(applicationAppManager), "blindsailers.com/iseeyou", 1 ether);
        whitelistMintNFT = new WhitelistMintERC721("MonkeysPlayingInBonsaiTrees", "MBT", address(applicationAppManager), "monkeysdontknowwhattodo.com/havingfun", 2);
        freeNFT = new FreeForAllERC721("ParkinsonBarbers", "PKB", address(applicationAppManager), "bloodinmyhands.com/bookyourcut");

        MintForAFeeNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(mintForAFeeNFT), false);
        mintForAFeeNFT.connectHandlerToToken(address(MintForAFeeNFTHandler));
        WhitelistNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(whitelistMintNFT), false);
        whitelistMintNFT.connectHandlerToToken(address(WhitelistNFTHandler));
        FreeForAllnNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(freeNFT), false);
        freeNFT.connectHandlerToToken(address(FreeForAllnNFTHandler));

        applicationAppManager.registerToken("BlindSailers", address(mintForAFeeNFT));
        applicationAppManager.registerToken("MonkeysPlayingInBonsaiTrees", address(whitelistMintNFT));
        applicationAppManager.registerToken("ParkinsonBarbers", address(freeNFT));

        /// create ERC721 examples upgradeable
        mintForAFeeNFTUpImplementation = new MintForAFeeERC721Upgradeable();
        whitelistMintNFTUpImplementation = new WhitelistMintERC721Upgradeable();
        freeNFTUpImplementation = new FreeForAllERC721Upgradeable();

        mintForAFeeNFTUp = new ApplicationERC721UProxy(address(mintForAFeeNFTUpImplementation), proxyOwner, ""); 
        whitelistMintNFTUp = new ApplicationERC721UProxy(address(whitelistMintNFTUpImplementation), proxyOwner, "");
        freeNFTUp = new ApplicationERC721UProxy(address(freeNFTUpImplementation), proxyOwner, "");

         MintForAFeeERC721Upgradeable(payable(address(mintForAFeeNFTUp))).initialize("BlindSailersUp", "BSLU", address(applicationAppManager), "blindsailers.com/iseeyou", 1 ether);
         WhitelistMintERC721Upgradeable(payable(address(whitelistMintNFTUp))).initialize("MonkeysPlayingInBonsaiTreesUp", "MBTU", address(applicationAppManager), "monkeysdontknowwhattodo.com/havingfun", 2);
         FreeForAllERC721Upgradeable(payable(address(freeNFTUp))).initialize("ParkinsonBarbersUp", "PKBU", address(applicationAppManager), "bloodinmyhands.com/bookyourcut");

        MintForAFeeNFTHandlerUp = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(mintForAFeeNFTUp), false);
        MintForAFeeERC721Upgradeable(payable(address(mintForAFeeNFTUp))).connectHandlerToToken(address(MintForAFeeNFTHandlerUp));
        WhitelistNFTHandlerUp = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(whitelistMintNFTUp), false);
        WhitelistMintERC721Upgradeable(payable(address(whitelistMintNFTUp))).connectHandlerToToken(address(WhitelistNFTHandlerUp));
        FreeForAllnNFTHandlerUp = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(freeNFTUp), false);
        FreeForAllERC721Upgradeable(payable(address(freeNFTUp))).connectHandlerToToken(address(FreeForAllnNFTHandlerUp));

        applicationAppManager.registerToken("BlindSailersUp", address(mintForAFeeNFTUp));
        applicationAppManager.registerToken("MonkeysPlayingInBonsaiTreesUp", address(whitelistMintNFTUp));
        applicationAppManager.registerToken("ParkinsonBarbersUp", address(freeNFTUp));

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }

    function testERC721AndHandlerVersions() public {
        string memory version = applicationNFTHandler.version();
        assertEq(version, "1.0.1");
    }

    function testMintForAFee() public {
        switchToUser();
        /// let's give user some mills to spend on NFTs
        vm.deal(user, 2000 ether);
        /// let's make sure you can't mint without sending the right amount of Ether
        vm.expectRevert(0xa93074f9);
        mintForAFeeNFT.safeMint{value: 1 ether - 1}(user);
        /// now let's mint
        mintForAFeeNFT.safeMint{value: 1 ether}(user);
        mintForAFeeNFT.safeMint{value: 1 ether}(user);
        mintForAFeeNFT.safeMint{value: 1 ether}(user);
        /// let's do the same with the risk admin
        switchToRiskAdmin();
        /// let's give user some mills to spend on NFTs
        vm.deal(riskAdmin, 2000 ether);
        /// let's make sure you can't mint without sending the right amount of Ether
        vm.expectRevert(0xa93074f9);
        mintForAFeeNFT.safeMint{value: 1 ether - 1}(riskAdmin);
        /// now let's mint
        mintForAFeeNFT.safeMint{value: 1 ether}(riskAdmin);

        /// it's time to test our withdrawal methods
        /// let's deploy some treasury dummy contracts: 1 that works and 1 that doesnt
        DummyTreasury treasury = new DummyTreasury();
        FaultyDummyTreasury badTreasury = new FaultyDummyTreasury();
        /// now let's withdraw some money
        switchToAppAdministrator();
        /// first let's make sure we can withdraw. Let's propose the treasury
        mintForAFeeNFT.proposeTreasuryAddress(payable(address(treasury)));
        assertEq(mintForAFeeNFT.getProposedTreasuryAddress(), address(treasury));
        /// let's make sure only the right address can confirm the treasury
        vm.expectRevert(abi.encodeWithSignature("NotProposedTreasury(address)",address(treasury)));
        badTreasury.acceptTreasuryRole(address(mintForAFeeNFT));
        /// let's accept the role as treasury
        treasury.acceptTreasuryRole(address(mintForAFeeNFT));
        /// we check that the trasury is now "trasury"
        assertEq(mintForAFeeNFT.getTreasuryAddress(), address(treasury));
        /// and also that proposed address was reset to 0
        assertEq(mintForAFeeNFT.getProposedTreasuryAddress(), address(0));

        /// now we can withdraw
        mintForAFeeNFT.withdrawAmount(1 ether);
        assertEq(address(mintForAFeeNFT).balance, 3 ether);
        assertEq(address(treasury).balance, 1 ether);
        assertEq(treasury.balance(), 1 ether);
        /// and finally let's test the withdrawAll method
        mintForAFeeNFT.withdrawAll();
        assertEq(address(mintForAFeeNFT).balance, 0);
        assertEq(address(treasury).balance, 4 ether);
        assertEq(treasury.balance(), 4 ether);

        /// Let's see how the contract handles random people sending ETH to it
        switchToUser();
        (bool success, bytes memory data) = address(mintForAFeeNFT).call{value: 4 ether}("");
        console.log("success", success);
        console.log(data.length);
        assertEq(address(mintForAFeeNFT).balance, 4 ether);

        switchToAppAdministrator();
        /// Finally let's see how the contract handles reverts from treasury
        /// Let's propose the bad treasury first
        mintForAFeeNFT.proposeTreasuryAddress(payable(address(badTreasury)));
        /// let's accept the role as treasury
        badTreasury.acceptTreasuryRole(address(mintForAFeeNFT));
        /// now we can try to withdraw
        vm.expectRevert(abi.encodeWithSignature("TrasferFailed(bytes)", abi.encodeWithSignature("CannotReceive(uint256)",1 ether)));
        mintForAFeeNFT.withdrawAmount(1 ether);
        /// and finally let's test the withdrawAll method
        vm.expectRevert(abi.encodeWithSignature("TrasferFailed(bytes)", abi.encodeWithSignature("CannotReceive(uint256)",4 ether)));
        mintForAFeeNFT.withdrawAll();

        /// let's check that we can update the price. But before, let's check current price
        assertEq(mintForAFeeNFT.mintPrice(), 1 ether);
        /// let's raise the price to 5 ether
        mintForAFeeNFT.setMintPrice(5 ether);
        /// let's see if public variable got updated
        assertEq(mintForAFeeNFT.mintPrice(), 5 ether);
        /// now let's see if this works as expected.
        switchToUser();
        /// First let's try to send less than 5 ether
        vm.expectRevert(0xa93074f9);
        mintForAFeeNFT.safeMint{value: 5 ether - 1}(riskAdmin);
        /// finally we test that we can mint if we send the correct amount
        mintForAFeeNFT.safeMint{value: 5 ether}(riskAdmin);

    }

    function testMintForAFeeUpgradeable() public {
        MintForAFeeERC721Upgradeable nft = MintForAFeeERC721Upgradeable(payable(address(mintForAFeeNFTUp)));
        //nft.setMintPrice(1 ether);
        switchToUser();
        /// let's give user some mills to spend on NFTs
        vm.deal(user, 2000 ether);
        /// let's make sure you can't mint without sending the right amount of Ether
        vm.expectRevert(0xa93074f9);
        nft.safeMint{value: 1 ether - 1}(user);
        /// now let's mint
        nft.safeMint{value: 1 ether}(user);
        nft.safeMint{value: 1 ether}(user);
        nft.safeMint{value: 1 ether}(user);
        /// let's do the same with the risk admin
        switchToRiskAdmin();
        /// let's give user some mills to spend on NFTs
        vm.deal(riskAdmin, 2000 ether);
        /// let's make sure you can't mint without sending the right amount of Ether
        vm.expectRevert(0xa93074f9);
        nft.safeMint{value: 1 ether - 1}(riskAdmin);
        /// now let's mint
        nft.safeMint{value: 1 ether}(riskAdmin);

        /// it's time to test our withdrawal methods
        /// let's deploy some treasury dummy contracts: 1 that wors and 1 that doesnt
        DummyTreasury treasury = new DummyTreasury();
        FaultyDummyTreasury badTreasury = new FaultyDummyTreasury();
        /// now let's withdraw some money
        switchToAppAdministrator();
        /// first let's make sure we can withdraw. Let's propose the treasury
        nft.proposeTreasuryAddress(payable(address(treasury)));
        assertEq(nft.getProposedTreasuryAddress(), address(treasury));
        /// let's make sure only the right address can confirm the treasury
        vm.expectRevert(abi.encodeWithSignature("NotProposedTreasury(address)",address(treasury)));
        badTreasury.acceptTreasuryRole(address(nft));
        /// let's accept the role as treasury
        treasury.acceptTreasuryRole(address(nft));
        /// we check that the trasury is now "trasury"
        assertEq(nft.getTreasuryAddress(), address(treasury));
        /// and also that proposed address was reset to 0
        assertEq(nft.getProposedTreasuryAddress(), address(0));

        /// now we can withdraw
        nft.withdrawAmount(1 ether);
        assertEq(address(nft).balance, 3 ether);
        assertEq(address(treasury).balance, 1 ether);
        assertEq(treasury.balance(), 1 ether);
        /// and finally let's test the withdrawAll method
        nft.withdrawAll();
        assertEq(address(nft).balance, 0);
        assertEq(address(treasury).balance, 4 ether);
        assertEq(treasury.balance(), 4 ether);

        /// Let's see how the contract handles random people sending ETH to it
        switchToUser();
        (bool success, bytes memory data) = address(nft).call{value: 4 ether}("");
        console.log("success", success);
        console.log(data.length);
        assertEq(address(nft).balance, 4 ether);

        switchToAppAdministrator();
        /// Finally let's see how the contract handles reverts from treasury
        /// Let's propose the bad treasury first
        nft.proposeTreasuryAddress(payable(address(badTreasury)));
        /// let's accept the role as treasury
        badTreasury.acceptTreasuryRole(address(nft));
        /// now we can try to withdraw
        vm.expectRevert(abi.encodeWithSignature("TrasferFailed(bytes)", abi.encodeWithSignature("CannotReceive(uint256)",1 ether)));
        nft.withdrawAmount(1 ether);
        /// and finally let's test the withdrawAll method
        vm.expectRevert(abi.encodeWithSignature("TrasferFailed(bytes)", abi.encodeWithSignature("CannotReceive(uint256)",4 ether)));
        nft.withdrawAll();

        /// let's check that we can update the price. But before, let's check current price
        assertEq(nft.mintPrice(), 1 ether);
        /// let's raise the price to 5 ether
        nft.setMintPrice(5 ether);
        /// let's see if public variable got updated
        assertEq(nft.mintPrice(), 5 ether);
        /// now let's see if this works as expected.
        switchToUser();
        /// First let's try to send less than 5 ether
        vm.expectRevert(0xa93074f9);
        nft.safeMint{value: 5 ether - 1}(riskAdmin);
        /// finally we test that we can mint if we send the correct amount
        nft.safeMint{value: 5 ether}(riskAdmin);

    }

    function testWhitelistMint() public {
        /// let's add some addresses to the whitelist
        whitelistMintNFT.addAddressToWhitelist(user1);
        whitelistMintNFT.addAddressToWhitelist(user2);

        /// now let's try first to mint through a not-whitelisted address
        vm.expectRevert(0x202409e9);
        whitelistMintNFT.safeMint(user1);
        /// now let's mint one NFT from user1
        vm.stopPrank();
        vm.startPrank(user1);
        whitelistMintNFT.safeMint(user1);
        assertEq(whitelistMintNFT.mintsAvailable(user1), 1);
        /// let's mint another one
        whitelistMintNFT.safeMint(user1);
        assertEq(whitelistMintNFT.mintsAvailable(user1), 0);
        /// now, if we try to mint one more, it should fail since we ran out of free mints
        vm.expectRevert(0x202409e9);
        whitelistMintNFT.safeMint(user1);
        assertEq(whitelistMintNFT.mintsAvailable(user2), 2);

        /// let's test that we can update the free mints given. First let's check that a non admin can't
        vm.expectRevert();
        whitelistMintNFT.updateMintsAmount(3);
        /// now let's update from the app admin
        switchToAppAdministrator();
        whitelistMintNFT.updateMintsAmount(3);
        /// and let's add user1 again
        whitelistMintNFT.addAddressToWhitelist(user1);
        /// and we dance to the same song again
        vm.stopPrank();
        vm.startPrank(user1);
        whitelistMintNFT.safeMint(user1);
        assertEq(whitelistMintNFT.mintsAvailable(user1), 2);
        /// let's mint another one
        whitelistMintNFT.safeMint(user1);
        assertEq(whitelistMintNFT.mintsAvailable(user1), 1);
        /// let's mint another one
        whitelistMintNFT.safeMint(user1);
        assertEq(whitelistMintNFT.mintsAvailable(user1), 0);
        /// now, if we try to mint one more, it should fail since it ran out of free mints
        vm.expectRevert(0x202409e9);
        whitelistMintNFT.safeMint(user1);
        /// we test with another address as well
        assertEq(whitelistMintNFT.mintsAvailable(user2), 2);
        vm.stopPrank();
        vm.startPrank(user2);
        whitelistMintNFT.safeMint(user2);
        assertEq(whitelistMintNFT.mintsAvailable(user2), 1);
        /// let's mint another one
        whitelistMintNFT.safeMint(user2);
        assertEq(whitelistMintNFT.mintsAvailable(user2), 0);
        /// now, if we try to mint one more, it should fail since we ran out of free mints
        vm.expectRevert(0x202409e9);
        whitelistMintNFT.safeMint(user2);

    }

    function testWhitelistMintUpgradeable() public {
        WhitelistMintERC721Upgradeable nft = WhitelistMintERC721Upgradeable(payable(address(whitelistMintNFTUp)));
        //nft.updateMintsAmount(2);
        /// let's add some addresses to the whitelist
        nft.addAddressToWhitelist(user1);
        nft.addAddressToWhitelist(user2);

        /// now let's try first to mint through a not-whitelisted address
        vm.expectRevert(0x202409e9);
        nft.safeMint(user1);
        /// now let's mint one NFT from user1
        vm.stopPrank();
        vm.startPrank(user1);
        nft.safeMint(user1);
        assertEq(nft.mintsAvailable(user1), 1);
        /// let's mint another one
        nft.safeMint(user1);
        assertEq(nft.mintsAvailable(user1), 0);
        /// now, if we try to mint one more, it should fail since we ran out of free mints
        vm.expectRevert(0x202409e9);
        nft.safeMint(user1);
        assertEq(nft.mintsAvailable(user2), 2);

        /// let's test that we can update the free mints given. First let's check that a non admin can't
        vm.expectRevert();
        nft.updateMintsAmount(3);
        /// now let's update from the app admin
        switchToAppAdministrator();
        nft.updateMintsAmount(3);
        /// and let's add user1 again
        nft.addAddressToWhitelist(user1);
        /// and we dance to the same song again
        vm.stopPrank();
        vm.startPrank(user1);
        nft.safeMint(user1);
        assertEq(nft.mintsAvailable(user1), 2);
        /// let's mint another one
        nft.safeMint(user1);
        assertEq(nft.mintsAvailable(user1), 1);
        /// let's mint another one
        nft.safeMint(user1);
        assertEq(nft.mintsAvailable(user1), 0);
        /// now, if we try to mint one more, it should fail since it ran out of free mints
        vm.expectRevert(0x202409e9);
        nft.safeMint(user1);
        /// we test with another address as well
        assertEq(nft.mintsAvailable(user2), 2);
        vm.stopPrank();
        vm.startPrank(user2);
        nft.safeMint(user2);
        assertEq(nft.mintsAvailable(user2), 1);
        /// let's mint another one
        nft.safeMint(user2);
        assertEq(nft.mintsAvailable(user2), 0);
        /// now, if we try to mint one more, it should fail since we ran out of free mints
        vm.expectRevert(0x202409e9);
        nft.safeMint(user2);

    }

    function testFreeForAllMint() public {
        /// let's test that we can mint as many as we want for anybody
        vm.stopPrank();
        vm.startPrank(user1);
        for(uint i; i < 25; i++){
            freeNFT.safeMint(user1);
        }

        vm.stopPrank();
        vm.startPrank(user2);
        for(uint i; i < 6; i++){
            freeNFT.safeMint(user2);
        }

    }

    function testFreeForAllMintUpgradeable() public {
        FreeForAllERC721Upgradeable nft = FreeForAllERC721Upgradeable(payable(address(freeNFTUp)));
        /// let's test that we can mint as many as we want for anybody
        vm.stopPrank();
        vm.startPrank(user1);
        for(uint i; i < 25; i++){
            nft.safeMint(user1);
        }

        vm.stopPrank();
        vm.startPrank(user2);
        for(uint i; i < 6; i++){
            nft.safeMint(user2);
        }

    }

    function testOwnerOrAdminMint() public {
        /// since this is the default implementation, we only need to test the negative case
        switchToUser();
        vm.expectRevert(0x2a79d188);
        applicationNFT.safeMint(appAdministrator); 

        switchToAccessLevelAdmin();
        vm.expectRevert(0x2a79d188);
        applicationNFT.safeMint(appAdministrator);    

        switchToRuleAdmin();
        vm.expectRevert(0x2a79d188);
        applicationNFT.safeMint(appAdministrator); 

        switchToRiskAdmin();
        vm.expectRevert(0x2a79d188);
        applicationNFT.safeMint(appAdministrator);  
    }
}