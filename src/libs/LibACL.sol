// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";

library LibACL {

    error MustHaveAtLeastOneSystemAdmin();
    error CannotReassignExistingSystemAdmin(address newSystemAdmin);

    event SysAdminAdded(address sysAdminAddress);
    event SysAdminRemoved(address sysAdminAddress);
    event MinterSet(address minterAddress);

    function _setSystemAdmin(address _newSystemAdmin) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        if (s.sysAdmins[_newSystemAdmin]) {
            revert CannotReassignExistingSystemAdmin(_newSystemAdmin);
        }

        s.sysAdmins[_newSystemAdmin] = true;
        s.sysAdminsCount += 1;

        emit SysAdminAdded(_newSystemAdmin);
    }

    function _removeSystemAdmin(address _systemAdmin) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        if (s.sysAdmins[_systemAdmin]) {
            if (s.sysAdminsCount == 1) {
                revert MustHaveAtLeastOneSystemAdmin();
            }
            s.sysAdmins[_systemAdmin] = false;
            s.sysAdminsCount -= 1;

            emit SysAdminRemoved(_systemAdmin);
        }
    }

    function _setMinter(address _newMinter) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        s.minter = _newMinter;

        emit MinterSet(_newMinter);
    }
}
