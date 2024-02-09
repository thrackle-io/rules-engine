// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ActionTypes} from "src/common/ActionEnum.sol";

/**
 * @title IHandlerDiamond
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev the light version of the Handler Diamond for an efficient
 * import into the other contracts for calls to the checkAllRules function.
 * This is only used internally by the protocol.
 */

interface IHandlerDiamond {

    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, address _sender, uint256 _amount) external returns (bool); 

    function isFeeActive() external view returns (bool);

    function getApplicableFees(address _from, uint256 _balanceFrom) external view returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages);

    function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external;

    function checkTaggedAndTradingRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to,uint256 _amount, ActionTypes action) external;

    function checkTradingRules(address _from, address _to, bytes32[] memory fromTags, bytes32[] memory toTags, uint256 _amount, ActionTypes action) external;


}