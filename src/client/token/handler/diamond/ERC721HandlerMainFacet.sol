// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        
        bool isFromBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_from);
        bool isToBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_to);
        ActionTypes action = determineTransferAction(_from, _to, _sender);
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
                IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAdminMinTokenBalance(lib.adminMinTokenBalanceStorage().adminMinTokenBalance[action].ruleId, balanceFrom, _tokenId);
                emit RulesBypassedViaRuleBypassAccount(address(msg.sender), lib.handlerBaseStorage().appManager); 
            }
        return true;
    }
    
}