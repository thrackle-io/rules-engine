# Forte Rules Engine PR Checklist

1. Make sure unit tests pass
   1. run “forge test —ffi”
2. Make sure code deploys locally
   1. start the local chain
      1. “anvil”
   2. deploy code locally
      1. “sh script/clientScripts/deploy/DeployProtocol.sh”
      2. “sh script/clientScripts/deploy/DeployExampleApplication.sh”   
3. Code issues to look for
   1. Logic flaws
      1. especially those that could lead to vulnerabilities
   2. Naming standards
      1. variables, functions, and source folders
         1. camelCase with first letter lowercase
      2. contracts
         1. CamelCase with first letter uppercase
   3. Proper NatSpec comments
      1. See ticket #121 for explanation
   4. Coherent line comments
   5. Gas inefficiencies
4. Standard formatting(this should be run by the dev responsible for the branch prior to submitting PR):
   1. This is done by running prettier formatter
      1. npm install
      2. npx prettier --write .
5. Update the documentation. This is done in 2 simple steps:

   1. Make sure `foundry.lock` is set to an appropriate version, then update Foundry.

      `script/foundryScripts/foundry-version-check.sh`

   2. Generate the docs:

      `forge doc`
