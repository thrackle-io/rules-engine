# UPGRADING A HANDLER DIAMOND FACET

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

    ## Trouble Shooting

    If an upgrade needs to be reverted, see [Revert a Diamond Upgrade](../../common/DIAMOND-UPGRADE-REVERSION.md).