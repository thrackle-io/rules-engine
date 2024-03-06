# Contributor Guide

[![Project Version][version-image]][version-url]

# Welcome!

We're so glad you would want to come and contribute to Tron! We are a small team and we are always looking for help. There are multiple opportunities to contribute at all levels, be it in documentation or code. See a gas optimization, or a bug? We'd love to hear your take! This document will be the place to get you started. Please do not be intimidated by this as this is just a helpful guide to help you navigate the process.


## Code of Conduct

We follow the Rust code of conduct which can be read [here](https://www.rust-lang.org/policies/code-of-conduct). Violations of this code of conduct can be reported to [The Captain](mailto:johnathan@thrackle.io). 

## Asking For Help

If you have reviewed existing documentation and still have questions or are having problems, we are always a message away. You can reach out to us on the team slack or message [The Captain](mailto:johnathan@thrackle.io). Opening an issue is also a great way to get help for particularly complex issues. 

## Submitting a Bug Report

If you feel you have stumbled upon a particularly severe bug, please quietly message [The Captain](mailto:johnathan@thrackle.io) as soon as possible and keep the bug report private so as to protect customer funds. While we are audited, that is no guarantee that everything is perfect and we are happy to negotiate a bug bounty for a severe bug. If you have found a bug that is not severe or an optimization potential, please open an issue on the repository, and (if possible) a PR with a solution, and a test to show the bug and the fix. 

The most important pieces of information we need in a bug report are:

- A description of the bug
- The platform you are on
- Concrete steps to reproduce the bug
- Expected behavior
- Actual behavior
- Any error messages or logs
- Any other relevant information
- If possible, code snippets that demonstrate area where bug is occurring

## Reviewing pull requests

All contributors who choose to review and provide feedback on pull requests have a responsibility to both the project and individual making the contribution. Reviews and feedback must be helpful, insightful, and geared towards improving the contribution as opposed to simply blocking it. If there are reasons why you feel the PR should not be merged, explain what those are. Do not expect to be able to block a PR from advancing simply because you say "no" without giving an explanation. Be open to having your mind changed. Be open to working with the contributor to make the pull request better.

Reviews that are dismissive or disrespectful of the contributor or any other reviewers are strictly counter to the Code of Conduct.

When reviewing a pull request, the primary goals are for the codebase to improve and for the person submitting the request to succeed. Even if a pull request is not merged, the submitter should come away from the experience feeling like their effort was not unappreciated. Every PR from a new contributor is an opportunity to grow the community.

## Testing

All code changes should be accompanied by tests. If you are not sure how to write tests, please make yourself familiar with the [Foundry basic testing tools](https://book.getfoundry.sh/forge/writing-tests), [advanced testing tools](https://book.getfoundry.sh/forge/advanced-testing), and some of the fuzz testing available with [Echidna](https://github.com/crytic/echidna). If you're still having trouble writing tests, please feel free to reach out to the team, we're happy to help you reason through testing strategies.

## Adding a new feature

Due to the diamond pattern setup, spinning up new features and enabling new functionality has never been easier! Whether you are modifying the current core contracts or spinning up a different contracts, all can be made to interact with the system as a whole using the diamondCut function. This is a great way to add new functionality to the system without having to redeploy the entire system. Either modify the current contract in place, deploy a new contract to cut in and replace its previous version, or spin up a new contract to add into the system as a whole. To learn more about how this operates, read more [here](https://eip2535diamonds.substack.com/i/38730553/diamond-upgrades). All new features should first go through a strenuous effort of having been tested on a local network and verified by external team members on a test network before being merged into mainnet release.

## Adding dependencies

Foundry can sometimes get finnicky. Make sure all code changes are commited on your branch or no changes have been made before you add fresh dependencies to the code in place. If you are adding a new dependency, please make that it follows the styling of package dependencies as denoted in the `remappings.txt` file. 

## Branch names

If possible, please use JIRA to create new branch names. If you do not have access to the team JIRA, do not fret! Just come up with a decently descriptive name that tracks an issue in Github!

## Code Style

In every way possible, please fill out all nat spec that is reasonable to fill out in the code and try to follow the official [solidity styling guide](https://docs.soliditylang.org/en/latest/style-guide.html) and [order of layout](https://docs.soliditylang.org/en/latest/style-guide.html#order-of-layout). If you are not sure how to fill out a nat spec, please see this [documentation](https://docs.soliditylang.org/en/latest/natspec-format.html). 

## Commits

Always make sure your commits are descriptive. In order to ensure that commits have a chronological sensibility, it may make sense to squash many commits together. In the case of potential merge conflicts, the preferred methodology to resolve said conflicts is to rebase against the longer branch and make corrections along the way. A cherry-pick may also be of use here. 

## Relevant Documentation

1. [Repository Checkout][checkoutRepo-url]
2. [Upgrade Submodules][upgradeSubmodules-url]

<!-- These are the body links -->
[checkoutRepo-url]: ./CHECKOUT-REPO.md
[upgradeSubmodules-url]: ./SUBMODULE-UPGRADE.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron