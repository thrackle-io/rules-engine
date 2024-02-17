// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Action Enum
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Stores the possible actions for the protocol
 */
enum ActionTypes {
    P2P_TRANSFER,
    BUY,
    SELL,   
    MINT,
    BURN
}

// NOTE -- "NULLTYPE" is just a temporary solution to a problem centering around how
// we can iterate over these enum values. Having the NULLTYPE entry in the list makes it
// possible to break out of the for loop easily, to demonstrate the concept I'm going
// for here, but if we can figure out a better way to do this I'm all about it. 