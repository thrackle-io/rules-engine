# Protocol Tags Structure 

## Purpose



## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 


## Data Structure
Fees are stored in a struct inside the Fees data contract. 

```c
struct Fee {
        uint256 minBalance;
        uint256 maxBalance;
        int24 feePercentage;
        address feeCollectorAccount;
    }
```
- **minBalance** (uint256): minimum balance for fee application 
- **maxBalance** (uint256): maximum balance for fee application 
- **feePercentage** (int24): fee percentage to assess in basis units (-10000 to 10000)
- **feeCollectorAccount** (address): address of the fees recipient account 

Each Fee struct is stored in a mapping by the bytes32 tag associated to that fee: 
```c
///     tag   => Fee struct 
mapping(bytes32 => Fee) feesByTag;
```

###### *see [Fees](../../../src/client/token/data/Fees.sol)*

## Configuration and Enabling/Disabling
- Fees can only be configured in the asset handler by a **rule administrator**.
- Fees can only be added in the asset handler by a **rule administrator**.
- Fees can only be removed in the asset handler by a **rule administrator**.

## Fees Evaluation
DO WE NEED THIS SECTION?????

###### *see [ProtocolERC20](../../../src/client/token/ERC20/ProtocolERC20.sol) -> transfer*

## Evaluation Exceptions 
- There are no evaluation exceptions when fees are active. Fees are assessed in the token transfer function for token fees and in the swap function for AMM fees. No exceptions are made for the assessment of fees. If an address or account should not have fees assessed, there should not be a tag applied to it.

### Revert Message

The transaction will revert with the following error if Fees are higher than transfer amount: 

```
error FeesAreGreaterThanTransactionAmount();
```

The selector for this error is `0x248ee764`.


## Add Function

Adding a fee is done through the function:

```c
function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount)   external ruleAdministratorOnly(appManagerAddress); 
```
###### *see [Fees](../../../src/client/token/data/Fees.sol)*

### Parameters:

- **_tag** (bytes32): tag for fee application to an account.
- **minBalance** (uint256): minimum balance for fee application 
- **maxBalance** (uint256): maximum balance for fee application 
- **feePercentage** (int24): fee percentage to assess in basis units (-10000 to 10000)
- **_targetAccount** (address): address of the fees recipient account 

This create function allows for fees to be applied via a blank tag and will work as a default fee for all accounts. Additional tags applied to account will resault in additional fees being assessed for that account. Accounts can have up to 10 tags per account and can reflect both additive fees or deductive fees (discounts). 

### Parameter Optionality:

There are no options for the parameters of this function.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The `minBalance` is less than `maxBalance`.
- `feePercentage` is greater than -10000 and less than 10000.
- `feePercentage` is not equal to 0.
- `targetAccount` is not the zero address. 

###### *see [Fees](../../../src/client/token/data/Fees.sol)*

## Other Functions:

- In [Fees](../../../src/client/token/data/Fees.sol):
    -  Function to remove a fee:
        ```c
        function removeFee(bytes32 _tag) external onlyOwner;
        ```
    -  Function to get a fee:
        ```c
        function getFee(bytes32 _tag) public view onlyOwner returns (Fee memory);
        ```
    -  Function to get total nuber of fees:
        ```c
        function getFeeTotal() external view onlyOwner returns (uint256)
        ```
    -  Function to propose new data contract owner:
        ```c
        function proposeOwner(address _newOwner) external onlyOwner;
        ```
    -  Function to confirm new data contract owner:
        ```c
        function confirmOwner() external;
        ```

- In [Asset Handler](../../../src/client/token/ERC20/ProtocolERC20Handler.sol):
    -  Function to deploy a new data contract:
        ```c
        function deployDataContract() private;
        ```
    - Function to retrieve fees data contract address:
        ```c
        function getFeesDataAddress() external view returns (address);
        ```
    - Function to propose data contract migration to new handler:
        ```c
        function proposeDataContractMigration(address _newOwner) external appAdministratorOrOwnerOnly(appManagerAddress);
        ```
    - Function to confirm migration of data contracts to new handler:
        ```c
        function confirmDataContractMigration(address _oldHandlerAddress) external appAdministratorOrOwnerOnly(appManagerAddress);
        ```

## Return Data

When assessing fees the function getApplicableFees() returns: 
- **feeCollectorAccounts** (address[]): List of fee recipient addresses
- **feePercentagess** (int24[]): List of fee percentages 

## Data Recorded

Fee totals are added inside of a loop and then total fees are subtracted from the amount being transferred within the transfer or swap functions. This data is not saved to storage. 

## Events

- **FeeType(bytes32 indexed tag, bool indexed add, uint256 minBalance, uint256 maxBalance, int256 feePercentage, address targetAccount)**: emitted when:
    - A fee has been added. In this case, the `add` field of the event will be *true*.
    - A fee has been removed. In this case, the `add` field of the event will be *false*.

## Dependencies

- **Tags**: 