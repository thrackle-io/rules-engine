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

contract ERC721HandlerMainFacet is HandlerBase, HandlerAdminMinTokenBalance, HandlerUtils, ICommonApplicationHandlerEvents, NFTValuationLimit{

    /**
     * @dev Constructor sets params
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _assetAddress address of the controlling asset.
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    function initialize(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode) external {
        HandlerBaseS storage data = lib.handlerBaseStorage();
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) 
            revert ZeroAddress();
        data.appManager = _appManagerAddress;
        data.ruleProcessor = _ruleProcessorProxyAddress;
        lib.nftValuationLimitStorage().nftValuationLimit = 100;
        // transferOwnership(_assetAddress);
        // if (!_upgradeMode) {
        //     deployDataContract();
        //     emit HandlerDeployed(_appManagerAddress);
        // } else {
        //     emit HandlerDeployed(_appManagerAddress);
        // }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    // function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
    //     return interfaceId == type(IAdminMinTokenBalanceCapable).interfaceId || super.supportsInterface(interfaceId);
    // }

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
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to,  address _sender, uint256 _tokenId) external returns (bool) {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        
        bool isFromBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_from);
        bool isToBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_to);
        ActionTypes action = determineTransferAction(_from, _to, _sender);
        uint256 _amount = 1; /// currently not supporting batch NFT transactions. Only single NFT transfers.
        /// standard tagged and non-tagged rules do not apply when either to or from is an admin
        if (!isFromBypassAccount && !isToBypassAccount) {
            IAppManager(handlerBaseStorage.appManager).checkApplicationRules(address(msg.sender), _from, _to, _amount, lib.nftValuationLimitStorage().nftValuationLimit, _tokenId, action, HandlerTypes.ERC721HANDLER);
            // _checkTaggedAndTradingRules(balanceFrom, balanceTo, _from, _to, _amount, action);
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
            // _checkNonTaggedRules(action, _from, _to, _amount, _tokenId);
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
            // _checkSimpleRules(action, _tokenId); // done in NonTaggedRules
            /// set the ownership start time for the token if the Minimum Hold time rule is active or action is mint
            if (lib.tokenMinHoldTimeStorage().tokenMinHoldTime[action].active || action == ActionTypes.MINT) 
                lib.tokenMinHoldTimeStorage().ownershipStart[_tokenId] = block.timestamp;
        } else if (lib.adminMinTokenBalanceStorage().adminMinTokenBalance[action].active && isFromBypassAccount) {
                IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAdminMinTokenBalance(lib.adminMinTokenBalanceStorage().adminMinTokenBalance[action].ruleId, balanceFrom, _tokenId);
                emit RulesBypassedViaRuleBypassAccount(address(msg.sender), lib.handlerBaseStorage().appManager); 
            }
        /// If all rule checks pass, return true
        return true;
    }
    
}