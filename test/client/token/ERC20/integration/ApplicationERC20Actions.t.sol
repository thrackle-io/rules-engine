// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "src/client/token/handler/common/HandlerUtils.sol";
import "test/client/token/SCAWallet.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";

/**
 * @title Application Token Handler Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @VoR0220
 * @dev this contract tests the ApplicationERC20 Handler. This handler is deployed specifically for its implementation
 *      contains all the rule checks for the particular ERC20.
 * @notice It simulates the input from a token contract
 */
contract ApplicationERC20HandlerTest is ERC20Util, HandlerUtils{

    function setUp() public{
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndDiamondHandler();
    }
   

    function testERC20_ApplicationERC20Actions_DetermineTransferAction_Mint() public {
        address from;
        address to;
        address sender;
        address user1 = address(1);

        // mint
        sender = user1;
        to = user1;
        from = address(0);
        assertEq(uint8(ActionTypes.MINT), uint8(determineTransferAction(from, to, sender)));
    }

    function testERC20_ApplicationERC20Actions_DetermineTransferAction_Burn() public {
        address from;
        address to;
        address sender;
        address user1 = address(1);

        // burn
        sender = user1;
        to = address(0);
        from = user1;
        assertEq(uint8(ActionTypes.BURN), uint8(determineTransferAction(from, to, sender)));
    }

    function testERC20_ApplicationERC20Actions_DetermineTransferAction_Transfer() public {
        address from;
        address to;
        address sender;
        address user1 = address(1);
        address user2 = address(2);

        // p2p transfer
        sender = user2;
        to = user1;
        from = user2;
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction(from, to, sender)));
    }

    function testERC20_ApplicationERC20Actions_DetermineTransferAction_Buy() public {
        address from;
        address to;
        address sender;
        address user1 = address(1);

        // buy
        sender = address(this);
        to = user1;
        from = address(this);
        assertEq(uint8(ActionTypes.BUY), uint8(determineTransferAction(from, to, sender)));
    }

    function testERC20_ApplicationERC20Actions_DetermineTransferAction_Sell() public {
        address from;
        address to;
        address sender;
        address user1 = address(1);

        // sell
        sender = address(this);
        to = user1;
        from = tx.origin;
        assertEq(uint8(ActionTypes.SELL), uint8(determineTransferAction(from, to, sender)));
    }

    /** Test that actions are properly determined when calling determineTransfer directly */
    function testERC20_EOA_Integration_Sanitycheck() public {
        SCAWallet wallet = new SCAWallet();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        assertEq(10 * ATTO, wallet.getWalletBalance());

        vm.startPrank(address(wallet), address(wallet));
        // test Burns 
        assertEq(uint8(ActionTypes.BURN), uint8(determineTransferAction({_from: address(wallet), _to: address(0), _sender: address(wallet)})));
        // test Mints 
        assertEq(uint8(ActionTypes.MINT), uint8(determineTransferAction({_from: address(0), _to: address(wallet), _sender: address(wallet)})));
        
        // test transfers 
        // from EOA to SCA
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: user1, _to: address(wallet), _sender: user1})));

        // Set up amm for buys and sells
        DummyAMM amm = initializeERC20AMM(address(applicationCoin), address(applicationCoin2));

        // test Sells 
        assertEq(uint8(ActionTypes.SELL), uint8(determineTransferAction({_from: tx.origin, _to: address(amm), _sender: address(amm)})));

        // test Buys
        assertEq(uint8(ActionTypes.BUY), uint8(determineTransferAction({_from: address(amm), _to: user1, _sender: address(amm)})));

    }

    /** Test that actions are properly determined when calling determineTransfer directly 
        TODO: Fix the determine transfer action function to work with SCA
    */
    function testERC20_testSmartContractWallet() public {
        vm.skip(true);
        SCAWallet wallet = new SCAWallet();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        assertEq(10 * ATTO, wallet.getWalletBalance());

        vm.startPrank(address(wallet), address(wallet));
        // test Burns 
        assertEq(uint8(ActionTypes.BURN), uint8(determineTransferAction({_from: address(wallet), _to: address(0), _sender: address(wallet)})));
        // test Mints 
        assertEq(uint8(ActionTypes.MINT), uint8(determineTransferAction({_from: address(0), _to: address(wallet), _sender: address(wallet)})));
        
        // test transfers 
        // from EOA to SCA
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: user1, _to: address(wallet), _sender: user1})));

        // Set up amm for buys and sells
        DummyAMM amm = initializeERC20AMM(address(applicationCoin), address(applicationCoin2));

        // test Sells 
        assertEq(uint8(ActionTypes.SELL), uint8(determineTransferAction({_from: address(wallet), _to: address(amm), _sender: address(amm)})));

        // test Buys
        assertEq(uint8(ActionTypes.BUY), uint8(determineTransferAction({_from: address(amm), _to: address(wallet), _sender: address(amm)})));

    }

    /** 
        Test that actions are properly determined when calling determineTransfer directly for Gnosis SAFE variant 
        TODO: Fix the determine transfer action function to work with SCA 
    **/
    function testERC20_testSmartContractWalletSAFEImpl() public {
        vm.skip(true);
        SCAWalletSafeStyle wallet = new SCAWalletSafeStyle();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        assertEq(10 * ATTO, wallet.getWalletBalance());

        vm.startPrank(address(wallet), address(wallet));
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
        DummyAMM amm = initializeERC20AMM(address(applicationCoin), address(applicationCoin2));

        // test Sells 
        assertEq(uint8(ActionTypes.SELL), uint8(determineTransferAction({_from: address(wallet), _to: address(amm), _sender: address(amm)})));

        // test Buys
        assertEq(uint8(ActionTypes.BUY), uint8(determineTransferAction({_from: address(amm), _to: address(wallet), _sender: address(amm)})));
    }

    /** 
        Test that actions are properly determined when calling determineTransfer directly for Zerodev variant 
        TODO: Fix the determine transfer action function to work with SCA 
    **/
    function testERC20_testSmartContractWalletZerodevImpl() public {
        vm.skip(true);
        SCAWalletZeroDevStyle wallet = new SCAWalletZeroDevStyle();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        assertEq(10 * ATTO, wallet.getWalletBalance());

        vm.startPrank(address(wallet), address(wallet));
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
        DummyAMM amm = initializeERC20AMM(address(applicationCoin), address(applicationCoin2));

        // test Sells 
        assertEq(uint8(ActionTypes.SELL), uint8(determineTransferAction({_from: address(wallet), _to: address(amm), _sender: address(amm)})));

        // test Buys
        assertEq(uint8(ActionTypes.BUY), uint8(determineTransferAction({_from: address(amm), _to: address(wallet), _sender: address(amm)})));

    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Mint() public {
        SCAWallet wallet = new SCAWallet();
        
        vm.startPrank(address(wallet), address(wallet));        
        // test Mints
        vm.expectEmit();
        emit Action(uint8(ActionTypes.MINT));
        applicationCoin.mint(address(wallet), 1);
        
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Burn() public {
        SCAWallet wallet = new SCAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        
        vm.startPrank(address(wallet), address(wallet));
        // test Burns 
        vm.expectEmit();
        emit Action(uint8(ActionTypes.BURN));
        applicationCoin.burn(1);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Transfer() public {
        SCAWallet wallet = new SCAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        applicationCoin.mint(user1, 10 * ATTO);
        applicationCoin2.mint(user1, 10 * ATTO);
        
        // test transfers 
        vm.startPrank(user1, user1);
        // from EOA to SCA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationCoin.transfer(address(wallet),1);
        // from EOA to EOA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationCoin.transfer(user2,1);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Transfer_EOA_to_EOA() public {
        SCAWallet wallet = new SCAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        applicationCoin.mint(user1, 10 * ATTO);
        applicationCoin2.mint(user1, 10 * ATTO);
        
        // test transfers 
        vm.startPrank(user1, user1);
        // from EOA to EOA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationCoin.transfer(user2,1);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Transfer_EOA_to_SCA() public {
        SCAWallet wallet = new SCAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        applicationCoin.mint(user1, 10 * ATTO);
        applicationCoin2.mint(user1, 10 * ATTO);
        
        // test transfers 
        vm.startPrank(user1, user1);
        // from EOA to SCA
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationCoin.transfer(address(wallet),1);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Sell() public {
        SCAWallet wallet = new SCAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        applicationCoin2.mint(address(wallet), 10 * ATTO);
        
        // Set up amm for buy and sell tests
        DummyAMM amm = initializeERC20AMM(address(applicationCoin), address(applicationCoin2));
        // test Sells 
        vm.startPrank(address(wallet), address(wallet));
        applicationCoin2.approve(address(amm), 50000);
        applicationCoin.approve(address(amm), 50000);

        // test Sell should issue two events: 1. sell for applicationCoin2, 2. buy for applicationCoin
        vm.expectEmit(true,false,false,false,applicationCoin2.getHandlerAddress());
        emit Action(uint8(ActionTypes.SELL));
        vm.expectEmit(true,false,false,false,applicationCoin.getHandlerAddress());
        emit Action(uint8(ActionTypes.BUY));
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 1, 1, false);
    }

    /** Test that actions are properly determined when using protocol supported assets */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Buy() public {
        SCAWallet wallet = new SCAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        applicationCoin2.mint(address(wallet), 10 * ATTO);
        
        // Set up amm for buy and sell tests
        DummyAMM amm = initializeERC20AMM(address(applicationCoin), address(applicationCoin2));
        // test Sells 
        vm.startPrank(address(wallet), address(wallet));
        applicationCoin2.approve(address(amm), 50000);
        applicationCoin.approve(address(amm), 50000);

        // test Buys should issue two events: 1. sell for applicationCoin, 2. buy for applicationCoin2
        vm.expectEmit(true,false,false,false,applicationCoin.getHandlerAddress());
        emit Action(uint8(ActionTypes.SELL));
        vm.expectEmit(true,false,false,false,applicationCoin2.getHandlerAddress());
        emit Action(uint8(ActionTypes.BUY));
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 1, 1, true);
    }

    /** Test that actions are properly determined when using protocol supported assets. This discrepancy will be remedied in V2
     *  TODO: Fix the determine transfer action function to work with staking
     */
    function testERC20_EOAWithProtocolSupportedAssets_Staking() public {
        vm.skip(true);
        switchToAppAdministrator();
        applicationCoin.mint(user1, 10 * ATTO);
        // Set up amm for buy and sell tests
        DummyStaking staking = initializeERC20Stake(address(applicationCoin));
        // first test standard EOA stake
        vm.startPrank(user1, user1);
        applicationCoin.approve(address(staking), 50000);
        vm.expectEmit();
        emit Action(uint8(ActionTypes.SELL));
        staking.dummyStake(address(applicationCoin), 1);
        vm.expectEmit();
        emit Action(uint8(ActionTypes.BUY));
        staking.dummyUnStake(address(applicationCoin), 1);
    }

    /** Test that actions are properly determined when using protocol supported assets. This discrepancy will be remedied in V2
     *  TODO: Fix the determine transfer action function to work with staking
     */
    function testERC20_SmartContractWalletWithProtocolSupportedAssets_Staking() public {
        vm.skip(true);
        switchToAppAdministrator();
        // Set up amm for buy and sell tests
        DummyStaking staking = initializeERC20Stake(address(applicationCoin));
        SCAWallet wallet = new SCAWallet();
        applicationCoin.mint(address(wallet), 10 * ATTO);
        vm.startPrank(address(wallet), address(wallet));
        applicationCoin.approve(address(staking), 50000);
        vm.expectEmit();
        emit Action(uint8(ActionTypes.SELL));
        staking.dummyStake(address(applicationCoin), 1);
        vm.expectEmit();
        emit Action(uint8(ActionTypes.SELL));
        staking.dummyStake(address(applicationCoin), 1);
    }

    /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
        TODO: Fix the determine transfer action function to work with SCA
     */
    function testERC20_SmartContractWalletBroken_SCA_to_EOA() public {
        vm.skip(true);
        SCAWallet wallet = new SCAWallet();

        vm.startPrank(address(wallet), address(wallet));
        // test transfers 
        // from SCA to EOA(comes back as BUY)
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: address(wallet), _to: user1, _sender: address(wallet)})));
    }

    /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
        TODO: Fix the determine transfer action function to work with SCA
     */
    function testERC20_SmartContractWalletBroken_SCA_SCA() public {
        vm.skip(true);
        SCAWallet wallet = new SCAWallet();

        vm.startPrank(address(wallet), address(wallet));
        // test transfers 
        // from SCA to SCA(comes back as BUY)
        assertEq(uint8(ActionTypes.P2P_TRANSFER), uint8(determineTransferAction({_from: address(wallet), _to: address(wallet), _sender: address(wallet)})));
    }

    /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
        TODO: Fix the determine transfer action function to work with SCA
     */
    function testERC20_SmartContractWalletWithProtocolSupportedAssetsBroken_SCA_to_EOA() public {
        vm.skip(true);
        SCAWallet wallet = new SCAWallet();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        applicationCoin.mint(address(wallet), 10 * ATTO);
        applicationCoin.mint(user1, 10 * ATTO);
        
        vm.startPrank(address(wallet), address(wallet));
        // test transfers 
        // from SCA to EOA(comes back as BUY)
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationCoin.transfer(user1,1);
    }

     /**
        This test demonstrates current shortcomings with the protocol's detection of actions when a SCA is used. These issues will be addressed in v2.
        TODO: Fix the determine transfer action function to work with SCA
     */
    function testERC20_SmartContractWalletWithProtocolSupportedAssetsBroken_SCA_to_SCA() public {
        vm.skip(true);
        SCAWallet wallet = new SCAWallet();
        SCAWallet wallet2 = new SCAWallet();
        // make sure that wallet can hold ETH
        vm.deal(address(wallet), 10 ether);
        applicationCoin.mint(address(wallet), 10 * ATTO);
        applicationCoin.mint(user1, 10 * ATTO);
        
        vm.startPrank(address(wallet), address(wallet));
        // test transfers 
        // from SCA to SCA(comes back as BUY)
        vm.expectEmit();
        emit Action(uint8(ActionTypes.P2P_TRANSFER));
        applicationCoin.transfer(address(wallet2),1);
    }
    

}
