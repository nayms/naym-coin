// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice storage for NAYM coin

struct AppStorage {
    //// Has this diamond been initialized? ////
    bool diamondInitialized;
    //// NAYMS ERC20 TOKEN ////
    mapping(address account => mapping(address spender => uint256)) allowance;
    uint256 totalSupply;
    mapping(address account => uint256) balances;
    //// Simple two phase upgrade scheme ////
    mapping(bytes32 upgradeId => uint256 timestamp) upgradeScheduled; // id of the upgrade => the time that the upgrade
        // is valid until.
    uint256 upgradeExpiration; // the period of time that an upgrade is valid until.
    //// ROLES, ACL ////
    mapping(address sysAdmin => bool isSysAdmin) sysAdmins;
    uint256 sysAdminsCount;
    address minter;
}

library LibAppStorage {
    bytes32 internal constant NAYM_DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.naym.storage");

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = NAYM_DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
