// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IOAppCore, ILayerZeroEndpointV2 } from "./interfaces/IOAppCore.sol";
import { OFTStorage, oftStorage } from "../oft/OFTStorage.sol";
import { LibDiamond } from "diamond-2-hardhat/libraries/LibDiamond.sol";

/**
 * @title OAppCore
 * @dev Abstract contract implementing the IOAppCore interface with basic OApp configurations.
 */
abstract contract OAppCoreFacet is IOAppCore {
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() virtual {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    /**
     * @notice Sets the peer address (OApp instance) for a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @param _peer The address of the peer to be associated with the corresponding endpoint.
     *
     * @dev Only the owner/admin of the OApp can call this function.
     * @dev Indicates that the peer is trusted to send LayerZero messages to this OApp.
     * @dev Set this to bytes32(0) to remove the peer address.
     * @dev Peer is a bytes32 to accommodate non-evm chains.
     */
    function setPeer(uint32 _eid, bytes32 _peer) public virtual onlyOwner {
        oftStorage().peers[_eid] = _peer;
        emit PeerSet(_eid, _peer);
    }

    /**
     * @notice Internal function to get the peer address associated with a specific endpoint; reverts if NOT set.
     * ie. the peer is set to bytes32(0).
     * @param _eid The endpoint ID.
     * @return peer The address of the peer associated with the specified endpoint.
     */
    function _getPeerOrRevert(uint32 _eid) internal view virtual returns (bytes32) {
        bytes32 peer = oftStorage().peers[_eid];
        if (peer == bytes32(0)) revert NoPeer(_eid);
        return peer;
    }

    /**
     * @notice Sets the delegate address for the OApp.
     * @param _delegate The address of the delegate to be set.
     *
     * @dev Only the owner/admin of the OApp can call this function.
     * @dev Provides the ability for a delegate to set configs, on behalf of the OApp, directly on the Endpoint
     * contract.
     */
    function setDelegate(address _delegate) public onlyOwner {
        oftStorage().endpoint.setDelegate(_delegate);
    }

    function peers(uint32 _eid) external view returns (bytes32 peer) {
        return oftStorage().peers[_eid];
    }

    /**
     * @notice Retrieves the LayerZero endpoint associated with the OApp.
     * @return iEndpoint The LayerZero endpoint as an interface.
     */
    function endpoint() external view returns (ILayerZeroEndpointV2 iEndpoint) {
        return oftStorage().endpoint;
    }
}
