// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/example/application/ApplicationAppManager.sol";

abstract contract TestCommonEchidna is TestCommon {
    string[] inputs = ["python3", "script/python/get_selectors.py", ""];

    /**
     * @dev Deploy and set up an AppManager
     * @return _appManager fully configured app manager
     */
    function _createAppManager() public override returns (ApplicationAppManager _appManager) {
        _appManager = new ApplicationAppManager(msg.sender, "Castlevania", false);
        return _appManager;
    }

    /**
     * @dev Deploy and set up an AppManager
     * @param _address address to be super user
     * @return _appManager fully configured app manager
     */
    function _createAppManager2(address _address) public returns (ApplicationAppManager _appManager) {
        _appManager = new ApplicationAppManager(_address, "Castlevania", false);
        return _appManager;
    }

    /**
     * @dev Deploy and set up an AppManager
     * @param _ruleProcessor rule processor
     * @return _appManager fully configured app manager
     */
    function createAppManager(RuleProcessorDiamond _ruleProcessor) public returns (ApplicationAppManager _appManager) {
        ApplicationAppManager a = _createAppManager();
        a.setNewApplicationHandlerAddress(address(_createAppHandler(_ruleProcessor, a)));
        return a;
    }
}
