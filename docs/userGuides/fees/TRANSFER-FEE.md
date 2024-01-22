# Transfer Fee

## Purpose

The purpose of the Transfer Fee is to assess fees when protocol supported tokens are transferred. Application developers can utilize fees to influence their application's economy through incentivizing behavior. Fees are assigned via tags applied to accounts through the App Manager. A blank tag may be used when adding a fee to apply to all accounts as a "default" fee. Token fees are added and activated through the token handler contract. Token transfer fees are assessed and taken from the token when fees are active in the token handler. 


## Application of Transfer Fee

Transfer fees are assessed in the transfer function of the token. The fees are additive. If a user has multiple applicable fees, the sum of all their fees will be assessed. 

#### *See [Protocol Fee Structure](./PROTOCOL-FEE-STRUCTURE.md)*

## Dependencies

- **Tags**: This rule relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.