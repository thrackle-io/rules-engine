// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonEchidna.sol";

contract TestAppManager is TestCommonEchidna {
    constructor() public {
        applicationAppManager = _createAppManager(address(this));
    }

    function echidna_versionNotBlank() public returns (bool) {
        if (bytes(applicationAppManager.version()).length != 0) return true;
        return false;
    }

    function echidna_superAdminNotLost() public returns (bool) {
        if (applicationAppManager.isSuperAdmin(address(this))) return true;
        return false;
    }

    function echidna_appAdminNotLost() public returns (bool) {
        if (applicationAppManager.isAppAdministrator(address(this))) return true;
        return false;
    }

    function echidna_appAdminNotZero() public returns(bool){
        if (!applicationAppManager.isAppAdministrator(address(0))) return true;
        return false;
    }

    function echidna_riskAdminNotZero() public returns(bool){
        if (!applicationAppManager.isRiskAdmin(address(0))) return true;
        return false;
    }

    function echidna_accessLevelAdminNotZero() public returns(bool){
        if (!applicationAppManager.isAccessTier(address(0))) return true;
        return false;
    }


    function echidna_ruleAdminNotZero() public returns(bool){
        if (!applicationAppManager.isRuleAdministrator(address(0))) return true;
        return false;
    }

    function echidna_zeroAddressNoAccessLevel() public returns(bool){
        if (applicationAppManager.getAccessLevel(address(0))==0) return true;
        return false;
    }

    function echidna_zeroAddressNoRiskScore() public returns(bool){
        if (applicationAppManager.getRiskScore(address(0))==0) return true;
        return false;
    }


    function echidna_zeroAddressNoGeneralTags() public returns(bool){
        if (applicationAppManager.getAllTags(address(0)).length==0) return true;
        return false;
    }

    function echidna_zeroAddressNoTreasury() public returns(bool){
        if (!applicationAppManager.isTreasury(address(0)))return true;
        return false;
    }

   

    /* ------------ Provider Addresses -------------------*/

    function echidna_generalTagProviderNotZero() public returns(bool){
        if (applicationAppManager.getGeneralTagProvider()!=address(0))return true;
        return false;
    }

    function echidna_accessLevelProviderNotZero() public returns(bool){
        if (applicationAppManager.getAccessLevelProvider()!=address(0))return true;
        return false;
    }

    function echidna_riskScoreProviderNotZero() public returns(bool){
        if (applicationAppManager.getRiskScoresProvider()!=address(0))return true;
        return false;
    }

    function echidna_accountsProviderNotZero() public returns(bool){
        if (applicationAppManager.getAccountProvider()!=address(0))return true;
        return false;
    }

    function echidna_pauseRulesProviderNotZero() public returns(bool){
        if (applicationAppManager.getPauseRulesProvider()!=address(0))return true;
        return false;
    }



   

}
