// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";
import { LibHelpers } from "./LibHelpers.sol";
import { LibConstants as LC } from "./LibConstants.sol";
import {
    EntityDoesNotExist,
    ObjectCannotBeTokenized,
    ObjectTokenSymbolInvalid,
    ObjectTokenSymbolAlreadyInUse,
    ObjectTokenNameInvalid,
    InvalidObjectType,
    InvalidObjectIdForAddress,
    MinimumSellCannotBeZero
} from "../shared/CustomErrors.sol";

/// @notice Contains internal methods for core Nayms system functionality
library LibObject {
    event TokenizationEnabled(bytes32 objectId, string tokenSymbol, string tokenName);
    event TokenWrapped(bytes32 indexed entityId, address tokenWrapper);
    event TokenInfoUpdated(bytes32 indexed objectId, string symbol, string name);
    event ObjectCreated(bytes32 objectId, bytes32 parentId, bytes32 dataHash);
    event ObjectUpdated(bytes32 objectId, bytes32 parentId, bytes32 dataHash);

    function _createObject(bytes32 _objectId, bytes12 _objectType, bytes32 _parentId, bytes32 _dataHash) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        _createObject(_objectId, _objectType);
        s.objectParent[_objectId] = _parentId;
        s.objectDataHashes[_objectId] = _dataHash;

        emit ObjectCreated(_objectId, _parentId, _dataHash);
    }

    function _createObject(bytes32 _objectId, bytes12 _objectType, bytes32 _dataHash) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        _createObject(_objectId, _objectType);
        s.objectDataHashes[_objectId] = _dataHash;

        emit ObjectCreated(_objectId, 0, _dataHash);
    }

    function _createObject(bytes32 _objectId, bytes12 _objectType) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(!s.existingObjects[_objectId], "objectId is already being used by another object");
        if (_objectType == LC.OBJECT_TYPE_ADDRESS && !LibHelpers._isAddress(_objectId)) {
            revert InvalidObjectIdForAddress(_objectId);
        }
        if (_objectType != LC.OBJECT_TYPE_ADDRESS && LibHelpers._isAddress(_objectId)) {
            revert InvalidObjectType(_objectId, _objectType);
        }
        if (_objectType != LC.OBJECT_TYPE_ADDRESS && !_isObjectType(_objectId, _objectType)) {
            revert InvalidObjectType(_objectId, _objectType);
        }

        s.existingObjects[_objectId] = true;

        emit ObjectCreated(_objectId, 0, 0);
    }

    function _setDataHash(bytes32 _objectId, bytes32 _dataHash) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        require(s.existingObjects[_objectId], "setDataHash: object doesn't exist");
        s.objectDataHashes[_objectId] = _dataHash;

        emit ObjectUpdated(_objectId, 0, _dataHash);
    }

    function _getDataHash(bytes32 _objectId) internal view returns (bytes32 objectDataHash) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.objectDataHashes[_objectId];
    }

    function _getParent(bytes32 _objectId) internal view returns (bytes32) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.objectParent[_objectId];
    }

    function _getParentFromAddress(address addr) internal view returns (bytes32) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        bytes32 objectId = LibHelpers._getIdForAddress(addr);
        return s.objectParent[objectId];
    }

    function _setParent(bytes32 _objectId, bytes32 _parentId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.objectParent[_objectId] = _parentId;

        emit ObjectUpdated(_objectId, _parentId, 0);
    }

    function _isObjectTokenizable(bytes32 _objectId) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (bytes(s.objectTokenSymbol[_objectId]).length != 0);
    }

    function _tokenSymbolNotUsed(string memory _symbol) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.tokenSymbolObjectId[_symbol] == bytes32(0);
    }

    function _validateTokenNameAndSymbol(bytes32 _objectId, string memory _symbol, string memory _name) private view {
        AppStorage storage s = LibAppStorage.diamondStorage();

        if (bytes(_symbol).length == 0 || bytes(_symbol).length > 16) {
            revert ObjectTokenSymbolInvalid(_objectId, _symbol);
        }

        if (bytes(_name).length == 0 || bytes(_name).length > 64) {
            revert ObjectTokenNameInvalid(_objectId, _name);
        }

        if (s.tokenSymbolObjectId[_symbol] != bytes32(0)) {
            revert ObjectTokenSymbolAlreadyInUse(_objectId, _symbol);
        }
    }

    function _updateTokenInfo(bytes32 _objectId, string memory _symbol, string memory _name) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        _validateTokenNameAndSymbol(_objectId, _symbol, _name);

        require(_isObjectTokenizable(_objectId), "object not tokenized");

        string memory oldSymbol = s.objectTokenSymbol[_objectId];
        delete s.tokenSymbolObjectId[oldSymbol];

        s.objectTokenSymbol[_objectId] = _symbol;
        s.objectTokenName[_objectId] = _name;
        s.tokenSymbolObjectId[_symbol] = _objectId;

        emit TokenInfoUpdated(_objectId, _symbol, _name);
    }

    function _isObjectTokenWrapped(bytes32 _objectId) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (s.objectTokenWrapper[_objectId] != address(0));
    }

    function _isObject(bytes32 _id) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.existingObjects[_id];
    }

    function _getObjectType(bytes32 _objectId) internal pure returns (bytes12 objectType) {
        bytes32 shifted = _objectId >> 160;
        assembly {
            objectType := shl(160, shifted)
        }
        return objectType;
    }

    function _isObjectType(bytes32 _objectId, bytes12 _objectType) internal pure returns (bool) {
        return (_getObjectType(_objectId) == _objectType);
    }

    function _getObjectMeta(bytes32 _id)
        internal
        view
        returns (
            bytes32 parent,
            bytes32 dataHash,
            string memory tokenSymbol,
            string memory tokenName,
            address tokenWrapper
        )
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        parent = s.objectParent[_id];
        dataHash = s.objectDataHashes[_id];
        tokenSymbol = s.objectTokenSymbol[_id];
        tokenName = s.objectTokenName[_id];
        tokenWrapper = s.objectTokenWrapper[_id];
    }

    function _objectTokenSymbol(bytes32 _objectId) internal view returns (string memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.objectTokenSymbol[_objectId];
    }
}
