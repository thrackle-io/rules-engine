# Protocol Rule Processor Diamond Libraries  

## Purpose

The Rule Processor Diamond Libraries store functions used by the diamond structure. The Rule Processor Diamond Lib contract holds the function to store rules when added to the protocol, the diamond cut function for upgrading the diamond and adding or removing functions from facets. The Rule Processor Common Lib holds functions used throughout the facets to validate rules and parameters passed to the rule check functions. 

The importance of using these singular library contracts prevents data storage collision as functionality is added or removed from the protocol. Utilizing the remove function in the Rule Processor Diamond Lib prevents a situation where a facet may have been self destructed but the function selectors are still stored in the diamond. This could result in a "false posistive" successful transaction when attempting to add a rule and the rule is never added to the diamond. 


## Functions 

### Rule Processor Diamond Lib Functions 

### Rule Processor Common Lib Functions  

## Data Structures 

## Events 

## Upgrading 