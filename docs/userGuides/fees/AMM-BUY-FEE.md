# AMM Buy Fee

## Purpose

The purpose of the AMM Buy Fee is to assess fees via the AMM swap function for purchases. A purchase via the AMM is defined as the user exchanging collateralized tokens for application tokens via the AMM. Collateralized tokens can be chain native tokens (ETH/MATIC), non protocol supported ERC20 tokens (WETH/USDC) or protocol supported ERC20 tokens. AMM Fees are always taken from the collateralized token within the AMM.

Protocol supported tokens and AMMs will always assess all fees asigned to the account executing the current function. If a token and AMM have fees active and an account is tagged with applicable fees or a blank tag is used to assign a default fee, those fees are assessed on token transfers and AMM swaps (additive). Token fees are assessed and taken from the token itself, not a collateralized token, when fees are active in the token handler. 


## Application of Buy Fee

Buy fees are assessed on the collateralized token being swapped for application tokens inside the AMM. The fees are additive. If a user has multiple applicable fees, the sum of all their fees will be assessed. 

#### *See [Protocol Fee Structure](./PROTOCOL-FEE-STRUCTURE.md)*

## Dependencies

- **Tags**: This rule relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.