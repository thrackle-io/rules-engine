// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ApplicationERC721Common.t.i.sol";

/**
 * @title ApplicationERC721MintBurnInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC721 mint and burn functionality.
 */
contract ApplicationERC721MintBurnInvariantTest is ApplicationERC721Common {
    function setUp() public {
        prepERC721AndEnvironment();
    }

// The burn function should destroy tokens and reduce the total supply
    function invariant_ERC721_external_burnReducesTotalSupply() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if((selfBalance == 0))return;
        uint256 oldTotalSupply = applicationNFT.totalSupply();
        vm.startPrank(USER1, USER1);

        for(uint256 i; i < selfBalance; i++) {
            uint256 tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
            applicationNFT.burn(tokenId2);
        }
        // Check for underflow
        assertTrue(selfBalance <= oldTotalSupply);
        assertEq(oldTotalSupply - selfBalance, applicationNFT.totalSupply());
    }

    // A burned token should not be transferrable
    function invariant_ERC721_external_burnRevertOnTransfer() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return;

        uint256 tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
        vm.startPrank(USER1, USER1);
        applicationNFT.burn(tokenId2);
        vm.expectRevert("ERC721: invalid token ID");
        applicationNFT.transferFrom(USER1, target, tokenId2);
    }

    // approve() should revert if the token is burned
    function invariant_ERC721_external_burnRevertOnApprove() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return;

        uint256 tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
        vm.startPrank(USER1, USER1);
        applicationNFT.burn(tokenId2);
        vm.expectRevert("ERC721: invalid token ID");
        applicationNFT.approve(USER1, tokenId2);
    }

    // getApproved() should revert if the token is burned.
    function invariant_ERC721_external_burnRevertOnGetApproved() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return;

        uint256 tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
        vm.startPrank(USER1, USER1);
        applicationNFT.burn(tokenId2);
        vm.expectRevert("ERC721: invalid token ID");
        applicationNFT.getApproved(tokenId2);
    }

    // ownerOf() should revert if the token has been burned.
    function invariant_ERC721_external_burnRevertOnOwnerOf() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return;

        uint256 tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
        vm.startPrank(USER1, USER1);
        applicationNFT.burn(tokenId2);
        vm.expectRevert("ERC721: invalid token ID");
        applicationNFT.ownerOf(tokenId2);
    }

/** MINT */
    // Mint increases the total supply.
    function invariant_ERC721_external_mintIncreasesSupply() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        uint256 oldTotalSupply = applicationNFT.totalSupply();
        switchToAppAdministrator();
        try applicationNFT.safeMint(USER1) {
            assertEq(oldTotalSupply + 1, applicationNFT.totalSupply());
            assertEq(selfBalance + 1, applicationNFT.balanceOf(USER1));
        } catch {
            revert("Minting unexpectedly reverted");
        }
    }

    // Mint creates a fresh applicationNFT.
    function invariant_ERC721_external_mintCreatesFreshToken() public virtual {
        switchToAppAdministrator();
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        try applicationNFT.safeMint(USER1) {
            uint256 tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, selfBalance);
            assertTrue(applicationNFT.ownerOf(tokenId2) == USER1);
            assertEq(selfBalance + 1, applicationNFT.balanceOf(USER1));
        } catch {
            revert("Minting unexpectedly reverted");
        }
    }
}