# UPGRADING A PROTOCOL FACET

To upgrade a protocol facet, follow these steps:

1. Set the environment variables in the `.env` file for the upgrade. Specifically set these variables:

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

  ## Trouble Shooting

    If an upgrade needs to be reverted, see [Revert a Diamond Upgrade](../common/DIAMOND-UPGRADE-REVERSION.md).