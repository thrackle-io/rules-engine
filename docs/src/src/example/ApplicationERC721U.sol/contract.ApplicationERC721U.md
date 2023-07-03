# ApplicationERC721U
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/9adfea3f253340fbb4af30cdc0009d491b72e160/src/example/ApplicationERC721U.sol)

**Inherits:**
[ProtocolERC721U](/src/token/ProtocolERC721U.sol/contract.ProtocolERC721U.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

*This is an example implementation that App Devs should use.
During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
must be performed*


