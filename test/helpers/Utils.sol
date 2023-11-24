// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Utils{

    /**
    * @dev gets a bytes variable and checks if it is an ascii value or not.
    * @notice this algorythm is 100% accurate in the negative case, but false
    * positives are possible. This is because if all the bytes are between 30
    * and 39, then the code will say it is an ascii number, but there will be
    * cases where they are not. For instance, the decimal number 3333333333333333
    * will be interpreted as an ascii even though it is not.
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

    function decodeHexDecimalBytes(bytes memory byteDecimal) public pure returns(uint256 decodedUint){
        for (uint i; i < byteDecimal.length; i++){
            //emit Log(bytes(byteDecimal[i]));
            uint tens = ((uint(uint8(byteDecimal[i])) / 16 ) * 10);
            uint units = ( uint(uint8(byteDecimal[i])) - ((uint(uint8(byteDecimal[i])) / 16 ) * 16));
            if (i != byteDecimal.length - 1) decodedUint += ( tens + units) * (10 ** ((byteDecimal.length - i - 1 )*2));
            else decodedUint += ( tens + units);
        }
    }

    function areBytesEqual(bytes memory x, bytes memory y) public pure returns(bool) {
        return keccak256(x) == keccak256(y);
    }
}