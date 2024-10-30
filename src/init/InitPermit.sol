// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";

contract InitPermit {
    function init() external {
        uint256 initId = 2; // Using ID 2 since InitializationTest1 used ID 1

        AppStorage storage s = LibAppStorage.diamondStorage();
        require(!s.initComplete[initId], "Initialization already complete");

        // Initialize the domain separator and chain id
        s.initialChainId = block.chainid;
        s.initialDomainSeparator = _computeDomainSeparator();

        s.initComplete[initId] = true;
    }

    function _computeDomainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Naym")), // name
                keccak256(bytes("1")), // version
                block.chainid,
                address(this)
            )
        );
    }
}
