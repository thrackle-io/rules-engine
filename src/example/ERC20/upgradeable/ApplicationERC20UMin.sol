// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "src/client/token/ERC20/upgradeable/ProtocolERC20UMin.sol";
import "src/protocol/economic/AppAdministratorOnlyU.sol";

contract ApplicationERC20UMin is ProtocolERC20UMin {
    /**
     * @dev Initializer sets the the App Manager
     * @param _name Name of the token
     * @param _symbol Symbol of the token
     * @param _appManagerAddress Address of App Manager
     */
    function initialize(string memory _name, string memory _symbol, address _appManagerAddress) public initializer {
        _name = _name;
        _symbol = _symbol;
        __ProtocolERC20_init(_appManagerAddress);
    }

    /**
     * @dev Function mints new tokens. Allows for minting of tokens.
     * @param to recipient address
     * @param amount number of tokens to mint
     */
    function mint(address to, uint256 amount) public appAdministratorOnly(appManagerAddress) {
        _mint(to, amount);
    }

    /**
     * @dev Function burns tokens. Allows for burning of tokens.
     * @param account address tokens are burned from
     * @param amount number of tokens to burn
     */
    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
}
