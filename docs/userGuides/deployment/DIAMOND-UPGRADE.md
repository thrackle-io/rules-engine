# DIAMOND UPGRADE REVERSION PLAN

In the event that a diamond upgrade is wished to be reverted, the next steps must be followed:

1. Determine if the upgraded facet has changed at all (logic, function signatures, etc.). If not, skip next step and continue to step 3.
2. If the contract has changed, then use the version control system to go back to the desired state of the contract and build the entire repo to make sure that the `out` directory has the disired abi.
3. Checkout the `deployments/diamonds.json` file and find the facet that is wished to be reverted to a previous state. Make sure that the address of the facet recorded there is not the latest one. You can do this by looking at the historical version of this file through the version control system.
4. Configure the environment variables to carry out the reversion. Specifically set the following variables in the root `.env` file:
    ```
    DEPLOYMENT_OWNER_KEY=<YOUR_DEPLOYMENT_OWNER_KEY>
    FACET_NAME_TO_REVERT=<THE_NAME_OF_THE_FACET_CONTRACT_TO_REVERT>
    DIAMOND_TO_UPGRADE=<THE_NAME_OF_THE_DIAMOND_AS_IT_IS_RECORDED_IN_THE_DEPLOYMENTS>
    REVERT_TO_FACET_ADDRESS=<THE_PREVIOUS_RECORDED_ADDRESS_OF_THE_FACET>
    RECORD_DEPLOYMENTS_FOR_ALL_CHAINS=<true/false> #true if testing in 31337 and recorded values are needed
    ```
4. Finally, run the following script:
    ```
    forge script --ffi script/clientScripts/RevertAFacetUpgrade.s.sol --broadcast --rpc-url <YOUR_RPC_URL>
    ```

Notice that the environment variables are automatically cleaned by the script. This is to prevent accidental faulty upgrades. Also, the script makes sure that the reversion was successful by checking that the old selectors are first removed, and that the new ones are in the diamond pointing to the correct facet address.


# UPGRADING A PROTOCOL FACET

Upgrading a protocol facet must be done following the next steps:

1. Set the environment variables in the `.env` file for the upgrade. Specifically set the variables:

    ```
    DEPLOYMENT_OWNER_KEY=<YOUR_DEPLOYMENT_OWNER_KEY>
    FACET_NAME_TO_REVERT=<THE_NAME_OF_THE_FACET_CONTRACT_TO_REVERT>
    RECORD_DEPLOYMENTS_FOR_ALL_CHAINS=<true/false> #true if testing in 31337 and recorded values are needed
    ```
2. Run the following script:
    ```
    forge script --ffi script/UpgradeAProtocolFacet.s.sol --broadcast --rpc-url <YOUR_RPC_URL>
    ```

    Notice that the environment variables are automatically cleaned by the script. This is to prevent accidental faulty upgrades. Also, the script makes sure that the upgrade was successful by checking that the old selectors are first removed, and that the new ones are in the diamond pointing to the new facet address.

    # UPGRADING A HANDLER FACET

Upgrading an asset-handler facet must be done following the next steps:

1. Set the environment variables in the `.env` file for the upgrade. Specifically set the variables:

    ```
    DEPLOYMENT_OWNER_KEY=<YOUR_DEPLOYMENT_OWNER_KEY>
    FACET_NAME_TO_REVERT=<THE_NAME_OF_THE_FACET_CONTRACT_TO_REVERT>
    DIAMOND_TO_UPGRADE=<THE_NAME_OF_THE_DIAMOND_AS_IT_IS_RECORDED_IN_THE_DEPLOYMENTS>
    RECORD_DEPLOYMENTS_FOR_ALL_CHAINS=<true/false> #true if testing in 31337 and recorded values are needed
    ```
2. Run the following script:
    ```
    forge script --ffi script/clientScripts/UpgradeAHandlerFacet.s.sol --broadcast --rpc-url <YOUR_RPC_URL>
    ```

    Notice that the environment variables are automatically cleaned by the script. This is to prevent accidental faulty upgrades. Also, the script makes sure that the upgrade was successful by checking that the old selectors are first removed, and that the new ones are in the diamond pointing to the new facet address.