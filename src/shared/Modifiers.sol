// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice modifiers

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";

/**
 * @title Modifiers
 * @notice Function modifiers to control access
 * @dev Function modifiers to control access
 */
contract Modifiers {
    /**
     * @dev The caller account is not authorized to mint.
     */
    error UnauthorizedMinter(address account);

    /**
     * @dev The caller account is not a system admin.
     */
    error NotSystemAdmin(address account);

    /**
     * @dev Throws if called by any account other than the minter.
     */
    modifier onlyMinter() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (msg.sender != s.minter) {
            revert UnauthorizedMinter(msg.sender);
        }
        _;
    }

    /**
     * @dev Throws if called by any account other than a system admin.
     */
    modifier onlySysAdmin() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (!s.sysAdmins[msg.sender]) {
            revert NotSystemAdmin(msg.sender);
        }
        _;
    }
}
