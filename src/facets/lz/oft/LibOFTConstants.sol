// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library LibOFTConstants {
    string internal constant NAME = "OFT Token";
    string internal constant SYMBOL = "OFT";
    uint8 internal constant DECIMALS = 18;

    // @notice Msg types that are used to identify the various OFT operations.
    // @dev This can be extended in child contracts for non-default oft operations
    // @dev These values are used in things like combineOptions() in OAppOptionsType3.sol.
    uint16 internal constant SEND = 1;
    uint16 internal constant SEND_AND_CALL = 2;
}
