# ApplicationERC721UProxy
[Git Source](https://github.com/thrackle-io/rules-engine/blob/eddb7b007d5e1a45b26b48a2e20785ba6487ee41/src/example/ERC721/upgradeable/ApplicationERC721UProxy.sol)

**Inherits:**
ERC1967Proxy

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example ERC721Proxy implementation that App Devs can use.

*This contract implements a proxy that is upgradeable by an admin.
To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
clashing], which can potentially be used in an attack, this contract uses the
https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
things that go hand in hand:
1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
that call matches one of the admin functions exposed by the proxy itself.
2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
implementation. If the admin tries to call a function on the implementation it will fail with an error that says
"admin cannot fallback to proxy target".
These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
to sudden errors when trying to call a function from the proxy implementation.
Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.*


## Functions
### constructor


```solidity
constructor(address _implementation, bytes memory _data) ERC1967Proxy(_implementation, _data);
```

