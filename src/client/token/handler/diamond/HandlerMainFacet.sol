// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../common/HandlerUtils.sol";
import "../ruleContracts/HandlerBase.sol";
import "../ruleContracts/HandlerAdminMinTokenBalance.sol";
import "./TaggedRuleFacet.sol";
import "./NonTaggedRuleFacet.sol";
import "../../../application/IAppManager.sol";
import {ICommonApplicationHandlerEvents} from "../../../../common/IEvents.sol";

contract HandlerMainFacet is HandlerBase, HandlerAdminMinTokenBalance, HandlerUtils, ICommonApplicationHandlerEvents{

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
     * @param _amount number of tokens transferred
     * @return true if all checks pass
     */
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, address _sender, uint256 _amount)external returns (bool) {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        bool isFromBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_from);
        bool isToBypassAccount = IAppManager(handlerBaseStorage.appManager).isRuleBypassAccount(_to);
        ActionTypes action = determineTransferAction(_from, _to, _sender);
        // // // All transfers to treasury account are allowed
        // if (!appManager.isTreasury(_to)) {
        //     /// standard rules do not apply when either to or from is an admin
            if (!isFromBypassAccount && !isToBypassAccount) {
        //         /// appManager requires uint16 _nftValuationLimit and uin256 _tokenId for NFT pricing, 0 is passed for fungible token pricing
        //         appManager.checkApplicationRules(address(msg.sender), _from, _to, _amount,  0, 0, action, HandlerTypes.ERC20HANDLER); 
            //    _checkTaggedAndTradingRules(balanceFrom, balanceTo, _from, _to, _amount, action); => 36bd6ea7
                // gas cost: 61926
                // callAnotherFacet(
                //     0x36bd6ea7, 
                //     abi.encodeWithSignature(
                //         "checkTaggedAndTradingRules(uint256,uint256,address,address,uint256,uint8)",
                //         balanceFrom, 
                //         balanceTo, 
                //         _from, 
                //         _to, 
                //         _amount, 
                //         action
                //     )
                // );
                // // another way (gas cost: 61447): (~1.4% cheaper)
                TaggedRuleFacet(address(this)).checkTaggedAndTradingRules(balanceFrom, balanceTo, _from, _to, _amount, action);
                //     _checkNonTaggedRules(_from, _to, _amount, action);
                NonTaggedRuleFacet(address(this)).checkNonTaggedRules(_from, _to, _amount, action);
            } else if (lib.adminMinTokenBalanceStorage().adminMinTokenBalance[action].active && isFromBypassAccount) {
                IRuleProcessor(lib.handlerBaseStorage().ruleProcessor).checkAdminMinTokenBalance(lib.adminMinTokenBalanceStorage().adminMinTokenBalance[action].ruleId, balanceFrom, _amount);
                emit RulesBypassedViaRuleBypassAccount(address(msg.sender), lib.handlerBaseStorage().appManager); 
            }
            
       // }
        /// If all rule checks pass, return true
       
        return true;
    }

    

    
}