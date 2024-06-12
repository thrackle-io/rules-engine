// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/client/token/handler/common/HandlerUtils.sol";
import "src/client/token/handler/ruleContracts/HandlerBase.sol";
import "src/client/token/handler/diamond/ERC20TaggedRuleFacet.sol";
import "src/client/token/handler/diamond/ERC20NonTaggedRuleFacet.sol";
import "src/client/token/handler/diamond/TradingRuleFacet.sol";
import {ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import {ERC165Lib} from "diamond-std/implementations/ERC165/ERC165Lib.sol";
import {IHandlerDiamondErrors} from "src/common/IErrors.sol";

contract ERC20HandlerMainFacet is HandlerBase, HandlerUtils, ICommonApplicationHandlerEvents, IHandlerDiamondErrors {

    /**
     * @dev Initializer params
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _assetAddress address of the controlling asset.
     */
    function initialize(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress) external onlyOwner {
        InitializedS storage init = lib.initializedStorage();
        if(init.initialized) revert AlreadyInitialized();
        HandlerBaseS storage data = lib.handlerBaseStorage();
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) 
            revert ZeroAddress();
        data.appManager = _appManagerAddress;
        data.ruleProcessor = _ruleProcessorProxyAddress;
        data.assetAddress = _assetAddress;
        data.lastPossibleAction = 5;
        init.initialized = true;
        // function selector is (transferOwnership(address))
        callAnotherFacet(0xf2fde38b, abi.encodeWithSignature("transferOwnership(address)",_assetAddress));
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point.
     * @notice This function is called without passing in an action type. 
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _amount number of tokens transferred
     * @return true if all checks pass
     */
    function checkAllRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, address _sender, uint256 _amount) external onlyOwner returns (bool) {
        return _checkAllRules(_balanceFrom, _balanceTo, _from, _to, _sender, _amount, ActionTypes.NONE);
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _amount number of tokens transferred
     * @param _action Action Type 
     * @return true if all checks pass
     */
    function checkAllRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, address _sender, uint256 _amount, ActionTypes _action) external onlyOwner returns (bool) {
        return _checkAllRules(_balanceFrom, _balanceTo, _from, _to, _sender, _amount, _action);
    }

    /**
     * @dev This function contains the logic for checking all rules. It performs all the checks for the external functions.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _amount number of tokens transferred
     * @param _action Action Type 
     * @return true if all checks pass
     */
    function _checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, address _sender, uint256 _amount, ActionTypes _action) internal returns (bool) {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        bool isFromTreasuryAccount = IAppManager(handlerBaseStorage.appManager).isTreasuryAccount(_from);
        bool isToTreasuryAccount = IAppManager(handlerBaseStorage.appManager).isTreasuryAccount(_to);
        ActionTypes action;
        if (_action == ActionTypes.NONE){
            action = determineTransferAction(_from, _to, _sender);
        } else {
            action = _action;
        }
        /// standard rules do not apply when either to or from is a treasury account
        if (!isFromTreasuryAccount && !isToTreasuryAccount) {
            IAppManager(handlerBaseStorage.appManager).checkApplicationRules(address(msg.sender), _sender, _from, _to, _amount,  0, 0, action, HandlerTypes.ERC20HANDLER); 
            callAnotherFacet(
                // function selector is for checkTaggedAndTradingRules(uint256,uint256,address,address,uint256,uint8)
                0x36bd6ea7, 
                abi.encodeWithSignature(
                    "checkTaggedAndTradingRules(uint256,uint256,address,address,uint256,uint8)",
                    balanceFrom, 
                    balanceTo, 
                    _from, 
                    _to, 
                    _amount, 
                    action
                )
            );
            callAnotherFacet(
                // function selector is for checkNonTaggedRules(address,address,uint256,uint8)
                0x6f43d91d, 
                abi.encodeWithSignature(
                    "checkNonTaggedRules(address,address,uint256,uint8)",
                    _from, 
                    _to, 
                    _amount, 
                    action
                )
            );
        } else if (isFromTreasuryAccount || isToTreasuryAccount) {
            emit AD1467_RulesBypassedViaTreasuryAccount(address(msg.sender), lib.handlerBaseStorage().appManager); 
        }
        return true;
    }

    /**
     * @dev This function returns the configured application manager's address.
     * @return appManagerAddress address of the connected application manager
     */
    function getAppManagerAddress() external view returns(address){
        return address(lib.handlerBaseStorage().appManager);
    }
}