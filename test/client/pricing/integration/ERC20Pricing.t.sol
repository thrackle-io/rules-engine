// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";

/**
 * @title Test For The ERC20 Pricing Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests setting a price for an ERC20 token
 * @notice It simulates an on chain price source.
 */
contract ERC20PricingTest is TestCommonFoundry {

    function setUp() public {
        setUpProtocolAndAppManagerAndPricingAndTokens();

    }

    function testPricing_ERC20Pricing_PricerVersion() public view {
        string memory version = uniBase.version();
        assertEq(version, "1.3.0");
    }

    /// Testing setting the price for a single token under the right conditions
    function testPricing_ERC20Pricing_SettingSingleTokenPrice_Positive() public {
        uniBase.setSingleTokenPrice(address(boredCoin), 5000 * (10 ** 18));
        assertEq(uniBase.getTokenPrice(address(boredCoin)), 5000 * (10 ** 18));
        uniBase.setSingleTokenPrice(address(reptileToken), 666 * (10 ** 16));
        assertEq(uniBase.getTokenPrice(address(reptileToken)), 666 * (10 ** 16));
    }

    /// Testing that the pricing contract won't allow price setting to anyone but the owner
    function testPricing_ERC20Pricing_SettingSingleTokenPrice_Negative() public {
        switchToUser(); 
        vm.expectRevert("Ownable: caller is not the owner"); 
        uniBase.setSingleTokenPrice(address(boredCoin), 5000 * (10 ** 18));
    }


}
