// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice storage for NAYM coin

// solhint-disable no-global-import
import "./FreeStructs.sol";

struct AppStorage {
    // Has this diamond been initialized?
    bool diamondInitialized;
    //// EIP712 domain separator ////
    uint256 initialChainId;
    bytes32 initialDomainSeparator; // note: Deprecated. Use the method DOMAIN_SEPARATOR() in NaymsTokenFacet
    //// Reentrancy guard ////
    uint256 reentrancyStatus;
    //// NAYMS ERC20 TOKEN ////
    string name;
    mapping(address account => mapping(address spender => uint256)) allowance;
    uint256 totalSupply;
    mapping(bytes32 objectId => bool isInternalToken) internalToken;
    mapping(address account => uint256) balances;
    /// Simple two phase upgrade scheme
    mapping(bytes32 upgradeId => uint256 timestamp) upgradeScheduled; // id of the upgrade => the time that the upgrade
        // is valid until.
    uint256 upgradeExpiration; // the period of time that an upgrade is valid until.
    //// ROLES, ACL ////
    mapping(address sysAdmin => bool isSysAdmin) sysAdmins;
    uint256 sysAdminsCount;
    address minter;
    // upgrade initializations
    mapping(uint256 => bool) initComplete;
    mapping(address permitCaller => uint256 nonce) nonces;
}

library LibAppStorage {
    bytes32 internal constant NAYMS_DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.nayms.storage");

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = NAYMS_DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
