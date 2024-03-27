// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "src/client/application/data/IDataModule.sol";

/**
 * @title ApplicationERC721Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the common module for ERC721 invariant tests..
 */
abstract contract ApplicationERC721Common is TestCommonFoundry {
    address msgSender;
    uint256 value;
    uint256 tokenId;
    address target;
    address USER1;
    address USER2;
    address USER3;
    
    function prepERC721AndEnvironment() public {
        setUpProtocolAndAppManagerAndTokensWithERC721HandlerDiamond();
        switchToAppAdministrator();
        (USER1, USER2, USER3, target) = _get4RandomAddresses(uint8(block.timestamp % ADDRESSES.length));
        applicationNFT.safeMint(USER1);
        applicationNFT.safeMint(USER2);
        applicationNFT.safeMint(USER3);
        vm.stopPrank();
        targetSender(USER1);
        targetSender(USER2);
        targetSender(USER3);
        targetSender(target);
        targetContract(address(applicationNFT));
    }
}