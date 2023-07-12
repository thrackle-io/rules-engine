# ProtocolERC721A
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/1967bc8c4a91d28c4a17e06555cea67921b90fa3/src/token/ProtocolERC721A.sol)

**Inherits:**
[IERC721A](/src/interfaces/IERC721A.sol/interface.IERC721A.md), Pausable, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the base ERC721A used for new ERC721A contracts.

*Implementation of the [ERC721](https://eips.ethereum.org/EIPS/eip-721)
Non-Fungible Token Standard, including the Metadata extension.
Optimized for lower gas during batch mints.
Token IDs are minted in sequential order (e.g. 0, 1, 2, 3, ...)
starting from `_startTokenId()`.*


## State Variables
### _BITMASK_ADDRESS_DATA_ENTRY
=============================================================
CONSTANTS
=============================================================
Mask of an entry in packed address data.


```solidity
uint256 private constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;
```


### _BITPOS_NUMBER_MINTED
The bit position of `numberMinted` in packed address data.


```solidity
uint256 private constant _BITPOS_NUMBER_MINTED = 64;
```


### _BITPOS_NUMBER_BURNED
The bit position of `numberBurned` in packed address data.


```solidity
uint256 private constant _BITPOS_NUMBER_BURNED = 128;
```


### _BITPOS_AUX

```solidity
uint256 private constant _BITPOS_AUX = 192;
```


### _BITMASK_AUX_COMPLEMENT
Mask of all 256 bits in packed address data except the 64 bits for `aux`.


```solidity
uint256 private constant _BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;
```


### _BITPOS_START_TIMESTAMP
The bit position of `startTimestamp` in packed ownership.


```solidity
uint256 private constant _BITPOS_START_TIMESTAMP = 160;
```


### _BITMASK_BURNED
The bit mask of the `burned` bit in packed ownership.


```solidity
uint256 private constant _BITMASK_BURNED = 1 << 224;
```


### _BITPOS_NEXT_INITIALIZED
The bit position of the `nextInitialized` bit in packed ownership.


```solidity
uint256 private constant _BITPOS_NEXT_INITIALIZED = 225;
```


### _BITMASK_NEXT_INITIALIZED
The bit mask of the `nextInitialized` bit in packed ownership.


```solidity
uint256 private constant _BITMASK_NEXT_INITIALIZED = 1 << 225;
```


### _BITPOS_EXTRA_DATA
The bit position of `extraData` in packed ownership.


```solidity
uint256 private constant _BITPOS_EXTRA_DATA = 232;
```


### _BITMASK_EXTRA_DATA_COMPLEMENT
Mask of all 256 bits in a packed ownership except the 24 bits for `extraData`.


```solidity
uint256 private constant _BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;
```


### _BITMASK_ADDRESS
The mask of the lower 160 bits for addresses.


```solidity
uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;
```


### _MAX_MINT_ERC2309_QUANTITY_LIMIT
The maximum `quantity` that can be minted with {_mintERC2309}.
This limit is to prevent overflows on the address data entries.
For a limit of 5000, a total of 3.689e15 calls to {_mintERC2309}
is required to cause an overflow, which is unrealistic.


```solidity
uint256 private constant _MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;
```


### _TRANSFER_EVENT_SIGNATURE
The `Transfer` event signature is given by:
`keccak256(bytes("Transfer(address,address,uint256)"))`.


```solidity
bytes32 private constant _TRANSFER_EVENT_SIGNATURE = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
```


### handler
Protocol Addresses


```solidity
IProtocolERC721Handler handler;
```


### appManager

```solidity
IAppManager appManager;
```


### appManagerAddress

```solidity
address public appManagerAddress;
```


### handlerAddress

```solidity
address public handlerAddress;
```


### baseUri
Base Contract URI


```solidity
string public baseUri;
```


### VERSION
keeps track of RULE enum version and other features


```solidity
uint8 public constant VERSION = 1;
```


### _currentIndex
=============================================================
STORAGE
=============================================================
The next token ID to be minted.


```solidity
uint256 private _currentIndex;
```


### _burnCounter
The number of tokens burned.


```solidity
uint256 private _burnCounter;
```


### _name
Token name


```solidity
string private _name;
```


### _symbol
Token symbol


```solidity
string private _symbol;
```


### _packedOwnerships
Mapping from token ID to ownership details
An empty struct value does not necessarily mean the token is unowned.
See {_packedOwnershipOf} implementation for details.
Bits Layout:
- [0..159]   `addr`
- [160..223] `startTimestamp`
- [224]      `burned`
- [225]      `nextInitialized`
- [232..255] `extraData`


```solidity
mapping(uint256 => uint256) private _packedOwnerships;
```


### _packedAddressData
Mapping owner address to address data.
Bits Layout:
- [0..63]    `balance`
- [64..127]  `numberMinted`
- [128..191] `numberBurned`
- [192..255] `aux`


```solidity
mapping(address => uint256) private _packedAddressData;
```


### _tokenApprovals
Mapping from token ID to approved address.


```solidity
mapping(uint256 => TokenApprovalRef) private _tokenApprovals;
```


### _operatorApprovals
Mapping from owner to operator approvals


```solidity
mapping(address => mapping(address => bool)) private _operatorApprovals;
```


## Functions
### constructor

=============================================================
CONSTRUCTOR
=============================================================

*Constructor sets the name, symbol, base uri and the addresses for Handler and App Manager
Constructor sets the index for TokenId's*


```solidity
constructor(string memory name_, string memory symbol_, address _appManagerAddress, string memory _baseUri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|Name of NFT|
|`symbol_`|`string`|Symbol for the NFT|
|`_appManagerAddress`|`address`|Address of App Manager _upgradeMode is also passed to Handler contract to deploy a new data contract with the handler.|
|`_baseUri`|`string`|URI for the base token|


### _startTokenId

=============================================================
TOKEN COUNTING OPERATIONS
=============================================================

*Returns the starting token ID.
To change the starting token ID, please override this function.*


```solidity
function _startTokenId() internal view virtual returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|0 to start tokenId counter at 0|


### _nextTokenId

*Returns the next token ID to be minted.*


```solidity
function _nextTokenId() internal view virtual returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|_currentIndex counter of all created tokens|


### totalSupply

*Returns the total number of tokens in existence.
Burned tokens will reduce the count.
To get the total number of tokens minted, please see {_totalMinted}.*


```solidity
function totalSupply() public view virtual override returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total supply of tokens in circulation|


### _totalMinted

Counter underflow is impossible as _burnCounter cannot be incremented
more than `_currentIndex - _startTokenId()` times.

Minted total may be higher than total supply if tokens have been burned

*Returns the total amount of tokens minted in the contract.*


```solidity
function _totalMinted() internal view virtual returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Minted Total|


### _totalBurned

Counter underflow is impossible as `_currentIndex` does not decrement,
and it is initialized to `_startTokenId()`.

*Returns the total number of tokens burned.*


```solidity
function _totalBurned() internal view virtual returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Number of tokens burned|


### balanceOf

=============================================================
ADDRESS DATA OPERATIONS
=============================================================

*Returns the number of tokens in `owner`'s account.*


```solidity
function balanceOf(address owner) public view virtual override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Address of Owner|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Number of tokens held by address|


### _numberMinted

Returns the number of tokens minted by `owner`.


```solidity
function _numberMinted(address owner) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Address of Owner|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Number of tokens minted by address|


### _numberBurned

*Internal Function to return number of tokens burned by address*


```solidity
function _numberBurned(address owner) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Address of Owner|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the number of tokens burned by or on behalf of `owner`.|


### _getAux

*Internal Function to return owner of whitelisted slots for minting*


```solidity
function _getAux(address owner) internal view returns (uint64);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Address of Owner|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint64`|the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).|


### _setAux

*Function sets the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).
If there are multiple variables, please pack them into a uint64.*


```solidity
function _setAux(address owner, uint64 aux) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Address of Owner|
|`aux`|`uint64`|value for aux when casting assembly|


### supportsInterface

=============================================================
IERC165
=============================================================

*Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
[EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
to learn more about how these ids are created.
This function call must use less than 30000 gas.*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|Id of the interface for IERC165, ERC721, ERC721Metadata|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True equals support for interface|


### name

The interface IDs are constants representing the first 4 bytes
of the XOR of all function selectors in the interface.
See: [ERC165](https://eips.ethereum.org/EIPS/eip-165)
(e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`)
ERC165 interface ID for ERC165.
ERC165 interface ID for ERC721.
ERC165 interface ID for ERC721Metadata.
=============================================================
IERC721Metadata
=============================================================

*Function to return token name*


```solidity
function name() public view virtual override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|Returns the token collection name.|


### symbol

*Function to return token symbol*


```solidity
function symbol() public view virtual override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|Returns the token collection symbol.|


### tokenURI

*Function to returns the Uniform Resource Identifier (URI) for `tokenId` token.*


```solidity
function tokenURI(uint256 tokenId) public view virtual override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the token to return URI of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URI to token Id|


### _baseURI

*Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, it can be overridden in child contracts.*


```solidity
function _baseURI() internal view virtual returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|Concatenated baseURI and tokenId|


### _setBaseURI

Set in contructor but can be called later to update URI if needed

*Internal function to setBaseURI for the contract*


```solidity
function _setBaseURI(string memory _baseUri) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_baseUri`|`string`|URI for contract|


### ownerOf

=============================================================
OWNERSHIPS OPERATIONS
=============================================================

*Returns the owner of the `tokenId` token.
Requirements:
- `tokenId` must exist.*


```solidity
function ownerOf(uint256 tokenId) public view virtual override returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address of owner of tokenId|


### _ownershipOf

function called by ownerOf() to unpack data

*Gas spent here starts off proportional to the maximum mint batch size.
It gradually moves to O(1) as tokens get transferred around over time.*


```solidity
function _ownershipOf(uint256 tokenId) internal view virtual returns (TokenOwnership memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TokenOwnership`|unpackedOwnership of tokenId|


### _ownershipAt

*Returns the unpacked `TokenOwnership` struct at `index`.*


```solidity
function _ownershipAt(uint256 index) internal view virtual returns (TokenOwnership memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|position of data in storage|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TokenOwnership`|unpackedOwnership at index|


### _initializeOwnershipAt

*Initializes the ownership slot minted at `index` for efficiency purposes.*


```solidity
function _initializeOwnershipAt(uint256 index) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|index of data in storage|


### _packedOwnershipOf

*Returns the packed ownership data of `tokenId`.*


```solidity
function _packedOwnershipOf(uint256 tokenId) private view returns (uint256 packed);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`packed`|`uint256`|value for packed data storage|


### _unpackedOwnership

If not burned.
If the data at the starting slot does not exist, start the scan.
Invariant:
There will always be an initialized ownership slot
(i.e. `ownership.addr != address(0) && ownership.burned == false`)
before an unintialized ownership slot
(i.e. `ownership.addr == address(0) && ownership.burned == false`)
Hence, `tokenId` will not underflow.
We can directly compare the packed value.
If the address is zero, packed will be zero.
Otherwise, the data exists and is not burned. We can skip the scan.
This is possible because we have already achieved the target condition.
This saves 2143 gas on transfers of initialized tokens.

*Returns the unpacked `TokenOwnership` struct from `packed`.*


```solidity
function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`packed`|`uint256`|value for packed data to unpack|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ownership`|`TokenOwnership`|address, startTimestamp, burned and extraData for tokenId|


### _packOwnershipData

*Packs ownership data into a single uint256.*


```solidity
function _packOwnershipData(address owner, uint256 flags) private view returns (uint256 result);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Address of Owner|
|`flags`|`uint256`|value for flags|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`result`|`uint256`|ownership data in uint256|


### _nextInitializedFlag

Mask `owner` to the lower 160 bits, in case the upper bits somehow aren't clean.
`owner | (block.timestamp << _BITPOS_START_TIMESTAMP) | flags`.

*Returns the `nextInitialized` flag set if `quantity` equals 1.*


```solidity
function _nextInitializedFlag(uint256 quantity) private pure returns (uint256 result);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`quantity`|`uint256`|quantity of flag|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`result`|`uint256`|TODO|


### approve

`(quantity == 1) << _BITPOS_NEXT_INITIALIZED`.
=============================================================
APPROVAL OPERATIONS
=============================================================

*Gives permission to `to` to transfer `tokenId` token to another account. See {ERC721A-_approve}.
Requirements:
- The caller must own the token or be an approved operator.*


```solidity
function approve(address to, uint256 tokenId) public payable virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`tokenId`|`uint256`|ID of token|


### getApproved

*Returns the account approved for `tokenId` token.
Requirements:
- `tokenId` must exist.*


```solidity
function getApproved(uint256 tokenId) public view virtual override returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|_tokenApprovals address approved for tokenId|


### setApprovalForAll

*Approve or remove `operator` as an operator for the caller.
Operators can call {transferFrom} or {safeTransferFrom}
for any token owned by the caller.
Requirements:
- The `operator` cannot be the caller.
Emits an {ApprovalForAll} event.*


```solidity
function setApprovalForAll(address operator, bool approved) public virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|Address for operator|
|`approved`|`bool`|Boolean for approval (true equals approved)|


### isApprovedForAll

*Returns if the `operator` is allowed to manage all of the assets of `owner`.
See {setApprovalForAll}.*


```solidity
function isApprovedForAll(address owner, address operator) public view virtual override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Address of owner|
|`operator`|`address`|Address for operator|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|approval for operator address from owner address boolean|


### _exists

*Returns whether `tokenId` exists.
Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
Tokens start existing when they are minted. See {_mint}.*


```solidity
function _exists(uint256 tokenId) internal view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|exists equals true|


### _isSenderApprovedOrOwner

If within bounds,
and not burned.

*Returns whether `msgSender` is equal to `approvedAddress` or `owner`.*


```solidity
function _isSenderApprovedOrOwner(address approvedAddress, address owner, address msgSender)
    private
    pure
    returns (bool result);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`approvedAddress`|`address`|Approved Address|
|`owner`|`address`|Address of owner|
|`msgSender`|`address`|Address of message sender|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`result`|`bool`|equals true if msgSender equals owner or msgSender equals approvedAddress|


### _getApprovedSlotAndAddress

Mask `owner` to the lower 160 bits, in case the upper bits somehow aren't clean.
Mask `msgSender` to the lower 160 bits, in case the upper bits somehow aren't clean.
`msgSender == owner || msgSender == approvedAddress`.

*Returns the storage slot and value for the approved address of `tokenId`.*


```solidity
function _getApprovedSlotAndAddress(uint256 tokenId)
    private
    view
    returns (uint256 approvedAddressSlot, address approvedAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`approvedAddressSlot`|`uint256`|storage of approvedAddress memory|
|`approvedAddress`|`address`|Approved Address|


### transferFrom

=============================================================
TRANSFER OPERATIONS
=============================================================

*Transfers `tokenId` from `from` to `to`.
Requirements:
- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `tokenId` token must be owned by `from`.
- If the caller is not `from`, it must be approved to move this token
by either {approve} or {setApprovalForAll}.
Emits a {Transfer} event.*


```solidity
function transferFrom(address from, address to, uint256 tokenId) public payable virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of Recipient|
|`tokenId`|`uint256`|ID of token|


### safeTransferFrom

The nested ifs save around 20+ gas over a compound boolean condition.
This is equivalent to `delete _tokenApprovals[tokenId]`.
Underflow of the sender's balance is impossible because we check for
ownership above and the recipient's balance can't realistically overflow.
Counter overflow is incredibly unrealistic as `tokenId` would have to be 2**256.
We can directly increment and decrement the balances.
Updates: `balance -= 1`.
Updates: `balance += 1`.
Updates:
- `address` to the next owner.
- `startTimestamp` to the timestamp of transfering.
- `burned` to `false`.
- `nextInitialized` to `true`.
If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
If the next slot's address is zero and not burned (i.e. packed value is zero).
If the next slot is within bounds.
Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.

*Equivalent to `safeTransferFrom(from, to, tokenId, '')`.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) public payable virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of recipient|
|`tokenId`|`uint256`|ID of token|


### safeTransferFrom

*Safely transfers `tokenId` token from `from` to `to`.
Requirements:
- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `tokenId` token must exist and be owned by `from`.
- If the caller is not `from`, it must be approved to move this token
by either {approve} or {setApprovalForAll}.
- If `to` refers to a smart contract, it must implement
{IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
Emits a {Transfer} event.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
    public
    payable
    virtual
    override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of recipient|
|`tokenId`|`uint256`|ID of token|
|`_data`|`bytes`||


### _beforeTokenTransfers

*Hook that is called before a set of serially-ordered token IDs
are about to be transferred. This includes minting.
And also called before burning one token.
`startTokenId` - the first token ID to be transferred.
`quantity` - the amount to be transferred.
Calling conditions:
- When `from` and `to` are both non-zero, `from`'s `tokenId` will be
transferred to `to`.
- When `from` is zero, `tokenId` will be minted for `to`.
- When `to` is zero, `tokenId` will be burned by `from`.
- `from` and `to` are never both zero.*


```solidity
function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of recipient|
|`startTokenId`|`uint256`|ID of token|
|`quantity`|`uint256`|Number of tokens to transfer (used in batch minting)|


### _afterTokenTransfers

added to silence warnings - remove later TODO
added to silence warnings - remove later TODO

*Hook that is called after a set of serially-ordered token IDs
have been transferred. This includes minting.
And also called after one token has been burned.
`startTokenId` - the first token ID to be transferred.
`quantity` - the amount to be transferred.
Calling conditions:
- When `from` and `to` are both non-zero, `from`'s `tokenId` has been
transferred to `to`.
- When `from` is zero, `tokenId` has been minted for `to`.
- When `to` is zero, `tokenId` has been burned by `from`.
- `from` and `to` are never both zero.*


```solidity
function _afterTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of recipient|
|`startTokenId`|`uint256`|ID of token|
|`quantity`|`uint256`|Number of tokens to transfer (used in batch minting)|


### _checkContractOnERC721Received

*Private function to invoke {IERC721Receiver-onERC721Received} on a target contract.
`from` - Previous owner of the given token ID.
`to` - Target address that will receive the token.
`tokenId` - Token ID to be transferred.
`_data` - Optional data to send along with the call.*


```solidity
function _checkContractOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    private
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of recipient|
|`tokenId`|`uint256`|ID of token|
|`_data`|`bytes`|arguments|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|whether the call correctly returned the expected magic value.|


### _mint

=============================================================
MINT OPERATIONS
=============================================================

*Mints `quantity` tokens and transfers them to `to`.
Requirements:
- `to` cannot be the zero address.
- `quantity` must be greater than 0.
Emits a {Transfer} event for each mint.*


```solidity
function _mint(address to, uint256 quantity) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`quantity`|`uint256`|Number of tokens to mint|


### _mintERC2309

Overflows are incredibly unrealistic.
`balance` and `numberMinted` have a maximum limit of 2**64.
`tokenId` has a maximum limit of 2**256.
Updates:
- `balance += quantity`.
- `numberMinted += quantity`.
We can directly add to the `balance` and `numberMinted`.
Updates:
- `address` to the owner.
- `startTimestamp` to the timestamp of minting.
- `burned` to `false`.
- `nextInitialized` to `quantity == 1`.
Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
Emit the `Transfer` event.
Start of data (0, since no data).
End of data (0, since no data).
Signature.
`address(0)`.
`to`.
`tokenId`.
The `iszero(eq(,))` check ensures that large values of `quantity`
that overflows uint256 will make the loop run out of gas.
The compiler will optimize the `iszero` away for performance.
Emit the `Transfer` event. Similar to above.

*Mints `quantity` tokens and transfers them to `to`.
This function is intended for efficient minting only during contract creation.
It emits only one {ConsecutiveTransfer} as defined in
[ERC2309](https://eips.ethereum.org/EIPS/eip-2309),
instead of a sequence of {Transfer} event(s).
Calling this function outside of contract creation WILL make your contract
non-compliant with the ERC721 standard.
For full ERC721 compliance, substituting ERC721 {Transfer} event(s) with the ERC2309
{ConsecutiveTransfer} event is only permissible during contract creation.
Requirements:
- `to` cannot be the zero address.
- `quantity` must be greater than 0.
Emits a {ConsecutiveTransfer} event.*


```solidity
function _mintERC2309(address to, uint256 quantity) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`quantity`|`uint256`|Number of tokens to transfer (used in batch minting)|


### _safeMint

Overflows are unrealistic due to the above check for `quantity` to be below the limit.
Updates:
- `balance += quantity`.
- `numberMinted += quantity`.
We can directly add to the `balance` and `numberMinted`.
Updates:
- `address` to the owner.
- `startTimestamp` to the timestamp of minting.
- `burned` to `false`.
- `nextInitialized` to `quantity == 1`.

*Safely mints `quantity` tokens and transfers them to `to`.
Requirements:
- If `to` refers to a smart contract, it must implement
{IERC721Receiver-onERC721Received}, which is called for each safe transfer.
- `quantity` must be greater than 0.
See {_mint}.
Emits a {Transfer} event for each mint.*


```solidity
function _safeMint(address to, uint256 quantity, bytes memory _data) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`quantity`|`uint256`|Number of tokens to transfer (used in batch minting)|
|`_data`|`bytes`|arguments|


### _safeMint

Reentrancy protection.

*Equivalent to `_safeMint(to, quantity, '')`.*


```solidity
function _safeMint(address to, uint256 quantity) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`quantity`|`uint256`|Number of tokens to transfer (used in batch minting)|


### _approve

=============================================================
APPROVAL OPERATIONS
=============================================================

*Equivalent to `_approve(to, tokenId, false)`.*


```solidity
function _approve(address to, uint256 tokenId) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`tokenId`|`uint256`|ID of token|


### _approve

*Gives permission to `to` to transfer `tokenId` token to another account.
The approval is cleared when the token is transferred.
Only a single account can be approved at a time, so approving the
zero address clears previous approvals.
Requirements:
- `tokenId` must exist.
Emits an {Approval} event.*


```solidity
function _approve(address to, uint256 tokenId, bool approvalCheck) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`tokenId`|`uint256`|ID of token|
|`approvalCheck`|`bool`|approval boolean|


### _burn

=============================================================
BURN OPERATIONS
=============================================================

*Equivalent to `_burn(tokenId, false)`.*


```solidity
function _burn(uint256 tokenId) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of token|


### _burn

*Destroys `tokenId`.
The approval is cleared when the token is burned.
Requirements:
- `tokenId` must exist.
Emits a {Transfer} event.*


```solidity
function _burn(uint256 tokenId, bool approvalCheck) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of token|
|`approvalCheck`|`bool`|approval given boolean|


### _setExtraDataAt

The nested ifs save around 20+ gas over a compound boolean condition.
This is equivalent to `delete _tokenApprovals[tokenId]`.
Underflow of the sender's balance is impossible because we check for
ownership above and the recipient's balance can't realistically overflow.
Counter overflow is incredibly unrealistic as `tokenId` would have to be 2**256.
Updates:
- `balance -= 1`.
- `numberBurned += 1`.
We can directly decrement the balance, and increment the number burned.
This is equivalent to `packed -= 1; packed += 1 << _BITPOS_NUMBER_BURNED;`.
Updates:
- `address` to the last owner.
- `startTimestamp` to the timestamp of burning.
- `burned` to `true`.
- `nextInitialized` to `true`.
If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
If the next slot's address is zero and not burned (i.e. packed value is zero).
If the next slot is within bounds.
Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.
Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
=============================================================
EXTRA DATA OPERATIONS
=============================================================

*Directly sets the extra data for the ownership data `index`.*


```solidity
function _setExtraDataAt(uint256 index, uint24 extraData) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|position of data in storage array|
|`extraData`|`uint24`|ownership data at index|


### _extraData

*Called during each token transfer to set the 24bit `extraData` field.
Intended to be overridden by the cosumer contract.
`previousExtraData` - the value of `extraData` before transfer.
Calling conditions:
- When `from` and `to` are both non-zero, `from`'s `tokenId` will be
transferred to `to`.
- When `from` is zero, `tokenId` will be minted for `to`.
- When `to` is zero, `tokenId` will be burned by `from`.
- `from` and `to` are never both zero.*


```solidity
function _extraData(address from, address to, uint24 previousExtraData) internal view virtual returns (uint24);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of recipient|
|`previousExtraData`|`uint24`|data from previous function calls|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint24`|position of extraData in storage|


### _nextExtraData

*Returns the next extra data for the packed ownership data.
The returned result is shifted into position.*


```solidity
function _nextExtraData(address from, address to, uint256 prevOwnershipPacked) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of sender|
|`to`|`address`|Address of recipient|
|`prevOwnershipPacked`|`uint256`|data from previous function calls|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|position of extraData in storage|


### _msgSenderERC721A

=============================================================
OTHER OPERATIONS
=============================================================

*Returns the message sender (defaults to `msg.sender`).
If you are writing GSN compatible contracts, you need to override this function.*


```solidity
function _msgSenderERC721A() internal view virtual returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Address of msg.sender|


### _toString

*Converts a uint256 to its ASCII string decimal representation.*


```solidity
function _toString(uint256 value) internal pure virtual returns (string memory str);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`value`|`uint256`|value to stringify|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`str`|`string`|stringified value|


### setAppManagerAddress

The maximum value of a uint256 contains 78 digits (1 byte per digit), but
we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
We will need 1 word for the trailing zeros padding, 1 word for the length,
and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
Update the free memory pointer to allocate.
Assign the `str` to the end.
Zeroize the slot after the string.
Cache the end of the memory to calculate the length later.
We write the string from rightmost digit to leftmost digit.
The following is essentially a do-while loop that also handles the zero case.
prettier-ignore
Write the character to the pointer.
The ASCII index of the '0' character is 48.
Keep dividing `temp` until zero.
prettier-ignore
Move the pointer 32 bytes leftwards to make room for the length.
Store the length.

*Function to set the appManagerAddress and connect to the new appManager*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress);
```

### connectHandlerToToken

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


### getHandlerAddress

*this function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


## Structs
### TokenApprovalRef
Bypass for a `--via-ir` bug (https://github.com/chiru-labs/ERC721A/pull/364).


```solidity
struct TokenApprovalRef {
    address value;
}
```

