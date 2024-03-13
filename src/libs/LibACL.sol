// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";

library LibACL {
    /// @dev The Nayms Diamond (proxy contract) owner (address) must be mutually exclusive with the system admin role.
    error OwnerCannotBeSystemAdmin();

    function _setSystemAdmin(address _newSystemAdmin) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        s.sysAdmins[_newSystemAdmin] = true;
    }

    function _setMinter(address _newMinter) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        s.minter = _newMinter;
    }
}
