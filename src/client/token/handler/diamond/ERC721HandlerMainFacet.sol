// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../common/HandlerUtils.sol";
import "../ruleContracts/HandlerBase.sol";
import "../ruleContracts/HandlerAdminMinTokenBalance.sol";
import "../ruleContracts/NFTValuationLimit.sol";
import "./ERC721TaggedRuleFacet.sol";
import "./ERC721NonTaggedRuleFacet.sol";
import "../../../application/IAppManager.sol";
import {ICommonApplicationHandlerEvents} from "../../../../common/IEvents.sol";
import {ERC165Lib} from "diamond-std/implementations/ERC165/ERC165Lib.sol";
import {IHandlerDiamondErrors} from "../../../../common/IErrors.sol";
import "diamond-std/implementations/ERC173/ERC173.sol";

contract ERC721HandlerMainFacet is HandlerBase, HandlerAdminMinTokenBalance, HandlerUtils, ICommonApplicationHandlerEvents, NFTValuationLimit, IHandlerDiamondErrors, ERC173 {

    /**
     * @dev Initializer params
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _assetAddress address of the controlling asset.
     */
    function initialize(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress) external onlyOwner{
        InitializedS storage ini = lib.initializedStorage();
        if(ini.initialized) revert AlreadyInitialized();
        HandlerBaseS storage data = lib.handlerBaseStorage();
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) 
            revert ZeroAddress();
        data.appManager = _appManagerAddress;
        data.ruleProcessor = _ruleProcessorProxyAddress;
        data.assetAddress = _assetAddress;
        lib.nftValuationLimitStorage().nftValuationLimit = 100;
        ERC165Lib.setSupportedInterface(type(IAdminMinTokenBalanceCapable).interfaceId, true);
        data.lastPossibleAction = 4;
        ini.initialized = true;
        callAnotherFacet(0xf2fde38b, abi.encodeWithSignature("transferOwnership(address)",_assetAddress));
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _tokenId id of the NFT being transferred
     * @return true if all checks pass
     */
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to,  address _sender, uint256 _tokenId) external onlyOwner returns (bool) {
        return _checkAllRules(balanceFrom, balanceTo, _from, _to, _sender, _tokenId, ActionTypes.NONE);
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the legacy entry point. This function only serves as a pass-through to the active function.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _amount number of tokens transferred
     * @param _tokenId the token's specific ID
     * @param _action Action Type defined by ApplicationHandlerLib -- (Purchase, Sell, Trade, Inquire) are the legacy options
     * @return Success equals true if all checks pass
     */
    function checkAllRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, uint256 _tokenId, ActionTypes _action) external onlyOwner returns (bool) {
        _action = ActionTypes.P2P_TRANSFER;// This hard-coded setting is for the legacy clients. When this is no longer needed, this line can be removed giving clients the option of setting their own action
        _amount;// legacy parameter
        return _checkAllRules(_balanceFrom, _balanceTo, _from, _to, address(0), _tokenId, _action);
    }

    /**
     * @dev This function contains the logic for checking all rules. It performs all the checks for the external functions.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _sender the address triggering the contract action
     * @param _tokenId id of the NFT being transferred
     * @param _action the client determined action, if NONE then the action is dynamically determined
     * @return true if all checks pass
     */
    function _checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to,  address _sender, uint256 _tokenId, ActionTypes _action) internal returns (bool) {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        
        bool isFromBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_from);
        bool isToBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_to);
        ActionTypes action;
        if (_action == ActionTypes.NONE){
            action = determineTransferAction(_from, _to, _sender);
        } else {
            action = _action;
        }
        uint256 _amount = 1; /// currently not supporting batch NFT transactions. Only single NFT transfers.
        /// standard tagged and non-tagged rules do not apply when either to or from is an admin
        if (!isFromBypassAccount && !isToBypassAccount) {
            IAppManager(handlerBaseStorage.appManager).checkApplicationRules(address(msg.sender), _from, _to, _amount, lib.nftValuationLimitStorage().nftValuationLimit, _tokenId, action, HandlerTypes.ERC721HANDLER);
            callAnotherFacet(
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
                0x9466093a, 
                abi.encodeWithSignature(
                    "checkNonTaggedRules(uint8,address,address,uint256,uint256)",
                    action,
                    _from, 
                    _to, 
                    _amount, 
                    _tokenId
                )
            );
            if (lib.tokenMinHoldTimeStorage().tokenMinHoldTime[action].active || action == ActionTypes.MINT) 
                lib.tokenMinHoldTimeStorage().ownershipStart[_tokenId] = block.timestamp;
        } else if (lib.adminMinTokenBalanceStorage().adminMinTokenBalance[action].active && isFromBypassAccount) {
                IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAdminMinTokenBalance(lib.adminMinTokenBalanceStorage().adminMinTokenBalance[action].ruleId, balanceFrom, _amount);
                emit AD1467_RulesBypassedViaRuleBypassAccount(address(msg.sender), lib.handlerBaseStorage().appManager); 
            }
        return true;
    }

    
}