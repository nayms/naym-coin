// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";

library LibInitDiamond {
    function setSystemAdmin(address _newSystemAdmin) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        s.sysAdmins[_newSystemAdmin] = true;
        s.sysAdminsCount += 1;
    }

    function setMinter(address _newMinter) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        s.minter = _newMinter;
    }

    function setUpgradeExpiration() internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        /// @dev We set the upgrade expiration to 7 days from now (604800 seconds)
        s.upgradeExpiration = 1 weeks;
    }
}
