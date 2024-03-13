// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice modifiers

import { LibHelpers } from "../libs/LibHelpers.sol";
import { LibACL } from "../libs/LibACL.sol";
import { LibString } from "solady/utils/LibString.sol";

/**
 * @title Modifiers
 * @notice Function modifiers to control access
 * @dev Function modifiers to control access
 */
contract Modifiers {
    using LibHelpers for *;
    using LibACL for *;
    using LibString for *;

    /// @notice Error message for when a sender is not authorized to perform an action with their assigned role in a
    /// given context of a group
    /// @dev In the assertPrivilege modifier, this error message returns the context and the role in the context, not
    /// the user's role in the system context.
    /// @param msgSenderId Id of the sender
    /// @param context Context in which the sender is trying to perform an action
    /// @param roleInContext Role of the sender in the context
    /// @param group Group to check the sender's role in
    error InvalidGroupPrivilege(bytes32 msgSenderId, bytes32 context, string roleInContext, string group);

    modifier assertPrivilege(bytes32 _context, string memory _group) {
        if (!msg.sender._getIdForAddress()._hasGroupPrivilege(_context, _group._stringToBytes32())) {
            /// Note: If the role returned by `_getRoleInContext` is empty (represented by bytes32(0)), we explicitly
            /// return an empty string.
            /// This ensures the user doesn't receive a string that could potentially include unwanted data (like
            /// pointer and length) without any meaningful content.
            revert InvalidGroupPrivilege(
                msg.sender._getIdForAddress(),
                _context,
                (msg.sender._getIdForAddress()._getRoleInContext(_context) == bytes32(0))
                    ? ""
                    : msg.sender._getIdForAddress()._getRoleInContext(_context).fromSmallString(),
                _group
            );
        }
        _;
    }

    modifier assertIsInGroup(bytes32 _objectId, bytes32 _contextId, bytes32 _group) {
        require(LibACL._isInGroup(_objectId, _contextId, _group), "not in group");
        _;
    }
}
