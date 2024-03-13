// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageTokenMinTxSizeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract ApplicationAppManagerTest is TestCommonFoundry {

    function setUp() public {
        setUpProtocolAndAppManager();
    }

    // The Super Admin can't ever renounce their role. It must go through proposal process.
    function invariant_AlwaysASuperAdmin() public {
        assertTrue(applicationAppManager.isSuperAdmin(superAdmin));
    }

    
    
}
