# Adding A New Application Level Rule To The Rule Processor Diamond

## Purpose

There are several updates that need to take place in order to add a new applicaiton level rule. In this document we'll be covering the steps required to update the protocol rule processor diamond including: updating the code for the appropriate facets and upgrading the diamond. This document will walk through the process step by step. (We will be using an existing rule, Max Value By Risk Score, as our example) 

## Creating The Rule

### Updating Diamond Storage

The first step is to update the diamond storage to account for the new rule. We'll need to update [RuleStoragePositionLib](../../../../../src/protocol/economic/ruleProcessor/RuleStoragePositionLib.sol). For our example we would first add the following constant to the top of the contract to define the storage position for our Account Max Value By Risk Score rule:

```c
bytes32 constant ACCOUNT_MAX_VALUE_BY_RISK_SCORE_POSITION = bytes32(uint256(keccak256("account-max-value-by-risk-score")) - 1);
```

Next we'll want to define the storage structure for our rule. For our example we would add the following struct to [IRuleStorage](../../../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol):

```c
    struct AccountMaxValueByRiskScoreS {
        mapping(uint32 => IApplicationRules.AccountMaxValueByRiskScore) accountMaxValueByRiskScoreRules;
        uint32 accountMaxValueByRiskScoreIndex;
    }
```

Finally we'll want to add a function to retrieve the storage for our rule to RuleStoragePositionLib.sol. For our example we would add the following function:

```c
    function accountMaxTxValueByRiskScoreStorage() internal pure returns (IRuleStorage.AccountMaxTxValueByRiskScoreS storage ds) {
        bytes32 position = ACC_MAX_TX_VALUE_BY_RISK_SCORE_POSITION;
        assembly {
            ds.slot := position
        }
    }
```

### Facet Updates

The next step is to update the [AppRuleDataFacet](../../../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol) contract to include a function that can be used to create an instance of our new rule and register it with the diamond. For our example we would add the following function:

```c
    function addAccountMaxValueByRiskScore(address _appManagerAddr, uint8[] calldata _riskScores, uint48[] calldata _maxValue) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_maxValue.length != _riskScores.length) revert InputArraysSizesNotValid();
        if (_maxValue.length == 0) revert InvalidRuleInput();
        if (_riskScores[_riskScores.length - 1] > MAX_RISKSCORE) revert RiskLevelCannotExceed99();
        for (uint i = 1; i < _riskScores.length; ) {
            if (_riskScores[i] <= _riskScores[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        for (uint i = 1; i < _maxValue.length; ) {
            if (_maxValue[i] > _maxValue[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        return _addAccountMaxValueByRiskScore(_riskScores, _maxValue);
    }
```

The next step is to add the functions necessary to manage the rule to [ProtocolApplicationHandler](../../../../../src/client/application/ProtocolApplicationHandler.sol). The functions consist of: setRuleName, activateRuleName, getRuleNameId, isRuleNameActive (RuleName being replaced by the name of the specific rule instace the file is handling).

The following function uses the ruleId we received when we created the instance of the rule to set the instance in the diamond and activate it:

```c
    function setAccountMaxValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccountMaxValueByRiskScore(createActionTypesArray(_action), _ruleId);
        accountMaxValueByRiskScoreId = _ruleId;
        accountMaxValueByRiskScoreActive = true;
        emit ApplicationRuleApplied(ACC_MAX_VALUE_BY_RISK_SCORE, _ruleId);
    }
```

The following function is used to activate/deactivate the instance of the rule that's already set in the diamond:

```c
    function activateAccountMaxValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxValueByRiskScoreActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ACC_MAX_VALUE_BY_RISK_SCORE);
        } else {
            emit ApplicationHandlerDeactivated(ACC_MAX_VALUE_BY_RISK_SCORE);
        }
    }
```

The following function is used to retrieve the rule id for the Account Max Value By Risk Score Rule currently set on the diamond:

```c
    function getAccountMaxValueByRiskScoreId() external view returns (uint32) {
        return accountMaxValueByRiskScoreId;
    }
```

The following function is used to check whether the rule is currently active:

```c 
    function isAccountMaxValueByRiskScoreActive() external view returns (bool) {
        return accountMaxValueByRiskScoreActive;
    }
```


The next step is to update the appropriate function in `ProtocolApplicationHandler` to include a check for our new rule. For our example we'll be updating the `_checkRiskRules` function. 

```c
    function _checkRiskRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal {
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);
        if (accountMaxValueByRiskScoreActive) {
            ruleProcessor.checkAccountMaxValueByRiskScore(accountMaxValueByRiskScoreId, _to, riskScoreTo, _balanceValuation, _transferValuation);
        }
        ...
```

### Upgrading Existing Diamonds

Once the above changes have been made to add the new rule, in order to make the rule available we will need to upgrade the existing diamond instance. Step by step instructions on this upgrade are provided in [RULE-PROCESSOR-DIAMOND-UPGRADE.md](../../../Architecture/Protocol/RULE-PROCESSOR-DIAMOND-UPGRADE.md) 