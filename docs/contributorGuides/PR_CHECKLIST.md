# Pull Request Checklist


This document provides steps all developers must follow prior to submission of a Pull Request(PR) for the Rules Protocol. By strictly following these steps, it streamlines the PR process, improves code quality, and reduces changes of bug introduction.


## Code Quality
1. Format the code with "prettier"
2. Ensure that all touched functions include [nat spec](https://docs.soliditylang.org/en/develop/natspec-format.html) comments with the following sections:
	1. @dev
	2. @param
	3. @return
3. Make sure all input parameters are properly validated
4. Verify that all contracts in the ticket branch compile. 

## Testing

1. Define any new invariants the change may create
2. Modify any existing invariants the change may modify
3. It must contain tests that cover:
	1. positive results
	2. negative results
	3. fuzzing
      	1. boundary testing(edge cases) to ensure variables can handle all possible thresholds
	4. invariants 
4. Verify the change does not introduce Slither or Necessist issues
 
## Security Related

1. Make sure external function calls are properly gated. This is particularly true for functions that modify state.
2. Ensure that only the proper roles may modify the data

## Readability

1. Choose good names.
   1. Is the name straightforward to understand? Do you feel the need to jump back to the definition and remind yourself what it was whenever you see it?
   2. Is the name unambiguous in the context where it is used?
2. Avoid abbreviations.
   1. For example, don't use "tkn" instead of token.
3. Avoid code duplication. But not fanatically. Minimal amounts of duplication are acceptable if it aids readability. It is always best to consider how a dev unfamiliar with the project would view it.
4. Do not leave dead or commented-out code behind. You can still see old code in history. If you really have a good reason to do it, always leave a comment explaining what it is and why it is there. Log statements are a good example of commented-out code that may need to remain.
5. Mark hacks as such. If you have to leave behind a temporary workaround, make sure to include a comment that explains why and in what circumstances it can be removed. Preferably link to an issue you reported upstream. Add a `TODO` in the comment for how to address it in the future.
6. Avoid obvious comments.
7. Do include comments when the reader may need extra context to understand the code.
8.  More important comments should utilize /// comments
9.  Every line of assembly, if utilized, should be commented on and documented as to what it does.

## Issue Related

1. Do you fully understand what the PR does and why?
2. Are you confident that the code works and does not break unrelated functionality?
3. Does the Jira issue give enough information and context to adequately address the issue?
4. Is this a reasonable way to achieve the goal stated in the issue?
5. Is the code simple? Does the PR achieve its objective at the cost of significant complexity that may be a source of future bugs?
6. Is the code efficient? Does the PR introduce any major performance bottlenecks?
7. Does the PR introduce any breaking changes beyond what was agreed in the issue?

## Commit Related

1. Fetch the latest version of main branch and check for conflicts.
	1. If so, resolve conflicts
2. Is commit history simple and understandable?
3. Each commit should be a self-contained, logical step leading the goal of the PR, without going back and forth. In particular, review fixups should be squashed into the commits they fix.
4. Do not include any merge commits in your branch. Please use rebase to keep up to date with the base branch.

## JIRA Related

1. Change Ticket status to Ready For Review
2. Post PR notification in #engineering-prs in Slack and tag relevant reviewer(s)
3. All tasking comes from the Software Engineering Jira Board and should be documented such that a co-worker may replicate the work. This may be as simple as a “follow the README instructions to start the application” or as complex as a new document outlining how to launch an application and access it. Each ticket should contain or reference this information in the Developer Functional Test field prior to being marked for peer review. Verbose details are preferred over sparse details.

## Build and Test

1. Verify that all contracts compile with no warnings.
2. Verify that all tests pass.
3. Verify that deployment scripts complete successfully
4. Verify the DemoSetup.sh script completes successfully
5. Point your local DOOM docker compose setup to your Tron branch, spin up DOOM and verify that the contents of the branch do not break basic functionality 
	1. If functionality is broken or the change is known to break DOOM, create a ticket for the change, notify Johnathon Bailey, and create a message in #engineering-breaking-changes within Slack.

## Documentation

1. Update any related documentation taking special care to keep documentation references in sync with function signatures and parameters.
2. If inner workings of rules were changed, change the rule specific documentation and any script documentation as well.
	
## PR Creation Steps
1. Push code changes to GitHub
2. Create PR via JIRA. 
   1. Add yourself as the assignee in GitHub.
3. Change the status of the ticket to `READY FOR REVIEW`
4. Create a message in #engineering-prs that contains a link to the Jira issue and tag desired reviewer(s)
5. If the change creates known issues for DOOM or any other projects, create a message in #engineering-breaking-changes within Slack
   1. If the change breaks DOOM specifically, create a ticket for the change, notify Johnathon Bailey and Robert Kotz, and create a message in #engineering-breaking-changes within Slack.

## Protocol Deployment Scripts

DeployAllModules.s.sol (Pt1, Pt2, Pt3, and Pt4)

Application Deployment Scripts

ApplicationDeployAll.s.sol (all in one script)

DemoSetup.sh

