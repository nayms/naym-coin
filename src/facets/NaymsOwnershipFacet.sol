// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";
import { LibDiamond } from "lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol";
import { IERC173 } from "lib/diamond-2-hardhat/contracts/interfaces/IERC173.sol";
import { Modifiers } from "src/shared/Modifiers.sol";

contract NaymsOwnershipFacet is IERC173, Modifiers {
    error NewSystemAdminCannotAlsoBeTheOwner();

    function transferOwnership(address _newOwner) external override onlySysAdmin {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.sysAdmins[_newOwner] == true) {
            revert NewSystemAdminCannotAlsoBeTheOwner();
        }

        LibDiamond.setContractOwner(_newOwner);
    }

    function owner() external view override returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }
}
