// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAssetHandlerErrors, IOwnershipErrors, IZeroAddressError} from "src/common/IErrors.sol";
import {ITokenHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import "src/protocol/economic/ruleProcessor/RuleCodeData.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "src/client/application/IAppManager.sol";
import "src/protocol/economic/AppAdministratorOrOwnerOnly.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import "src/client/application/IAppManagerUser.sol";
import "src/client/token/IAdminWithdrawalRuleCapable.sol";
import "src/client/token/HandlerTypeEnum.sol";

/**
 * @title Protocol Handler Common
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract contains common variables and functions for all Protocol Asset Handlers
 */

abstract contract ProtocolHandlerCommon is IAppManagerUser, IOwnershipErrors, IZeroAddressError, ITokenHandlerEvents, ICommonApplicationHandlerEvents, IAssetHandlerErrors, AppAdministratorOrOwnerOnly {
    string private constant VERSION="1.1.0";
    address private newAppManagerAddress;
    address public appManagerAddress;
    IRuleProcessor ruleProcessor;
    IAppManager appManager;

    /**
     * @dev this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process
     * @param _newAppManagerAddress the new address being proposed
     */
    function proposeAppManagerAddress(address _newAppManagerAddress) external appAdministratorOrOwnerOnly(appManagerAddress) {
        if (_newAppManagerAddress == address(0)) revert ZeroAddress();
        newAppManagerAddress = _newAppManagerAddress;
        emit AppManagerAddressProposed(_newAppManagerAddress);
    }

    /**
     * @dev this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address
     */
    function confirmAppManagerAddress() external {
        if (newAppManagerAddress == address(0)) revert NoProposalHasBeenMade();
        if (msg.sender != newAppManagerAddress) revert ConfirmerDoesNotMatchProposedAddress();
        appManagerAddress = newAppManagerAddress;
        appManager = IAppManager(appManagerAddress);
        delete newAppManagerAddress;
        emit AppManagerAddressSet(appManagerAddress);
    }

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}

interface IToken {
    function balanceOf(address owner) external view returns (uint256 balance);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);
}
