# Demo

## Purpose

This is a basic run down of what is needed to demo Tron in a local anvil

## Steps

1. Run setup script.
   1. This will deploy the protocol, retrieve the addresses, and deploy the following application contracts:
      1. AppManager
      2. FrankensteinCoin with a configured handler
      3. Mint 1_000_000_000 Frankensteins to Admin
      4. Create Account Min/Max Token Balance rule       
      3. Apply Account Min/Max Token Balance rule to P2P transfer
2. Live DEMO
   1. Explain the architecture of the Protocol and recent changes including:
      1. Action based rules
   2. Display the diagrams
   3. Run script commands that:
      1. Demonstrate Account Min/Max Token Balance rule violation
      2. Mint Frankensteins to User1 to show it does not violate the rule
      3. Apply Account Min/Max Token Balance rule to mint
      4. Mint again showing Account Min/Max Token Balance violation