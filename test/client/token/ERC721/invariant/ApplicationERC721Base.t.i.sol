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
        targetSender(appAdministrator);
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
        uint256 selfBalance = applicationNFT.balanceOf(msg.sender);
        if(!(selfBalance > 0))return;        
        if(!(target != address(this)))return;
        if(!(target != msg.sender))return;
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(msg.sender, 0);
        bool isApproved = applicationNFT.isApprovedForAll(msg.sender, address(this));
        address approved = applicationNFT.getApproved(tokenId2);
        if(!(approved != address(this) && !isApproved))return;
        vm.expectRevert("ERC721: Invalid token owner query should have reverted");
        applicationNFT.transferFrom(msg.sender, target, tokenId2);
    }

    // transferFrom should reset approval for that token
    function invariant_ERC721_external_transferFromResetApproval() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(msg.sender);
        if(!(selfBalance > 0)) return;  
        if(!(target != address(this)))return;
        if(!(target != msg.sender))return;
        if(!(target != address(0)))return;

        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(msg.sender, 0);

        vm.startPrank(msg.sender);
        applicationNFT.approve(address(this), tokenId2);
        applicationNFT.transferFrom(msg.sender, target, tokenId2);
        
        address approved = applicationNFT.getApproved(tokenId2);
        assertTrue(approved == address(0));
    }

    // transferFrom correctly updates owner
    function invariant_ERC721_external_transferFromUpdatesOwner() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(msg.sender);
        if(!(selfBalance > 0))return;  
        if(!(target != address(this)))return;
        if(!(target != msg.sender))return;
        if(!(target != address(0)))return;
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(msg.sender, 0);

        vm.startPrank(msg.sender);
        try applicationNFT.transferFrom(msg.sender, target, tokenId2) {
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
        uint256 selfBalance = applicationNFT.balanceOf(msg.sender);
        if(!(selfBalance > 0))return; 
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(msg.sender, 0);

        vm.startPrank(msg.sender);
        vm.expectRevert("ERC721: Invalid token owner query should have reverted");
        applicationNFT.transferFrom(msg.sender, address(0), tokenId2);

    }

    // Transfers to self should not break accounting
    function invariant_ERC721_external_transferFromSelf() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(msg.sender);
        if(!(selfBalance > 0))return; 
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(msg.sender, 0);
        vm.startPrank(msg.sender);

        try applicationNFT.transferFrom(msg.sender, msg.sender, tokenId2) {
            assertTrue(applicationNFT.ownerOf(tokenId2) == msg.sender);
            assertEq(applicationNFT.balanceOf(msg.sender), selfBalance);
        } catch {
            revert("transferFrom unexpectedly reverted");
        }

    }

    // Transfer to self reset approval
    function invariant_ERC721_external_transferFromSelfResetsApproval() public virtual {
        uint256 selfBalance = applicationNFT.balanceOf(msg.sender);
        if(!(selfBalance > 0))return; 
        uint tokenId2 = applicationNFT.tokenOfOwnerByIndex(msg.sender, 0);
        if(!(applicationNFT.ownerOf(tokenId2) == msg.sender))return;

        vm.startPrank(msg.sender);
        applicationNFT.approve(address(this), tokenId2);

        applicationNFT.transferFrom(msg.sender, msg.sender, tokenId2);
        assertTrue(applicationNFT.getApproved(tokenId2) == address(0));
    }

}