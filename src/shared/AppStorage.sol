// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @notice storage for NAYM coin

// solhint-disable no-global-import
import "./FreeStructs.sol";

struct AppStorage {
    // Has this diamond been initialized?
    bool diamondInitialized;
    //// EIP712 domain separator ////
    uint256 initialChainId;
    bytes32 initialDomainSeparator;
    //// Reentrancy guard ////
    uint256 reentrancyStatus;
    //// NAYMS ERC20 TOKEN ////
    string name;
    mapping(address account => mapping(address spender => uint256)) allowance;
    uint256 totalSupply;
    mapping(bytes32 objectId => bool isInternalToken) internalToken;
    mapping(address account => uint256) balances;
    //// Object ////
    mapping(bytes32 objectId => bool isObject) existingObjects; // objectId => is an object?
    mapping(bytes32 objectId => bytes32 objectsParent) objectParent; // objectId => parentId
    mapping(bytes32 objectId => bytes32 objectsDataHash) objectDataHashes;
    mapping(bytes32 objectId => string tokenSymbol) objectTokenSymbol;
    mapping(bytes32 objectId => string tokenName) objectTokenName;
    mapping(bytes32 objectId => address tokenWrapperAddress) objectTokenWrapper;
    //// ACL Configuration////
    mapping(bytes32 roleId => mapping(bytes32 groupId => bool isRoleInGroup)) groups; //role => (group => isRoleInGroup)
    mapping(bytes32 roleId => bytes32 assignerGroupId) canAssign; //role => Group that can assign/unassign that role
    //// User Data ////
    mapping(bytes32 objectId => mapping(bytes32 contextId => bytes32 roleId)) roles; // userId => (contextId => role)
    address naymsToken; // represents the address key for this NAYMS token in AppStorage
    bytes32 naymsTokenId; // represents the bytes32 key for this NAYMS token in AppStorage
    /// Simple two phase upgrade scheme
    mapping(bytes32 upgradeId => uint256 timestamp) upgradeScheduled; // id of the upgrade => the time that the upgrade
        // is valid until.
    uint256 upgradeExpiration; // the period of time that an upgrade is valid until.
    uint256 sysAdmins; // counter for the number of sys admin accounts currently assigned
    mapping(address tokenWrapperAddress => bytes32 tokenId) objectTokenWrapperId; // reverse mapping token wrapper
        // address => object ID
    mapping(string tokenSymbol => bytes32 objectId) tokenSymbolObjectId; // reverse mapping token symbol => object ID,
        // to ensure symbol uniqueness
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
