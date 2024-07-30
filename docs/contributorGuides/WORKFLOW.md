# Development Process


## Workflow For Thrackle Employees

This document seeks to inform onboarding developers and project managers as to how the project should be developed by using a particular workflow. This workflow is to provide structure to the development process and to keep all parties informed on the progress of the project and removes the need for daily status updates since the board is kept up to date. 

1. Start by moving the topmost Ready For Development issue to the In Progress column on the applicable Project Board.

    a. If the top issue cannot be worked due to lack of clarity, move the issue to the To Do column. The Project Lead should respond as soon as possible and no later than 18 hours after the ticket is moved to To Do.

    b. Set the Assignee within the ticket as the team member working the ticket

    c. Create a branch from the ticket in Jira using the Create branch button

2. Perform development in the previously mentioned branch and push changes to the GitHub repository daily to show progress. All commit messages should describe the changes in the commit in such a way that end-users can read when the commit is eventually exposed to the customers.

    a. Get an initial implementation in place. Follow check effects pattern and/or [FREI](https://www.nascent.xyz/idea/youre-writing-require-statements-wrong).

    b. Be sure to make use of the solidity [nat spec](https://docs.soliditylang.org/en/develop/natspec-format.html) features to document your code along the way.

    c. Every line of assembly, if utilized, should be commented on and documented as to what it does.

    d. Write initial [tests](https://book.getfoundry.sh/forge/tests). Use Foundry's `forge coverage` to see how much of the codebase has been covered by tests. Cleanup the implementation based on results. Repeat this process until the implementation is complete and the tests pass.

    e. Run the [slither](https://github.com/crytic/slither) static analyzer. This tool detects known vulnerability patterns and can help to prevent holes in implementation.

    f. Depending on the change, consider writing [fuzz tests](https://book.getfoundry.sh/forge/fuzz-testing). A good fuzz test should consider all valid inputs, and include as many state transition assertions as possible (think: is this function monotonically in/decreasing, should it be always less than something else, etc.)

    g. Submit your PR for peer review.

3. Follow the steps in the [PR CHECKLIST](./PR_CHECKLIST.md)
    

4. The first peer reviewer should begin their review by updating the ticket status to PR In Progress. All peer reviewers verify:

    a. The feature meets the requirements specified.

    b. The feature has been tested to verify the functionality (run through the functional test)

    c. Unit tests are added and complete successfully

    d. The code/chain runs and maintains compatibility with previously committed features

    e. Documentation has been updated to showcase the feature (to include the README.md if necessary)

5. Once code is modified as necessary to address any peer review concerns, the last peer reviewer will merge the ticket into main (or applicable primary trunk in the repository) and update the ticket status to the Done.

6. Be sure to set up monitoring once the PR is merged and deployed via [Openzeppelin Defender](https://docs.openzeppelin.com/defender/module/monitor).