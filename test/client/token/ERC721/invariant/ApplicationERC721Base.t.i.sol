// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "src/client/application/data/IDataModule.sol";

/**
 * @title ApplicationERC721BasicInvariantTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @VoR0220
 * @dev This is the invariant test for ERC721 general functionality.
 */
contract ApplicationERC721BasicInvariantTest is TestCommonFoundry {
    address msgSender;
    uint256 value;
    uint256 tokenId;
    address target;
    address USER1;
    address USER2;
    address USER3;
    
    function setUp() public {
        setUpProtocolAndAppManagerAndTokensWithERC721HandlerDiamond();
        switchToAppAdministrator();
        address[] memory addressList = getUniqueAddresses(block.timestamp % ADDRESSES.length, 4);
        USER1 = addressList[0];
        USER2 = addressList[1];
        USER3 = addressList[2];
        target = addressList[3];
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


    // Querying the balance of address(0) should throw
    function invariant_ERC721_external_balanceOfZeroAddressMustRevert() public virtual {
        vm.expectRevert("ERC721: address zero is not a valid owner");
        applicationNFT.balanceOf(address(0));
    }

    // Querying the owner of an invalid token should throw
    function invariant_ERC721_external_ownerOfInvalidTokenMustRevert() public virtual {
        vm.expectRevert("ERC721: invalid token ID");
        applicationNFT.ownerOf(type(uint256).max);
    }

    // Approving an invalid token should throw
    function invariant_ERC721_external_approvingInvalidTokenMustRevert() public virtual {
        vm.expectRevert("ERC721: invalid token ID");
        applicationNFT.approve(address(0), type(uint256).max);
    }

    // transferFrom a token that the caller is not approved for should revert
    function invariant_ERC721_external_transferFromNotApproved() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return;        
        if(!(target != target))return;
        if(!(target != USER1))return;
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
        bool isApproved = applicationNFT.isApprovedForAll(USER1, target);
        address approved = applicationNFT.getApproved(tokenId2);
        if(!(approved != target && !isApproved))return;
        vm.expectRevert("ERC721: Invalid token owner query should have reverted");
        applicationNFT.transferFrom(USER1, target, tokenId2);
    }

    // transferFrom should reset approval for that token
    function invariant_ERC721_external_transferFromResetApproval() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0)) return;  
        if(!(target != address(this)))return;
        if(!(target != USER1))return;
        if(!(target != address(0)))return;

        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);

        vm.startPrank(USER1);
        applicationNFT.approve(address(this), tokenId2);
        applicationNFT.transferFrom(USER1, target, tokenId2);
        
        address approved = applicationNFT.getApproved(tokenId2);
        assertTrue(approved == address(0));
    }

    // transferFrom correctly updates owner
    function invariant_ERC721_external_transferFromUpdatesOwner() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return;  
        if(!(target != address(this)))return;
        if(!(target != USER1))return;
        if(!(target != address(0)))return;
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);

        vm.startPrank(USER1);
        try applicationNFT.transferFrom(USER1, target, tokenId2) {
            assertEq(applicationNFT.ownerOf(tokenId2),target);
        } catch {
            revert ("transferFrom unexpectedly reverted");
        }
    }

    // transfer from zero address should revert
    function invariant_ERC721_external_transferFromZeroAddress() public virtual {
        try applicationNFT.ownerOf(tokenId) {
            vm.expectRevert("ERC721: caller is not token owner or approved");
            applicationNFT.transferFrom(address(0), target, tokenId);
        } catch {
            vm.expectRevert("ERC721: invalid token ID");
            applicationNFT.transferFrom(address(0), target, tokenId);
        }
    }

    // Transfers to the zero address should revert
    function invariant_ERC721_external_transferToZeroAddress() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return; 
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);

        vm.startPrank(USER1);
        vm.expectRevert("ERC721: transfer to the zero address");
        applicationNFT.transferFrom(USER1, address(0), tokenId2);

    }

    // Transfers to self should not break accounting
    function invariant_ERC721_external_transferFromSelf() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return; 
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
        vm.startPrank(USER1);

        try applicationNFT.transferFrom(USER1, USER1, tokenId2) {
            assertTrue(applicationNFT.ownerOf(tokenId2) == USER1);
            assertEq(applicationNFT.balanceOf(USER1), selfBalance);
        } catch {
            revert("transferFrom unexpectedly reverted");
        }

    }

    // Transfer to self reset approval
    function invariant_ERC721_external_transferFromSelfResetsApproval() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(USER1);
        if(!(selfBalance > 0))return; 
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(USER1, 0);
        if(!(applicationNFT.ownerOf(tokenId2) == USER1))return;

        vm.startPrank(USER1);
        applicationNFT.approve(address(this), tokenId2);

        applicationNFT.transferFrom(USER1, USER1, tokenId2);
        assertTrue(applicationNFT.getApproved(tokenId2) == address(0));
    }

}