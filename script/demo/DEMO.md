# Demo

## Purpose

This is a basic run down of what is needed to demo in a local anvil. This version will demonstrate the Account Min/Max Token Balance rule with a generic ERC20 token.

## Steps

1. Run setup script.
   1. Run script command from the root folder
      ``` sh script/demo/DemoSetup.sh ```
      1. This will deploy the protocol, retrieve the addresses, and deploy the following application contracts:
         1. AppManager
         2. FrankensteinCoin with a configured handler
         3. Mint 1_000_000_000 Frankensteins to Admin
         4. Create Account Min/Max Token Balance rule       
         5. Apply Account Min/Max Token Balance rule to P2P transfer
   2. Copy the output(the export commands), paste them to a terminal, and run them.
2. Live DEMO
   1. Explain the architecture of the Protocol and recent changes including:
      1. Action based rules
   2. Display the diagrams
      1. Protocol Diagram.png(very high level)
      2. ActionBasedRules.png
   3. Run script commands in Demo.txt one by one 
   