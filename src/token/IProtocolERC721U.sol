// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

/**
 * @title  Upgradeable ERC721 Protocol Interface
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721Upgradeables
 */
interface IProtocolERC721U is IERC721EnumerableUpgradeable {
    event NewNFTDeployed(address indexed applicationNFT, address indexed appManagerAddress);
    event HandlerConnected(address indexed handlerAddress, address indexed assetAddress);
    error ZeroAddress();

    /**
     * @dev Function to set the appManagerAddress
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses assigned as AppAdministrator can call function.
     */
    function setAppManagerAddress(address _appManagerAddress) external;

    /**
     * @dev Function to get the appManagerAddress
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function getAppManagerAddress() external view returns (address);

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address);

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external;

    /**
     * @dev Function to return token's total circulating supply
     * @return _totalSupply token's total circulating supply
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Function to connect Token to the protocol assets
     * @param _appManagerAddress address of the currently deployed app manager
     * @param _assetHandlerAddress address of the currently deployed asset Handler
     */
    function initiateProtocol(address _appManagerAddress, address _assetHandlerAddress) external;
}