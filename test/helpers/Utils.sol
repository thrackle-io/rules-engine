// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Utils{

    /**
    * @dev calculates the difference between 2 uints without risk of overflow/underflow
    * @param x uint
    * @param y uint
    * @return diff the absolute difference between *x* and *y*
    */
    function absoluteDiff(uint x, uint y) public pure returns (uint diff){
        diff = x > y ? x - y : y - x;
    }

    /**
    * @dev gets a bytes variable and checks if it is an ascii value or not.
    * @notice this algorithm is 100% accurate in the negative case, but false
    * positives are possible. This is because if all the bytes are between 0x30
    * and 0x39, then the code will say it is an ascii number, but there will be
    * cases where they are not. For instance, the decimal number 0x3333333333333333
    * will be interpreted as an ascii even though it might not be.
    * @param _bytes the variable to decide if it is a possible ascii.
    * @return true if it is a possible ascii.
    */
    function isPossiblyAnAscii(bytes memory _bytes) public pure returns(bool){
        bool isAscii = true;
        for (uint i; i < _bytes.length; i++){
            if (uint(uint8(_bytes[i])) < 0x30 || uint(uint8(_bytes[i])) > 0x39) {
                isAscii = false;
                break;
            }
        }
        return isAscii;
    }

    /**
    * @dev decodes a byte variable trying to express a decimal number. For instance 0x297462 = 297462.
    * @param bytesDecimal the byte variable to convert to uint.
    * @return decodedUint the uint that the bytes variable was trying to imply.
    */
    function decodeFakeDecimalBytes(bytes memory bytesDecimal) public pure returns(uint256 decodedUint){
        for (uint i; i < bytesDecimal.length; i++){
            uint tens = ((uint(uint8(bytesDecimal[i])) / 16 ) * 10);
            uint units = ( uint(uint8(bytesDecimal[i])) - ((uint(uint8(bytesDecimal[i])) / 16 ) * 16));
            if (i != bytesDecimal.length - 1) decodedUint += ( tens + units) * (10 ** ((bytesDecimal.length - i - 1 )*2));
            else decodedUint += ( tens + units);
        }
    }

    /**
    * @dev decodes an ascii number to return the uint
    * @param ascii the number to convert to uint
    * @return decodedUint 
    */
    function decodeAsciiUint(bytes memory ascii) public pure returns(uint256 decodedUint){
        for (uint i; i < ascii.length; i++){
            uint units = uint(uint8(ascii[i])) - 0x30;
            if (i != ascii.length - 1) decodedUint += units * (10 ** ((ascii.length - i - 1 )));
            else decodedUint +=  units;
        }
    }

    /**
    * @dev checks if 2 bytes variables are identical
    * @param x first bytes variable to compare
    * @param y second bytes variable to compare 
    * @return true if they x and y are identical 
    */
    function areBytesEqual(bytes memory x, bytes memory y) public pure returns(bool) {
        return keccak256(x) == keccak256(y);
    }
}