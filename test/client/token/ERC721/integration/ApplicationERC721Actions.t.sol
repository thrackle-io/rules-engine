// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "src/client/token/handler/common/HandlerUtils.sol";
import "test/client/token/SBAWallet.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";
import "test/client/token/ERC721/util/NftMarketplace.sol";


/**
 * @title Application Token Handler Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @VoR0220
 * @dev this contract tests the ApplicationERC721 Handler. This handler is deployed specifically for its implementation
 *      contains all the rule checks for the particular ERC721.
 * @notice It simulates the input from a token contract
 */

 contract ApplicationERC721HandlerTest is ERC721Util, HandlerUtils{
    
    function setUp() public{
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC721MinAndDiamondHandler();
    }

    // note: Most of the action determination tests can be found handled in the ERC20 Actions test suite. We do this purely to test the ERC721 specific actions.

    /** Test that actions are properly determined when calling determineTransfer directly */
    function testERC721_testSmartContractWallet() public {
        SBAWallet wallet = new SBAWallet();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        assertEq(10 * ATTO, wallet.getWalletBalance());

        vm.startPrank(address(wallet));
        // test Burns 
        assertEq(uint8(ActionTypes.BURN), uint8(determineTransferAction({_from: address(wallet), _to: address(0), _sender: address(wallet)})));
        // test Mints 
        assertEq(uint8(ActionTypes.MINT), uint8(determineTransferAction({_from: address(0), _to: address(wallet), _sender: address(wallet)})));
        
        // test transfers 
        // from EOA to SCA
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: user1, _to: address(wallet), _sender: user1})));

        // SCA to EOA        
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: address(wallet), _to: user1, _sender: address(wallet)})));
        // Set up amm for buys and sells
        // switchToAppAdministrator();
        // applicationNFT.safeMint(address(wallet));
        // DummyNFTAMM amm = new DummyNFTAMM();
        DummyNFTAMM amm = initializeERC721AMM(address(applicationCoin), address(applicationNFTv2));

        // test Sells 
        assertEq(uint8(ActionTypes.SELL), uint8(determineTransferAction({_from: address(wallet), _to: address(amm), _sender: address(amm)})));

        // test Buys
        assertEq(uint8(ActionTypes.BUY), uint8(determineTransferAction({_from: address(amm), _to: address(wallet), _sender: address(amm)})));

    }


    /** Test that actions are properly determined when using protocol supported assets */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_Mint() public {
        SBAWallet wallet = new SBAWallet();
        
        switchToAppAdministrator();      
        // test Mints
        vm.expectEmit();
        emit Action(uint8(ActionTypes.MINT));
        applicationNFTv2.safeMint(address(wallet));
        
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_Burn() public {
        SBAWallet wallet = new SBAWallet();
        switchToAppAdministrator();
        applicationNFTv2.safeMint(address(wallet));
        
        vm.startPrank(address(wallet));
        // test Burns 
        vm.expectEmit();
        emit Action(uint8(ActionTypes.BURN));
        applicationNFTv2.burn(0);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_Transfer_SCA_to_EOA() public {
        SBAWallet wallet = new SBAWallet();
        switchToAppAdministrator();
        applicationNFTv2.safeMint(address(wallet));
        applicationNFTv2.safeMint(user1);
        applicationNFTv2.safeMint(user1);
        
        // test transfers 
        vm.startPrank(address(wallet));
        // from SCA to EOA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationNFTv2.safeTransferFrom(address(wallet), user1, 0);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_Transfer_EOA_to_EOA() public {
        SBAWallet wallet = new SBAWallet();
        switchToAppAdministrator();
        applicationNFTv2.safeMint(address(wallet));
        applicationNFTv2.safeMint(user1);
        applicationNFTv2.safeMint(user1);
        
        // test transfers 
        vm.startPrank(user1);
        // from EOA to EOA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationNFTv2.transferFrom(user1,user2,1);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_Transfer_EOA_to_SCA() public {
        SBAWallet wallet = new SBAWallet();
        switchToAppAdministrator();
        applicationNFTv2.safeMint(address(wallet));
        applicationNFTv2.safeMint(user1);
        applicationNFTv2.safeMint(user1);
        
        // test transfers 
        vm.startPrank(user1);
        // from EOA to SCA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationNFTv2.transferFrom(user1,address(wallet),1);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_Sell() public {
        SBAWallet wallet = new SBAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        switchToAppAdministrator();
        applicationNFTv2.safeMint(address(wallet));
        
        // Set up amm for buy and sell tests
        DummyNFTAMM amm = initializeERC721AMM(address(applicationCoin), address(applicationNFTv2));
        // test Sells 
        vm.startPrank(address(wallet));
        applicationNFTv2.approve(address(amm), 0);

        // test Sell should issue two events: 1. sell for applicationNFTv2, 2. buy for applicationCoin
        vm.expectEmit(true,false,false,false,applicationNFTv2.getHandlerAddress());
        emit Action(uint8(ActionTypes.SELL));
        vm.expectEmit(true,false,false,false,applicationCoin.getHandlerAddress());
        emit Action(uint8(ActionTypes.BUY));
        amm.dummyTrade(address(applicationCoin), address(applicationNFTv2), 1 * ATTO, 0, false);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_Buy() public {
        SBAWallet wallet = new SBAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        // Set up amm for buy and sell tests
        DummyNFTAMM amm = initializeERC721AMM(address(applicationCoin), address(applicationNFTv2));
        // test Buys 
        vm.startPrank(address(wallet));
        applicationCoin.approve(address(amm), 1 * ATTO);

        // test Buys should issue two events: 1. sell for applicationCoin, 2. buy for applicationNFTv2
        vm.expectEmit(true,false,false,false,applicationCoin.getHandlerAddress());
        emit Action(uint8(ActionTypes.SELL));
        vm.expectEmit(true,false,false,false,applicationNFTv2.getHandlerAddress());
        emit Action(uint8(ActionTypes.BUY));
        amm.dummyTrade(address(applicationCoin), address(applicationNFTv2), 1 * ATTO, 0, true);
    }

    /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
     */
    function testERC721_SmartContractWallet_SCA_to_EOA() public {
        address eoa = address(1);
        vm.startPrank(eoa);
        SBAWallet wallet = new SBAWallet();
        vm.stopPrank();
        vm.startPrank(address(wallet));
        // test transfers 
        // from SCA to EOA(comes back as BUY)
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: address(wallet), _to: user1, _sender: address(wallet)})));
    }

    /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
     */
    function testERC721_SmartContractWallet_SCA_SCA() public {
        address eoa = address(1);
        vm.startPrank(eoa);
        SBAWallet wallet = new SBAWallet();
        vm.stopPrank();
        vm.startPrank(address(wallet));
        // test transfers 
        // from SCA to SCA(comes back as BUY)
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: address(wallet), _to: address(wallet), _sender: address(wallet)})));
    }

    /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
     */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_SCA_to_EOA() public {
        address eoa = address(1);
        vm.startPrank(eoa);
        SBAWallet wallet = new SBAWallet();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        switchToAppAdministrator();
        applicationNFTv2.safeMint(address(wallet));
        applicationNFTv2.safeMint(user1);
        
        vm.stopPrank();
        vm.startPrank(address(wallet));
        // test transfers 
        // from SCA to EOA(comes back as BUY)
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationNFTv2.transferFrom(address(wallet), user1, 0);
    }

     /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
     */
    function testERC721_SmartContractWalletWithProtocolSupportedAssets_SCA_to_SCA() public {
        address eoa = address(1);
        vm.prank(eoa);
        SBAWallet wallet = new SBAWallet();
        address eoa2 = address(2);
        vm.prank(eoa2);
        SBAWallet wallet2 = new SBAWallet();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        switchToAppAdministrator();
        applicationNFTv2.safeMint(address(wallet));
        vm.stopPrank();
        vm.prank(address(wallet));
        // test transfers 
        // from SCA to SCA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationNFTv2.transferFrom(address(wallet), address(wallet2), 0);
    }

    function testERC721_SmartContractWalletWithNftMarketplace_Transfer_SCA_Sell() public {
        SBAWallet wallet = new SBAWallet();
        NftMarketplace marketplace = new NftMarketplace();

        switchToAppAdministrator();
        vm.expectEmit();
        emit Action(uint8(ActionTypes.MINT));
        applicationNFTv2.safeMint(address(wallet));
        vm.stopPrank();

        vm.startPrank(address(wallet));
        applicationNFTv2.approve(address(marketplace), 0);

        marketplace.listItem(address(applicationNFTv2), 0, 1 * ATTO);

        vm.stopPrank();
        vm.deal(user1, 10 ether);
        vm.prank(address(user1));

        vm.expectEmit();
        emit Action(uint8(ActionTypes.SELL));
        // vm.expectEmit();
        // emit Action(uint8(ActionTypes.BUY));
        marketplace.buyItem{ value: 1 * ATTO}(address(applicationNFTv2), 0);
    }

    function testERC721_EOA_to_NftMarketPlace_Sell() public {
        NftMarketplace marketplace = new NftMarketplace();

        switchToAppAdministrator();
        applicationNFTv2.safeMint(user1);
        vm.stopPrank();
        
        vm.startPrank(user1);
        applicationNFTv2.approve(address(marketplace), 0);
        marketplace.listItem(address(applicationNFTv2), 0, 1 * ATTO);

        vm.stopPrank();
        vm.deal(user2, 10 ether);
        vm.prank(user2);

        vm.expectEmit(true,false,false,false,applicationNFTv2.getHandlerAddress());
        emit Action(uint8(ActionTypes.SELL));
        vm.expectEmit(true,false,false,false,applicationNFTv2.getHandlerAddress());
        emit Action(uint8(ActionTypes.BUY));
        marketplace.buyItem{ value: 1 * ATTO}(address(applicationNFTv2), 0);

    }
    

 }