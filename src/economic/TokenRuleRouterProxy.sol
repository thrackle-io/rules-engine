// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../src/helpers/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {IEconomicEvents} from "../interfaces/IEvents.sol";

/**
 * @title Token Rule Router Proxy Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is the proxy interface of the Token Rule Router.
 * @notice All calls to the TokenRuleRouter will be pointed here and delegated to the router.
 */
contract TokenRuleRouterProxy is Initializable, ProxyAdmin, IEconomicEvents {
    address tokenRuleRouter;
    address private admin;

    /**
     * @dev Constructor sets the Token Rule Router address of implememtation contract
     * @param _tokenRuleRouter Address of Token Rule Router
     */
    constructor(address _tokenRuleRouter) {
        admin = msg.sender;
        tokenRuleRouter = _tokenRuleRouter;
    }

    /**
     * @dev Fallback to delegate calls to the implementation contract TokenRuleRouter.sol
     */
    fallback() external payable {
        address _currentEC = tokenRuleRouter;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _currentEC, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 {
                revert(0, size)
            }
            default {
                return(0, size)
            }
        }
    }

    /**
     * @dev Recieve function for calls with no data
     */
    receive() external payable {}

    /**
     * @dev Function sets new implementation address after upgrade. Requires that the new address is not 0 address and caller is Admin.
     * @param _newHandler Address of new Implementation contract
     * @return tokenRuleRouter Address of new implementation contract
     */
    function newImplementationAddr(address _newHandler) public onlyOwner returns (address) {
        require(_newHandler != address(0));
        emit newHandler(tokenRuleRouter);
        return tokenRuleRouter;
    }

    function getAdmin() public view returns (address) {
        return admin;
    }
}
