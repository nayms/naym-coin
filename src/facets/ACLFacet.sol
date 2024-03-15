// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { LibACL } from "../libs/LibACL.sol";
import { Modifiers } from "../shared/Modifiers.sol";

/**
 * @title Access Control List
 * @notice Use it to authorize various actions on the contracts
 * @dev Use it to (un)assign or check role membership
 */
contract ACLFacet is Modifiers {
    function setSystemAdmin(address _newSystemAdmin) external onlySysAdmin {
        LibACL._setSystemAdmin(_newSystemAdmin);
    }

    function setMinter(address _newMinter) external onlySysAdmin {
        LibACL._setMinter(_newMinter);
    }

    function removeSysAdmin(address _removeSystemAdmin) external onlySysAdmin {
        LibACL._removeSystemAdmin(_removeSystemAdmin);
    }
}
