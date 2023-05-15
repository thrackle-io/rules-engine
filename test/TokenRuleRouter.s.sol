// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
/**
 * @title EconActionTest
 * @author @oscarsernarosero @ShaneDuncan602
 * @dev this contract tests the whole Economic submodule.
 * It simulates the input from a token contract
 */

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "./TaggedRuleProcessorDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import "../src/application/AppManager.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import {TokenRuleRouter} from "../src/economic/TokenRuleRouter.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules, IFeeRules as Fee} from "../src/economic/ruleStorage/RuleDataInterfaces.sol";
import {FeeRuleDataFacet} from "../src/economic/ruleStorage/FeeRuleDataFacet.sol";
import {SampleFacet} from "../src/diamond/core/test/SampleFacet.sol";
import {ERC173Facet} from "../src/diamond/implementations/ERC173/ERC173Facet.sol";
import {RuleDataFacet as Facet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";

contract TokenRuleRouterTest is Test, RuleProcessorDiamondTestUtil, TaggedRuleProcessorDiamondTestUtil {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    AppManager public appManager;
    address defaultAdmin = address(0xAD);
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address appAdminstrator = address(0xDEAD);
    address ac;
    address[] badBoys;
    address[] goodBoys;

    RuleProcessorDiamond tokenRuleProcessorsDiamond;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    TokenRuleRouter tokenRuleRouter;
    RuleStorageDiamond ruleStorageDiamond;
    TokenRuleRouterProxy ruleRouterProxy;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the rule processor diamonds
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        taggedRuleProcessorDiamond = getTaggedRuleProcessorDiamond();
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // Deploy app manager
        appManager = new AppManager(defaultAdmin, "Castlevania", false);
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdminstrator);
        ac = address(appManager);
        // deploy the TokenRuleRouter
        tokenRuleRouter = new TokenRuleRouter();
        //deploy and initialize Proxy to TokenRuleRouter
        ruleRouterProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        TokenRuleRouter(address(ruleRouterProxy)).initialize(payable(address(tokenRuleProcessorsDiamond)), payable(address(taggedRuleProcessorDiamond)));

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }

    function testAddMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 1000);
        assertEq(RuleDataFacet(address(ruleStorageDiamond)).getMinimumTransferRule(index), 1000);
    }

    function testFailAddMinTransferRuleByNonAdmin() public {
        vm.stopPrank();
        vm.startPrank(address(0xDEADA55));
        RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 1000);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
    }

    function testMinTransfer() public {
        // add the rule.
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 10);
        assertEq(RuleDataFacet(address(ruleStorageDiamond)).getMinimumTransferRule(ruleId), 10);
        // test that the minimum works
        TokenRuleRouter(address(ruleRouterProxy)).checkMinTransferPasses(ruleId, 15);
        // test that the minimum fails when it should
        vm.expectRevert(0x70311aa2);
        TokenRuleRouter(address(ruleRouterProxy)).checkMinTransferPasses(ruleId, 5);
    }

    function testMinMaxAccountBalancePasses() public {
        bytes32[] memory _accountTypes = new bytes32[](1);
        uint256[] memory _minimum = new uint256[](1);
        uint256[] memory _maximum = new uint256[](1);

        // Set the rule data
        _accountTypes[0] = "BALLER";
        _minimum[0] = 10;
        _maximum[0] = 1000;
        // add the rule.
        uint32 index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, _accountTypes, _minimum, _maximum);

        // test that them minimum works
        TokenRuleRouter(address(ruleRouterProxy)).checkMinMaxAccountBalancePasses(index, 20, 0, 10, _accountTypes, _accountTypes);
        // test that them maximum works
        TokenRuleRouter(address(ruleRouterProxy)).checkMinMaxAccountBalancePasses(index, 1000, 0, 500, _accountTypes, _accountTypes);
    }

    function testNotPassMinMaxAccountBalance() public {
        bytes32[] memory _accountTypes = new bytes32[](1);
        uint256[] memory _minimum = new uint256[](1);
        uint256[] memory _maximum = new uint256[](1);

        // Set the rule data
        _accountTypes[0] = "BALLER";
        _minimum[0] = 10;
        _maximum[0] = 1000;
        // add the rule.
        uint32 index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, _accountTypes, _minimum, _maximum);

        // test that them minimum won't allow balance below threshold
        vm.expectRevert(0xf1737570);
        TokenRuleRouter(address(ruleRouterProxy)).checkMinMaxAccountBalancePasses(index, 15, 0, 10, _accountTypes, _accountTypes);
        // test that the maximum won't allow balance above threshold
        vm.expectRevert(0x24691f6b);
        TokenRuleRouter(address(ruleRouterProxy)).checkMinMaxAccountBalancePasses(index, 1000, 999, 2, _accountTypes, _accountTypes);
    }

    function testOracle() public {
        // add the rule.
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blacklist address
        badBoys.push(address(69));
        oracleRestricted.addToSanctionsList(badBoys);
        // test that the oracle works
        // This one should pass
        TokenRuleRouter(address(ruleRouterProxy)).checkOraclePasses(_index, address(79));
        // This one should fail
        vm.expectRevert();
        tokenRuleRouter.checkOraclePasses(_index, address(69));

        // check the allowed list type
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 1, address(oracleAllowed));
        // add an allowed address
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        // This one should pass
        TokenRuleRouter(address(ruleRouterProxy)).checkOraclePasses(_index, address(59));
        // This one should fail
        vm.expectRevert();
        TokenRuleRouter(address(ruleRouterProxy)).checkOraclePasses(_index, address(88));

        // Finally, check the invalid type
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(ac, 2, address(oracleAllowed));
        vm.expectRevert();
        TokenRuleRouter(address(ruleRouterProxy)).checkOraclePasses(_index, address(88));
    }

    function testNftCounter() public {
        // add the rule.
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed);
        assertEq(_index, 0);
        bytes32[] memory nftTags2 = new bytes32[](3);
        nftTags2[0] = bytes32("BoredGrape");
        NonTaggedRules.NFTTradeCounterRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        vm.warp(1666706998); // set block.timestamp to an arbitrary date/time
        console.logUint(block.timestamp);

        uint64 timeLastTraded = uint64(block.timestamp - 1 hours);
        console.logUint(timeLastTraded);
        // Test for the first tag's rule
        // this one should pass
        TokenRuleRouter(address(ruleRouterProxy)).checkNFTTransferCounter(_index, 0, nftTags2, timeLastTraded);
        // this one should fail for too many transfers
        vm.expectRevert(0x00b223e3);
        TokenRuleRouter(address(ruleRouterProxy)).checkNFTTransferCounter(_index, 1, nftTags2, timeLastTraded);
        // Test for the second tag's rule
        nftTags2[0] = bytes32("DiscoPunk");
        // this one should pass
        TokenRuleRouter(address(ruleRouterProxy)).checkNFTTransferCounter(_index, 3, nftTags2, timeLastTraded);
        // this one should fail for too many transfers
        vm.expectRevert(0x00b223e3);
        TokenRuleRouter(address(ruleRouterProxy)).checkNFTTransferCounter(_index, 5, nftTags2, timeLastTraded);
        // Test for an NFT that has been tagged multiple times(including one without a rule attached) This should
        // use the most restrictive tag rule
        nftTags2[0] = bytes32("BoredGrape");
        nftTags2[1] = bytes32("DiscoPunk");
        nftTags2[2] = bytes32("noRule");
        // this one should pass
        TokenRuleRouter(address(ruleRouterProxy)).checkNFTTransferCounter(_index, 0, nftTags2, timeLastTraded);
        // // this one should fail for too many transfers
        vm.expectRevert(0x00b223e3);
        TokenRuleRouter(address(ruleRouterProxy)).checkNFTTransferCounter(_index, 1, nftTags2, timeLastTraded);
    }

    function testAddAMMFeeRule() public {
        uint32 index = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(ac, 300);
        Fee.AMMFeeRule memory rule = FeeRuleDataFacet(address(ruleStorageDiamond)).getAMMFeeRule(index);
        assertEq(rule.feePercentage, 300);
    }

    function testAMMFeeRule() public {
        uint32 index = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(ac, 300);
        Fee.AMMFeeRule memory rule = FeeRuleDataFacet(address(ruleStorageDiamond)).getAMMFeeRule(index);
        assertEq(rule.feePercentage, 300);
        assertEq(TokenRuleRouter(address(ruleRouterProxy)).assessAMMFee(index, 100 * (10 ** 18)), 3 * (10 ** 18));
    }

    function testOwnerFunctions() public {
        // Test Diamond Address Setters
        TokenRuleRouter(address(ruleRouterProxy)).setRuleProcessorDiamondAddress(payable(address(tokenRuleProcessorsDiamond)));
        TokenRuleRouter(address(ruleRouterProxy)).setTaggedRuleProcessorDiamondAddress(payable(address(taggedRuleProcessorDiamond)));
        // Test setting new implementation address
        console.log(ruleRouterProxy.owner());
        ruleRouterProxy.getAdmin();
        // admin calls newImplementationAddr
        ruleRouterProxy.newImplementationAddr(address(tokenRuleRouter));

        // attempt to call newImplementationAddr as non admin
        vm.stopPrank();
        vm.startPrank(appAdminstrator);

        vm.expectRevert("Ownable: caller is not the owner");
        ruleRouterProxy.newImplementationAddr(address(tokenRuleRouter));
    }
}
