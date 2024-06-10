// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";

import "seaport-types/interfaces/SeaportInterface.sol";
import {BasicOrderParameters, OrderComponents, OfferItem, ConsiderationItem, AdditionalRecipient} from "seaport-types/lib/ConsiderationStructs.sol";
import {BasicOrderType, OrderType, ItemType} from "seaport-types/lib/ConsiderationEnums.sol";

//import "seaport/contracts/Seaport.sol";


contract ApplicationERC721ExampleForkTest is TestCommonFoundry {

    SeaportInterface opensea;
    //Seaport opensea;
    address alice;
    uint256 alicePk;
    //address bob; already declared above
    uint256 bobPk;

    function setUp() public {
        if (vm.envBool("FORK_TEST")) {
            vm.createSelectFork("https://rpc.ankr.com/eth");
            opensea = SeaportInterface(0x00000000000000ADc04C56Bf30aC9d3c0aAF14dC);
            setUpProcotolAndCreateERC20AndDiamondHandler();
        } else {
            vm.skip(true);
        }
    }

    function testERC721_ApplicationERC721Examples_OpenseaTrade() public endWithStopPrank {
        switchToAppAdministrator();
        (alice, alicePk) = makeAddrAndKey("alice");
        (bob, bobPk) = makeAddrAndKey("bob");
        applicationNFTv2.safeMint(alice);
        applicationCoin.mint(bob, 10000000000000000000);

        
        vm.startPrank(alice);

        applicationNFTv2.approve(address(opensea), 0);
        applicationCoin.approve(address(opensea), 1000000000000000000);

        vm.startPrank(bob);

        applicationCoin.approve(address(opensea), 1000000000000000000);

        vm.stopPrank();

        OfferItem memory _offer = OfferItem({
            itemType: ItemType.ERC721,
            token: address(applicationNFTv2),
            identifierOrCriteria: 0,
            startAmount: 1,
            endAmount: 1
        });

        OfferItem[] memory _offers = new OfferItem[](1);
        _offers[0] = _offer;


        ConsiderationItem memory _consideration = ConsiderationItem({
            token: address(applicationCoin),
            identifierOrCriteria: 0,
            startAmount: 1000000000000000000,
            endAmount: 1000000000000000000,
            itemType: ItemType.ERC20,
            recipient: payable(address(alice))
        });

        ConsiderationItem[] memory _considerations = new ConsiderationItem[](1);
        _considerations[0] = _consideration;

        uint256 _counter = opensea.getCounter(bob);

        OrderComponents memory components = OrderComponents({
            offerer: bob,
            zone: address(0x0),
            offer: _offers,
            consideration: _considerations,
            orderType: OrderType.FULL_OPEN,
            startTime: block.timestamp,
            endTime: block.timestamp + 1000,
            zoneHash: bytes32(0),
            salt: uint256(keccak256(abi.encode("MYSALT"))),
            conduitKey: bytes32(0),
            counter: _counter
        });

        bytes32 orderHash = opensea.getOrderHash(components);

        (, bytes32 domainSeperator,) = opensea.information();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, keccak256(abi.encodePacked(bytes2(0x1901), domainSeperator, orderHash)));

        bytes memory sig = abi.encodePacked(v, r, s);

        AdditionalRecipient[] memory _additionalRecipients = new AdditionalRecipient[](0);

        BasicOrderParameters memory orderParams = BasicOrderParameters({
            considerationToken: address(applicationCoin),
            considerationIdentifier: 0,
            considerationAmount: 1000000000000000000,
            offerer: payable(address(bob)),
            zone: address(0x0),
            offerToken: address(applicationNFTv2),
            offerIdentifier: 0,
            offerAmount: 1,
            basicOrderType: BasicOrderType.ERC20_TO_ERC721_FULL_OPEN,
            startTime: block.timestamp,
            endTime: block.timestamp + 1000,
            zoneHash: bytes32(0),
            salt: uint256(keccak256(abi.encode("MYSALT"))),
            offererConduitKey: bytes32(0),
            fulfillerConduitKey: bytes32(0),
            totalOriginalAdditionalRecipients: 0,
            additionalRecipients: _additionalRecipients,
            signature: sig
        });

        vm.startPrank(alice);
        bool fulfilled = opensea.fulfillBasicOrder(orderParams);
        assertTrue(fulfilled, "Order was not fulfilled");
    }
}

