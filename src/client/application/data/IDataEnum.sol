pragma solidity ^0.8.24;

/**
 * @title Provider Type Enum
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
interface IDataEnum {
    enum ProviderType {
        ACCESS_LEVEL,
        ACCOUNT,
        TAG,
        PAUSE_RULE,
        RISK_SCORE
    }
}