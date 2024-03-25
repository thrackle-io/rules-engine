# Development Process


## Workflow For Thrackle Employees

This document seeks to inform onboarding developers and project managers as to how the project should be developed by using a particular workflow. This workflow is to provide structure to the development process and to keep all parties informed on the progress of the project and removes the need for daily status updates since the board is kept up to date. 

1. Start by moving the topmost Ready For Development issue to the In Progress column on the applicable Project Board.

    a. If the top issue cannot be worked due to lack of clarity, move the issue to the To Do column. The Project Lead  should respond as soon as possible and no later than 18 hours after the ticket is moved to To Do.

    b. Set the Assignee within the ticket as the team member working the ticket

    c. Create a branch from the ticket in Jira using the Create branch button:

Open image-20230823-201618.png
image-20230823-201618.png

2. Perform development in the previously mentioned branch and push changes to the GitHub repository daily to show progress. All commit messages should describe the changes in the commit in such a way that end-users can read when the commit is eventually exposed to the customers.

3. Transitioning to Ready for Review

    a. When development is completed for the branch, create/submit a pull request in GitHub for another team member to peer review. 

    b. The developer must add the desired PR Devs to the following fields:

        i. Peer Review Developer(s) field on the Jira ticket

        ii. Reviewers field on the PR in Github

        iii. Tag them in the #software-prs channel for the ticket

    c. All tasking comes from the Software Engineering Jira Board and should be documented such that a co-worker may replicate the work. This may be as simple as a “follow the README instructions to start the application” or as complex as a new document outlining how to launch an application and access it. Each ticket should contain or reference this information in the Developer Functional Test field prior to being marked for peer review. Verbose details are preferred over sparse details.

    d. Change the ticket status from the In Progress to the Ready For Review. Notify the #software-prs channel in slack.

 4. The first peer reviewer should begin their review by updating the ticket status to PR In Progress. All peer reviewers verify:

    a. The feature meets the requirements specified.

    b. The feature has been tested to verify the functionality (run through the functional test)

    c. Unit tests are added and complete successfully

    d. The code/chain runs and maintains compatibility with previously committed features

    e. Documentation has been updated to showcase the feature (to include the README.md if necessary)

5. Once code is modified as necessary to address any peer review concerns, the last peer reviewer will merge the ticket into main (or applicable primary trunk in the repository) and update the ticket status to the Done.