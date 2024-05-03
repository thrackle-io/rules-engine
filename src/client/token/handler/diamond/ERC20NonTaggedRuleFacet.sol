// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./FacetsCommonImports.sol";
import "../common/AppAdministratorOrOwnerOnlyDiamondVersion.sol";
import "./RuleStorage.sol";
import "../../ITokenInterface.sol";
import "../ruleContracts/HandlerAccountApproveDenyOracle.sol";
import "../ruleContracts/HandlerTokenMaxSupplyVolatility.sol";
import "../ruleContracts/HandlerTokenMaxTradingVolume.sol";
import "../ruleContracts/HandlerTokenMinTxSize.sol";

contract ERC20NonTaggedRuleFacet is AppAdministratorOrOwnerOnlyDiamondVersion, HandlerAccountApproveDenyOracle, HandlerTokenMaxSupplyVolatility, HandlerTokenMaxTradingVolume, HandlerTokenMinTxSize {
    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     */
    function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external onlyOwner {
        HandlerBaseS storage handlerBaseStorage = lib.handlerBaseStorage();
        address handlerBase = handlerBaseStorage.ruleProcessor; 
        if (lib.tokenMinTxSizeStorage().tokenMinTxSize[action].active) {
            _checkTokenMinTxSizeRule(_amount, action, handlerBase);
        }
        _checkAccountApproveDenyOraclesRule(_from, _to, action, handlerBase);
        if (lib.tokenMaxTradingVolumeStorage().tokenMaxTradingVolume[action]) {
            _checkTokenMaxTradingVolumeRule(_amount, handlerBase);
        }
        if (lib.tokenMaxSupplyVolatilityStorage().tokenMaxSupplyVolatility[action] && (_from == address(0x00) || _to == address(0x00))) {
            _checkTokenMaxSupplyVolatilityRule(_to, _amount,handlerBase);
        }
    }

    /**
     * @dev Internal function to check the Token Min Transaction Size rule 
     * @param _amount number of tokens transferred
     * @param action if selling or buying (of ActionTypes type)
     * @param handlerBase address of the handler proxy
     */
    function _checkTokenMinTxSizeRule(uint256 _amount, ActionTypes action, address handlerBase) internal view {
        IRuleProcessor(handlerBase).checkTokenMinTxSize(lib.tokenMinTxSizeStorage().tokenMinTxSize[action].ruleId, _amount);
    }

    /**
     * @dev Internal function to check the Account Approve Deny Oracle Rules 
     * @param _from address of the from account
     * @param _to address of the to account
     * @param action if selling or buying (of ActionTypes type)
     * @param handlerBase address of the handler proxy
     */
    function _checkAccountApproveDenyOraclesRule(address _from, address _to, ActionTypes action, address handlerBase) internal view {
        mapping(ActionTypes => Rule[]) storage accountApproveDenyOracle = lib.accountApproveDenyOracleStorage().accountApproveDenyOracle;
        /// The action type determines if the _to or _from is checked by the oracle
        /// _from address is checked for Burn and Sell action types
        if (action == ActionTypes.BURN || action == ActionTypes.SELL){
            IRuleProcessor(handlerBase).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _from);
        } 
        /// _to address is checked  for Mint, Buy, Transfer actions 
        if (action == ActionTypes.MINT || action == ActionTypes.BUY || action == ActionTypes.P2P_TRANSFER){
            IRuleProcessor(handlerBase).checkAccountApproveDenyOracles(accountApproveDenyOracle[action], _to);
        }
    }

    /**
     * @dev Internal function to check the Token Max Trading Volume rule 
     * @param _amount number of tokens transferred
     * @param handlerBase address of the handler proxy
     */
    function _checkTokenMaxTradingVolumeRule(uint256 _amount, address handlerBase) internal {
        TokenMaxTradingVolumeS storage maxTradingVolume = lib.tokenMaxTradingVolumeStorage();
        maxTradingVolume.transferVolume = IRuleProcessor(handlerBase).checkTokenMaxTradingVolume(
            maxTradingVolume.ruleId,
            maxTradingVolume.transferVolume,
            IToken(msg.sender).totalSupply(),
            _amount,
            maxTradingVolume.lastTransferTime
        );
        maxTradingVolume.lastTransferTime = uint64(block.timestamp);
    }

    /**
     * @dev Internal function to check the Token Max Supply Volatility rule 
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param handlerBase address of the handler proxy
     */
    function _checkTokenMaxSupplyVolatilityRule(address _to, uint256 _amount, address handlerBase) internal {
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        TokenMaxSupplyVolatilityS storage maxSupplyVolatility = lib.tokenMaxSupplyVolatilityStorage();
        (maxSupplyVolatility.volumeTotalForPeriod, maxSupplyVolatility.totalSupplyForPeriod) = IRuleProcessor(handlerBase).checkTokenMaxSupplyVolatility(
            maxSupplyVolatility.ruleId,
            maxSupplyVolatility.volumeTotalForPeriod,
            maxSupplyVolatility.totalSupplyForPeriod,
            IToken(msg.sender).totalSupply(),
            _to == address(0x00) ? int(_amount) * -1 : int(_amount),
            maxSupplyVolatility.lastSupplyUpdateTime
        );
        maxSupplyVolatility.lastSupplyUpdateTime = uint64(block.timestamp);
    }
}
