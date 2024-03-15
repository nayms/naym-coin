// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @dev Settings keys.
 */
library LibConstants {
    /// Reserved IDs

    string internal constant SYSTEM_IDENTIFIER = "System";

    /// Reserved Ids in bytes32

    bytes32 internal constant SYSTEM_IDENTIFIER_BYTES32 =
        0x53797374656d0000000000000000000000000000000000000000000000000000; // LibHelpers._stringToBytes32(LC.SYSTEM_IDENTIFIER));
}
