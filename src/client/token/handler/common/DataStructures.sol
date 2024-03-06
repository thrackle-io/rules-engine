// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


/**
 * @title Rule struct
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev data structure for storing rule state in handlers
 */
struct Rule {
    uint32 ruleId;
    bool active;
}

/**
 * @title Handly Type Enum
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores the Handler Types for the protocol 
 */
enum HandlerTypes {
    ERC20HANDLER,
    ERC721HANDLER
}