// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "../data/Fees.sol";
import {IZeroAddressError, IAssetHandlerErrors} from "../../interfaces/IErrors.sol";
import "../ProtocolHandlerCommon.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title Example ApplicationERC1155Handler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC1155 that implements it.
 * @notice Any rules may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.
 */
contract ProtocolERC1155Handler is Ownable, ProtocolHandlerCommon, AppAdministratorOnly, RuleAdministratorOnly, ERC165 {
    using ERC165Checker for address;

    /// Contract level RuleIds
    uint32 private minTransferRuleId;

    /// on-off switches for rules
    bool private minTransferRuleActive;

    /// Token level RuleIds
    mapping(uint256 tokenId => uint32 ruleId) tokenIdToMinTransferRuleId;
    mapping(uint256 tokenId => bool active) isTokenMinTransferRuleActive;

    /**
     * @dev Constructor sets params
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _assetAddress address of the controlling asset.
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode) {
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        transferOwnership(_assetAddress);
        if (!_upgradeMode) {
            emit HandlerDeployed(address(this), _appManagerAddress);
        } else {
            emit HandlerDeployed(address(this), _appManagerAddress);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IAdminWithdrawalRuleCapable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _ids tokenIds being transferred
     * @param _amounts number of each token being transferred
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return true if all checks pass
     */
    function checkAllRules(
        uint256[] memory balanceFrom,
        uint256[] memory balanceTo,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        ActionTypes _action
    ) external onlyOwner returns (bool) {
        bool isFromAdmin = appManager.isAppAdministrator(_from);
        bool isToAdmin = appManager.isAppAdministrator(_to);
        // // All transfers to treasury account are allowed
        if (!appManager.isTreasury(_to)) {
            /// standard rules do not apply when either to or from is an admin
            if (!isFromAdmin && !isToAdmin) {
                uint128 balanceValuation;
                uint128 price;
                uint128 transferValuation;
                if (appManager.requireValuations()) {
                    uint256 amount;
                    // add up all the amounts and balances
                    for (uint i = 0; i < _amounts.length; ) {
                        amount += _amounts[i];
                        unchecked {
                            i++;
                        }
                    }
                    balanceValuation = uint128(getAccTotalValuation(_to, 0));
                    price = uint128(_getERC20Price(msg.sender));
                    transferValuation = uint128((price * amount) / (10 ** IToken(msg.sender).decimals()));
                }
                appManager.checkApplicationRules(_action, _from, _to, balanceValuation, transferValuation);
                checkContractLevelRules(balanceFrom, balanceTo, _from, _to, _ids, _amounts, _action);
                checkTokenLevelRules(balanceFrom, balanceTo, _from, _to, _ids, _amounts, _action);
            }
        }
        /// If all rule checks pass, return true
        return true;
    }

    /**
     * @dev This function checks only the contract level rules. It adds amounts and deals with the tokens like they are all the same.
     * @param _balanceFrom token balances of sender address
     * @param _balanceTo token balances of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _ids tokenIds being transferred
     * @param _amounts number of each token being transferred
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return _return true if all checks pass
     */
    function checkContractLevelRules(
        uint256[] memory _balanceFrom,
        uint256[] memory _balanceTo,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        ActionTypes _action
    ) internal view returns (bool _return) {
        _action;
        _ids;
        uint256 amount;
        uint256 balanceFrom;
        uint256 balanceTo;
        // add up all the amounts and balances
        for (uint i = 0; i < _amounts.length; ) {
            amount += _amounts[i];
            balanceFrom += _balanceFrom[i];
            balanceTo += _balanceTo[i];
            unchecked {
                i++;
            }
        }
        _checkTaggedRules(balanceFrom, balanceTo, _from, _to, amount);
        _checkNonTaggedRules(_from, _to, amount);
        return true;
    }

    /**
     * @dev This function checks only the token level rules. It loops through each token and amount and deals with each token like a separate transfer.
     * @param _balanceFrom token balances of sender address
     * @param _balanceTo token balances of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param _ids tokenIds being transferred
     * @param _amounts number of each token being transferred
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return _return true if all checks pass
     */
    function checkTokenLevelRules(
        uint256[] memory _balanceFrom,
        uint256[] memory _balanceTo,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        ActionTypes _action
    ) internal returns (bool _return) {
        _action;
        // add up all the amounts and balances
        for (uint i = 0; i < _amounts.length; ) {
            if (_amounts[i] != 0) {
                _checkTokenTaggedRules(_ids[i], _balanceFrom[i], _balanceTo[i], _from, _to, _amounts[i]);
                _checkTokenNonTaggedRules(_ids[i], _from, _to, _amounts[i]);
            }

            unchecked {
                i++;
            }
        }
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
     * @param _tokenId token id being checked
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkTokenTaggedRules(uint256 _tokenId, uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount) internal {}

    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _tokenId token id being checked
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkTokenNonTaggedRules(uint256 _tokenId, address _from, address _to, uint256 _amount) internal view {
        _from;
        _to;
        if (isTokenMinTransferRuleActive[_tokenId]) ruleProcessor.checkMinTransferPasses(tokenIdToMinTransferRuleId[_tokenId], _amount);
    }

    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkNonTaggedRules(address _from, address _to, uint256 _amount) internal view {
        _from;
        _to;
        if (minTransferRuleActive) ruleProcessor.checkMinTransferPasses(minTransferRuleId, _amount);
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount) internal view {
        _checkTaggedIndividualRules(_from, _to, _balanceFrom, _balanceTo, _amount);
    }

    /**
     * @dev This function consolidates all the tagged rules that utilize account tags.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkTaggedIndividualRules(address _from, address _to, uint256 _balanceFrom, uint256 _balanceTo, uint256 _amount) internal view {}

    /**
     * @dev Set the minTransferRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinTransferRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinTransfer(_ruleId);
        minTransferRuleId = _ruleId;
        minTransferRuleActive = true;
        emit ApplicationHandlerApplied(MIN_TRANSFER, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransferRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minTransferRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_TRANSFER, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MIN_TRANSFER, address(this));
        }
    }

    /**
     * @dev Retrieve the minTransferRuleId
     * @return minTransferRuleId
     */
    function getMinTransferRuleId() external view returns (uint32) {
        return minTransferRuleId;
    }

    /**
     * @dev Tells you if the MinTransferRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinTransferActive() external view returns (bool) {
        return minTransferRuleActive;
    }

    /**------------------- TOKEN LEVEL RULES ------------------ */
    /**
     * @dev Set the minTransferRuleId for a specific tokenId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _tokenId token Id for which the rule applies
     * @param _ruleId Rule Id to set
     */
    function setTokenMinTransferRuleId(uint256 _tokenId, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        tokenIdToMinTransferRuleId[_tokenId] = _ruleId;
        isTokenMinTransferRuleActive[_tokenId] = true;
        emit ApplicationHandlerTokenApplied(MIN_TRANSFER, address(this), _tokenId, _ruleId);
    }

    /**
     * @dev Retrieve the minTransferRuleId for a specific tokenId
     * @param _tokenId token Id for which the rule applies
     * @return minTransferRuleId
     */
    function getTokenMinTransferRuleId(uint256 _tokenId) external view returns (uint32) {
        return tokenIdToMinTransferRuleId[_tokenId];
    }

    /**
     * @dev Tells you if the token's MinTransferRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinTransferActive(uint256 _tokenId) external view returns (bool) {
        return isTokenMinTransferRuleActive[_tokenId];
    }

    /**
     * @dev enable/disable rule for a specific token. Disabling a rule will save gas on transfer transactions.
     * @param _tokenId token Id for which the rule applies
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTokenMinTransferRule(uint256 _tokenId, bool _on) external ruleAdministratorOnly(appManagerAddress) {
        isTokenMinTransferRuleActive[_tokenId] = _on;
        if (_on) {
            emit ApplicationHandlerTokenActivated(MIN_TRANSFER, _tokenId, address(this));
        } else {
            emit ApplicationHandlerTokenDeactivated(MIN_TRANSFER, _tokenId, address(this));
        }
    }
}
