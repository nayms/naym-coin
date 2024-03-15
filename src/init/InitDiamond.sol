// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";
import "src/libs/LibInitDiamond.sol";

error DiamondAlreadyInitialized();

contract InitDiamond {
    event InitializeDiamond(address sender);

    function init(address _systemAdmin) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.diamondInitialized) {
            revert DiamondAlreadyInitialized();
        }

        LibInitDiamond.setSystemAdmin(_systemAdmin);
        LibInitDiamond.setMinter(_systemAdmin); //todo
        LibInitDiamond.setUpgradeExpiration();
    }
}
