# IERC721A
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/b3877670eae43a9723081d42c4401502ebd5b9f6/src/interfaces/IERC721A.sol)

*Interface of ERC721A.*


## Functions
### totalSupply

*Returns the total number of tokens in existence.
Burned tokens will reduce the count.
To get the total number of tokens minted, please see {_totalMinted}.*


```solidity
function totalSupply() external view returns (uint256);
```

### supportsInterface

*Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
[EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
to learn more about how these ids are created.
This function call must use less than 30000 gas.*


```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```

### balanceOf

*Returns the number of tokens in `owner`'s account.*


```solidity
function balanceOf(address owner) external view returns (uint256 balance);
```

### ownerOf

*Returns the owner of the `tokenId` token.
Requirements:
- `tokenId` must exist.*


```solidity
function ownerOf(uint256 tokenId) external view returns (address owner);
```

### safeTransferFrom

*Safely transfers `tokenId` token from `from` to `to`,
checking first that contract recipients are aware of the ERC721 protocol
to prevent tokens from being forever locked.
Requirements:
- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `tokenId` token must exist and be owned by `from`.
- If the caller is not `from`, it must be have been allowed to move
this token by either {approve} or {setApprovalForAll}.
- If `to` refers to a smart contract, it must implement
{IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
Emits a {Transfer} event.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable;
```

### safeTransferFrom

*Equivalent to `safeTransferFrom(from, to, tokenId, '')`.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external payable;
```

### transferFrom

*Transfers `tokenId` from `from` to `to`.
WARNING: Usage of this method is discouraged, use {safeTransferFrom}
whenever possible.
Requirements:
- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `tokenId` token must be owned by `from`.
- If the caller is not `from`, it must be approved to move this token
by either {approve} or {setApprovalForAll}.
Emits a {Transfer} event.*


```solidity
function transferFrom(address from, address to, uint256 tokenId) external payable;
```

### approve

*Gives permission to `to` to transfer `tokenId` token to another account.
The approval is cleared when the token is transferred.
Only a single account can be approved at a time, so approving the
zero address clears previous approvals.
Requirements:
- The caller must own the token or be an approved operator.
- `tokenId` must exist.
Emits an {Approval} event.*


```solidity
function approve(address to, uint256 tokenId) external payable;
```

### setApprovalForAll

*Approve or remove `operator` as an operator for the caller.
Operators can call {transferFrom} or {safeTransferFrom}
for any token owned by the caller.
Requirements:
- The `operator` cannot be the caller.
Emits an {ApprovalForAll} event.*


```solidity
function setApprovalForAll(address operator, bool _approved) external;
```

### getApproved

*Returns the account approved for `tokenId` token.
Requirements:
- `tokenId` must exist.*


```solidity
function getApproved(uint256 tokenId) external view returns (address operator);
```

### isApprovedForAll

*Returns if the `operator` is allowed to manage all of the assets of `owner`.
See {setApprovalForAll}.*


```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool);
```

### name

*Returns the token collection name.*


```solidity
function name() external view returns (string memory);
```

### symbol

*Returns the token collection symbol.*


```solidity
function symbol() external view returns (string memory);
```

### tokenURI

*Returns the Uniform Resource Identifier (URI) for `tokenId` token.*


```solidity
function tokenURI(uint256 tokenId) external view returns (string memory);
```

## Events
### Transfer
*Emitted when `tokenId` token is transferred from `from` to `to`.*


```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
```

### Approval
*Emitted when `owner` enables `approved` to manage the `tokenId` token.*


```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
```

### ApprovalForAll
*Emitted when `owner` enables or disables
(`approved`) `operator` to manage all of its assets.*


```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
```

### ConsecutiveTransfer
*Emitted when tokens in `fromTokenId` to `toTokenId`
(inclusive) is transferred from `from` to `to`, as defined in the
[ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
See {_mintERC2309} for more details.*


```solidity
event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
```

## Errors
### ApprovalCallerNotOwnerNorApproved
The caller must own the token or be an approved operator.


```solidity
error ApprovalCallerNotOwnerNorApproved();
```

### ApprovalQueryForNonexistentToken
The token does not exist.


```solidity
error ApprovalQueryForNonexistentToken();
```

### BalanceQueryForZeroAddress
Cannot query the balance for the zero address.


```solidity
error BalanceQueryForZeroAddress();
```

### MintToZeroAddress
Cannot mint to the zero address.


```solidity
error MintToZeroAddress();
```

### MintZeroQuantity
The quantity of tokens minted must be more than zero.


```solidity
error MintZeroQuantity();
```

### OwnerQueryForNonexistentToken
The token does not exist.


```solidity
error OwnerQueryForNonexistentToken();
```

### TransferCallerNotOwnerNorApproved
The caller must own the token or be an approved operator.


```solidity
error TransferCallerNotOwnerNorApproved();
```

### TransferFromIncorrectOwner
The token must be owned by `from`.


```solidity
error TransferFromIncorrectOwner();
```

### TransferToNonERC721ReceiverImplementer
Cannot safely transfer to a contract that does not implement the
ERC721Receiver interface.


```solidity
error TransferToNonERC721ReceiverImplementer();
```

### TransferToZeroAddress
Cannot transfer to the zero address.


```solidity
error TransferToZeroAddress();
```

### URIQueryForNonexistentToken
The token does not exist.


```solidity
error URIQueryForNonexistentToken();
```

### MintERC2309QuantityExceedsLimit
The `quantity` minted with ERC2309 exceeds the safety limit.


```solidity
error MintERC2309QuantityExceedsLimit();
```

### OwnershipNotInitializedForExtraData
The `extraData` cannot be set on an unintialized ownership slot.


```solidity
error OwnershipNotInitializedForExtraData();
```

## Structs
### TokenOwnership

```solidity
struct TokenOwnership {
    address addr;
    uint64 startTimestamp;
    bool burned;
    uint24 extraData;
}
```

