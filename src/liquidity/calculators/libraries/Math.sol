// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library Math{

    /**
     * @dev This function calculates the square root using uniswap style logic
     */
    function sqrt(uint256 y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /**
     * @dev calculate the total digits in a number.
     * @param _number number to count digits for
     */
    function getNumberOfDigits(uint256 _number) internal pure returns (uint8 digits) {
        while (_number != 0) {
            _number /= 10;
            ++digits;
        }
        return digits;
    }

}